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
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              child: const Icon(Icons.inventory_2, color: Colors.white),
                            ),
                            title: Text(product.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product.description),
                                const SizedBox(height: 4),
                                Text(
                                  'Categoría: ${product.category}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${product.basePrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Stock: 0', // TODO: Implementar stock cuando se tenga ProductStock
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              // TODO: Implementar edición de producto
                            },
                          ),
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
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
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