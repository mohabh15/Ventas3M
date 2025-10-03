import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../utils/responsive_utils.dart';

/// Variantes modernas del botón
enum AppButtonVariant {
  primary,      // Botón principal con fondo sólido
  secondary,    // Botón secundario con fondo sutil
  outline,      // Botón con borde y fondo transparente
  ghost,        // Botón transparente solo con texto
  gradient,     // Botón con gradiente
}

/// Tamaños del botón
enum AppButtonSize {
  small,        // 32px altura
  medium,       // 40px altura
  large,        // 48px altura
  responsive,   // Se adapta al contexto
}

/// Estados del botón
enum AppButtonState {
  normal,
  hover,
  focus,
  pressed,
  disabled,
  loading,
}

class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final bool enableHapticFeedback;
  final Duration animationDuration;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.leadingIcon,
    this.trailingIcon,
    this.width,
    this.padding,
    this.enableHapticFeedback = true,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _iconController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _iconRotationAnimation;

  AppButtonState _currentState = AppButtonState.normal;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _iconController = AnimationController(
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

    _iconRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.easeInOut,
    ));
  }

  void _updateState(AppButtonState newState) {
    if (_currentState != newState) {
      setState(() {
        _currentState = newState;
      });

      switch (newState) {
        case AppButtonState.pressed:
          _scaleController.forward();
          break;
        case AppButtonState.hover:
          _scaleController.reverse();
          break;
        case AppButtonState.loading:
          _iconController.repeat(reverse: true);
          break;
        case AppButtonState.normal:
        case AppButtonState.focus:
        case AppButtonState.disabled:
          _scaleController.reverse();
          _iconController.stop();
          _iconController.value = 0.0;
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isButtonDisabled = widget.isDisabled || widget.onPressed == null;

    return MouseRegion(
      onEnter: (_) => _updateState(AppButtonState.hover),
      onExit: (_) => _updateState(AppButtonState.normal),
      child: GestureDetector(
        onTapDown: (_) {
          if (!isButtonDisabled && !widget.isLoading) {
            _updateState(AppButtonState.pressed);
          }
        },
        onTapUp: (_) {
          if (!isButtonDisabled && !widget.isLoading) {
            _updateState(AppButtonState.hover);
          }
        },
        onTapCancel: () {
          _updateState(AppButtonState.normal);
        },
        child: Focus(
          onFocusChange: (hasFocus) {
            _updateState(hasFocus ? AppButtonState.focus : AppButtonState.normal);
          },
          child: AnimatedBuilder(
            animation: Listenable.merge([_scaleController, _iconController]),
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: SizedBox(
                  width: widget.width,
                  height: _getHeight(),
                  child: _buildButton(theme, isButtonDisabled),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildButton(ThemeData theme, bool isDisabled) {
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return _ModernElevatedButton(
          text: widget.text,
          onPressed: isDisabled || widget.isLoading ? null : widget.onPressed,
          size: widget.size,
          isLoading: widget.isLoading,
          leadingIcon: widget.leadingIcon,
          trailingIcon: widget.trailingIcon,
          padding: widget.padding,
          state: _currentState,
          iconAnimation: _iconRotationAnimation,
        );

      case AppButtonVariant.secondary:
        return _ModernSecondaryButton(
          text: widget.text,
          onPressed: isDisabled || widget.isLoading ? null : widget.onPressed,
          size: widget.size,
          isLoading: widget.isLoading,
          leadingIcon: widget.leadingIcon,
          trailingIcon: widget.trailingIcon,
          padding: widget.padding,
          state: _currentState,
          iconAnimation: _iconRotationAnimation,
        );

      case AppButtonVariant.outline:
        return _ModernOutlineButton(
          text: widget.text,
          onPressed: isDisabled || widget.isLoading ? null : widget.onPressed,
          size: widget.size,
          isLoading: widget.isLoading,
          leadingIcon: widget.leadingIcon,
          trailingIcon: widget.trailingIcon,
          padding: widget.padding,
          state: _currentState,
          iconAnimation: _iconRotationAnimation,
        );

      case AppButtonVariant.ghost:
        return _ModernGhostButton(
          text: widget.text,
          onPressed: isDisabled || widget.isLoading ? null : widget.onPressed,
          size: widget.size,
          isLoading: widget.isLoading,
          leadingIcon: widget.leadingIcon,
          trailingIcon: widget.trailingIcon,
          padding: widget.padding,
          state: _currentState,
          iconAnimation: _iconRotationAnimation,
        );

      case AppButtonVariant.gradient:
        return _ModernGradientButton(
          text: widget.text,
          onPressed: isDisabled || widget.isLoading ? null : widget.onPressed,
          size: widget.size,
          isLoading: widget.isLoading,
          leadingIcon: widget.leadingIcon,
          trailingIcon: widget.trailingIcon,
          padding: widget.padding,
          state: _currentState,
          iconAnimation: _iconRotationAnimation,
        );
    }
  }

  double _getHeight() {
    switch (widget.size) {
      case AppButtonSize.small:
        return ResponsiveUtils.getResponsiveTouchTargetSize(context) - 4;
      case AppButtonSize.medium:
        return ResponsiveUtils.getResponsiveButtonHeight(context);
      case AppButtonSize.large:
        return ResponsiveUtils.getResponsiveButtonHeight(context) + 8;
      case AppButtonSize.responsive:
        return ResponsiveUtils.getResponsiveButtonHeight(context);
    }
  }
}

/// Botón primario moderno con elevación y sombras suaves
class _ModernElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonSize size;
  final bool isLoading;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final EdgeInsetsGeometry? padding;
  final AppButtonState state;
  final Animation<double> iconAnimation;

  const _ModernElevatedButton({
    required this.text,
    required this.onPressed,
    required this.size,
    required this.isLoading,
    required this.leadingIcon,
    required this.trailingIcon,
    required this.padding,
    required this.state,
    required this.iconAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final elevation = _getElevation();
    final shadowColor = _getShadowColor(theme);

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _getBackgroundColor(theme),
        foregroundColor: _getForegroundColor(theme),
        elevation: elevation,
        shadowColor: shadowColor,
        surfaceTintColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_getBorderRadius()),
        ),
        padding: padding ?? EdgeInsets.symmetric(
          horizontal: _getHorizontalPadding(),
          vertical: _getVerticalPadding(),
        ),
      ).copyWith(
        overlayColor: WidgetStateProperty.all(_getOverlayColor(theme)),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            AppColors.textOnPrimary,
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null) ...[
          AnimatedBuilder(
            animation: iconAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: iconAnimation.value * 2 * 3.14159,
                child: leadingIcon!,
              );
            },
          ),
          SizedBox(width: _getIconSpacing()),
        ],
        Text(
          text,
          style: _getTextStyle(),
        ),
        if (trailingIcon != null) ...[
          SizedBox(width: _getIconSpacing()),
          AnimatedBuilder(
            animation: iconAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: iconAnimation.value * 2 * 3.14159,
                child: trailingIcon!,
              );
            },
          ),
        ],
      ],
    );
  }

  double _getElevation() {
    switch (state) {
      case AppButtonState.pressed:
        return 2;
      case AppButtonState.hover:
        return 8;
      case AppButtonState.focus:
        return 6;
      case AppButtonState.disabled:
      case AppButtonState.loading:
        return 0;
      default:
        return 4;
    }
  }

  Color _getShadowColor(ThemeData theme) {
    switch (state) {
      case AppButtonState.hover:
        return AppColors.primary.withValues(alpha: 0.3);
      case AppButtonState.focus:
        return AppColors.focus.withValues(alpha: 0.3);
      default:
        return AppColors.shadow;
    }
  }

  Color _getBackgroundColor(ThemeData theme) {
    if (state == AppButtonState.disabled || state == AppButtonState.loading) {
      return AppColors.disabled;
    }
    return AppColors.primary;
  }

  Color _getForegroundColor(ThemeData theme) {
    if (state == AppButtonState.disabled || state == AppButtonState.loading) {
      return AppColors.textDisabled;
    }
    return AppColors.textOnPrimary;
  }

  Color _getOverlayColor(ThemeData theme) {
    switch (state) {
      case AppButtonState.hover:
        return AppColors.hover.withValues(alpha: 0.1);
      case AppButtonState.focus:
        return AppColors.focus.withValues(alpha: 0.1);
      case AppButtonState.pressed:
        return AppColors.primary.withValues(alpha: 0.2);
      default:
        return Colors.transparent;
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case AppButtonSize.small:
        return 6;
      case AppButtonSize.medium:
        return 8;
      case AppButtonSize.large:
        return 12;
      case AppButtonSize.responsive:
        return 10;
    }
  }

  double _getHorizontalPadding() {
    switch (size) {
      case AppButtonSize.small:
        return 12;
      case AppButtonSize.medium:
        return 16;
      case AppButtonSize.large:
        return 20;
      case AppButtonSize.responsive:
        return 18;
    }
  }

  double _getVerticalPadding() {
    switch (size) {
      case AppButtonSize.small:
        return 6;
      case AppButtonSize.medium:
        return 10;
      case AppButtonSize.large:
        return 12;
      case AppButtonSize.responsive:
        return 11;
    }
  }

  double _getIconSpacing() {
    switch (size) {
      case AppButtonSize.small:
        return 6;
      case AppButtonSize.medium:
        return 8;
      case AppButtonSize.large:
        return 10;
      case AppButtonSize.responsive:
        return 8;
    }
  }

  TextStyle _getTextStyle() {
    final baseStyle = TextStyle(
      fontFamily: 'Lufga',
      fontWeight: FontWeight.w600,
      letterSpacing: 0.02,
    );

    switch (size) {
      case AppButtonSize.small:
        return baseStyle.copyWith(fontSize: 12);
      case AppButtonSize.medium:
        return baseStyle.copyWith(fontSize: 14);
      case AppButtonSize.large:
        return baseStyle.copyWith(fontSize: 16);
      case AppButtonSize.responsive:
        return baseStyle.copyWith(fontSize: 15);
    }
  }
}

/// Botón secundario moderno
class _ModernSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonSize size;
  final bool isLoading;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final EdgeInsetsGeometry? padding;
  final AppButtonState state;
  final Animation<double> iconAnimation;

  const _ModernSecondaryButton({
    required this.text,
    required this.onPressed,
    required this.size,
    required this.isLoading,
    required this.leadingIcon,
    required this.trailingIcon,
    required this.padding,
    required this.state,
    required this.iconAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: _getBackgroundColor(theme),
        foregroundColor: _getForegroundColor(theme),
        elevation: _getElevation(),
        shadowColor: _getShadowColor(theme),
        surfaceTintColor: AppColors.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_getBorderRadius()),
        ),
        padding: padding ?? EdgeInsets.symmetric(
          horizontal: _getHorizontalPadding(),
          vertical: _getVerticalPadding(),
        ),
      ).copyWith(
        overlayColor: WidgetStateProperty.all(_getOverlayColor(theme)),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            AppColors.secondary,
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null) ...[
          AnimatedBuilder(
            animation: iconAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: iconAnimation.value * 2 * 3.14159,
                child: leadingIcon!,
              );
            },
          ),
          SizedBox(width: _getIconSpacing()),
        ],
        Text(
          text,
          style: _getTextStyle(),
        ),
        if (trailingIcon != null) ...[
          SizedBox(width: _getIconSpacing()),
          AnimatedBuilder(
            animation: iconAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: iconAnimation.value * 2 * 3.14159,
                child: trailingIcon!,
              );
            },
          ),
        ],
      ],
    );
  }

  double _getElevation() {
    switch (state) {
      case AppButtonState.pressed:
        return 1;
      case AppButtonState.hover:
        return 4;
      case AppButtonState.focus:
        return 3;
      default:
        return 0;
    }
  }

  Color _getShadowColor(ThemeData theme) {
    switch (state) {
      case AppButtonState.hover:
        return AppColors.secondary.withValues(alpha: 0.2);
      case AppButtonState.focus:
        return AppColors.focus.withValues(alpha: 0.2);
      default:
        return AppColors.shadow;
    }
  }

  Color _getBackgroundColor(ThemeData theme) {
    if (state == AppButtonState.disabled || state == AppButtonState.loading) {
      return Colors.transparent;
    }

    switch (state) {
      case AppButtonState.hover:
        return AppColors.hover;
      case AppButtonState.focus:
        return AppColors.focus.withValues(alpha: 0.05);
      case AppButtonState.pressed:
        return AppColors.secondary.withValues(alpha: 0.1);
      default:
        return Colors.transparent;
    }
  }

  Color _getForegroundColor(ThemeData theme) {
    if (state == AppButtonState.disabled || state == AppButtonState.loading) {
      return AppColors.textDisabled;
    }
    return AppColors.secondary;
  }

  Color _getOverlayColor(ThemeData theme) {
    switch (state) {
      case AppButtonState.hover:
        return AppColors.secondary.withValues(alpha: 0.1);
      case AppButtonState.focus:
        return AppColors.focus.withValues(alpha: 0.1);
      case AppButtonState.pressed:
        return AppColors.secondary.withValues(alpha: 0.2);
      default:
        return Colors.transparent;
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case AppButtonSize.small:
        return 6;
      case AppButtonSize.medium:
        return 8;
      case AppButtonSize.large:
        return 12;
      case AppButtonSize.responsive:
        return 10;
    }
  }

  double _getHorizontalPadding() {
    switch (size) {
      case AppButtonSize.small:
        return 12;
      case AppButtonSize.medium:
        return 16;
      case AppButtonSize.large:
        return 20;
      case AppButtonSize.responsive:
        return 18;
    }
  }

  double _getVerticalPadding() {
    switch (size) {
      case AppButtonSize.small:
        return 6;
      case AppButtonSize.medium:
        return 10;
      case AppButtonSize.large:
        return 12;
      case AppButtonSize.responsive:
        return 11;
    }
  }

  double _getIconSpacing() {
    switch (size) {
      case AppButtonSize.small:
        return 6;
      case AppButtonSize.medium:
        return 8;
      case AppButtonSize.large:
        return 10;
      case AppButtonSize.responsive:
        return 8;
    }
  }

  TextStyle _getTextStyle() {
    final baseStyle = TextStyle(
      fontFamily: 'Lufga',
      fontWeight: FontWeight.w600,
      letterSpacing: 0.02,
    );

    switch (size) {
      case AppButtonSize.small:
        return baseStyle.copyWith(fontSize: 12);
      case AppButtonSize.medium:
        return baseStyle.copyWith(fontSize: 14);
      case AppButtonSize.large:
        return baseStyle.copyWith(fontSize: 16);
      case AppButtonSize.responsive:
        return baseStyle.copyWith(fontSize: 15);
    }
  }
}

/// Botón outline moderno
class _ModernOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonSize size;
  final bool isLoading;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final EdgeInsetsGeometry? padding;
  final AppButtonState state;
  final Animation<double> iconAnimation;

  const _ModernOutlineButton({
    required this.text,
    required this.onPressed,
    required this.size,
    required this.isLoading,
    required this.leadingIcon,
    required this.trailingIcon,
    required this.padding,
    required this.state,
    required this.iconAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: _getBackgroundColor(theme),
        foregroundColor: _getForegroundColor(theme),
        side: BorderSide(
          color: _getBorderColor(theme),
          width: _getBorderWidth(),
        ),
        elevation: _getElevation(),
        shadowColor: _getShadowColor(theme),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_getBorderRadius()),
        ),
        padding: padding ?? EdgeInsets.symmetric(
          horizontal: _getHorizontalPadding(),
          vertical: _getVerticalPadding(),
        ),
      ).copyWith(
        overlayColor: WidgetStateProperty.all(_getOverlayColor(theme)),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            AppColors.primary,
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null) ...[
          AnimatedBuilder(
            animation: iconAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: iconAnimation.value * 2 * 3.14159,
                child: leadingIcon!,
              );
            },
          ),
          SizedBox(width: _getIconSpacing()),
        ],
        Text(
          text,
          style: _getTextStyle(),
        ),
        if (trailingIcon != null) ...[
          SizedBox(width: _getIconSpacing()),
          AnimatedBuilder(
            animation: iconAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: iconAnimation.value * 2 * 3.14159,
                child: trailingIcon!,
              );
            },
          ),
        ],
      ],
    );
  }

  double _getElevation() {
    switch (state) {
      case AppButtonState.pressed:
        return 1;
      case AppButtonState.hover:
        return 4;
      case AppButtonState.focus:
        return 3;
      default:
        return 0;
    }
  }

  Color _getShadowColor(ThemeData theme) {
    switch (state) {
      case AppButtonState.hover:
        return AppColors.primary.withValues(alpha: 0.2);
      case AppButtonState.focus:
        return AppColors.focus.withValues(alpha: 0.2);
      default:
        return AppColors.shadow;
    }
  }

  Color _getBackgroundColor(ThemeData theme) {
    if (state == AppButtonState.disabled || state == AppButtonState.loading) {
      return Colors.transparent;
    }

    switch (state) {
      case AppButtonState.hover:
        return AppColors.hover;
      case AppButtonState.focus:
        return AppColors.focus.withValues(alpha: 0.05);
      case AppButtonState.pressed:
        return AppColors.primary.withValues(alpha: 0.05);
      default:
        return Colors.transparent;
    }
  }

  Color _getForegroundColor(ThemeData theme) {
    if (state == AppButtonState.disabled || state == AppButtonState.loading) {
      return AppColors.textDisabled;
    }
    return AppColors.primary;
  }

  Color _getBorderColor(ThemeData theme) {
    if (state == AppButtonState.disabled || state == AppButtonState.loading) {
      return AppColors.disabled;
    }

    switch (state) {
      case AppButtonState.hover:
        return AppColors.primary;
      case AppButtonState.focus:
        return AppColors.focus;
      case AppButtonState.pressed:
        return AppColors.primary;
      default:
        return AppColors.border;
    }
  }

  double _getBorderWidth() {
    switch (state) {
      case AppButtonState.hover:
      case AppButtonState.focus:
      case AppButtonState.pressed:
        return 2;
      default:
        return 1.5;
    }
  }

  Color _getOverlayColor(ThemeData theme) {
    switch (state) {
      case AppButtonState.hover:
        return AppColors.primary.withValues(alpha: 0.1);
      case AppButtonState.focus:
        return AppColors.focus.withValues(alpha: 0.1);
      case AppButtonState.pressed:
        return AppColors.primary.withValues(alpha: 0.15);
      default:
        return Colors.transparent;
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case AppButtonSize.small:
        return 6;
      case AppButtonSize.medium:
        return 8;
      case AppButtonSize.large:
        return 12;
      case AppButtonSize.responsive:
        return 10;
    }
  }

  double _getHorizontalPadding() {
    switch (size) {
      case AppButtonSize.small:
        return 12;
      case AppButtonSize.medium:
        return 16;
      case AppButtonSize.large:
        return 20;
      case AppButtonSize.responsive:
        return 18;
    }
  }

  double _getVerticalPadding() {
    switch (size) {
      case AppButtonSize.small:
        return 6;
      case AppButtonSize.medium:
        return 10;
      case AppButtonSize.large:
        return 12;
      case AppButtonSize.responsive:
        return 11;
    }
  }

  double _getIconSpacing() {
    switch (size) {
      case AppButtonSize.small:
        return 6;
      case AppButtonSize.medium:
        return 8;
      case AppButtonSize.large:
        return 10;
      case AppButtonSize.responsive:
        return 8;
    }
  }

  TextStyle _getTextStyle() {
    final baseStyle = TextStyle(
      fontFamily: 'Lufga',
      fontWeight: FontWeight.w600,
      letterSpacing: 0.02,
    );

    switch (size) {
      case AppButtonSize.small:
        return baseStyle.copyWith(fontSize: 12);
      case AppButtonSize.medium:
        return baseStyle.copyWith(fontSize: 14);
      case AppButtonSize.large:
        return baseStyle.copyWith(fontSize: 16);
      case AppButtonSize.responsive:
        return baseStyle.copyWith(fontSize: 15);
    }
  }
}

/// Botón ghost moderno (transparente)
class _ModernGhostButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonSize size;
  final bool isLoading;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final EdgeInsetsGeometry? padding;
  final AppButtonState state;
  final Animation<double> iconAnimation;

  const _ModernGhostButton({
    required this.text,
    required this.onPressed,
    required this.size,
    required this.isLoading,
    required this.leadingIcon,
    required this.trailingIcon,
    required this.padding,
    required this.state,
    required this.iconAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: _getBackgroundColor(theme),
        foregroundColor: _getForegroundColor(theme),
        elevation: _getElevation(),
        shadowColor: _getShadowColor(theme),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_getBorderRadius()),
        ),
        padding: padding ?? EdgeInsets.symmetric(
          horizontal: _getHorizontalPadding(),
          vertical: _getVerticalPadding(),
        ),
      ).copyWith(
        overlayColor: WidgetStateProperty.all(_getOverlayColor(theme)),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            AppColors.primary,
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null) ...[
          AnimatedBuilder(
            animation: iconAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: iconAnimation.value * 2 * 3.14159,
                child: leadingIcon!,
              );
            },
          ),
          SizedBox(width: _getIconSpacing()),
        ],
        Text(
          text,
          style: _getTextStyle(),
        ),
        if (trailingIcon != null) ...[
          SizedBox(width: _getIconSpacing()),
          AnimatedBuilder(
            animation: iconAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: iconAnimation.value * 2 * 3.14159,
                child: trailingIcon!,
              );
            },
          ),
        ],
      ],
    );
  }

  double _getElevation() {
    switch (state) {
      case AppButtonState.pressed:
        return 1;
      case AppButtonState.hover:
        return 2;
      case AppButtonState.focus:
        return 2;
      default:
        return 0;
    }
  }

  Color _getShadowColor(ThemeData theme) {
    switch (state) {
      case AppButtonState.hover:
        return AppColors.primary.withValues(alpha: 0.2);
      case AppButtonState.focus:
        return AppColors.focus.withValues(alpha: 0.2);
      default:
        return AppColors.shadow;
    }
  }

  Color _getBackgroundColor(ThemeData theme) {
    if (state == AppButtonState.disabled || state == AppButtonState.loading) {
      return Colors.transparent;
    }

    switch (state) {
      case AppButtonState.hover:
        return AppColors.hover;
      case AppButtonState.focus:
        return AppColors.focus.withValues(alpha: 0.05);
      case AppButtonState.pressed:
        return AppColors.primary.withValues(alpha: 0.05);
      default:
        return Colors.transparent;
    }
  }

  Color _getForegroundColor(ThemeData theme) {
    if (state == AppButtonState.disabled || state == AppButtonState.loading) {
      return AppColors.textDisabled;
    }
    return AppColors.primary;
  }

  Color _getOverlayColor(ThemeData theme) {
    switch (state) {
      case AppButtonState.hover:
        return AppColors.primary.withValues(alpha: 0.1);
      case AppButtonState.focus:
        return AppColors.focus.withValues(alpha: 0.1);
      case AppButtonState.pressed:
        return AppColors.primary.withValues(alpha: 0.15);
      default:
        return Colors.transparent;
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case AppButtonSize.small:
        return 6;
      case AppButtonSize.medium:
        return 8;
      case AppButtonSize.large:
        return 12;
      case AppButtonSize.responsive:
        return 10;
    }
  }

  double _getHorizontalPadding() {
    switch (size) {
      case AppButtonSize.small:
        return 8;
      case AppButtonSize.medium:
        return 12;
      case AppButtonSize.large:
        return 16;
      case AppButtonSize.responsive:
        return 14;
    }
  }

  double _getVerticalPadding() {
    switch (size) {
      case AppButtonSize.small:
        return 4;
      case AppButtonSize.medium:
        return 8;
      case AppButtonSize.large:
        return 10;
      case AppButtonSize.responsive:
        return 9;
    }
  }

  double _getIconSpacing() {
    switch (size) {
      case AppButtonSize.small:
        return 6;
      case AppButtonSize.medium:
        return 8;
      case AppButtonSize.large:
        return 10;
      case AppButtonSize.responsive:
        return 8;
    }
  }

  TextStyle _getTextStyle() {
    final baseStyle = TextStyle(
      fontFamily: 'Lufga',
      fontWeight: FontWeight.w600,
      letterSpacing: 0.02,
    );

    switch (size) {
      case AppButtonSize.small:
        return baseStyle.copyWith(fontSize: 12);
      case AppButtonSize.medium:
        return baseStyle.copyWith(fontSize: 14);
      case AppButtonSize.large:
        return baseStyle.copyWith(fontSize: 16);
      case AppButtonSize.responsive:
        return baseStyle.copyWith(fontSize: 15);
    }
  }
}

/// Botón con gradiente moderno
class _ModernGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonSize size;
  final bool isLoading;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final EdgeInsetsGeometry? padding;
  final AppButtonState state;
  final Animation<double> iconAnimation;

  const _ModernGradientButton({
    required this.text,
    required this.onPressed,
    required this.size,
    required this.isLoading,
    required this.leadingIcon,
    required this.trailingIcon,
    required this.padding,
    required this.state,
    required this.iconAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: _getGradient(),
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        boxShadow: [
          BoxShadow(
            color: _getShadowColor(),
            blurRadius: _getBlurRadius(),
            offset: _getShadowOffset(),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: _getForegroundColor(),
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_getBorderRadius()),
          ),
          padding: padding ?? EdgeInsets.symmetric(
            horizontal: _getHorizontalPadding(),
            vertical: _getVerticalPadding(),
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.all(_getOverlayColor()),
        ),
        child: _buildButtonContent(),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            AppColors.textOnPrimary,
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null) ...[
          AnimatedBuilder(
            animation: iconAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: iconAnimation.value * 2 * 3.14159,
                child: leadingIcon!,
              );
            },
          ),
          SizedBox(width: _getIconSpacing()),
        ],
        Text(
          text,
          style: _getTextStyle(),
        ),
        if (trailingIcon != null) ...[
          SizedBox(width: _getIconSpacing()),
          AnimatedBuilder(
            animation: iconAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: iconAnimation.value * 2 * 3.14159,
                child: trailingIcon!,
              );
            },
          ),
        ],
      ],
    );
  }

  LinearGradient _getGradient() {
    if (state == AppButtonState.disabled || state == AppButtonState.loading) {
      return LinearGradient(
        colors: [
          AppColors.disabled,
          AppColors.disabled.withValues(alpha: 0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    switch (state) {
      case AppButtonState.hover:
        return AppGradients.buttonGradient;
      case AppButtonState.pressed:
        return LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.8),
            AppColors.tertiary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return AppGradients.buttonGradient;
    }
  }

  Color _getShadowColor() {
    switch (state) {
      case AppButtonState.hover:
        return AppColors.primary.withValues(alpha: 0.4);
      case AppButtonState.focus:
        return AppColors.focus.withValues(alpha: 0.3);
      case AppButtonState.pressed:
        return AppColors.primary.withValues(alpha: 0.2);
      default:
        return AppColors.shadow;
    }
  }

  double _getBlurRadius() {
    switch (state) {
      case AppButtonState.pressed:
        return 4;
      case AppButtonState.hover:
        return 12;
      case AppButtonState.focus:
        return 8;
      default:
        return 6;
    }
  }

  Offset _getShadowOffset() {
    switch (state) {
      case AppButtonState.pressed:
        return const Offset(1, 2);
      case AppButtonState.hover:
        return const Offset(0, 4);
      case AppButtonState.focus:
        return const Offset(0, 2);
      default:
        return const Offset(2, 4);
    }
  }

  Color _getForegroundColor() {
    if (state == AppButtonState.disabled || state == AppButtonState.loading) {
      return AppColors.textDisabled;
    }
    return AppColors.textOnPrimary;
  }

  Color _getOverlayColor() {
    switch (state) {
      case AppButtonState.hover:
        return Colors.white.withValues(alpha: 0.1);
      case AppButtonState.focus:
        return AppColors.focus.withValues(alpha: 0.1);
      case AppButtonState.pressed:
        return Colors.white.withValues(alpha: 0.2);
      default:
        return Colors.transparent;
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case AppButtonSize.small:
        return 6;
      case AppButtonSize.medium:
        return 8;
      case AppButtonSize.large:
        return 12;
      case AppButtonSize.responsive:
        return 10;
    }
  }

  double _getHorizontalPadding() {
    switch (size) {
      case AppButtonSize.small:
        return 12;
      case AppButtonSize.medium:
        return 16;
      case AppButtonSize.large:
        return 20;
      case AppButtonSize.responsive:
        return 18;
    }
  }

  double _getVerticalPadding() {
    switch (size) {
      case AppButtonSize.small:
        return 6;
      case AppButtonSize.medium:
        return 10;
      case AppButtonSize.large:
        return 12;
      case AppButtonSize.responsive:
        return 11;
    }
  }

  double _getIconSpacing() {
    switch (size) {
      case AppButtonSize.small:
        return 6;
      case AppButtonSize.medium:
        return 8;
      case AppButtonSize.large:
        return 10;
      case AppButtonSize.responsive:
        return 8;
    }
  }

  TextStyle _getTextStyle() {
    final baseStyle = TextStyle(
      fontFamily: 'Lufga',
      fontWeight: FontWeight.w600,
      letterSpacing: 0.02,
    );

    switch (size) {
      case AppButtonSize.small:
        return baseStyle.copyWith(fontSize: 12);
      case AppButtonSize.medium:
        return baseStyle.copyWith(fontSize: 14);
      case AppButtonSize.large:
        return baseStyle.copyWith(fontSize: 16);
      case AppButtonSize.responsive:
        return baseStyle.copyWith(fontSize: 15);
    }
  }
}