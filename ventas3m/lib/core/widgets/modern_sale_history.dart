import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'app_card.dart';
import '../../models/sale.dart';

/// Widget para mostrar historial reciente de ventas
class ModernSaleHistory extends StatefulWidget {
  final List<Sale> sales;
  final int maxItems;
  final VoidCallback? onViewAll;
  final Function(Sale)? onSaleTap;
  final bool showCustomer;
  final bool showPaymentMethod;

  const ModernSaleHistory({
    super.key,
    required this.sales,
    this.maxItems = 5,
    this.onViewAll,
    this.onSaleTap,
    this.showCustomer = true,
    this.showPaymentMethod = true,
  });

  @override
  State<ModernSaleHistory> createState() => _ModernSaleHistoryState();
}

class _ModernSaleHistoryState extends State<ModernSaleHistory>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final displaySales = widget.sales.take(widget.maxItems).toList();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: AppCard(
        variant: AppCardVariant.elevated,
        elevation: AppCardElevation.level2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header del historial
            Row(
              children: [
                const Icon(
                  Icons.history,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Ventas Recientes',
                  style: TextStyle(
                    fontFamily: 'Lufga',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (widget.onViewAll != null)
                  TextButton(
                    onPressed: widget.onViewAll,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      textStyle: const TextStyle(
                        fontFamily: 'Lufga',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Ver Todas'),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Lista de ventas recientes
            if (displaySales.isEmpty)
              _buildEmptyHistoryState()
            else
              Column(
                children: displaySales.map((sale) {
                  return _buildSaleHistoryItem(sale);
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  /// Construye elemento del historial de ventas
  Widget _buildSaleHistoryItem(Sale sale) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        onTap: () => widget.onSaleTap?.call(sale),
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: [
            Row(
              children: [
                // Información principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Venta #${sale.invoiceNumber ?? sale.id.substring(0, 8)}',
                        style: const TextStyle(
                          fontFamily: 'Lufga',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDateTime(sale.createdAt),
                        style: const TextStyle(
                          fontFamily: 'Lufga',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Estado y total
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildStatusBadge(sale.status),
                    const SizedBox(height: 4),
                    Text(
                      '\$${sale.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontFamily: 'Lufga',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Información adicional
            Row(
              children: [
                // Número de artículos
                Row(
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      size: 16,
                      color: AppColors.textDisabled,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${sale.totalItems} artículos',
                      style: const TextStyle(
                        fontFamily: 'Lufga',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textDisabled,
                      ),
                    ),
                  ],
                ),

                if (widget.showCustomer && sale.hasCustomer) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 16,
                          color: AppColors.textDisabled,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            sale.customer!.name,
                            style: const TextStyle(
                              fontFamily: 'Lufga',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textDisabled,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (widget.showPaymentMethod) ...[
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getPaymentMethodColor(sale.paymentMethod.type).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      sale.paymentMethod.type.displayName,
                      style: TextStyle(
                        fontFamily: 'Lufga',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _getPaymentMethodColor(sale.paymentMethod.type),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Construye badge de estado
  Widget _buildStatusBadge(SaleStatus status) {
    final Color color = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontFamily: 'Lufga',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  /// Obtiene color según estado de venta
  Color _getStatusColor(SaleStatus status) {
    switch (status) {
      case SaleStatus.completed:
        return AppColors.secondary;
      case SaleStatus.pending:
        return AppColors.tertiary;
      case SaleStatus.processing:
        return AppColors.primary;
      case SaleStatus.cancelled:
        return AppColors.error;
      case SaleStatus.refunded:
        return AppColors.error;
    }
  }

  /// Obtiene color según método de pago
  Color _getPaymentMethodColor(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.cash:
        return AppColors.secondary;
      case PaymentMethodType.card:
        return AppColors.primary;
      case PaymentMethodType.transfer:
        return AppColors.products;
      case PaymentMethodType.check:
        return AppColors.tertiary;
      case PaymentMethodType.credit:
        return AppColors.error;
    }
  }

  /// Estado vacío del historial
  Widget _buildEmptyHistoryState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_outlined,
            size: 48,
            color: AppColors.textDisabled,
          ),
          const SizedBox(height: 16),
          Text(
            'Sin ventas recientes',
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Las ventas aparecerán aquí una vez procesadas',
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textDisabled,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Formatea fecha y hora
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'Hace ${difference.inMinutes} minutos';
      }
      return 'Hace ${difference.inHours} horas';
    } else if (difference.inDays == 1) {
      return 'Ayer ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}

/// Widget para estadísticas rápidas de ventas
class QuickSaleStats extends StatelessWidget {
  final List<Sale> sales;
  final int periodDays;

  const QuickSaleStats({
    super.key,
    required this.sales,
    this.periodDays = 7,
  });

  @override
  Widget build(BuildContext context) {
    final recentSales = sales.where((sale) {
      return sale.createdAt.isAfter(DateTime.now().subtract(Duration(days: periodDays)));
    }).toList();

    final totalSales = recentSales.length;
    final totalRevenue = recentSales.fold(0.0, (sum, sale) => sum + sale.total);
    final averageSale = totalSales > 0 ? totalRevenue / totalSales : 0.0;

    return AppCard(
      variant: AppCardVariant.elevated,
      elevation: AppCardElevation.level1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Últimos $periodDays días',
              style: const TextStyle(
                fontFamily: 'Lufga',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Ventas',
                    totalSales.toString(),
                    Icons.shopping_cart_outlined,
                    AppColors.primary,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Ingresos',
                    '\$${totalRevenue.toStringAsFixed(2)}',
                    Icons.attach_money,
                    AppColors.secondary,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Promedio',
                    '\$${averageSale.toStringAsFixed(2)}',
                    Icons.trending_up,
                    AppColors.products,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
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
          label,
          style: const TextStyle(
            fontFamily: 'Lufga',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Widget para acciones rápidas de venta
class QuickSaleActions extends StatelessWidget {
  final VoidCallback? onNewSale;
  final VoidCallback? onViewInventory;
  final VoidCallback? onViewReports;
  final VoidCallback? onSettings;

  const QuickSaleActions({
    super.key,
    this.onNewSale,
    this.onViewInventory,
    this.onViewReports,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.filled,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Acciones Rápidas',
              style: TextStyle(
                fontFamily: 'Lufga',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Nueva Venta',
                    Icons.add,
                    AppColors.primary,
                    onNewSale,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'Inventario',
                    Icons.inventory_2,
                    AppColors.products,
                    onViewInventory,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Reportes',
                    Icons.analytics,
                    AppColors.secondary,
                    onViewReports,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'Configuración',
                    Icons.settings,
                    AppColors.tertiary,
                    onSettings,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback? onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: color.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Lufga',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}