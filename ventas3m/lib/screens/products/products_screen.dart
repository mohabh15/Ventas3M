import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/products_provider.dart';
import '../../models/product.dart';
import '../../core/widgets/gradient_app_bar.dart';
import 'add_product_modal.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Calcular la altura de la barra de navegación inferior
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final marginBottom = bottomPadding + 16.0; // Margen de 16px encima de la navbar

    return Scaffold(
      appBar: GradientAppBar(
        title: 'Productos',
      ),
      body: Stack(
        children: [
          // Contenido principal
          Column(
            children: [
              // Lista de productos o mensaje si no hay productos
              Expanded(
                child: Consumer<ProductsProvider>(
                  builder: (context, productsProvider, child) {
                    final products = productsProvider.products;
                    final isLoading = productsProvider.isLoading;
                    final error = productsProvider.error;

                    if (isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (error != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 80,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              error,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => productsProvider.loadProducts(),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (products.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 80,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No hay productos registrados',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Presiona el botón + para añadir un producto',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                       padding: const EdgeInsets.all(16),
                       itemCount: products.length,
                       itemBuilder: (context, index) {
                         final product = products[index];
                         return ProductCard(
                           product: product,
                           onTap: () {
                             // TODO: Implementar edición de producto
                           },
                         );
                       },
                     );
                  },
                ),
              ),
            ],
          ),
          // Botón flotante con gradiente
          Positioned(
            bottom: marginBottom,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0D47A1),
                    Color(0xFF1976D2),
                    Color(0xFF42A5F5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton(
                heroTag: 'products_fab', // Tag único para evitar conflictos de Hero
                onPressed: _showAddProductModal,
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

  void _showAddProductModal() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: const AddProductModal(),
        );
      },
    );

    if (result != null && mounted) {
      // Crear objeto Product desde el mapa usando el factory fromFormData
      final newProduct = Product.fromFormData(result);

      // Usar addPostFrameCallback para evitar el error de setState durante el build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final productsProvider = Provider.of<ProductsProvider>(context, listen: false);

          try {
            // Intentar añadir el producto
            productsProvider.addProduct(newProduct);

            // Si no hay error, mostrar snackbar de éxito
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && productsProvider.error == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Producto ${newProduct.name} guardado exitosamente'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            });
          } catch (e) {
            // Si hay error, mostrar snackbar con el error del provider
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && productsProvider.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(productsProvider.error!),
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
}

// Widget personalizado para mostrar cada producto
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stock = _getProductStock(product.id); // Obtener stock del producto
    final stockStatus = _getStockStatus(stock);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Ícono del producto con colores variados
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getProductColor(product.name).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getProductIcon(product.name),
                    color: _getProductColor(product.name),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Información del producto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre del producto
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF212121),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // SKU y Stock
                      Row(
                        children: [
                          Text(
                            'SKU: ${product.id.substring(0, 8).toUpperCase()} • Stock: $stock',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Precio y estado de stock
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Precio
                    Text(
                      '\$${product.basePrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF4CAF50) : const Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Estado de stock
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStockStatusColor(stockStatus, isDark),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStockStatusText(stockStatus),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: _getStockStatusTextColor(stockStatus, isDark),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Método para obtener el color del ícono según el nombre del producto
  Color _getProductColor(String productName) {
    final colors = [
      const Color(0xFF2196F3), // Azul
      const Color(0xFF4CAF50), // Verde
      const Color(0xFFFF9800), // Naranja
      const Color(0xFFE91E63), // Rosa
      const Color(0xFF9C27B0), // Púrpura
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFFF44336), // Rojo
      const Color(0xFF795548), // Marrón
    ];

    // Usar el hash del nombre para asignar un color consistente
    final hash = productName.hashCode.abs();
    return colors[hash % colors.length];
  }

  // Método para obtener el ícono según el nombre del producto
  IconData _getProductIcon(String productName) {
    final name = productName.toLowerCase();

    if (name.contains('laptop') || name.contains('computadora') || name.contains('pc')) {
      return Icons.laptop;
    } else if (name.contains('iphone') || name.contains('phone') || name.contains('celular')) {
      return Icons.phone_android;
    } else if (name.contains('audifono') || name.contains('headphone') || name.contains('auricular')) {
      return Icons.headphones;
    } else if (name.contains('ipad') || name.contains('tablet')) {
      return Icons.tablet;
    } else if (name.contains('camara') || name.contains('camera') || name.contains('dslr')) {
      return Icons.camera_alt;
    } else if (name.contains('playstation') || name.contains('ps5') || name.contains('consola')) {
      return Icons.gamepad;
    } else {
      return Icons.inventory_2;
    }
  }

  // Método para obtener el stock del producto (simulado por ahora)
  int _getProductStock(String productId) {
    // Simulación de stock - en producción esto vendría de ProductStock
    final stocks = {
      'laptop': 12,
      'iphone': 8,
      'audifono': 3,
      'ipad': 15,
      'camara': 0,
      'playstation': 6,
    };

    // Buscar por nombre del producto para simular stock
    for (final entry in stocks.entries) {
      if (productId.toLowerCase().contains(entry.key)) {
        return entry.value;
      }
    }

    return 5; // Stock por defecto
  }

  // Método para obtener el estado del stock
  String _getStockStatus(int stock) {
    if (stock == 0) return 'agotado';
    if (stock <= 5) return 'bajo';
    return 'disponible';
  }

  // Método para obtener el color del estado de stock
  Color _getStockStatusColor(String status, bool isDark) {
    switch (status) {
      case 'disponible':
        return isDark ? const Color(0xFF66BB6A) : const Color(0xFF4CAF50);
      case 'bajo':
        return isDark ? const Color(0xFFFFB74D) : const Color(0xFFFF9800);
      case 'agotado':
        return isDark ? const Color(0xFFEF5350) : const Color(0xFFF44336);
      default:
        return isDark ? Colors.grey[600]! : Colors.grey[400]!;
    }
  }

  // Método para obtener el texto del estado de stock
  String _getStockStatusText(String status) {
    switch (status) {
      case 'disponible':
        return 'En Stock';
      case 'bajo':
        return 'Stock Bajo';
      case 'agotado':
        return 'Agotado';
      default:
        return 'Sin Stock';
    }
  }

  // Método para obtener el color del texto del estado de stock
  Color _getStockStatusTextColor(String status, bool isDark) {
    return Colors.white;
  }
}