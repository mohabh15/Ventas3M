import 'package:flutter/material.dart';
import '../../core/widgets/gradient_app_bar.dart';
import '../../core/theme/colors.dart';

class BankingScreen extends StatefulWidget {
  const BankingScreen({super.key});

  @override
  State<BankingScreen> createState() => _BankingScreenState();
}

class _BankingScreenState extends State<BankingScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = isDark ? AppDarkColors : AppColors;

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

  Widget _buildBalanceTotalCard() {
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
              '\$45,320.50',
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
              Icon(Icons.arrow_upward, size: 14, color: Colors.greenAccent),
              const SizedBox(width: 4),
              Text(
                '+12.5% este mes',
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              icon: Icons.arrow_downward,
              iconColor: Colors.green,
              title: 'Por Cobrar',
              amount: '\$12,850',
              subtitle: '15 pendientes',
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
              iconColor: Colors.orange,
              title: 'Por Pagar',
              amount: '\$8,240',
              subtitle: '8 pendientes',
              gradient: LinearGradient(
                colors: [Color(0xFFE65100), Color(0xFFFF9800)],
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
              amount: '\$5,680',
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
                onPressed: () {},
                child: Text(
                  'Ver todo',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).primaryColor,
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
              children: [
                _buildTeamMemberCard(
                  name: 'María González',
                  role: 'Administrador',
                  amount: '\$15,200',
                  change: '+2.5%',
                  avatarColor: Colors.blue,
                ),
                _buildTeamMemberCard(
                  name: 'Carlos Ruiz',
                  role: 'Vendedor',
                  amount: '\$12,850',
                  change: '+1.8%',
                  avatarColor: Colors.green,
                ),
                _buildTeamMemberCard(
                  name: 'Ana López',
                  role: 'Contadora',
                  amount: '\$17,270',
                  change: '+3.7%',
                  avatarColor: Colors.purple,
                ),
              ],
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
                onPressed: () {},
                child: Text(
                  'Ver todo',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildExpenseItem(
            icon: Icons.inventory,
            iconColor: Colors.orange,
            title: 'Inventario',
            subtitle: 'Compra de productos',
            amount: '-\$2,340',
            date: 'Ayer',
          ),
          _buildExpenseItem(
            icon: Icons.electrical_services,
            iconColor: Colors.purple,
            title: 'Servicios',
            subtitle: 'Electricidad y agua',
            amount: '-\$890',
            date: '3 Oct',
          ),
          _buildExpenseItem(
            icon: Icons.local_shipping,
            iconColor: Colors.blue,
            title: 'Transporte',
            subtitle: 'Gasolina y mantenimiento',
            amount: '-\$450',
            date: '1 Oct',
          ),
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
          _buildPendingItem(
            client: 'Cliente ABC Corp',
            invoice: 'Factura #001234',
            amount: '\$3,250',
            dueDate: 'Vence: 15 Oct',
            status: 'pending',
          ),
          _buildPendingItem(
            client: 'Tienda XYZ',
            invoice: 'Factura #001235',
            amount: '\$1,890',
            dueDate: 'Vencido: 2 días',
            status: 'overdue',
          ),
          _buildPendingItem(
            client: 'Empresa DEF',
            invoice: 'Factura #001236',
            amount: '\$7,710',
            dueDate: 'Vence: 22 Oct',
            status: 'pending',
          ),
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