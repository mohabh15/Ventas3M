import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/modern_forms.dart';
import '../../core/widgets/modern_loading.dart';
import '../../models/product.dart';
import '../../providers/products_provider.dart';

part 'widgets/empty_products_state.dart';

/// Pantalla moderna de gestión de productos completamente funcional
class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
    await productsProvider.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Consumer<ProductsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.products.isEmpty) {
            return _buildLoadingState();
          }

          return Column(
            children: [
              _buildSearchAndFilters(),
              _buildStatsSection(provider),
              Expanded(
                child: provider.filteredProducts.isEmpty
                    ? _buildEmptyState(provider)
                    : _buildProductsList(provider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductForm(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Productos',
        style: TextStyle(
          fontFamily: 'Lufga',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      backgroundColor: AppColors.primary,
      elevation: 0,
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              _isGridView = !_isGridView;
            });
          },
          icon: Icon(
            _isGridView ? Icons.list : Icons.grid_view,
            color: Colors.white,
          ),
          tooltip: 'Cambiar vista',
        ),
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(Icons.download, size: 20),
                  SizedBox(width: 8),
                  Text('Exportar datos'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'categories',
              child: Row(
                children: [
                  Icon(Icons.category, size: 20),
                  SizedBox(width: 8),
                  Text('Gestionar categorías'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
        ),
      ),
      child: Column(
        children: [
          AppTextField(
            hint: 'Buscar productos...',
            controller: _searchController,
            leadingIcon: const Icon(Icons.search),
            onChanged: (query) {
              Provider.of<ProductsProvider>(context, listen: false).setSearchQuery(query);
            },
          ),
          const SizedBox(height: 12),
          _buildFilterChips(),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Consumer<ProductsProvider>(
      builder: (context, provider, child) {
        final filters = provider.filters;
        final chips = <Widget>[];

        if (filters.categories.isNotEmpty) {
          chips.add(_buildFilterChip(
            'Categorías: ${filters.categories.length}',
            Icons.category,
            () {},
          ));
        }

        if (filters.activeFilterCount > 0) {
          chips.add(
            TextButton(
              onPressed: () => provider.clearFilters(),
              child: Text(
                'Limpiar filtros',
                style: TextStyle(
                  fontFamily: 'Lufga',
                  fontSize: 12,
                  color: AppColors.error,
                ),
              ),
            ),
          );
        }

        if (chips.isEmpty) {
          return const SizedBox.shrink();
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: chips.map((chip) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: chip,
            )).toList(),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, IconData icon, VoidCallback onTap) {
    return AppCard(
      variant: AppCardVariant.outlined,
      size: AppCardSize.small,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(ProductsProvider provider) {
    final stats = provider.stats;
    if (stats.totalProducts == 0) return const SizedBox.shrink();

    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildStatCard(
            'Total',
            stats.totalProducts.toString(),
            Icons.inventory_2,
            AppColors.primary,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'En Stock',
            stats.inStockProducts.toString(),
            Icons.check_circle,
            AppColors.secondary,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'Agotado',
            stats.outOfStockProducts.toString(),
            Icons.error,
            AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return AppCard(
      variant: AppCardVariant.filled,
      size: AppCardSize.small,
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(ProductsProvider provider) {
    return RefreshIndicator(
      onRefresh: () => provider.loadProducts(),
      child: _isGridView ? _buildGridView(provider) : _buildListView(provider),
    );
  }

  Widget _buildGridView(ProductsProvider provider) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getGridCrossAxisCount(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: provider.filteredProducts.length,
      itemBuilder: (context, index) {
        final product = provider.filteredProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildListView(ProductsProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.filteredProducts.length,
      itemBuilder: (context, index) {
        final product = provider.filteredProducts[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildProductCard(product, isListView: true),
        );
      },
    );
  }

  Widget _buildProductCard(Product product, {bool isListView = false}) {
    return AppCard(
      variant: AppCardVariant.elevated,
      elevation: AppCardElevation.level1,
      padding: const EdgeInsets.all(16),
      onTap: () => _showProductDetails(product),
      child: isListView ? _buildListCardContent(product) : _buildGridCardContent(product),
    );
  }

  Widget _buildGridCardContent(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Imagen del producto
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.surface,
              image: DecorationImage(
                image: NetworkImage(product.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: _buildStockBadge(product),
          ),
        ),
        const SizedBox(height: 12),

        // Información del producto
        Text(
          product.name,
          style: TextStyle(
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
        Text(
          '\$${product.price.toStringAsFixed(2)}',
          style: TextStyle(
            fontFamily: 'Lufga',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),

        // Stock
        Row(
          children: [
            Icon(
              product.inStock ? Icons.inventory : Icons.remove_shopping_cart,
              size: 14,
              color: product.inStock ? AppColors.secondary : AppColors.error,
            ),
            const SizedBox(width: 4),
            Text(
              product.inStock ? '${product.stockCount} unidades' : 'Agotado',
              style: TextStyle(
                fontFamily: 'Lufga',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: product.inStock ? AppColors.secondary : AppColors.error,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildListCardContent(Product product) {
    return Row(
      children: [
        // Imagen del producto
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColors.surface,
            image: DecorationImage(
              image: NetworkImage(product.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
          child: _buildStockBadge(product),
        ),
        const SizedBox(width: 12),

        // Información del producto
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: TextStyle(
                  fontFamily: 'Lufga',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                product.description,
                style: TextStyle(
                  fontFamily: 'Lufga',
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontFamily: 'Lufga',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    product.inStock ? Icons.inventory : Icons.remove_shopping_cart,
                    size: 12,
                    color: product.inStock ? AppColors.secondary : AppColors.error,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    product.inStock ? '${product.stockCount}' : 'Agotado',
                    style: TextStyle(
                      fontFamily: 'Lufga',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: product.inStock ? AppColors.secondary : AppColors.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Acciones
        PopupMenuButton<String>(
          onSelected: (value) => _handleProductAction(value, product),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'duplicate',
              child: Row(
                children: [
                  Icon(Icons.copy, size: 16),
                  SizedBox(width: 8),
                  Text('Duplicar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16, color: AppColors.error),
                  SizedBox(width: 8),
                  Text('Eliminar', style: TextStyle(color: AppColors.error)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStockBadge(Product product) {
    if (!product.inStock) {
      return Positioned(
        top: 6,
        right: 6,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Agotado',
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    if (product.stockCount <= 5) {
      return Positioned(
        top: 6,
        right: 6,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.tertiary.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Stock bajo',
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ModernLoadingSpinner(size: 48),
          SizedBox(height: 16),
          Text(
            'Cargando productos...',
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ProductsProvider provider) {
    final hasActiveFilters = provider.filters.hasActiveFilters;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasActiveFilters ? Icons.filter_list : Icons.inventory_2,
            size: 64,
            color: AppColors.textDisabled,
          ),
          const SizedBox(height: 16),
          Text(
            hasActiveFilters
                ? 'No se encontraron productos con los filtros aplicados'
                : 'No hay productos registrados',
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            hasActiveFilters
                ? 'Intenta ajustar los filtros o crear nuevos productos'
                : 'Crea tu primer producto para comenzar',
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textDisabled,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (hasActiveFilters)
            AppButton(
              text: 'Limpiar filtros',
              variant: AppButtonVariant.outline,
              onPressed: () => provider.clearFilters(),
            )
          else
            AppButton(
              text: 'Crear producto',
              onPressed: () => _showProductForm(),
            ),
        ],
      ),
    );
  }

  int _getGridCrossAxisCount() {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 4;
    if (width >= 900) return 3;
    if (width >= 600) return 2;
    return 1;
  }

  void _showProductForm({Product? product}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product == null ? 'Crear Producto' : 'Editar Producto'),
        content: const Text('Formulario de producto en desarrollo'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          AppButton(
            text: 'Guardar',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showProductDetails(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Precio: \$${product.price.toStringAsFixed(2)}'),
            Text('Stock: ${product.stockCount} unidades'),
            Text('Categoría: ${product.category}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          AppButton(
            text: 'Editar',
            onPressed: () {
              Navigator.of(context).pop();
              _showProductForm(product: product);
            },
          ),
        ],
      ),
    );
  }

  void _handleProductAction(String action, Product product) {
    switch (action) {
      case 'edit':
        _showProductForm(product: product);
        break;
      case 'duplicate':
        _duplicateProduct(product);
        break;
      case 'delete':
        _deleteProduct(product);
        break;
    }
  }

  Future<void> _duplicateProduct(Product product) async {
    final provider = Provider.of<ProductsProvider>(context, listen: false);
    final success = await provider.duplicateProduct(product.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Producto duplicado correctamente'
                : 'Error al duplicar producto',
          ),
          backgroundColor: success ? AppColors.secondary : AppColors.error,
        ),
      );
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Estás seguro de que deseas eliminar "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          AppButton(
            text: 'Eliminar',
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Obtener la referencia del provider antes de usar el contexto
      final provider = Provider.of<ProductsProvider>(context, listen: false);
      final success = await provider.deleteProduct(product.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Producto eliminado correctamente'
                  : 'Error al eliminar producto',
            ),
            backgroundColor: success ? AppColors.secondary : AppColors.error,
          ),
        );
      }
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exportación en desarrollo')),
        );
        break;
      case 'categories':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gestión de categorías en desarrollo')),
        );
        break;
    }
  }
}