/// Estado vacío para productos
part of '../products_screen.dart';

class EmptyProductsState extends StatelessWidget {
  final bool hasActiveFilters;
  final VoidCallback onClearFilters;
  final VoidCallback onCreateProduct;

  const EmptyProductsState({
    super.key,
    required this.hasActiveFilters,
    required this.onClearFilters,
    required this.onCreateProduct,
  });

  @override
  Widget build(BuildContext context) {
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
              onPressed: onClearFilters,
            )
          else
            AppButton(
              text: 'Crear producto',
              onPressed: onCreateProduct,
            ),
        ],
      ),
    );
  }
}