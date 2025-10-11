import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/products_provider.dart';
import '../../providers/product_stock_provider.dart';
import '../../models/product.dart';
import '../../core/widgets/gradient_app_bar.dart';
import '../../router/app_router.dart';
import 'add_product_modal.dart';
import 'add_stock_modal.dart';
import 'edit_product_modal.dart';
import 'stock_details_modal.dart';
import 'edit_stock_modal.dart';
import 'stock_card.dart';

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
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              error,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                if (error == 'No hay proyecto seleccionado') {
                                  Navigator.pushNamed(context, AppRouter.settings);
                                } else {
                                  productsProvider.loadProducts();
                                }
                              },
                              child: Text(error == 'No hay proyecto seleccionado' ? 'Selecciona uno' : 'Reintentar'),
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
                           onTap: () {},
                           onAddStock: () => _showAddStockModal(product.id, product.name),
                           onEdit: () => _showEditProductModal(product),
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

  void _showAddStockModal(String productId, String productName) async {
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
          child: AddStockModal(
            productId: productId,
            productName: productName,
          ),
        );
      },
    );

    if (result != null && mounted) {

      // Crear objeto ProductStock desde los datos del formulario
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
        projectId: '', // Se establecerá después con el proyecto actual
      );

      // Usar addPostFrameCallback para evitar el error de setState durante el build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final stockProvider = Provider.of<ProductStockProvider>(context, listen: false);

          try {
            // Intentar añadir el stock
            stockProvider.addStock(newStock);

            // Si no hay error, mostrar snackbar de éxito y forzar actualización de UI
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && stockProvider.error == null) {

                // Forzar reconstrucción del estado para asegurar que la UI se actualice
                setState(() {});

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Stock añadido exitosamente'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            });
          } catch (e) {
            // Si hay error, mostrar snackbar con el error del provider
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

  void _showEditProductModal(Product product) async {
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
          child: EditProductModal(product: product),
        );
      },
    );

    if (result != null && mounted) {
      // Crear objeto Product actualizado desde los datos del formulario
      final updatedProduct = Product(
        id: result['id'] as String,
        name: result['name'] as String,
        description: result['description'] as String,
        basePrice: result['basePrice'] as double,
        category: result['category'] as String,
        createdAt: product.createdAt,
        updatedAt: DateTime.now(),
        projectId: product.projectId,
      );

      // Usar addPostFrameCallback para evitar el error de setState durante el build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final productsProvider = Provider.of<ProductsProvider>(context, listen: false);

          try {
            // Intentar actualizar el producto
            productsProvider.updateProduct(updatedProduct);

            // Si no hay error, mostrar snackbar de éxito
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && productsProvider.error == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Producto ${updatedProduct.name} actualizado exitosamente'),
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
class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddStock;
  final VoidCallback onEdit;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAddStock,
    required this.onEdit,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key(widget.product.id),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF44336),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 30,
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.edit,
          color: Colors.white,
          size: 30,
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          widget.onEdit();
          return false;
        } else if (direction == DismissDirection.startToEnd) {
          final stockProvider = Provider.of<ProductStockProvider>(context, listen: false);
          final totalStock = stockProvider.getTotalStockForProduct(widget.product.id);
          if (totalStock > 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('No se puede eliminar el producto porque aún hay stock'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 2),
              ),
            );
            return false;
          }
          return true;
        }
        return false;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          _showDeleteProductDialog();
        }
      },
      child: Container(
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
        child: Column(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Ícono del producto con colores variados
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _getProductColor(widget.product.name).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getProductIcon(widget.product.name),
                          color: _getProductColor(widget.product.name),
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
                              widget.product.name,
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
                                  'SKU: ${widget.product.id.substring(0, 8).toUpperCase()}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                                  size: 16,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
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
                            '\$${widget.product.basePrice.toStringAsFixed(2)}',
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
                              color: _getStockStatusColor(_getStockStatus(_getProductStock(widget.product.id)), isDark),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getStockStatusText(_getStockStatus(_getProductStock(widget.product.id))),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
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

            // Contenido expandido con cards de stock
            if (_isExpanded)
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[50],
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título de stocks
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Stocks Disponibles',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : const Color(0xFF212121),
                            ),
                          ),
                          Text(
                            '${_getProductStock(widget.product.id)} unidades',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Cards de stock individuales
                      ..._getStockCards(),

                      // Botón para añadir stock
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: widget.onAddStock,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Añadir Stock'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF42A5F5),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _getStockCards() {
    final stockProvider = Provider.of<ProductStockProvider>(context, listen: true);
    final stocks = stockProvider.getStocksForProduct(widget.product.id);

    if (stocks == null || stocks.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF333333)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
              const SizedBox(width: 12),
              Text(
                'No hay stocks registrados',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ];
    }

    return stocks.map((stock) {
      return StockCard(
        stock: stock,
        onTap: () => _showStockDetailsModal(stock),
        onEdit: () => _showEditStockModal(stock),
        onDelete: () => _deleteStock(stock),
      );
    }).toList();
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

  // Método para obtener el stock del producto desde el provider
  int _getProductStock(String productId) {
    final stockProvider = Provider.of<ProductStockProvider>(context, listen: true);
    final stock = stockProvider.getTotalStockForProduct(productId);
    return stock;
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

  // Método para mostrar diálogo de confirmación de eliminación
  void _showDeleteProductDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Producto'),
          content: Text('¿Estás seguro de que quieres eliminar el producto "${widget.product.name}"? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar diálogo
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar diálogo
                _deleteProduct(); // Proceder con la eliminación
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  // Método para eliminar el producto
  void _deleteProduct() {
    final productsProvider = Provider.of<ProductsProvider>(context, listen: false);

    try {
      // Eliminar el producto
      productsProvider.removeProduct(widget.product.id);

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Producto "${widget.product.name}" eliminado exitosamente'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar el producto: ${productsProvider.error ?? e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Método para mostrar detalles del stock
  void _showStockDetailsModal(ProductStock stock) async {
    await showModalBottomSheet(
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
          child: StockDetailsModal(stock: stock),
        );
      },
    );
  }

  // Método para mostrar modal de edición del stock
  void _showEditStockModal(ProductStock stock) async {
    final result = await showModalBottomSheet<ProductStock>(
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
          child: EditStockModal(stock: stock),
        );
      },
    );

    if (result != null && mounted) {
      // Actualizar el stock
      final stockProvider = Provider.of<ProductStockProvider>(context, listen: false);

      try {
        await stockProvider.updateStock(result);

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stock actualizado exitosamente'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (e) {
        // Mostrar mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar el stock: ${stockProvider.error ?? e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Método para eliminar el stock
  void _deleteStock(ProductStock stock) async {
    final stockProvider = Provider.of<ProductStockProvider>(context, listen: false);

    try {
      await stockProvider.removeStock(stock.id);

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stock eliminado exitosamente'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar el stock: ${stockProvider.error ?? e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

}