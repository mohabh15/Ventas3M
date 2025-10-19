import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/gradient_app_bar.dart';
import '../../router/app_router.dart';
import '../../providers/expense_provider.dart';
import '../../providers/team_balance_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/sales_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/debt_provider.dart';
import '../../models/debt.dart';
import '../../services/debt_service.dart';

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
   late AuthProvider _authProvider;
   late DebtService _debtService;
   late DebtProvider _debtProvider;
  bool _isBalanceVisible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _expenseProvider = Provider.of<ExpenseProvider>(context);
    _teamBalanceProvider = Provider.of<TeamBalanceProvider>(context);
    _settingsProvider = Provider.of<SettingsProvider>(context);
    _salesProvider = Provider.of<SalesProvider>(context);
    _authProvider = Provider.of<AuthProvider>(context);
    _debtService = DebtService();
    _debtProvider = Provider.of<DebtProvider>(context);

    // Cargar datos iniciales después de que el frame esté construido
     WidgetsBinding.instance.addPostFrameCallback((_) {
       if (mounted && _settingsProvider.activeProjectId != null) {
         _salesProvider.loadSales(_settingsProvider.activeProjectId!);
         _debtProvider.loadDebts(_settingsProvider.activeProjectId!);
       }
     });
   }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Theme disponible a través de context cuando sea necesario

    // Calcular la altura de la barra de navegación inferior
    //final bottomPadding = MediaQuery.of(context).padding.bottom;

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

                // Tarjetas de resumen financiero con listener para deudas
                Consumer<DebtProvider>(
                  builder: (context, debtProvider, child) {
                    return _buildFinancialSummaryCards();
                  },
                ),

                const SizedBox(height: 32),

                // Balance del Equipo
                _buildTeamBalanceSection(),

                const SizedBox(height: 32),

                // Gastos Recientes
                _buildRecentExpensesSection(),

                const SizedBox(height: 32),

                // Últimas Deudas
                _buildRecentDebtsSection(),
              ],
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

  // Método para obtener deudas recientes formateadas
  List<Widget> _buildRecentDebtsFromData() {
    final currentUserEmail = _authProvider.currentUser?.email ?? '';
    final activeProjectId = _settingsProvider.activeProjectId ?? '';

    return [
      StreamBuilder<List<Debt>>(
        stream: _debtService.getRecentDebts(limit: 3),
        builder: (context, snapshot) {
          // Si no hay usuario o proyecto activo, mostrar mensaje
          if (currentUserEmail.isEmpty || activeProjectId.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Text(
                'No hay usuario activo',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).textTheme.bodySmall?.color
                      : Colors.black54,
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting && snapshot.data == null) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Cargando deudas...',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).textTheme.bodySmall?.color
                      : Colors.black54,
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Error al cargar deudas',
                style: TextStyle(
                  color: Colors.red,
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
          }

          final debts = snapshot.data ?? [];

          if (debts.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Text(
                'No hay deudas registradas',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).textTheme.bodySmall?.color
                      : Colors.black54,
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
          }

          return Column(
            children: debts.map((debt) => _buildDebtItem(debt)).toList(),
          );
        },
      ),
    ];
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
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isBalanceVisible = !_isBalanceVisible;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _isBalanceVisible ? Icons.visibility : Icons.visibility_off,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            child: Text(
              _isBalanceVisible ? '\$${balanceTotal.toStringAsFixed(2)}' : '••••••',
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

    // Calcular total de deudas pendientes reales usando DebtProvider
    final totalPending = _debtProvider.totalPendingAmount;
    final pendingCount = _debtProvider.pendingDebts.length;

    // Calcular total de todas las deudas del proyecto
    //final currentUserEmail = _authProvider.currentUser?.email ?? '';
    //final activeProjectId = _settingsProvider.activeProjectId ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              icon: Icons.arrow_downward,
              iconColor: Colors.green,
              title: 'Deuda Total',
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
                    context.push(AppRouter.teamBalance);
                  },
                  child: Text(
                    '>',
                    style: TextStyle(
                      fontSize: 24,
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
                    context.push(AppRouter.teamBalance);
                  },
                  child: Text(
                    '>',
                    style: TextStyle(
                      fontSize: 24,
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
                  context.push(AppRouter.teamBalance);
                },
                child: Text(
                  '>',
                  style: TextStyle(
                    fontSize: 24,
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
                // Asignar colores basados en el índice
                final colors = [Colors.blue, Colors.green, Colors.purple, Colors.orange, Colors.teal];
                final colorIndex = teamBalances.indexOf(member) % colors.length;

                return _buildTeamMemberCard(
                  name: member.name,
                  role: member.role,
                  amount: '\$${member.balance.toStringAsFixed(0)}',
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
                  context.push(AppRouter.expenses);
                },
                child: Text(
                  '>',
                  style: TextStyle(
                    fontSize: 24,
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

  Widget _buildRecentDebtsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Últimas Deudas',
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
                  context.push('/debt-management');
                },
                child: Text(
                  '>',
                  style: TextStyle(
                    fontSize: 24,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Color(0xFF2196F3) // Azul primario en modo oscuro
                        : Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._buildRecentDebtsFromData(),
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

  Widget _buildDebtItem(Debt debt) {
    // Obtener usuario actual
    final currentUserEmail = _authProvider.currentUser?.email ?? '';

    // Determinar si somos el deudor o acreedor
    final isWeDebtor = debt.debtor == currentUserEmail;
    final isWeCreditor = debt.creditor == currentUserEmail;

    // Obtener ícono basado en el estado de la deuda
    IconData getIconForStatus(DebtStatus status) {
      switch (status) {
        case DebtStatus.pending:
          return Icons.pending;
        case DebtStatus.paid:
          return Icons.check_circle;
        case DebtStatus.overdue:
          return Icons.warning;
        case DebtStatus.cancelled:
          return Icons.cancel;
      }
    }

    // Obtener color basado en el estado de la deuda
    Color getColorForStatus(DebtStatus status) {
      switch (status) {
        case DebtStatus.pending:
          return Colors.blue;
        case DebtStatus.paid:
          return Colors.green;
        case DebtStatus.overdue:
          return Colors.red;
        case DebtStatus.cancelled:
          return Colors.grey;
      }
    }

    // Calcular monto con signo según nuestra posición
    double displayAmount = debt.amount;
    if (isWeDebtor) {
      displayAmount = -debt.amount; // Negativo si debemos pagar
    }

    // Color del monto basado en el tipo de deuda
    Color amountColor;
    if (debt.isToPay) {
      amountColor = Colors.red; // Rojo si es deuda a pagar
    } else if (debt.isToCollect) {
      amountColor = Colors.green; // Verde si es deuda a cobrar
    } else {
      amountColor = Colors.black87; // Color por defecto
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
              color: getColorForStatus(debt.status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(getIconForStatus(debt.status), color: getColorForStatus(debt.status), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  debt.description,
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
                  isWeDebtor
                    ? '${debt.debtor} → ${debt.creditor} (debemos)'
                    : isWeCreditor
                      ? '${debt.debtor} → ${debt.creditor} (nos deben)'
                      : '${debt.debtor} → ${debt.creditor}',
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
                '${displayAmount >= 0 ? '+' : ''}\$${displayAmount.abs().toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                ),
              ),
              Text(
                getRelativeDate(debt.date),
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


}