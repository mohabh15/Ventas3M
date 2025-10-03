import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/sales_provider.dart';
import '../../models/sale.dart';
import '../../core/widgets/gradient_app_bar.dart';
import 'add_sale_modal.dart';

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
        Provider.of<SalesProvider>(context, listen: false).loadSales();
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
                child: Consumer<SalesProvider>(
                  builder: (context, salesProvider, child) {
                    final sales = salesProvider.sales;
                    return sales.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 80,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No hay ventas registradas',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Presiona el botón + para añadir una venta',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
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
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor,
                                child: const Icon(Icons.shopping_bag, color: Colors.white),
                              ),
                              title: Text(sale.product),
                              subtitle: Text('Cliente: ${sale.customer}'),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'x${sale.quantity}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '\$${sale.total.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
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
      final newSale = Sale.fromMap(result);
      // Usar addPostFrameCallback para evitar el error de setState durante el build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Provider.of<SalesProvider>(context, listen: false).addSale(newSale);
          
          // Mostrar snackbar de confirmación
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Venta de ${newSale.product} guardada exitosamente'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      });
    }
  }
}