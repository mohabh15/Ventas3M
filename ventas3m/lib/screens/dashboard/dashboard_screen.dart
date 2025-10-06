import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/gradient_app_bar.dart';
import '../../models/sale.dart';
import '../settings/settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Datos de ejemplo para ventas recientes
  final List<Sale> recentSales = [
    Sale(
      id: 'VT-001234',
      product: 'Producto A',
      quantity: 2,
      unitPrice: 122.50,
      total: 245.00,
      customer: 'Ana García',
      date: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Sale(
      id: 'VT-001233',
      product: 'Producto B',
      quantity: 1,
      unitPrice: 89.50,
      total: 89.50,
      customer: 'Carlos Méndez',
      date: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    Sale(
      id: 'VT-001232',
      product: 'Producto C',
      quantity: 3,
      unitPrice: 52.25,
      total: 156.75,
      customer: 'María López',
      date: DateTime.now().subtract(const Duration(hours: 8)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: 'Dashboard',
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tarjetas superiores de métricas
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Ventas Hoy',
                      value: '\$24,580',
                      subtitle: '+12% vs ayer',
                      backgroundColor: AppColors.secondary,
                      icon: Icons.trending_up,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Productos',
                      value: '1,247',
                      subtitle: 'En inventario',
                      backgroundColor: AppColors.tertiary,
                      icon: Icons.inventory,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Tarjetas inferiores de métricas
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Clientes',
                      value: '348',
                      subtitle: '',
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      icon: Icons.people,
                      isDark: Theme.of(context).brightness == Brightness.dark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Promedio',
                      value: '\$187',
                      subtitle: '',
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      icon: Icons.attach_money,
                      isDark: Theme.of(context).brightness == Brightness.dark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Sección de Acciones Rápidas
              Text(
                'Acciones Rápidas',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      title: 'Nueva\nVenta',
                      icon: Icons.add,
                      backgroundColor: Theme.of(context).brightness == Brightness.dark
                          ? AppDarkColors.primary
                          : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      title: 'Productos',
                      icon: Icons.inventory_2_outlined,
                      backgroundColor: Theme.of(context).brightness == Brightness.dark
                          ? AppDarkColors.products
                          : AppColors.products,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      title: 'Reportes',
                      icon: Icons.analytics,
                      backgroundColor: Theme.of(context).brightness == Brightness.dark
                          ? AppDarkColors.secondary
                          : AppColors.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Sección de Ventas Recientes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ventas Recientes',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Ver todas',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...recentSales.map((sale) => _buildRecentSaleCard(sale)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required Color backgroundColor,
    required IconData icon,
    bool isDark = false,
  }) {
    return AppCard(
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
              Icon(
                icon,
                color: isDark ? Colors.white70 : Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : Theme.of(context).colorScheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: isDark ? Colors.white70 : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Color backgroundColor,
  }) {
    return AppCard(
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.all(20),
      onTap: () {},
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSaleCard(Sale sale) {
    return AppCard(
      backgroundColor: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _getAvatarColor(sale.customer),
            child: Text(
              sale.customer.split(' ').map((name) => name[0]).join('').toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${sale.id}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  sale.customer,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${sale.total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                DateFormat('HH:mm a').format(sale.date),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getAvatarColor(String customer) {
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
    ];

    int hash = customer.codeUnits.fold(0, (int sum, int char) => sum + char);
    return colors[hash % colors.length];
  }
}