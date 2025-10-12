import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/gradient_app_bar.dart';
import '../../core/widgets/loading_widget.dart';
import '../../models/sale.dart';
import '../../models/product.dart';
import '../../providers/sales_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/products_provider.dart';
import '../../providers/product_stock_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_service.dart';
import '../settings/settings_screen.dart';
import '../sales/add_sale_modal.dart';
import '../products/add_stock_modal.dart';
import '../reports/reports_screen.dart';

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
                      onTap: _showAddSaleModal,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      title: 'Añadir\nStock',
                      icon: Icons.add_box,
                      backgroundColor: Theme.of(context).brightness == Brightness.dark
                          ? AppDarkColors.products
                          : AppColors.products,
                      onTap: _showAddStockModal,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      title: 'Ver\nAnálisis',
                      icon: Icons.analytics,
                      backgroundColor: Theme.of(context).brightness == Brightness.dark
                          ? AppDarkColors.secondary
                          : AppColors.secondary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ReportsScreen()),
                        );
                      },
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
                    onPressed: () => Provider.of<NavigationProvider>(context, listen: false).setSelectedIndex(1),
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
              Consumer2<SalesProvider, ProductsProvider>(
                builder: (context, salesProvider, productsProvider, child) {
                  // Trigger lazy loading when screen is accessed
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _ensureSalesDataLoaded();
                    }
                  });

                  // Función auxiliar para obtener el nombre del producto
                  String getProductName(String productId) {
                    final product = productsProvider.products.firstWhere(
                      (product) => product.id == productId,
                      orElse: () => Product(
                        id: productId,
                        name: productId, // Fallback al ID si no se encuentra
                        description: '',
                        basePrice: 0,
                        category: '',
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                        projectId: '',
                      ),
                    );
                    return product.name;
                  }

                  // Función auxiliar para obtener el nombre del vendedor
                  Future<String> getSellerName(String sellerId) async {
                    try {
                      final user = await AuthService().getUserById(sellerId);
                      return user?.name ?? sellerId;
                    } catch (e) {
                      return sellerId;
                    }
                  }

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
                    children: recentSales.map((sale) => FutureBuilder<String>(
                      future: getSellerName(sale.sellerId),
                      builder: (context, snapshot) {
                        final sellerName = snapshot.data ?? sale.sellerId;
                        return _buildRecentSaleCard(sale, getProductName(sale.productId), sellerName);
                      },
                    )).toList(),
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
    VoidCallback? onTap,
  }) {
    return AppCard(
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.all(20),
      onTap: onTap ?? () {},
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

  Widget _buildRecentSaleCard(Sale sale, String productName, String sellerName) {
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
                  productName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  sellerName,
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
                '\$${sale.profit.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
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

  void _showAddSaleModal() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: const AddSaleModal(),
        );
      },
    );

    // Verificar que el widget esté montado antes de continuar
    if (!mounted) return;

    if (result != null) {
      // Crear objeto Sale desde el mapa
      final newSale = result['sale'] as Sale?;
      if (newSale != null) {
        // Usar addPostFrameCallback para evitar el error de setState durante el build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            // La venta ya fue creada en el modal, solo mostrar confirmación
            final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
            final productName = productsProvider.products.firstWhere(
              (product) => product.id == newSale.productId,
              orElse: () => Product(
                id: newSale.productId,
                name: newSale.productId,
                description: '',
                basePrice: 0,
                category: '',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                projectId: '',
              ),
            ).name;

            // Verificación adicional justo antes de usar el contexto
            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Venta de $productName guardada exitosamente'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        });
      }
    }
  }

  void _showAddStockModal() async {
    // First, show product selection dialog
    final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
    final products = productsProvider.products;

    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay productos disponibles. Crea un producto primero.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final selectedProduct = await showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Seleccionar Producto',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: isDark ? 0.3 : 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.outline.withValues(alpha: 0.3),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Text(
                            product.name,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            'Precio base: \$${product.basePrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          onTap: () => Navigator.of(context).pop(product),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );

    if (selectedProduct == null || !mounted) return;

    // Now show the AddStockModal for the selected product
    // Get project members and providers
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final activeProjectId = settingsProvider.activeProjectId;
    List<String> projectMembers = [];
    List<String> projectProviders = [];
    if (activeProjectId != null) {
      try {
        final firebaseService = FirebaseService();
        final project = await firebaseService.getProjectById(activeProjectId);
        if (project != null) {
          projectMembers = project.members;
          projectProviders = project.providers.map((provider) => provider.name).toList();
        }
      } catch (e) {
        // En caso de error, usar lista vacía
        projectMembers = [];
        projectProviders = [];
      }
    }

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: AddStockModal(
            productId: selectedProduct.id,
            productName: selectedProduct.name,
            projectMembers: projectMembers,
            projectProviders: projectProviders,
          ),
        );
      },
    );

    if (result != null && mounted) {
      // Create ProductStock object from the form data
      final newStock = ProductStock(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: result['productId'] as String,
        quantity: result['quantity'] as int,
        responsibleId: result['responsibleId'] as String,
        providerId: result['providerId'] as String,
        price: result['price'] as double,
        purchaseDate: result['purchaseDate'] as DateTime,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        projectId: activeProjectId ?? '',
      );

      // Use addPostFrameCallback to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final stockProvider = Provider.of<ProductStockProvider>(context, listen: false);

          try {
            // Add the stock
            stockProvider.addStock(newStock);

            // Show success message
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && stockProvider.error == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Stock añadido exitosamente'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            });
          } catch (e) {
            // Show error message
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && stockProvider.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(stockProvider.error!),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            });
          }
        }
      });
    }
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