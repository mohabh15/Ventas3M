import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';

/// Controlador para el selector de cantidad moderno
class QuantitySelectorController extends ChangeNotifier {
  int _quantity;
  final int minQuantity;
  final int maxQuantity;

  QuantitySelectorController({
    int initialQuantity = 1,
    this.minQuantity = 1,
    this.maxQuantity = 999,
  }) : _quantity = initialQuantity.clamp(minQuantity, maxQuantity);

  int get quantity => _quantity;

  set quantity(int value) {
    final clampedValue = value.clamp(minQuantity, maxQuantity);
    if (_quantity != clampedValue) {
      _quantity = clampedValue;
      notifyListeners();
    }
  }

  void increment() {
    if (_quantity < maxQuantity) {
      _quantity++;
      notifyListeners();
    }
  }

  void decrement() {
    if (_quantity > minQuantity) {
      _quantity--;
      notifyListeners();
    }
  }

  bool get canIncrement => _quantity < maxQuantity;
  bool get canDecrement => _quantity > minQuantity;
}

/// Variantes del selector de cantidad
enum QuantitySelectorVariant {
  compact,      // Diseño compacto para espacios pequeños
  normal,       // Diseño estándar
  large,        // Diseño grande con mejor visibilidad
}

/// Estilos del selector de cantidad
enum QuantitySelectorStyle {
  outlined,     // Borde exterior
  filled,       // Fondo sólido
  minimal,      // Diseño minimalista
}

/// Selector de cantidad moderno con controles + y -
class ModernQuantitySelector extends StatefulWidget {
  final QuantitySelectorController? controller;
  final int initialQuantity;
  final int minQuantity;
  final int maxQuantity;
  final QuantitySelectorVariant variant;
  final QuantitySelectorStyle style;
  final double size;
  final EdgeInsetsGeometry? padding;
  final Function(int)? onChanged;
  final bool enabled;
  final bool showMinMaxButtons;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final Color? buttonColor;
  final Duration animationDuration;

  const ModernQuantitySelector({
    super.key,
    this.controller,
    this.initialQuantity = 1,
    this.minQuantity = 1,
    this.maxQuantity = 999,
    this.variant = QuantitySelectorVariant.normal,
    this.style = QuantitySelectorStyle.outlined,
    this.size = 40,
    this.padding,
    this.onChanged,
    this.enabled = true,
    this.showMinMaxButtons = true,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.buttonColor,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  State<ModernQuantitySelector> createState() => _ModernQuantitySelectorState();
}

class _ModernQuantitySelectorState extends State<ModernQuantitySelector>
    with TickerProviderStateMixin {
  late QuantitySelectorController _controller;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? QuantitySelectorController(
      initialQuantity: widget.initialQuantity,
      minQuantity: widget.minQuantity,
      maxQuantity: widget.maxQuantity,
    );

    _controller.addListener(_onQuantityChanged);

    _initializeAnimations();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _scaleController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  void _onQuantityChanged() {
    widget.onChanged?.call(_controller.quantity);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final responsivePadding = widget.padding ?? _getDefaultPadding();

    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _scaleAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: responsivePadding,
            decoration: _buildContainerDecoration(theme),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Botón decrementar
                if (widget.showMinMaxButtons) ...[
                  _buildQuantityButton(
                    onPressed: widget.enabled && _controller.canDecrement
                        ? () {
                            _scaleController.forward().then((_) {
                              _scaleController.reverse();
                              _controller.decrement();
                            });
                          }
                        : null,
                    icon: Icons.remove,
                    isEnabled: widget.enabled && _controller.canDecrement,
                  ),
                  SizedBox(width: _getSpacing()),
                ],

                // Campo de texto para cantidad
                _buildQuantityDisplay(),

                // Botón incrementar
                if (widget.showMinMaxButtons) ...[
                  SizedBox(width: _getSpacing()),
                  _buildQuantityButton(
                    onPressed: widget.enabled && _controller.canIncrement
                        ? () {
                            _scaleController.forward().then((_) {
                              _scaleController.reverse();
                              _controller.increment();
                            });
                          }
                        : null,
                    icon: Icons.add,
                    isEnabled: widget.enabled && _controller.canIncrement,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// Construye botón de incremento/decremento
  Widget _buildQuantityButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required bool isEnabled,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(_getButtonBorderRadius()),
        child: Container(
          width: _getButtonSize(),
          height: _getButtonSize(),
          decoration: BoxDecoration(
            color: isEnabled
                ? (widget.buttonColor ?? AppColors.primary.withValues(alpha: 0.1))
                : AppColors.disabled.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(_getButtonBorderRadius()),
          ),
          child: Icon(
            icon,
            size: _getIconSize(),
            color: isEnabled
                ? (widget.buttonColor ?? AppColors.primary)
                : AppColors.disabled,
          ),
        ),
      ),
    );
  }

  /// Construye display de cantidad
  Widget _buildQuantityDisplay() {
    return Container(
      width: _getDisplayWidth(),
      height: _getButtonSize(),
      decoration: BoxDecoration(
        color: widget.enabled
            ? (widget.backgroundColor ?? AppColors.surface)
            : AppColors.disabled.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(_getDisplayBorderRadius()),
        border: Border.all(
          color: widget.enabled
              ? (widget.borderColor ?? AppColors.border)
              : AppColors.disabled,
          width: 1,
        ),
      ),
      child: TextField(
        controller: TextEditingController(text: _controller.quantity.toString()),
        enabled: widget.enabled,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(3),
        ],
        style: TextStyle(
          fontFamily: 'Lufga',
          fontSize: _getFontSize(),
          fontWeight: FontWeight.w600,
          color: widget.enabled
              ? (widget.textColor ?? AppColors.textPrimary)
              : AppColors.disabled,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
        onChanged: (value) {
          final intValue = int.tryParse(value);
          if (intValue != null) {
            _controller.quantity = intValue;
          }
        },
        onSubmitted: (value) {
          final intValue = int.tryParse(value);
          if (intValue != null) {
            _controller.quantity = intValue;
          }
        },
      ),
    );
  }

  /// Construye decoración del contenedor
  BoxDecoration _buildContainerDecoration(ThemeData theme) {
    switch (widget.style) {
      case QuantitySelectorStyle.filled:
        return BoxDecoration(
          color: widget.enabled
              ? (widget.backgroundColor ?? AppColors.surface)
              : AppColors.disabled.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(_getContainerBorderRadius()),
          border: Border.all(
            color: widget.enabled
                ? (widget.borderColor ?? AppColors.border)
                : AppColors.disabled,
            width: 1,
          ),
        );

      case QuantitySelectorStyle.minimal:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(_getContainerBorderRadius()),
        );

      default:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(_getContainerBorderRadius()),
          border: Border.all(
            color: widget.enabled
                ? (widget.borderColor ?? AppColors.border)
                : AppColors.disabled,
            width: 1,
          ),
        );
    }
  }

  /// Obtiene tamaño del botón según variante
  double _getButtonSize() {
    switch (widget.variant) {
      case QuantitySelectorVariant.compact:
        return widget.size * 0.8;
      case QuantitySelectorVariant.large:
        return widget.size * 1.2;
      default:
        return widget.size;
    }
  }

  /// Obtiene tamaño del ícono según variante
  double _getIconSize() {
    switch (widget.variant) {
      case QuantitySelectorVariant.compact:
        return 16;
      case QuantitySelectorVariant.large:
        return 24;
      default:
        return 20;
    }
  }

  /// Obtiene tamaño de fuente según variante
  double _getFontSize() {
    switch (widget.variant) {
      case QuantitySelectorVariant.compact:
        return 12;
      case QuantitySelectorVariant.large:
        return 18;
      default:
        return 14;
    }
  }

  /// Obtiene ancho del display según variante
  double _getDisplayWidth() {
    switch (widget.variant) {
      case QuantitySelectorVariant.compact:
        return 40;
      case QuantitySelectorVariant.large:
        return 80;
      default:
        return 60;
    }
  }

  /// Obtiene espaciado según variante
  double _getSpacing() {
    switch (widget.variant) {
      case QuantitySelectorVariant.compact:
        return 4;
      case QuantitySelectorVariant.large:
        return 12;
      default:
        return 8;
    }
  }

  /// Obtiene border radius del botón según variante
  double _getButtonBorderRadius() {
    switch (widget.variant) {
      case QuantitySelectorVariant.compact:
        return 6;
      case QuantitySelectorVariant.large:
        return 10;
      default:
        return 8;
    }
  }

  /// Obtiene border radius del display según variante
  double _getDisplayBorderRadius() {
    switch (widget.variant) {
      case QuantitySelectorVariant.compact:
        return 6;
      case QuantitySelectorVariant.large:
        return 10;
      default:
        return 8;
    }
  }

  /// Obtiene border radius del contenedor según variante
  double _getContainerBorderRadius() {
    switch (widget.variant) {
      case QuantitySelectorVariant.compact:
        return 8;
      case QuantitySelectorVariant.large:
        return 16;
      default:
        return 12;
    }
  }

  /// Obtiene padding por defecto según variante
  EdgeInsetsGeometry _getDefaultPadding() {
    switch (widget.variant) {
      case QuantitySelectorVariant.compact:
        return const EdgeInsets.all(4);
      case QuantitySelectorVariant.large:
        return const EdgeInsets.all(12);
      default:
        return const EdgeInsets.all(8);
    }
  }
}

/// Selector de cantidad simplificado para listas
class SimpleQuantitySelector extends StatelessWidget {
  final int quantity;
  final Function(int) onChanged;
  final int minQuantity;
  final int maxQuantity;
  final bool enabled;
  final double size;

  const SimpleQuantitySelector({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.minQuantity = 1,
    this.maxQuantity = 999,
    this.enabled = true,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? AppColors.surface : AppColors.disabled.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: enabled ? AppColors.border : AppColors.disabled,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: enabled && quantity > minQuantity
                ? () => onChanged(quantity - 1)
                : null,
            icon: Icon(Icons.remove, size: size * 0.6),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tight(Size.square(size)),
          ),
          Container(
            width: size * 1.2,
            height: size,
            alignment: Alignment.center,
            child: Text(
              quantity.toString(),
              style: TextStyle(
                fontFamily: 'Lufga',
                fontSize: size * 0.4,
                fontWeight: FontWeight.w600,
                color: enabled ? AppColors.textPrimary : AppColors.disabled,
              ),
            ),
          ),
          IconButton(
            onPressed: enabled && quantity < maxQuantity
                ? () => onChanged(quantity + 1)
                : null,
            icon: Icon(Icons.add, size: size * 0.6),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tight(Size.square(size)),
          ),
        ],
      ),
    );
  }
}

/// Campo de precio moderno con formato automático
class ModernPriceField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final double? initialValue;
  final Function(double)? onChanged;
  final bool enabled;
  final bool showCurrencySymbol;
  final String currencySymbol;

  const ModernPriceField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.initialValue,
    this.onChanged,
    this.enabled = true,
    this.showCurrencySymbol = true,
    this.currencySymbol = '\$',
  });

  @override
  State<ModernPriceField> createState() => _ModernPriceFieldState();
}

class _ModernPriceFieldState extends State<ModernPriceField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(
      text: widget.initialValue?.toStringAsFixed(2) ?? '',
    );
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      enabled: widget.enabled,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.showCurrencySymbol
            ? Text(
                widget.currencySymbol,
                style: TextStyle(
                  fontFamily: 'Lufga',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(
          fontFamily: 'Lufga',
          color: AppColors.textSecondary,
          fontSize: 16,
        ),
        hintStyle: TextStyle(
          fontFamily: 'Lufga',
          color: AppColors.textDisabled,
          fontSize: 14,
        ),
      ),
      style: TextStyle(
        fontFamily: 'Lufga',
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      onChanged: (value) {
        final doubleValue = double.tryParse(value) ?? 0.0;
        widget.onChanged?.call(doubleValue);
      },
    );
  }
}

/// Selector de descuento moderno
class ModernDiscountSelector extends StatefulWidget {
  final double initialDiscount;
  final Function(double) onChanged;
  final bool enabled;
  final List<double> presetDiscounts;

  const ModernDiscountSelector({
    super.key,
    this.initialDiscount = 0.0,
    required this.onChanged,
    this.enabled = true,
    this.presetDiscounts = const [0, 5, 10, 15, 20, 25],
  });

  @override
  State<ModernDiscountSelector> createState() => _ModernDiscountSelectorState();
}

class _ModernDiscountSelectorState extends State<ModernDiscountSelector> {
  late double _discount;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _discount = widget.initialDiscount;
    _controller = TextEditingController(text: _discount.toStringAsFixed(1));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo de texto para descuento personalizado
        TextField(
          controller: _controller,
          enabled: widget.enabled,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          decoration: InputDecoration(
            labelText: 'Descuento (%)',
            hintText: '0.0',
            suffixText: '%',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: TextStyle(
            fontFamily: 'Lufga',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          onChanged: (value) {
            final doubleValue = double.tryParse(value) ?? 0.0;
            setState(() => _discount = doubleValue);
            widget.onChanged(doubleValue);
          },
        ),

        const SizedBox(height: 12),

        // Botones de descuento predefinido
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.presetDiscounts.map((discount) {
            final isSelected = (discount - _discount).abs() < 0.01;

            return ElevatedButton(
              onPressed: widget.enabled
                  ? () {
                      setState(() => _discount = discount);
                      _controller.text = discount.toStringAsFixed(1);
                      widget.onChanged(discount);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected
                    ? AppColors.primary
                    : AppColors.surface,
                foregroundColor: isSelected
                    ? AppColors.textOnPrimary
                    : AppColors.textPrimary,
                elevation: isSelected ? 2 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Text(
                '${discount.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontFamily: 'Lufga',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}