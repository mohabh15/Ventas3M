import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../utils/responsive_utils.dart';

/// Variantes modernas de tarjetas
enum AppCardVariant {
  filled,       // Tarjeta sólida con fondo
  outlined,     // Tarjeta con borde transparente
  elevated,     // Tarjeta elevada con sombras
  gradient,     // Tarjeta con gradiente
  interactive,  // Tarjeta interactiva con efectos hover
}

/// Tamaños de tarjeta
enum AppCardSize {
  small,        // Padding pequeño (8px-12px)
  medium,       // Padding medio (16px-20px)
  large,        // Padding grande (24px-32px)
  responsive,   // Se adapta al contexto
}

/// Sistema de elevación Material Design 3
enum AppCardElevation {
  level0,       // 0dp - Sin elevación
  level1,       // 1dp - Elevación mínima
  level2,       // 3dp - Elevación baja
  level3,       // 6dp - Elevación media
  level4,       // 8dp - Elevación alta
  level5,       // 12dp - Elevación máxima
}

/// Estados de la tarjeta
enum AppCardState {
  normal,
  hover,
  focus,
  pressed,
  disabled,
}

class AppCard extends StatefulWidget {
  final Widget child;
  final AppCardVariant variant;
  final AppCardSize size;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final AppCardElevation elevation;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;
  final bool enableHapticFeedback;
  final Duration animationDuration;
  final bool isDisabled;
  final Gradient? gradient;
  final Widget? leading;
  final Widget? trailing;
  final CrossAxisAlignment contentAlignment;

  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.filled,
    this.size = AppCardSize.medium,
    this.padding,
    this.margin,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.backgroundColor,
    this.borderColor,
    this.elevation = AppCardElevation.level1,
    this.borderRadius,
    this.boxShadow,
    this.enableHapticFeedback = true,
    this.animationDuration = const Duration(milliseconds: 200),
    this.isDisabled = false,
    this.gradient,
    this.leading,
    this.trailing,
    this.contentAlignment = CrossAxisAlignment.start,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _elevationController;
  late Animation<double> _scaleAnimation;

  AppCardState _currentState = AppCardState.normal;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _elevationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _elevationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

  }

  void _updateState(AppCardState newState) {
    if (_currentState != newState && !widget.isDisabled) {
      setState(() {
        _currentState = newState;
      });

      switch (newState) {
        case AppCardState.pressed:
          _scaleController.forward();
          _elevationController.reverse();
          break;
        case AppCardState.hover:
          _scaleController.reverse();
          _elevationController.forward();
          break;
        case AppCardState.focus:
          _elevationController.forward();
          break;
        case AppCardState.normal:
        case AppCardState.disabled:
          _scaleController.reverse();
          _elevationController.reverse();
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final responsiveBorderRadius = widget.borderRadius ?? _getResponsiveBorderRadius(context);
    final responsiveMargin = widget.margin ?? _getResponsiveMargin(context);

    return AnimatedBuilder(
      animation: Listenable.merge([_scaleController, _elevationController]),
      builder: (context, child) {
        return MouseRegion(
          onEnter: (_) => _updateState(AppCardState.hover),
          onExit: (_) => _updateState(AppCardState.normal),
          child: GestureDetector(
            onTapDown: (_) {
              if (!widget.isDisabled && widget.onTap != null) {
                _updateState(AppCardState.pressed);
              }
            },
            onTapUp: (_) {
              if (!widget.isDisabled && widget.onTap != null) {
                _updateState(AppCardState.hover);
              }
            },
            onTapCancel: () {
              _updateState(AppCardState.normal);
            },
            onTap: widget.isDisabled ? null : widget.onTap,
            onLongPress: widget.isDisabled ? null : widget.onLongPress,
            onDoubleTap: widget.isDisabled ? null : widget.onDoubleTap,
            child: Focus(
              onFocusChange: (hasFocus) {
                _updateState(hasFocus ? AppCardState.focus : AppCardState.normal);
              },
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  margin: responsiveMargin,
                  decoration: _buildBoxDecoration(theme, responsiveBorderRadius),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onTap,
                      borderRadius: BorderRadius.circular(responsiveBorderRadius),
                      splashColor: _getSplashColor(theme),
                      highlightColor: _getHighlightColor(theme),
                      child: Container(
                    padding: widget.padding ?? _getDefaultPadding(context),
                    child: _buildCardContent(),
                  ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardContent() {
    final children = <Widget>[];

    if (widget.leading != null) {
      children.add(widget.leading!);
    }

    if (widget.leading != null) {
      children.add(const SizedBox(height: 12));
    }

    children.add(widget.child);

    if (widget.trailing != null) {
      children.add(const SizedBox(height: 12));
    }

    if (widget.trailing != null) {
      children.add(widget.trailing!);
    }

    if (children.length > 1) {
      return Column(
        crossAxisAlignment: widget.contentAlignment,
        children: children,
      );
    }

    return widget.child;
  }

  BoxDecoration _buildBoxDecoration(ThemeData theme, double borderRadius) {
    final decoration = BoxDecoration(
      color: _getBackgroundColor(theme),
      borderRadius: BorderRadius.circular(borderRadius),
      border: _getBorder(theme),
      boxShadow: _getBoxShadow(theme),
      gradient: _getGradient(),
    );

    return decoration;
  }

  Color _getBackgroundColor(ThemeData theme) {
    if (widget.isDisabled) {
      return AppColors.disabled.withValues(alpha: 0.1);
    }

    if (widget.backgroundColor != null) {
      return widget.backgroundColor!;
    }

    switch (widget.variant) {
      case AppCardVariant.filled:
        return theme.cardTheme.color ?? AppColors.cardBackground;
      case AppCardVariant.outlined:
      case AppCardVariant.interactive:
        return Colors.transparent;
      case AppCardVariant.elevated:
        return theme.cardTheme.color ?? AppColors.cardBackground;
      case AppCardVariant.gradient:
        return Colors.transparent; // El gradiente se aplica por separado
    }
  }

  Border _getBorder(ThemeData theme) {
    if (widget.variant == AppCardVariant.gradient) {
      return Border.all(color: Colors.transparent);
    }

    final borderColor = widget.borderColor ?? _getBorderColor(theme);
    final borderWidth = _getBorderWidth();

    if (borderColor == Colors.transparent && borderWidth == 0) {
      return Border.all(width: 0, color: Colors.transparent);
    }

    return Border.all(
      color: borderColor,
      width: borderWidth,
    );
  }

  Color _getBorderColor(ThemeData theme) {
    if (widget.isDisabled) {
      return AppColors.disabled;
    }

    switch (_currentState) {
      case AppCardState.hover:
        return AppColors.primary.withValues(alpha: 0.5);
      case AppCardState.focus:
        return AppColors.focus;
      case AppCardState.pressed:
        return AppColors.primary;
      default:
        switch (widget.variant) {
          case AppCardVariant.outlined:
          case AppCardVariant.interactive:
            return AppColors.border;
          case AppCardVariant.filled:
          case AppCardVariant.elevated:
          case AppCardVariant.gradient:
            return Colors.transparent;
        }
    }
  }

  double _getBorderWidth() {
    switch (_currentState) {
      case AppCardState.hover:
      case AppCardState.focus:
        return 2;
      case AppCardState.pressed:
        return 1;
      default:
        switch (widget.variant) {
          case AppCardVariant.outlined:
          case AppCardVariant.interactive:
            return 1.5;
          case AppCardVariant.filled:
          case AppCardVariant.elevated:
          case AppCardVariant.gradient:
            return 0;
        }
    }
  }

  List<BoxShadow> _getBoxShadow(ThemeData theme) {
    if (widget.boxShadow != null) {
      return widget.boxShadow!;
    }

    if (widget.variant == AppCardVariant.gradient) {
      return _getGradientShadow();
    }

    final elevation = _getCurrentElevation();
    if (elevation <= 0) return [];

    return [
      BoxShadow(
        color: _getShadowColor(theme),
        blurRadius: elevation * 2,
        offset: Offset(0, elevation),
      ),
    ];
  }

  List<BoxShadow> _getGradientShadow() {
    switch (_currentState) {
      case AppCardState.hover:
        return [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ];
      case AppCardState.pressed:
        return [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ];
      default:
        return [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ];
    }
  }

  Color _getShadowColor(ThemeData theme) {
    if (widget.isDisabled) {
      return AppColors.shadow.withValues(alpha: 0.5);
    }

    switch (_currentState) {
      case AppCardState.hover:
        return AppColors.primary.withValues(alpha: 0.2);
      case AppCardState.focus:
        return AppColors.focus.withValues(alpha: 0.3);
      default:
        return AppColors.shadow;
    }
  }

  Gradient? _getGradient() {
    if (widget.variant != AppCardVariant.gradient) {
      return null;
    }

    if (widget.gradient != null) {
      return widget.gradient!;
    }

    if (widget.isDisabled) {
      return LinearGradient(
        colors: [
          AppColors.disabled.withValues(alpha: 0.1),
          AppColors.disabled.withValues(alpha: 0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    switch (_currentState) {
      case AppCardState.hover:
        return AppGradients.primaryGradient;
      case AppCardState.pressed:
        return LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.8),
            AppColors.secondary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return AppGradients.cardGradient;
    }
  }

  Color _getSplashColor(ThemeData theme) {
    if (widget.isDisabled) {
      return Colors.transparent;
    }

    switch (widget.variant) {
      case AppCardVariant.gradient:
        return Colors.white.withValues(alpha: 0.1);
      default:
        return AppColors.primary.withValues(alpha: 0.1);
    }
  }

  Color _getHighlightColor(ThemeData theme) {
    if (widget.isDisabled) {
      return Colors.transparent;
    }

    switch (widget.variant) {
      case AppCardVariant.gradient:
        return Colors.white.withValues(alpha: 0.05);
      default:
        return AppColors.primary.withValues(alpha: 0.05);
    }
  }

  double _getCurrentElevation() {
    if (widget.isDisabled) {
      return 0;
    }

    switch (_currentState) {
      case AppCardState.pressed:
        return _getPressedElevation();
      case AppCardState.hover:
        return _getHoverElevation();
      case AppCardState.focus:
        return _getFocusElevation();
      default:
        return _getBaseElevation();
    }
  }

  double _getBaseElevation() {
    switch (widget.elevation) {
      case AppCardElevation.level0:
        return 0;
      case AppCardElevation.level1:
        return 1;
      case AppCardElevation.level2:
        return 3;
      case AppCardElevation.level3:
        return 6;
      case AppCardElevation.level4:
        return 8;
      case AppCardElevation.level5:
        return 12;
    }
  }

  double _getHoverElevation() {
    switch (widget.elevation) {
      case AppCardElevation.level0:
        return 2;
      case AppCardElevation.level1:
        return 4;
      case AppCardElevation.level2:
        return 6;
      case AppCardElevation.level3:
        return 10;
      case AppCardElevation.level4:
        return 12;
      case AppCardElevation.level5:
        return 16;
    }
  }

  double _getFocusElevation() {
    switch (widget.elevation) {
      case AppCardElevation.level0:
        return 1;
      case AppCardElevation.level1:
        return 3;
      case AppCardElevation.level2:
        return 5;
      case AppCardElevation.level3:
        return 8;
      case AppCardElevation.level4:
        return 10;
      case AppCardElevation.level5:
        return 14;
    }
  }

  double _getPressedElevation() {
    switch (widget.elevation) {
      case AppCardElevation.level0:
        return 0;
      case AppCardElevation.level1:
        return 1;
      case AppCardElevation.level2:
        return 2;
      case AppCardElevation.level3:
        return 3;
      case AppCardElevation.level4:
        return 4;
      case AppCardElevation.level5:
        return 6;
    }
  }

  double _getResponsiveBorderRadius(BuildContext context) {
    switch (widget.size) {
      case AppCardSize.small:
        return 8;
      case AppCardSize.medium:
        return 12;
      case AppCardSize.large:
        return 16;
      case AppCardSize.responsive:
        return ResponsiveUtils.getResponsiveBorderRadius(context);
    }
  }

  EdgeInsetsGeometry _getResponsiveMargin(BuildContext context) {
    return EdgeInsets.all(ResponsiveUtils.getResponsiveMargin(context));
  }

  EdgeInsetsGeometry _getDefaultPadding(BuildContext context) {
    switch (widget.size) {
      case AppCardSize.small:
        return const EdgeInsets.all(12);
      case AppCardSize.medium:
        return const EdgeInsets.all(16);
      case AppCardSize.large:
        return const EdgeInsets.all(24);
      case AppCardSize.responsive:
        return ResponsiveUtils.getResponsivePadding(context);
    }
  }
}

/// Tarjeta especializada para métricas importantes
class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final Widget? icon;
  final Color? valueColor;
  final bool showTrend;
  final double? trendValue;
  final AppCardVariant variant;
  final AppCardSize size;
  final AppCardElevation elevation;
  final VoidCallback? onTap;
  final bool isDisabled;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.valueColor,
    this.showTrend = false,
    this.trendValue,
    this.variant = AppCardVariant.elevated,
    this.size = AppCardSize.medium,
    this.elevation = AppCardElevation.level2,
    this.onTap,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: variant,
      size: size,
      elevation: elevation,
      onTap: onTap,
      isDisabled: isDisabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Lufga',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              if (showTrend && trendValue != null) _buildTrendIndicator(trendValue!),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.primary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                fontFamily: 'Lufga',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.textDisabled,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Widget _buildTrendIndicator(double? trendValue) {
    if (trendValue == null) return const SizedBox.shrink();

    final isPositive = trendValue > 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isPositive ? Icons.trending_up : Icons.trending_down,
          size: 16,
          color: isPositive ? AppColors.secondary : AppColors.error,
        ),
        const SizedBox(width: 4),
        Text(
          '${isPositive ? '+' : ''}${trendValue.abs().toStringAsFixed(1)}%',
          style: TextStyle(
            fontFamily: 'Lufga',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isPositive ? AppColors.secondary : AppColors.error,
          ),
        ),
      ],
    );
  }
}

/// Estados de venta
enum SalesStatus {
  completed,
  pending,
  cancelled,
}

/// Tarjeta especializada para información de ventas
class SalesCard extends StatelessWidget {
  final String title;
  final String amount;
  final String? description;
  final int itemCount;
  final DateTime date;
  final SalesStatus status;
  final VoidCallback? onTap;
  final bool isDisabled;

  const SalesCard({
    super.key,
    required this.title,
    required this.amount,
    this.description,
    required this.itemCount,
    required this.date,
    required this.status,
    this.onTap,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.filled,
      size: AppCardSize.medium,
      elevation: AppCardElevation.level1,
      onTap: onTap,
      isDisabled: isDisabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Lufga',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _buildStatusBadge(status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.sales,
            ),
          ),
          if (description != null) ...[
            const SizedBox(height: 4),
            Text(
              description!,
              style: TextStyle(
                fontFamily: 'Lufga',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 16,
                color: AppColors.textDisabled,
              ),
              const SizedBox(width: 4),
              Text(
                '$itemCount artículos',
                style: TextStyle(
                  fontFamily: 'Lufga',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textDisabled,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: AppColors.textDisabled,
              ),
              const SizedBox(width: 4),
              Text(
                _formatDate(date),
                style: TextStyle(
                  fontFamily: 'Lufga',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textDisabled,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildStatusBadge(SalesStatus status) {
    final Color color;
    switch (status) {
      case SalesStatus.completed:
        color = AppColors.secondary;
        break;
      case SalesStatus.pending:
        color = AppColors.tertiary;
        break;
      case SalesStatus.cancelled:
        color = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        _getStatusText(status),
        style: TextStyle(
          fontFamily: 'Lufga',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  static String _getStatusText(SalesStatus status) {
    switch (status) {
      case SalesStatus.completed:
        return 'Completada';
      case SalesStatus.pending:
        return 'Pendiente';
      case SalesStatus.cancelled:
        return 'Cancelada';
    }
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

/// Tarjeta especializada para productos
class ProductCard extends StatelessWidget {
  final String name;
  final String? description;
  final String price;
  final String? originalPrice;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final bool inStock;
  final int stockCount;
  final List<String> tags;
  final VoidCallback? onTap;
  final bool isDisabled;

  const ProductCard({
    super.key,
    required this.name,
    this.description,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.inStock = true,
    this.stockCount = 0,
    this.tags = const [],
    this.onTap,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.elevated,
      size: AppCardSize.medium,
      elevation: AppCardElevation.level1,
      onTap: onTap,
      isDisabled: isDisabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del producto
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Información del producto
          Text(
            name,
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          if (description != null) ...[
            const SizedBox(height: 4),
            Text(
              description!,
              style: TextStyle(
                fontFamily: 'Lufga',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 8),

          // Precio
          Row(
            children: [
              Text(
                price,
                style: TextStyle(
                  fontFamily: 'Lufga',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              if (originalPrice != null) ...[
                const SizedBox(width: 8),
                Text(
                  originalPrice!,
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

          // Rating y stock
          Row(
            children: [
              if (rating > 0) ...[
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontFamily: 'Lufga',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (reviewCount > 0) ...[
                      const SizedBox(width: 4),
                      Text(
                        '($reviewCount)',
                        style: TextStyle(
                          fontFamily: 'Lufga',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textDisabled,
                        ),
                      ),
                    ],
                  ],
                ),
                const Spacer(),
              ],

              // Estado de stock
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: inStock ? AppColors.secondary.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  inStock ? 'En stock' : 'Agotado',
                  style: TextStyle(
                    fontFamily: 'Lufga',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: inStock ? AppColors.secondary : AppColors.error,
                  ),
                ),
              ),
            ],
          ),

          if (tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: tags.take(3).map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontFamily: 'Lufga',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

/// Contenedor para gráficos y análisis
class ChartContainer extends StatelessWidget {
  final String title;
  final Widget chart;
  final List<Widget>? actions;
  final bool showLegend;
  final EdgeInsetsGeometry? chartPadding;
  final AppCardVariant variant;
  final AppCardSize size;
  final AppCardElevation elevation;
  final VoidCallback? onTap;
  final bool isDisabled;

  const ChartContainer({
    super.key,
    required this.title,
    required this.chart,
    this.actions,
    this.showLegend = false,
    this.chartPadding,
    this.variant = AppCardVariant.filled,
    this.size = AppCardSize.large,
    this.elevation = AppCardElevation.level1,
    this.onTap,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: variant,
      size: size,
      elevation: elevation,
      onTap: onTap,
      isDisabled: isDisabled,
      leading: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Lufga',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (actions != null) ...actions!,
        ],
      ),
      child: Container(
        padding: chartPadding ?? const EdgeInsets.all(16),
        child: chart,
      ),
    );
  }
}