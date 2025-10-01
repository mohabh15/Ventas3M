import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class ManagementScreen extends StatelessWidget {
  const ManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Banca',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildManagementCard(
                  context,
                  'Productos',
                  Icons.inventory,
                  AppColors.products,
                  () {
                    // Navegar a productos
                  },
                ),
                _buildManagementCard(
                  context,
                  'Ventas',
                  Icons.point_of_sale,
                  AppColors.sales,
                  () {
                    // Navegar a ventas
                  },
                ),
                _buildManagementCard(
                  context,
                  'Gastos',
                  Icons.account_balance_wallet,
                  AppColors.expenses,
                  () {
                    // Navegar a gastos
                  },
                ),
                _buildManagementCard(
                  context,
                  'Reportes',
                  Icons.analytics,
                  theme.colorScheme.tertiary,
                  () {
                    // Navegar a reportes
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}