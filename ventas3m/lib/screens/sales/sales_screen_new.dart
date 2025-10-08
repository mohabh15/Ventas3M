import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/sales_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/products_provider.dart';
import '../../models/sale.dart';
import '../../models/product.dart';
import '../../models/payment_method.dart';
import '../../models/sale_status.dart';
import '../../core/widgets/gradient_app_bar.dart';
import 'add_sale_modal.dart';
import 'sale_details_modal.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar ventas después de que el frame esté completo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
        final projectId = settingsProvider.activeProjectId;
        if (projectId != null) {
          Provider.of<SalesProvider>(context, listen: false).loadSales(projectId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calcular la altura de la barra de navegación inferior
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final marginBottom = bottomPadding + 16.0; // Margen de 16px encima de la navbar

    return Scaffold(
      appBar: GradientAppBar(
        title: 'Ventas',
      ),
      body: Stack(
        children: [
          // Contenido principal
          Column(
            children: [
              // Lista de ventas o mensaje si no hay ventas
              Expanded(
                child: Consumer2<SalesProvider, ProductsProvider>(
                  builder: (context, salesProvider, productsProvider, child) {
                    final sales = salesProvider.sales;

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

                    return sales.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                size: 80,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[300]
                                    : Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No hay ventas registradas',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.grey[300]
                                      : Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Presiona el botón + para añadir una venta',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.grey[300]
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: sales.length,
                          itemBuilder: (context, index) {
                            final sale = sales[index];
                            return _buildSaleCard(context, sale, getProductName(sale.productId));
                          },
                        );
                  },
                ),
              ),
            ],
          ),
          // Botón flotante posicionado relativo a la navbar
          Positioned(
            right: 16.0,
            bottom: marginBottom,
            child: Container(
              decoration: const BoxDecoration(
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
                heroTag: 'sales_fab', // Tag único para evitar conflictos de Hero
                onPressed: _showAddSaleModal,
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

  Widget _buildSaleCard(BuildContext context, Sale sale, String productName) {
    // Formatear fecha
    String formattedDate;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final saleDate = DateTime(sale.saleDate.year, sale.saleDate.month, sale.saleDate.day);

    if (saleDate == today) {
      formattedDate = 'Hoy, ${DateFormat('h:mm a').format(sale.saleDate)}';
    } else {
      formattedDate = DateFormat('dd MMM, h:mm a').format(sale.saleDate);
    }

    // Generar número de venta
    final saleNumber = '#VNT-${sale.id.substring(0, 6).toUpperCase()}';

    // Obtener color del badge según el estado
    Color statusColor;
    switch (sale.status) {
      case SaleStatus.completed:
        statusColor = Colors.green;
        break;
      case SaleStatus.pending:
        statusColor = Colors.orange;
        break;
      case SaleStatus.cancelled:
        statusColor = Colors.red;
        break;
      case SaleStatus.refunded:
        statusColor = Colors.blue;
        break;
    }

    return GestureDetector(
      onTap: () => _showSaleDetailsModal(context, sale),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[850]
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Primera fila: Número de venta
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          saleNumber,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[300]
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Monto en la esquina superior derecha
                  Text(
                    '\$${sale.totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.blue[400]!
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Información del cliente y estado en la misma fila
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Cliente: ${sale.customerName}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[200]
                            : Colors.grey[700],
                      ),
                    ),
                  ),
                  // Badge de estado alineado a la derecha
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      sale.status.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Información de productos y método de pago más compacta
              Row(
                children: [
                  Text(
                    '${sale.quantity} ${sale.quantity == 1 ? 'producto' : 'productos'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[300]
                          : Colors.grey[600],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      Icons.circle,
                      size: 3,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[300]
                          : Colors.grey[600],
                    ),
                  ),
                  Text(
                    sale.paymentMethod.displayName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[300]
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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

    if (result != null && mounted) {
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

  void _showSaleDetailsModal(BuildContext context, Sale sale) {
    // Obtener información del producto
    final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
    final product = productsProvider.products.firstWhere(
      (product) => product.id == sale.productId,
      orElse: () => Product(
        id: sale.productId,
        name: 'Producto no encontrado',
        description: '',
        basePrice: 0,
        category: 'N/A',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        projectId: '',
      ),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SaleDetailsModal(
            sale: sale,
            product: product,
          ),
        );
      },
    );
  }
}