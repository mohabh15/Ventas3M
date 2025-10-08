import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/gradient_app_bar.dart';
import '../../core/widgets/loading_widget.dart';
import '../../models/sale.dart';
import '../../providers/sales_provider.dart';
import '../../providers/settings_provider.dart';
import '../settings/settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  @override
  void initState() {
    super.initState();

    // Escuchar cambios en el proyecto activo pero no cargar datos automáticamente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      settingsProvider.addListener(_onProjectChanged);
    });
  }

  @override
  void dispose() {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    settingsProvider.removeListener(_onProjectChanged);
    super.dispose();
  }

  void _onProjectChanged() {
    // No cargar datos automáticamente en cambios de proyecto
    // Los datos se cargarán cuando el usuario interactúe con la pantalla
  }

  /// Carga datos de ventas solo cuando sea necesario (lazy loading)
  Future<void> _ensureSalesDataLoaded() async {
    final salesProvider = Provider.of<SalesProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

    final projectId = settingsProvider.activeProjectId;
    if (projectId != null && !salesProvider.isDataLoadedForProject(projectId)) {
      await _loadRecentSales();
    }
  }

  Future<void> _loadRecentSales() async {
    final salesProvider = Provider.of<SalesProvider>(context, listen: false);

    // Prevenir múltiples llamadas simultáneas usando el flag del provider
    if (salesProvider.isCurrentlyLoadingSales) {
      return;
    }

    try {
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

      final projectId = settingsProvider.activeProjectId;
      if (projectId != null) {
        await salesProvider.loadSales(projectId);
      }
    } catch (e) {
      // Error manejado silenciosamente
    }
  }

  List<Sale> _getRecentSales() {
    final salesProvider = Provider.of<SalesProvider>(context);
    final completedSales = salesProvider.completedSales;

    // Ordenar por fecha (más recientes primero) y obtener las 5 más recientes
    return completedSales
        .toList()
        ..sort((a, b) => b.saleDate.compareTo(a.saleDate))
        ..take(5)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // Calcular la altura de la barra de navegación inferior
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBody: true, // Permite que el contenido pase debajo de la barra inferior
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
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
          top: true, // Mantenemos el padding superior para el AppBar
          bottom: false, // Removemos el padding inferior para permitir extensión debajo de la navbar
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              top: 16.0,
              left: 16.0,
              right: 16.0,
              bottom: bottomPadding + 100.0, // Padding adecuado considerando la navbar inferior
            ),
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
              Consumer<SalesProvider>(
                builder: (context, salesProvider, child) {
                  // Trigger lazy loading when screen is accessed
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _ensureSalesDataLoaded();
                    }
                  });
                  if (salesProvider.isLoading) {
                    return const LoadingWidget();
                  }

                  if (salesProvider.error != null) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error al cargar ventas',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            salesProvider.error!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadRecentSales,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    );
                  }

                  final recentSales = _getRecentSales();

                  if (recentSales.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay ventas recientes',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Las ventas aparecerán aquí cuando se registren',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: recentSales.map((sale) => _buildRecentSaleCard(sale)).toList(),
                  );
                },
              ),
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
            backgroundColor: _getAvatarColor(sale.customerName),
            child: Text(
              sale.customerName.split(' ').map((name) => name[0]).join('').toUpperCase(),
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
                  sale.customerName,
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
                '\$${sale.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                DateFormat('HH:mm a').format(sale.saleDate),
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

    int hash = customer.codeUnits.fold(0, (int accumulator, int char) => accumulator + char);
    return colors[hash % colors.length];
  }
}