import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/modern_forms.dart';
import '../../core/widgets/modern_loading.dart';
import '../../core/widgets/modern_quantity_selector.dart';
import '../../models/product.dart';
import '../../models/cart_item.dart';
import '../../models/sale.dart';

/// Pantalla moderna de ventas completamente rediseñada
class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen>
    with TickerProviderStateMixin {
  // Controladores para las pestañas modernas
  late TabController _tabController;

  // Estado de la aplicación
  final List<CartItem> _cartItems = [];
  final List<Product> _products = [];
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Estados de carga y UI
  bool _isLoading = false;
  bool _isProcessingSale = false;
  String _searchQuery = '';
  ProductCategory? _selectedCategory;
  PaymentMethodType _selectedPaymentMethod = PaymentMethodType.cash;

  // Configuración de ventas
  double _globalDiscount = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _customerNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Inicializa datos de ejemplo para demostración
  Future<void> _initializeData() async {
    setState(() => _isLoading = true);

    // Simular carga de productos
    await Future.delayed(const Duration(seconds: 1));

    _products.addAll([
      Product(
        id: '1',
        name: 'Laptop Gaming Pro',
        description: 'Laptop de alto rendimiento para gaming',
        price: 1299.99,
        originalPrice: 1499.99,
        imageUrl: 'https://via.placeholder.com/200x150/1976D2/FFFFFF?text=Laptop',
        category: 'Electrónicos',
        rating: 4.5,
        reviewCount: 128,
        inStock: true,
        stockCount: 15,
        tags: ['Gaming', 'Alta Performance'],
        barcode: '1234567890123',
        sku: 'LT-GAMING-001',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '2',
        name: 'Smartphone Premium',
        description: 'Teléfono inteligente con cámara avanzada',
        price: 899.99,
        imageUrl: 'https://via.placeholder.com/200x150/4CAF50/FFFFFF?text=Phone',
        category: 'Electrónicos',
        rating: 4.2,
        reviewCount: 89,
        inStock: true,
        stockCount: 23,
        tags: ['Smartphone', 'Premium'],
        barcode: '1234567890124',
        sku: 'SP-PREMIUM-001',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '3',
        name: 'Auriculares Inalámbricos',
        description: 'Auriculares con cancelación de ruido',
        price: 199.99,
        originalPrice: 249.99,
        imageUrl: 'https://via.placeholder.com/200x150/9C27B0/FFFFFF?text=Headphones',
        category: 'Electrónicos',
        rating: 4.7,
        reviewCount: 156,
        inStock: true,
        stockCount: 8,
        tags: ['Audio', 'Inalámbrico'],
        barcode: '1234567890125',
        sku: 'HP-WIRELESS-001',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ]);

    setState(() => _isLoading = false);
  }

  /// Filtra productos según búsqueda y categoría
  List<Product> get _filteredProducts {
    return _products.where((product) {
      final matchesSearch = _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.sku.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == null ||
          product.category == _selectedCategory!.displayName;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  /// Calcula totales del carrito
  double get _cartSubtotal {
    return _cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  double get _cartTax {
    return _cartSubtotal * 0.16; // IVA 16%
  }

  double get _cartTotal {
    return _cartSubtotal + _cartTax - _globalDiscount;
  }

  /// Agrega producto al carrito
  void _addToCart(Product product, {int quantity = 1}) {
    final existingItem = _cartItems.where((item) => item.product.id == product.id);

    if (existingItem.isNotEmpty) {
      // Incrementar cantidad si ya existe
      final item = existingItem.first;
      final updatedItem = item.copyWith(
        quantity: item.quantity + quantity,
      );
      setState(() {
        _cartItems.remove(item);
        _cartItems.add(updatedItem);
      });
    } else {
      // Agregar nuevo item
      final cartItem = CartItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        product: product,
        quantity: quantity,
        unitPrice: product.price,
        addedAt: DateTime.now(),
      );
      setState(() => _cartItems.add(cartItem));
    }

    // Animación de feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} agregado al carrito'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Procesa la venta
  Future<void> _processSale() async {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agregue productos al carrito antes de procesar la venta'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isProcessingSale = true);

    try {
      // Simular procesamiento de venta
      await Future.delayed(const Duration(seconds: 2));

      final sale = Sale(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        items: List.from(_cartItems),
        subtotal: _cartSubtotal,
        tax: _cartTax,
        discount: _globalDiscount,
        total: _cartTotal,
        paymentMethod: PaymentMethod(type: _selectedPaymentMethod),
        customer: _customerNameController.text.isNotEmpty
            ? Customer(
                id: 'temp',
                name: _customerNameController.text,
              )
            : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'Usuario Actual',
        invoiceNumber: 'VTA-${DateTime.now().millisecondsSinceEpoch}',
      );

      // Limpiar carrito y mostrar éxito
      setState(() {
        _cartItems.clear();
        _customerNameController.clear();
        _notesController.clear();
        _globalDiscount = 0.0;
      });

      // Mostrar diálogo de éxito
      if (mounted) {
        _showSuccessDialog(sale);
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar la venta: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isProcessingSale = false);
    }
  }

  /// Muestra diálogo de éxito de venta
  void _showSuccessDialog(Sale sale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Venta Procesada'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Factura: ${sale.invoiceNumber}'),
            Text('Total: \$${sale.total.toStringAsFixed(2)}'),
            Text('Método de pago: ${sale.paymentMethod.type.displayName}'),
            if (sale.customer != null) Text('Cliente: ${sale.customer!.name}'),
          ],
        ),
        actions: [
          AppButton(
            text: 'Aceptar',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildModernAppBar(),
      body: _isLoading ? _buildLoadingState() : _buildMainContent(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// Construye AppBar moderno con acciones rápidas
  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Punto de Venta',
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '${_cartItems.length} productos en carrito',
            style: const TextStyle(
              fontFamily: 'Lufga',
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      actions: [
        // Acciones rápidas del AppBar
        IconButton(
          onPressed: () => _tabController.animateTo(3),
          icon: const Icon(Icons.payment),
          tooltip: 'Procesar Venta',
        ),
        IconButton(
          onPressed: () => _showQuickActions(),
          icon: const Icon(Icons.more_vert),
          tooltip: 'Más opciones',
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          color: AppColors.primary.withValues(alpha: 0.9),
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.textOnPrimary,
            labelColor: AppColors.textOnPrimary,
            unselectedLabelColor: AppColors.textOnPrimary.withValues(alpha: 0.7),
            tabs: const [
              Tab(text: 'Productos', icon: Icon(Icons.inventory_2)),
              Tab(text: 'Carrito', icon: Icon(Icons.shopping_cart)),
              Tab(text: 'Cliente', icon: Icon(Icons.person)),
              Tab(text: 'Pagar', icon: Icon(Icons.payment)),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye el contenido principal con pestañas
  Widget _buildMainContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildProductsTab(),
        _buildCartTab(),
        _buildCustomerTab(),
        _buildCheckoutTab(),
      ],
    );
  }

  /// Pestaña de productos con diseño moderno
  Widget _buildProductsTab() {
    return Column(
      children: [
        // Barra de búsqueda y filtros
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(color: AppColors.border),
            ),
          ),
          child: Column(
            children: [
              // Campo de búsqueda
              AppSearchField(
                controller: _searchController,
                hint: 'Buscar productos por nombre, descripción o SKU...',
                onChanged: (value) => setState(() => _searchQuery = value),
                showFilter: true,
                onFilter: () => _showCategoryFilter(),
              ),
              const SizedBox(height: 12),

              // Filtros rápidos de categoría
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryChip(null, 'Todos'),
                    ...ProductCategory.values.map(
                      (category) => _buildCategoryChip(category, category.displayName),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Lista de productos
        Expanded(
          child: _filteredProducts.isEmpty
              ? _buildEmptyProductsState()
              : _buildProductsGrid(),
        ),
      ],
    );
  }

  /// Construye grid de productos moderno
  Widget _buildProductsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 280,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  /// Construye tarjeta de producto moderna
  Widget _buildProductCard(Product product) {
    return AppCard(
      variant: AppCardVariant.elevated,
      elevation: AppCardElevation.level2,
      onTap: () => _showProductDetails(product),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del producto
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(product.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Información del producto
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre y categoría
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontFamily: 'Lufga',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Precio
                  Row(
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontFamily: 'Lufga',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      if (product.originalPrice != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '\$${product.originalPrice!.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontFamily: 'Lufga',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textDisabled,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const Spacer(),

                  // Stock y botón agregar
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: product.inStock
                              ? AppColors.secondary.withValues(alpha: 0.1)
                              : AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product.inStock ? 'En stock' : 'Agotado',
                          style: TextStyle(
                            fontFamily: 'Lufga',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: product.inStock ? AppColors.secondary : AppColors.error,
                          ),
                        ),
                      ),
                      const Spacer(),
                      AppButton(
                        text: 'Agregar',
                        variant: AppButtonVariant.primary,
                        size: AppButtonSize.small,
                        onPressed: product.inStock ? () => _addToCart(product) : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Pestaña del carrito de ventas
  Widget _buildCartTab() {
    if (_cartItems.isEmpty) {
      return _buildEmptyCartState();
    }

    return Column(
      children: [
        // Resumen del carrito
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(color: AppColors.border),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total productos: ${_cartItems.length}',
                      style: const TextStyle(
                        fontFamily: 'Lufga',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Subtotal: \$${_cartSubtotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontFamily: 'Lufga',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              AppButton(
                text: 'Vaciar Carrito',
                variant: AppButtonVariant.outline,
                onPressed: () => _clearCart(),
              ),
            ],
          ),
        ),

        // Lista de productos en carrito
        Expanded(
          child: ListView.builder(
            itemCount: _cartItems.length,
            itemBuilder: (context, index) {
              return _buildCartItemCard(_cartItems[index]);
            },
          ),
        ),
      ],
    );
  }

  /// Construye tarjeta de elemento del carrito
  Widget _buildCartItemCard(CartItem item) {
    return AppCard(
      variant: AppCardVariant.filled,
      size: AppCardSize.medium,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Imagen del producto
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(item.product.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Información del producto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(
                      fontFamily: 'Lufga',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '\$${item.unitPrice.toStringAsFixed(2)} c/u',
                    style: const TextStyle(
                      fontFamily: 'Lufga',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (item.hasDiscount) ...[
                    Text(
                      'Descuento: \$${item.discount!.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontFamily: 'Lufga',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Controles de cantidad modernos
            ModernQuantitySelector(
              initialQuantity: item.quantity,
              minQuantity: 1,
              maxQuantity: item.product.stockCount,
              variant: QuantitySelectorVariant.compact,
              onChanged: (quantity) => _updateCartItemQuantity(item, quantity),
              enabled: true,
            ),

            const SizedBox(width: 8),

            // Subtotal
            Text(
              '\$${item.subtotal.toStringAsFixed(2)}',
              style: const TextStyle(
                fontFamily: 'Lufga',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Pestaña de información del cliente
  Widget _buildCustomerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información del Cliente',
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          AppTextField(
            label: 'Nombre del Cliente',
            hint: 'Ingrese el nombre del cliente (opcional)',
            controller: _customerNameController,
            leadingIcon: const Icon(Icons.person),
          ),

          const SizedBox(height: 16),

          AppTextArea(
            label: 'Notas de la Venta',
            hint: 'Notas adicionales para esta venta (opcional)',
            controller: _notesController,
            maxLines: 3,
            minLines: 2,
          ),

          const SizedBox(height: 24),

          const Text(
            'Descuento Global',
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Descuento (\$)',
                  hint: '0.00',
                  controller: TextEditingController(text: _globalDiscount.toStringAsFixed(2)),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _globalDiscount = double.tryParse(value) ?? 0.0;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              AppButton(
                text: 'Aplicar',
                variant: AppButtonVariant.primary,
                onPressed: () {
                  setState(() {});
                },
              ),
            ],
          ),

          if (_globalDiscount > 0) ...[
            const SizedBox(height: 8),
            Text(
              'Descuento aplicado: \$${_globalDiscount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontFamily: 'Lufga',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.error,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Pestaña de checkout y pago
  Widget _buildCheckoutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen de la venta
          AppCard(
            variant: AppCardVariant.elevated,
            elevation: AppCardElevation.level2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumen de Venta',
                    style: TextStyle(
                      fontFamily: 'Lufga',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Detalle de totales
                  _buildTotalRow('Subtotal:', '\$${_cartSubtotal.toStringAsFixed(2)}'),
                  _buildTotalRow('IVA (16%):', '\$${_cartTax.toStringAsFixed(2)}'),
                  if (_globalDiscount > 0)
                    _buildTotalRow('Descuento:', '-\$${_globalDiscount.toStringAsFixed(2)}', AppColors.error),

                  const Divider(height: 24),

                  _buildTotalRow(
                    'TOTAL:',
                    '\$${_cartTotal.toStringAsFixed(2)}',
                    AppColors.primary,
                    true,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Método de pago
          const Text(
            'Método de Pago',
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          ...PaymentMethodType.values.map(
            (method) => _buildPaymentMethodOption(method),
          ),

          const SizedBox(height: 24),

          // Botón de procesar venta
          AppButton(
            text: 'Procesar Venta',
            variant: AppButtonVariant.primary,
            size: AppButtonSize.large,
            isLoading: _isProcessingSale,
            onPressed: _cartItems.isNotEmpty ? _processSale : null,
          ),

          const SizedBox(height: 16),

          // Información adicional
          if (_customerNameController.text.isNotEmpty) ...[
            AppCard(
              variant: AppCardVariant.outlined,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Cliente: ${_customerNameController.text}',
                      style: const TextStyle(
                        fontFamily: 'Lufga',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Construye fila de totales
  Widget _buildTotalRow(String label, String amount, [Color? color, bool isBold = false]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Lufga',
                fontSize: isBold ? 16 : 14,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                color: color ?? AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye opción de método de pago
  Widget _buildPaymentMethodOption(PaymentMethodType method) {
    final isSelected = _selectedPaymentMethod == method;

    return AppCard(
      variant: isSelected ? AppCardVariant.elevated : AppCardVariant.outlined,
      elevation: isSelected ? AppCardElevation.level2 : AppCardElevation.level0,
      margin: const EdgeInsets.only(bottom: 8),
      onTap: () => setState(() => _selectedPaymentMethod = method),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              _getPaymentMethodIcon(method),
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                method.displayName,
                style: TextStyle(
                  fontFamily: 'Lufga',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  /// Obtiene ícono para método de pago
  IconData _getPaymentMethodIcon(PaymentMethodType method) {
    switch (method) {
      case PaymentMethodType.cash:
        return Icons.money;
      case PaymentMethodType.card:
        return Icons.credit_card;
      case PaymentMethodType.transfer:
        return Icons.account_balance;
      case PaymentMethodType.check:
        return Icons.description;
      case PaymentMethodType.credit:
        return Icons.schedule;
    }
  }

  /// Estado de carga moderno
  Widget _buildLoadingState() {
    return const ModernLoadingSpinner(
      size: 60,
      color: AppColors.primary,
    );
  }

  /// Estado vacío de productos
  Widget _buildEmptyProductsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: AppColors.textDisabled,
          ),
          const SizedBox(height: 16),
          Text(
            'No se encontraron productos',
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intente ajustar los filtros de búsqueda',
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textDisabled,
            ),
          ),
        ],
      ),
    );
  }

  /// Estado vacío del carrito
  Widget _buildEmptyCartState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppColors.textDisabled,
          ),
          const SizedBox(height: 16),
          Text(
            'Carrito vacío',
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agregue productos desde la pestaña Productos',
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textDisabled,
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            text: 'Ver Productos',
            variant: AppButtonVariant.primary,
            onPressed: () => _tabController.animateTo(0),
          ),
        ],
      ),
    );
  }

  /// Floating Action Button moderno
  Widget _buildFloatingActionButton() {
    if (_cartItems.isEmpty) return const SizedBox.shrink();

    return FloatingActionButton.extended(
      onPressed: () => _tabController.animateTo(3),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      icon: const Icon(Icons.payment),
      label: Text(
        '\$${_cartTotal.toStringAsFixed(2)}',
        style: const TextStyle(
          fontFamily: 'Lufga',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Construye chip de categoría
  Widget _buildCategoryChip(ProductCategory? category, String label) {
    final isSelected = _selectedCategory == category;

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedCategory = selected ? category : null);
        },
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary.withValues(alpha: 0.1),
        checkmarkColor: AppColors.primary,
        labelStyle: TextStyle(
          fontFamily: 'Lufga',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }

  /// Muestra detalles del producto
  void _showProductDetails(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen del producto
                  Center(
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(product.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Información del producto
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontFamily: 'Lufga',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    product.description,
                    style: const TextStyle(
                      fontFamily: 'Lufga',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Precio y stock
                  Row(
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontFamily: 'Lufga',
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: product.inStock
                              ? AppColors.secondary.withValues(alpha: 0.1)
                              : AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          product.inStock ? '${product.stockCount} disponibles' : 'Agotado',
                          style: TextStyle(
                            fontFamily: 'Lufga',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: product.inStock ? AppColors.secondary : AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Agregar al Carrito',
                          variant: AppButtonVariant.primary,
                          onPressed: product.inStock ? () => _addToCart(product) : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Muestra menú de acciones rápidas
  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text('Escanear Código'),
              subtitle: const Text('Funcionalidad pendiente: integración con cámara para escanear códigos de barras'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Escaneo de códigos próximamente')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Ver Inventario'),
              subtitle: const Text('Funcionalidad pendiente: navegación a pantalla de gestión de inventario'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Inventario próximamente')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Historial de Ventas'),
              subtitle: const Text('Funcionalidad pendiente: mostrar historial completo de ventas realizadas'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Historial de ventas próximamente')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Muestra filtro de categorías
  void _showCategoryFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtrar por Categoría',
              style: TextStyle(
                fontFamily: 'Lufga',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildCategoryChip(null, 'Todas'),
                ...ProductCategory.values.map(
                  (category) => _buildCategoryChip(category, category.displayName),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Actualiza cantidad de elemento en carrito
  void _updateCartItemQuantity(CartItem item, int newQuantity) {
    if (newQuantity <= 0) {
      _removeCartItem(item);
      return;
    }

    final updatedItem = item.copyWith(quantity: newQuantity);
    setState(() {
      _cartItems.remove(item);
      _cartItems.add(updatedItem);
    });
  }

  /// Remueve elemento del carrito
  void _removeCartItem(CartItem item) {
    setState(() => _cartItems.remove(item));
  }

  /// Limpia todo el carrito
  void _clearCart() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vaciar Carrito'),
        content: const Text('¿Está seguro de que desea vaciar todo el carrito?'),
        actions: [
          AppButton(
            text: 'Cancelar',
            variant: AppButtonVariant.outline,
            onPressed: () => Navigator.of(context).pop(),
          ),
          AppButton(
            text: 'Vaciar',
            variant: AppButtonVariant.primary,
            onPressed: () {
              setState(() => _cartItems.clear());
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}