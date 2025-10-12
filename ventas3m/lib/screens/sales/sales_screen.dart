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
import '../../services/auth_service.dart';
import 'add_sale_modal.dart';
import 'edit_sale_modal.dart';
import 'sale_details_modal.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final Set<String> _deletingSaleIds = {}; // Track sales being deleted

  // Variables para búsqueda y filtros
  String _searchQuery = '';
  SaleStatus? _selectedStatus;
  PaymentMethod? _selectedPaymentMethod;
  DateTimeRange? _selectedDateRange;

  late SettingsProvider _settingsProvider;
  bool _listenerAdded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_listenerAdded) {
      _settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      _settingsProvider.addListener(_onProjectChanged);
      _listenerAdded = true;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (_listenerAdded) {
      _settingsProvider.removeListener(_onProjectChanged);
    }
    super.dispose();
  }

  void _onProjectChanged() {
    // Limpiar el set de ventas siendo eliminadas al cambiar de proyecto
    setState(() {
      _deletingSaleIds.clear();
    });
    // No cargar datos automáticamente en cambios de proyecto
    // Los datos se cargarán cuando el usuario interactúe con la pantalla
  }

  /// Función auxiliar para obtener el nombre del producto
  String _getProductName(String productId) {
    final product = Provider.of<ProductsProvider>(context, listen: false).products.firstWhere(
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

  /// Función para filtrar ventas según búsqueda y filtros aplicados
  List<Sale> _getFilteredSales(List<Sale> sales) {
    return sales.where((sale) {
      // Filtro por búsqueda
      if (_searchQuery.isNotEmpty) {
        final productName = _getProductName(sale.productId).toLowerCase();
        if (!productName.contains(_searchQuery.toLowerCase())) return false;
      }

      // Filtro por estado
      if (_selectedStatus != null && sale.status != _selectedStatus) return false;

      // Filtro por método de pago
      if (_selectedPaymentMethod != null && sale.paymentMethod != _selectedPaymentMethod) return false;

      // Filtro por rango de fechas
      if (_selectedDateRange != null) {
        final saleDate = DateTime(sale.saleDate.year, sale.saleDate.month, sale.saleDate.day);
        if (saleDate.isBefore(_selectedDateRange!.start) || saleDate.isAfter(_selectedDateRange!.end)) return false;
      }

      return true;
    }).toList();
  }

  /// Carga datos de ventas solo cuando sea necesario (lazy loading)
  Future<void> _ensureSalesDataLoaded() async {
    final salesProvider = Provider.of<SalesProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

    final projectId = settingsProvider.activeProjectId;
    if (projectId != null && !salesProvider.isDataLoadedForProject(projectId)) {
      await _loadSalesData();
    }
  }

  Future<void> _loadSalesData() async {
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

  @override
  Widget build(BuildContext context) {
    // Calcular la altura de la barra de navegación inferior
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final marginBottom = bottomPadding + 16.0; // Margen de 16px encima de la navbar

    return Scaffold(
      appBar: GradientAppBar(
        title: 'Ventas',
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: _showSearchModal,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterModal,
          ),
        ],
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
                    // Trigger lazy loading when screen is accessed
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        _ensureSalesDataLoaded();
                      }
                    });
                    final allSales = salesProvider.sales;
                    final unfilteredSales = allSales.where((sale) => !_deletingSaleIds.contains(sale.id)).toList();
                    final sales = _getFilteredSales(unfilteredSales);

                    return sales.isEmpty && allSales.isEmpty
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
                            return _buildSaleCard(context, sale, _getProductName(sale.productId));
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Dismissible(
          key: Key(sale.id),
          direction: DismissDirection.horizontal,
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF44336),
              borderRadius: BorderRadius.circular(12),
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
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.edit,
              color: Colors.white,
              size: 30,
            ),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              // Editar
              _showEditSaleModal(sale);
              return false;
            } else if (direction == DismissDirection.startToEnd) {
              // Eliminar - mostrar diálogo de confirmación
              return await _showDeleteSaleDialog(sale);
            }
            return false;
          },
          onDismissed: (direction) {
            if (direction == DismissDirection.startToEnd) {
              _deleteSale(sale);
            }
          },
          child: GestureDetector(
            onTap: () => _showSaleDetailsModal(sale),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1E1E1E)
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
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Transform.translate(
                              offset: const Offset(0, -4),
                              child: Text(
                                productName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black87,
                                ),
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
                      const SizedBox(width: 16),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Column(
                          children: [
                            Text(
                              '\$${sale.totalAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.blue[400]!
                                    : Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                sale.status.displayName,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
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
        ),
      ),
    )
    );
  }

  void _showEditSaleModal(Sale sale) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[900]
                : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: EditSaleModal(sale: sale),
        );
      },
    );

    if (result != null && mounted) {
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Venta actualizada exitosamente'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<bool> _showDeleteSaleDialog(Sale sale) async {
    final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
    final productName = productsProvider.products.firstWhere(
      (product) => product.id == sale.productId,
      orElse: () => Product(
        id: sale.productId,
        name: 'Producto no encontrado',
        description: '',
        basePrice: 0,
        category: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        projectId: '',
      ),
    ).name;

    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Venta'),
          content: Text('¿Estás seguro de que quieres eliminar la venta de "$productName"? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  void _deleteSale(Sale sale) {
    // Immediately hide the dismissed item
    setState(() {
      _deletingSaleIds.add(sale.id);
    });

    final salesProvider = Provider.of<SalesProvider>(context, listen: false);

    try {
      salesProvider.deleteSale(sale.id);

      final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
      final productName = productsProvider.products.firstWhere(
        (product) => product.id == sale.productId,
        orElse: () => Product(
          id: sale.productId,
          name: 'Producto no encontrado',
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
          content: Text('Venta de $productName eliminada exitosamente'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // If deletion failed, show the item again
      setState(() {
        _deletingSaleIds.remove(sale.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar venta: ${salesProvider.error ?? e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
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

  void _showSearchModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[900]
                : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Buscar Ventas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                autofocus: true,
                controller: TextEditingController(text: _searchQuery),
                decoration: const InputDecoration(
                  hintText: 'Buscar por nombre de producto...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Limpiar'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Buscar'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFilterModal() async {
    // Variables temporales para el modal
    SaleStatus? tempStatus = _selectedStatus;
    PaymentMethod? tempPaymentMethod = _selectedPaymentMethod;
    DateTimeRange? tempDateRange = _selectedDateRange;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[900]
                    : Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filtrar Ventas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  // Filtro por estado
                  Text('Estado:', style: TextStyle(fontWeight: FontWeight.w500)),
                  DropdownButton<SaleStatus>(
                    value: tempStatus,
                    isExpanded: true,
                    hint: const Text('Seleccionar estado'),
                    items: SaleStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setModalState(() {
                        tempStatus = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Filtro por método de pago
                  Text('Método de Pago:', style: TextStyle(fontWeight: FontWeight.w500)),
                  DropdownButton<PaymentMethod>(
                    value: tempPaymentMethod,
                    isExpanded: true,
                    hint: const Text('Seleccionar método'),
                    items: PaymentMethod.values.map((method) {
                      return DropdownMenuItem(
                        value: method,
                        child: Text(method.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setModalState(() {
                        tempPaymentMethod = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Filtro por rango de fechas
                  Text('Rango de Fechas:', style: TextStyle(fontWeight: FontWeight.w500)),
                  ElevatedButton(
                    onPressed: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        initialDateRange: tempDateRange,
                      );
                      if (picked != null) {
                        setModalState(() {
                          tempDateRange = picked;
                        });
                      }
                    },
                    child: Text(
                      tempDateRange != null
                          ? '${DateFormat('dd/MM/yyyy').format(tempDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(tempDateRange!.end)}'
                          : 'Seleccionar rango',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedStatus = null;
                            _selectedPaymentMethod = null;
                            _selectedDateRange = null;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Limpiar Filtros'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedStatus = tempStatus;
                            _selectedPaymentMethod = tempPaymentMethod;
                            _selectedDateRange = tempDateRange;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Aplicar'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSaleDetailsModal(Sale sale) async {
    // Verificar que el widget esté montado antes de continuar
    if (!mounted) return;

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

    // Obtener información del usuario que creó la venta
    String createdByName = 'Usuario desconocido';
    try {
      final authService = AuthService();
      final user = await authService.getUserById(sale.createdBy);
      createdByName = user?.name ?? sale.createdBy;
    } catch (e) {
      // Si hay error, usar el ID como fallback
      createdByName = sale.createdBy;
    }

    // Verificar que el widget esté montado antes de usar el contexto
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[900]
                : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SaleDetailsModal(
            sale: sale,
            product: product,
            createdByName: createdByName,
          ),
        );
      },
    );
  }
}