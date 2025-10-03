import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../models/product.dart';
import '../../../providers/products_provider.dart';

/// Tarjeta moderna de producto con diseño mejorado
class ProductCardModern extends StatefulWidget {
  final Product product;
  final bool isListView;

  const ProductCardModern({
    super.key,
    required this.product,
    this.isListView = false,
  });

  @override
  State<ProductCardModern> createState() => _ProductCardModernState();
}

class _ProductCardModernState extends State<ProductCardModern> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _imageController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _imageAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _imageController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _imageAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _imageController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductsProvider>(context);
    final isSelected = provider.selectedProducts.contains(widget.product.id);

    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _imageAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: AppCard(
            variant: isSelected ? AppCardVariant.gradient : AppCardVariant.elevated,
            elevation: AppCardElevation.level2,
            padding: const EdgeInsets.all(16),
            margin: EdgeInsets.zero,
            onTap: () => _handleCardTap(provider),
            onLongPress: () => _handleCardLongPress(provider),
            gradient: isSelected ? AppGradients.primaryGradient : null,
            child: widget.isListView ? _buildListContent() : _buildGridContent(),
          ),
        );
      },
    );
  }

  Widget _buildGridContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Imagen del producto
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.surface,
              image: DecorationImage(
                image: NetworkImage(widget.product.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: _buildStockBadge(),
          ),
        ),
        const SizedBox(height: 12),

        // Información del producto
        Text(
          widget.product.name,
          style: TextStyle(
            fontFamily: 'Lufga',
            fontSize: 16,
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
              '\$${widget.product.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontFamily: 'Lufga',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            if (widget.product.originalPrice != null) ...[
              const SizedBox(width: 8),
              Text(
                '\$${widget.product.originalPrice!.toStringAsFixed(2)}',
                style: TextStyle(
                  fontFamily: 'Lufga',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textDisabled,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),

        // Stock y acciones
        Row(
          children: [
            _buildStockInfo(),
            const Spacer(),
            _buildQuickActions(),
          ],
        ),
      ],
    );
  }

  Widget _buildListContent() {
    return Row(
      children: [
        // Imagen del producto
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColors.surface,
            image: DecorationImage(
              image: NetworkImage(widget.product.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
          child: _buildStockBadge(),
        ),
        const SizedBox(width: 16),

        // Información del producto
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.product.name,
                style: TextStyle(
                  fontFamily: 'Lufga',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                widget.product.description,
                style: TextStyle(
                  fontFamily: 'Lufga',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '\$${widget.product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontFamily: 'Lufga',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildStockInfo(),
                  const Spacer(),
                  _buildQuickActions(),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStockBadge() {
    if (!widget.product.inStock) {
      return Positioned(
        top: 8,
        right: 8,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Agotado',
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textOnPrimary,
            ),
          ),
        ),
      );
    }

    if (widget.product.stockCount <= 5) {
      return Positioned(
        top: 8,
        right: 8,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.tertiary.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Stock bajo',
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textOnPrimary,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildStockInfo() {
    final color = widget.product.inStock ? AppColors.secondary : AppColors.error;

    return Row(
      children: [
        Icon(
          widget.product.inStock ? Icons.inventory : Icons.remove_shopping_cart,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          widget.product.inStock ? '${widget.product.stockCount} unidades' : 'Agotado',
          style: TextStyle(
            fontFamily: 'Lufga',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        AppButton(
          text: '',
          variant: AppButtonVariant.ghost,
          size: AppButtonSize.small,
          padding: const EdgeInsets.all(8),
          onPressed: () => _showQuickView(),
          leadingIcon: Icon(
            Icons.visibility,
            size: 16,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 4),
        AppButton(
          text: '',
          variant: AppButtonVariant.ghost,
          size: AppButtonSize.small,
          padding: const EdgeInsets.all(8),
          onPressed: () => _editProduct(),
          leadingIcon: Icon(
            Icons.edit,
            size: 16,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 4),
        AppButton(
          text: '',
          variant: AppButtonVariant.ghost,
          size: AppButtonSize.small,
          padding: const EdgeInsets.all(8),
          onPressed: () => _duplicateProduct(),
          leadingIcon: Icon(
            Icons.copy,
            size: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  void _handleCardTap(ProductsProvider provider) {
    if (provider.isSelectionMode) {
      provider.toggleProductSelection(widget.product.id);
    } else {
      _showQuickView();
    }
  }

  void _handleCardLongPress(ProductsProvider provider) {
    if (!provider.isSelectionMode) {
      provider.toggleSelectionMode();
      provider.toggleProductSelection(widget.product.id);
    }
  }

  void _showQuickView() {
    // Implementar vista rápida del producto
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Vista rápida: ${widget.product.name}')),
    );
  }

  void _editProduct() {
    final provider = Provider.of<ProductsProvider>(context, listen: false);
    provider.selectProduct(widget.product);

    showDialog(
      context: context,
      builder: (context) => _ProductFormDialog(product: widget.product),
    );
  }

  void _duplicateProduct() async {
    final provider = Provider.of<ProductsProvider>(context, listen: false);
    final success = await provider.duplicateProduct(widget.product.id);

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
}

/// Gradientes utilizados en las tarjetas
class AppGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFF2196F3),
      Color(0xFF1976D2),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [
      Color(0xFFF5F5F5),
      Color(0xFFE8E8E8),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Diálogo para crear/editar productos
class _ProductFormDialog extends StatelessWidget {
  final Product? product;

  const _ProductFormDialog({this.product});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(product == null ? 'Crear Producto' : 'Editar Producto'),
      content: const Text('Formulario de producto en desarrollo'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        AppButton(
          text: 'Guardar',
          variant: AppButtonVariant.primary,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}