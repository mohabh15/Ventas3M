import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/gradient_app_bar.dart';
import '../../router/app_router.dart';
import '../../core/theme/colors.dart';
import '../../providers/expense_provider.dart';
import '../../providers/team_balance_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/sales_provider.dart';

class BankingScreen extends StatefulWidget {
  const BankingScreen({super.key});

  @override
  State<BankingScreen> createState() => _BankingScreenState();
}

class _BankingScreenState extends State<BankingScreen> {
  late ExpenseProvider _expenseProvider;
  late TeamBalanceProvider _teamBalanceProvider;
  late SettingsProvider _settingsProvider;
  late SalesProvider _salesProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _expenseProvider = Provider.of<ExpenseProvider>(context);
    _teamBalanceProvider = Provider.of<TeamBalanceProvider>(context);
    _settingsProvider = Provider.of<SettingsProvider>(context);
    _salesProvider = Provider.of<SalesProvider>(context);

    // Cargar datos iniciales después de que el frame esté construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _settingsProvider.activeProjectId != null) {
        _salesProvider.loadSales(_settingsProvider.activeProjectId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Theme disponible a través de context cuando sea necesario

    // Calcular la altura de la barra de navegación inferior
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: GradientAppBar(
        title: 'Banca',
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance Total
                _buildBalanceTotalCard(),

                const SizedBox(height: 24),

                // Tarjetas de resumen financiero
                _buildFinancialSummaryCards(),

                const SizedBox(height: 32),

                // Balance del Equipo
                _buildTeamBalanceSection(),

                const SizedBox(height: 32),

                // Gastos Recientes
                _buildRecentExpensesSection(),

                const SizedBox(height: 32),

                // Pendientes
                _buildPendingSection(),
              ],
            ),
          ),

          // Botón flotante posicionado relativo a la navbar
          Positioned(
            right: 16.0,
            bottom: bottomPadding + 16.0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0D47A1), // Azul oscuro
                    Color(0xFF1976D2), // Azul primario
                    Color(0xFF42A5F5), // Azul claro
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: FloatingActionButton(
                heroTag: 'banking_fab',
                onPressed: () {
                  // TODO: Implementar navegación a pantalla de agregar transacción
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Método para obtener gastos recientes formateados
  List<Widget> _buildRecentExpensesFromData() {
    // Mostrar indicador de carga si está cargando
    if (_expenseProvider.isLoading) {
      return [
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Cargando gastos...',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).textTheme.bodySmall?.color
                      : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ];
    }

    final recentExpenses = _expenseProvider.expenses.take(3).toList();

    if (recentExpenses.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(20),
          child: Text(
            'No hay gastos registrados',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).textTheme.bodySmall?.color
                  : Colors.black54,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ];
    }

    return recentExpenses.map((expense) {
      // Mapear categorías a íconos apropiados
      IconData getIconForCategory(String category) {
        switch (category.toLowerCase()) {
          case 'inventario':
          case 'productos':
            return Icons.inventory;
          case 'servicios':
          case 'electricidad':
          case 'agua':
          case 'gas':
            return Icons.electrical_services;
          case 'transporte':
          case 'gasolina':
          case 'mantenimiento':
            return Icons.local_shipping;
          case 'oficina':
          case 'materiales':
            return Icons.business;
          case 'marketing':
          case 'publicidad':
            return Icons.campaign;
          default:
            return Icons.receipt;
        }
      }

      // Mapear categorías a colores apropiados
      Color getColorForCategory(String category) {
        switch (category.toLowerCase()) {
          case 'inventario':
          case 'productos':
            return Colors.orange;
          case 'servicios':
          case 'electricidad':
          case 'agua':
          case 'gas':
            return Colors.purple;
          case 'transporte':
          case 'gasolina':
          case 'mantenimiento':
            return Colors.blue;
          case 'oficina':
          case 'materiales':
            return Colors.green;
          case 'marketing':
          case 'publicidad':
            return Colors.red;
          default:
            return Colors.grey;
        }
      }

      // Formatear fecha relativa
      String getRelativeDate(DateTime date) {
        final now = DateTime.now();
        final difference = now.difference(date).inDays;

        if (difference == 0) return 'Hoy';
        if (difference == 1) return 'Ayer';
        if (difference < 7) return 'Hace $difference días';
        if (difference < 30) return '${(difference / 7).floor()} sem';
        return '${(difference / 30).floor()} mes';
      }

      return _buildExpenseItem(
        icon: getIconForCategory(expense.category),
        iconColor: getColorForCategory(expense.category),
        title: expense.category,
        subtitle: expense.description,
        amount: '-${expense.formattedAmount}',
        date: getRelativeDate(expense.date),
      );
    }).toList();
  }

  Widget _buildBalanceTotalCard() {
    // Calcular ingresos totales desde ventas completadas
    final totalSales = _salesProvider.sales
        .where((sale) => sale.isCompleted)
        .fold<double>(0.0, (sum, sale) => sum + sale.totalAmount);

    // Calcular gastos totales desde expenses
    final totalExpenses = _expenseProvider.totalExpenses;

    // Calcular balance total (ingresos - gastos)
    final balanceTotal = totalSales - totalExpenses;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0D47A1), // Azul oscuro
            Color(0xFF1976D2), // Azul primario
            Color(0xFF42A5F5), // Azul claro
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Balance Total',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.visibility_off, size: 14, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            child: Text(
              '\$${balanceTotal.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                balanceTotal >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                size: 14,
                color: balanceTotal >= 0 ? Colors.greenAccent : Colors.redAccent,
              ),
              const SizedBox(width: 4),
              Text(
                balanceTotal >= 0 ? '+${((balanceTotal / (totalExpenses == 0 ? 1 : totalExpenses)) * 100).toStringAsFixed(1)}% este mes' : '${((balanceTotal / (totalExpenses == 0 ? 1 : totalExpenses)) * 100).toStringAsFixed(1)}% este mes',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummaryCards() {
    // Calcular gastos totales reales usando el provider
    final totalExpenses = _expenseProvider.totalExpenses;
    final formattedExpenses = '\$${totalExpenses.toStringAsFixed(0)}';

    // Calcular ventas con deuda (por cobrar)
    final pendingSales = _salesProvider.sales.where((sale) => sale.hasDebt && !sale.isCompleted).toList();
    final totalPending = pendingSales.fold<double>(0.0, (sum, sale) => sum + sale.totalAmount);
    final pendingCount = pendingSales.length;


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              icon: Icons.arrow_downward,
              iconColor: Colors.green,
              title: 'Por Cobrar',
              amount: '\$${totalPending.toStringAsFixed(0)}',
              subtitle: '$pendingCount pendientes',
              gradient: LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              icon: Icons.arrow_upward,
              iconColor: AppColors.primary,
              title: 'Por Pagar',
              amount: '\$${totalExpenses.toStringAsFixed(0)}',
              subtitle: 'Gastos registrados',
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              icon: Icons.receipt,
              iconColor: Colors.purple,
              title: 'Gastos',
              amount: formattedExpenses,
              subtitle: 'Este mes',
              gradient: LinearGradient(
                colors: [Color(0xFF4A148C), Color(0xFF9C27B0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String amount,
    required String subtitle,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 9,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTeamBalanceSection() {
    // Mostrar indicador de carga si está cargando
    if (_teamBalanceProvider.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Balance del Equipo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).textTheme.titleLarge?.color
                        : Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRouter.teamBalance);
                  },
                  child: Text(
                    'Ver todo',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Color(0xFF2196F3) // Azul primario en modo oscuro
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Cargando balances...',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).textTheme.bodySmall?.color
                          : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final teamBalances = _teamBalanceProvider.teamBalances;

    if (teamBalances.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Balance del Equipo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).textTheme.titleLarge?.color
                        : Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRouter.teamBalance);
                  },
                  child: Text(
                    'Ver todo',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Color(0xFF2196F3) // Azul primario en modo oscuro
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              child: Text(
                'No hay miembros del equipo registrados',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).textTheme.bodySmall?.color
                      : Colors.black54,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Balance del Equipo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).textTheme.titleLarge?.color
                      : Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRouter.teamBalance);
                },
                child: Text(
                  'Ver todo',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Color(0xFF2196F3) // Azul primario en modo oscuro
                        : Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: teamBalances.take(3).map((member) {
                // Calcular cambio porcentual (simulado por ahora)
                final change = '+2.5%'; // TODO: Calcular cambio real basado en datos históricos

                // Asignar colores basados en el índice
                final colors = [Colors.blue, Colors.green, Colors.purple, Colors.orange, Colors.teal];
                final colorIndex = teamBalances.indexOf(member) % colors.length;

                return _buildTeamMemberCard(
                  name: member.name,
                  role: member.role,
                  amount: '\$${member.balance.toStringAsFixed(0)}',
                  change: change,
                  avatarColor: colors[colorIndex],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMemberCard({
    required String name,
    required String role,
    required String amount,
    required String change,
    required Color avatarColor,
  }) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: avatarColor,
            child: Text(name[0], style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).textTheme.titleMedium?.color
                        : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  role,
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).textTheme.bodySmall?.color
                        : Colors.black54,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).textTheme.titleLarge?.color
                      : Colors.black87,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.arrow_upward, size: 10, color: Colors.green),
                  Text(
                    change,
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentExpensesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gastos Recientes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).textTheme.titleLarge?.color
                      : Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRouter.expenses);
                },
                child: Text(
                  'Ver todo',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Color(0xFF2196F3) // Azul primario en modo oscuro
                        : Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._buildRecentExpensesFromData(),
        ],
      ),
    );
  }

  Widget _buildExpenseItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String amount,
    required String date,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).textTheme.titleMedium?.color
                        : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).textTheme.bodySmall?.color
                        : Colors.black54,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).textTheme.bodySmall?.color
                      : Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPendingSection() {
    // Obtener ventas pendientes reales
    final pendingSales = _salesProvider.sales.where((sale) => sale.hasDebt && !sale.isCompleted).toList();

    if (pendingSales.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pendientes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).textTheme.titleLarge?.color
                    : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              child: Text(
                'No hay ventas pendientes',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).textTheme.bodySmall?.color
                      : Colors.black54,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pendientes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).textTheme.titleLarge?.color
                  : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...pendingSales.take(3).map((sale) {
            // Calcular días de vencimiento (simulado)
            final daysUntilDue = 7; // TODO: Calcular basado en fecha real de vencimiento
            final isOverdue = daysUntilDue < 0;

            return _buildPendingItem(
              client: sale.customerName,
              invoice: 'Factura #${sale.id.substring(0, 8).toUpperCase()}',
              amount: '\$${sale.totalAmount.toStringAsFixed(0)}',
              dueDate: isOverdue ? 'Vencido: ${daysUntilDue.abs()} días' : 'Vence: $daysUntilDue días',
              status: isOverdue ? 'overdue' : 'pending',
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPendingItem({
    required String client,
    required String invoice,
    required String amount,
    required String dueDate,
    required String status,
  }) {
    final isOverdue = status == 'overdue';
    final isPaid = status == 'paid';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: isPaid ? Colors.green : (isOverdue ? Colors.red : Colors.blue),
                child: Icon(
                  isPaid ? Icons.check : Icons.person,
                  color: Colors.white,
                  size: 14,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(context).textTheme.titleMedium?.color
                            : Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      invoice,
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(context).textTheme.bodySmall?.color
                            : Colors.black54,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).textTheme.titleLarge?.color
                          : Colors.black87,
                    ),
                  ),
                  Text(
                    dueDate,
                    style: TextStyle(
                      fontSize: 11,
                      color: isOverdue ? Colors.red : (Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).textTheme.bodySmall?.color
                          : Colors.black54),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Flexible(
                flex: 1,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.call, size: 14),
                  label: Text('Recordar', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOverdue ? Colors.orange : Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                flex: 1,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(isPaid ? Icons.visibility : Icons.check, size: 14),
                  label: Text(isPaid ? 'Ver' : 'Cobrar', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isPaid ? Colors.green : Theme.of(context).primaryColor,
                    side: BorderSide(color: isPaid ? Colors.green : Theme.of(context).primaryColor),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}