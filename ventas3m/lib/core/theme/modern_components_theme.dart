import 'package:flutter/material.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/modern_forms.dart';
import 'colors.dart';

/// Utilidades para facilitar la integración de componentes modernos con el sistema de tema
class ModernComponentsTheme {

  /// Obtiene el estilo de botón moderno según el tema actual
  static ButtonStyle getModernButtonStyle({
    required BuildContext context,
    required AppButtonVariant variant,
    required AppButtonSize size,
    AppButtonState state = AppButtonState.normal,
  }) {
    final theme = Theme.of(context);

    switch (variant) {
      case AppButtonVariant.primary:
        return _getPrimaryButtonStyle(theme, size, state);
      case AppButtonVariant.secondary:
        return _getSecondaryButtonStyle(theme, size, state);
      case AppButtonVariant.outline:
        return _getOutlineButtonStyle(theme, size, state);
      case AppButtonVariant.ghost:
        return _getGhostButtonStyle(theme, size, state);
      case AppButtonVariant.gradient:
        return _getGradientButtonStyle(theme, size, state);
    }
  }

  static ButtonStyle _getPrimaryButtonStyle(ThemeData theme, AppButtonSize size, AppButtonState state) {
    return ElevatedButton.styleFrom(
      backgroundColor: _getButtonBackgroundColor(state, AppColors.primary),
      foregroundColor: _getButtonForegroundColor(state, AppColors.textOnPrimary),
      elevation: _getButtonElevation(state),
      shadowColor: _getButtonShadowColor(state, AppColors.primary),
      surfaceTintColor: AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_getButtonBorderRadius(size)),
      ),
      padding: _getButtonPadding(size),
      textStyle: _getButtonTextStyle(size),
    );
  }

  static ButtonStyle _getSecondaryButtonStyle(ThemeData theme, AppButtonSize size, AppButtonState state) {
    return TextButton.styleFrom(
      backgroundColor: _getButtonBackgroundColor(state, AppColors.secondary, transparent: true),
      foregroundColor: _getButtonForegroundColor(state, AppColors.secondary),
      elevation: _getButtonElevation(state, low: true),
      shadowColor: _getButtonShadowColor(state, AppColors.secondary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_getButtonBorderRadius(size)),
      ),
      padding: _getButtonPadding(size),
      textStyle: _getButtonTextStyle(size),
    );
  }

  static ButtonStyle _getOutlineButtonStyle(ThemeData theme, AppButtonSize size, AppButtonState state) {
    return OutlinedButton.styleFrom(
      backgroundColor: _getButtonBackgroundColor(state, AppColors.primary, transparent: true),
      foregroundColor: _getButtonForegroundColor(state, AppColors.primary),
      side: BorderSide(
        color: _getButtonBorderColor(state, AppColors.primary),
        width: _getButtonBorderWidth(state),
      ),
      elevation: _getButtonElevation(state, low: true),
      shadowColor: _getButtonShadowColor(state, AppColors.primary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_getButtonBorderRadius(size)),
      ),
      padding: _getButtonPadding(size),
      textStyle: _getButtonTextStyle(size),
    );
  }

  static ButtonStyle _getGhostButtonStyle(ThemeData theme, AppButtonSize size, AppButtonState state) {
    return TextButton.styleFrom(
      backgroundColor: _getButtonBackgroundColor(state, AppColors.primary, transparent: true),
      foregroundColor: _getButtonForegroundColor(state, AppColors.primary),
      elevation: _getButtonElevation(state, low: true),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_getButtonBorderRadius(size)),
      ),
      padding: _getButtonPadding(size, ghost: true),
      textStyle: _getButtonTextStyle(size),
    );
  }

  static ButtonStyle _getGradientButtonStyle(ThemeData theme, AppButtonSize size, AppButtonState state) {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      foregroundColor: _getButtonForegroundColor(state, AppColors.textOnPrimary),
      elevation: _getButtonElevation(state),
      shadowColor: _getButtonShadowColor(state, AppColors.primary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_getButtonBorderRadius(size)),
      ),
      padding: _getButtonPadding(size),
      textStyle: _getButtonTextStyle(size),
    );
  }

  static Color _getButtonBackgroundColor(AppButtonState state, Color baseColor, {bool transparent = false}) {
    if (state == AppButtonState.disabled || state == AppButtonState.loading) {
      return AppColors.disabled;
    }

    switch (state) {
      case AppButtonState.hover:
        return transparent ? baseColor.withValues(alpha: 0.1) : baseColor;
      case AppButtonState.focus:
        return transparent ? baseColor.withValues(alpha: 0.05) : baseColor;
      case AppButtonState.pressed:
        return transparent ? baseColor.withValues(alpha: 0.15) : baseColor.withValues(alpha: 0.8);
      default:
        return transparent ? Colors.transparent : baseColor;
    }
  }

  static Color _getButtonForegroundColor(AppButtonState state, Color baseColor) {
    if (state == AppButtonState.disabled || state == AppButtonState.loading) {
      return AppColors.textDisabled;
    }
    return baseColor;
  }

  static double _getButtonElevation(AppButtonState state, {bool low = false}) {
    switch (state) {
      case AppButtonState.pressed:
        return low ? 1 : 2;
      case AppButtonState.hover:
        return low ? 4 : 8;
      case AppButtonState.focus:
        return low ? 3 : 6;
      default:
        return low ? 0 : 4;
    }
  }

  static Color _getButtonShadowColor(AppButtonState state, Color baseColor) {
    switch (state) {
      case AppButtonState.hover:
        return baseColor.withValues(alpha: 0.3);
      case AppButtonState.focus:
        return AppColors.focus.withValues(alpha: 0.3);
      default:
        return AppColors.shadow;
    }
  }

  static Color _getButtonBorderColor(AppButtonState state, Color baseColor) {
    if (state == AppButtonState.disabled || state == AppButtonState.loading) {
      return AppColors.disabled;
    }

    switch (state) {
      case AppButtonState.hover:
      case AppButtonState.focus:
      case AppButtonState.pressed:
        return baseColor;
      default:
        return AppColors.border;
    }
  }

  static double _getButtonBorderWidth(AppButtonState state) {
    switch (state) {
      case AppButtonState.hover:
      case AppButtonState.focus:
        return 2;
      case AppButtonState.pressed:
        return 1;
      default:
        return 1.5;
    }
  }

  static double _getButtonBorderRadius(AppButtonSize size) {
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

  static EdgeInsetsGeometry _getButtonPadding(AppButtonSize size, {bool ghost = false}) {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case AppButtonSize.responsive:
        return const EdgeInsets.symmetric(horizontal: 18, vertical: 11);
    }
  }

  static TextStyle _getButtonTextStyle(AppButtonSize size) {
    return TextStyle(
      fontFamily: 'Lufga',
      fontWeight: FontWeight.w600,
      letterSpacing: 0.02,
      fontSize: _getButtonFontSize(size),
    );
  }

  static double _getButtonFontSize(AppButtonSize size) {
    switch (size) {
      case AppButtonSize.small:
        return 12;
      case AppButtonSize.medium:
        return 14;
      case AppButtonSize.large:
        return 16;
      case AppButtonSize.responsive:
        return 15;
    }
  }

  /// Obtiene la configuración de tarjeta moderna según el tema
  static CardThemeData getModernCardTheme({
    required AppCardVariant variant,
    required AppCardElevation elevation,
    AppCardState state = AppCardState.normal,
  }) {
    return CardThemeData(
      color: _getCardBackgroundColor(variant, state),
      elevation: _getCardElevation(elevation, state),
      surfaceTintColor: _getCardSurfaceTintColor(variant),
      shape: _getCardShape(variant, elevation, state),
      margin: _getCardMargin(variant),
    );
  }

  static Color _getCardBackgroundColor(AppCardVariant variant, AppCardState state) {
    if (state == AppCardState.disabled) {
      return AppColors.disabled.withValues(alpha: 0.1);
    }

    switch (variant) {
      case AppCardVariant.filled:
        return AppColors.cardBackground;
      case AppCardVariant.outlined:
      case AppCardVariant.interactive:
        return Colors.transparent;
      case AppCardVariant.elevated:
        return AppColors.cardBackground;
      case AppCardVariant.gradient:
        return Colors.transparent;
    }
  }

  static double _getCardElevation(AppCardElevation elevation, AppCardState state) {
    if (state == AppCardState.disabled) {
      return 0;
    }

    double baseElevation = _getBaseCardElevation(elevation);

    switch (state) {
      case AppCardState.hover:
        return _getHoverCardElevation(elevation);
      case AppCardState.focus:
        return _getFocusCardElevation(elevation);
      case AppCardState.pressed:
        return _getPressedCardElevation(elevation);
      default:
        return baseElevation;
    }
  }

  static double _getBaseCardElevation(AppCardElevation elevation) {
    switch (elevation) {
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

  static double _getHoverCardElevation(AppCardElevation elevation) {
    switch (elevation) {
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

  static double _getFocusCardElevation(AppCardElevation elevation) {
    switch (elevation) {
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

  static double _getPressedCardElevation(AppCardElevation elevation) {
    switch (elevation) {
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

  static Color _getCardSurfaceTintColor(AppCardVariant variant) {
    switch (variant) {
      case AppCardVariant.gradient:
        return Colors.transparent;
      default:
        return AppColors.primary;
    }
  }

  static RoundedRectangleBorder _getCardShape(AppCardVariant variant, AppCardElevation elevation, AppCardState state) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_getCardBorderRadius(variant)),
      side: _getCardBorderSide(variant, state),
    );
  }

  static double _getCardBorderRadius(AppCardVariant variant) {
    switch (variant) {
      case AppCardVariant.filled:
      case AppCardVariant.elevated:
        return 12;
      case AppCardVariant.gradient:
        return 16;
      case AppCardVariant.outlined:
      case AppCardVariant.interactive:
        return 8;
    }
  }

  static BorderSide _getCardBorderSide(AppCardVariant variant, AppCardState state) {
    if (variant == AppCardVariant.filled || variant == AppCardVariant.elevated) {
      return BorderSide.none;
    }

    Color borderColor = _getCardBorderColor(variant, state);
    double borderWidth = _getCardBorderWidth(variant, state);

    return BorderSide(
      color: borderColor,
      width: borderWidth,
    );
  }

  static Color _getCardBorderColor(AppCardVariant variant, AppCardState state) {
    if (state == AppCardState.disabled) {
      return AppColors.disabled;
    }

    switch (state) {
      case AppCardState.hover:
        return AppColors.primary.withValues(alpha: 0.5);
      case AppCardState.focus:
        return AppColors.focus;
      case AppCardState.pressed:
        return AppColors.primary;
      default:
        return AppColors.border;
    }
  }

  static double _getCardBorderWidth(AppCardVariant variant, AppCardState state) {
    switch (state) {
      case AppCardState.hover:
      case AppCardState.focus:
        return 2;
      case AppCardState.pressed:
        return 1;
      default:
        return 1.5;
    }
  }

  static EdgeInsetsGeometry _getCardMargin(AppCardVariant variant) {
    return const EdgeInsets.all(8);
  }

  /// Utilidades para campos de texto modernos
  static InputDecorationTheme getModernInputDecorationTheme({
    AppTextFieldVariant variant = AppTextFieldVariant.outlined,
    AppTextFieldState state = AppTextFieldState.normal,
  }) {
    return InputDecorationTheme(
      filled: variant == AppTextFieldVariant.filled,
      fillColor: _getInputBackgroundColor(variant, state),
      contentPadding: _getInputPadding(variant),
      border: _getInputBorder(variant, state),
      enabledBorder: _getInputBorder(variant, AppTextFieldState.normal),
      focusedBorder: _getInputBorder(variant, AppTextFieldState.focused),
      errorBorder: _getInputBorder(variant, AppTextFieldState.error),
      focusedErrorBorder: _getInputBorder(variant, AppTextFieldState.error),
      disabledBorder: _getInputBorder(variant, AppTextFieldState.disabled),
      labelStyle: _getInputLabelStyle(state),
      hintStyle: _getInputHintStyle(state),
      errorStyle: _getInputErrorStyle(),
      helperStyle: _getInputHelperStyle(),
    );
  }

  static Color _getInputBackgroundColor(AppTextFieldVariant variant, AppTextFieldState state) {
    if (state == AppTextFieldState.disabled) {
      return AppColors.disabled.withValues(alpha: 0.1);
    }

    switch (variant) {
      case AppTextFieldVariant.filled:
        return AppColors.surface;
      case AppTextFieldVariant.outlined:
      case AppTextFieldVariant.underlined:
        return Colors.transparent;
    }
  }

  static EdgeInsetsGeometry _getInputPadding(AppTextFieldVariant variant) {
    switch (variant) {
      case AppTextFieldVariant.filled:
      case AppTextFieldVariant.outlined:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
      case AppTextFieldVariant.underlined:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    }
  }

  static InputBorder _getInputBorder(AppTextFieldVariant variant, AppTextFieldState state) {
    final borderRadius = BorderRadius.circular(_getInputBorderRadius(variant));

    switch (variant) {
      case AppTextFieldVariant.outlined:
      case AppTextFieldVariant.filled:
        return OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(
            color: _getInputBorderColor(state),
            width: _getInputBorderWidth(state),
          ),
        );
      case AppTextFieldVariant.underlined:
        return UnderlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(
            color: _getInputBorderColor(state),
            width: _getInputBorderWidth(state),
          ),
        );
    }
  }

  static double _getInputBorderRadius(AppTextFieldVariant variant) {
    switch (variant) {
      case AppTextFieldVariant.filled:
      case AppTextFieldVariant.outlined:
        return 12;
      case AppTextFieldVariant.underlined:
        return 0;
    }
  }

  static Color _getInputBorderColor(AppTextFieldState state) {
    switch (state) {
      case AppTextFieldState.error:
        return AppColors.error;
      case AppTextFieldState.success:
        return AppColors.secondary;
      case AppTextFieldState.focused:
        return AppColors.primary;
      case AppTextFieldState.disabled:
        return AppColors.disabled;
      default:
        return AppColors.border;
    }
  }

  static double _getInputBorderWidth(AppTextFieldState state) {
    switch (state) {
      case AppTextFieldState.focused:
        return 2;
      case AppTextFieldState.error:
      case AppTextFieldState.success:
        return 1.5;
      default:
        return 1;
    }
  }

  static TextStyle _getInputLabelStyle(AppTextFieldState state) {
    return TextStyle(
      fontFamily: 'Lufga',
      color: _getInputTextColor(state, AppColors.textSecondary),
      fontSize: 16,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle _getInputHintStyle(AppTextFieldState state) {
    return TextStyle(
      fontFamily: 'Lufga',
      color: AppColors.textDisabled,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle _getInputErrorStyle() {
    return TextStyle(
      fontFamily: 'Lufga',
      color: AppColors.error,
      fontSize: 12,
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle _getInputHelperStyle() {
    return TextStyle(
      fontFamily: 'Lufga',
      color: AppColors.textDisabled,
      fontSize: 12,
      fontWeight: FontWeight.w400,
    );
  }

  static Color _getInputTextColor(AppTextFieldState state, Color defaultColor) {
    if (state == AppTextFieldState.disabled) {
      return AppColors.textDisabled;
    }

    switch (state) {
      case AppTextFieldState.error:
        return AppColors.error;
      case AppTextFieldState.success:
        return AppColors.secondary;
      case AppTextFieldState.focused:
        return AppColors.primary;
      default:
        return defaultColor;
    }
  }

  /// Tema para navegación moderna
  static BottomNavigationBarThemeData getModernNavigationTheme({
    bool showLabels = true,
    bool showIndicators = true,
  }) {
    return BottomNavigationBarThemeData(
      backgroundColor: AppColors.cardBackground,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      elevation: 12,
      selectedLabelStyle: TextStyle(
        fontFamily: 'Lufga',
        fontSize: showLabels ? 12 : 0,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: 'Lufga',
        fontSize: showLabels ? 12 : 0,
        fontWeight: FontWeight.w400,
      ),
      showSelectedLabels: showLabels,
      showUnselectedLabels: showLabels,
      selectedIconTheme: IconThemeData(
        size: showIndicators ? 28 : 24,
        color: AppColors.primary,
      ),
      unselectedIconTheme: IconThemeData(
        size: 24,
        color: AppColors.textSecondary,
      ),
    );
  }

  /// Tema para componentes de carga
  static ProgressIndicatorThemeData getModernProgressTheme() {
    return const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.surface,
      refreshBackgroundColor: AppColors.cardBackground,
    );
  }

  /// Método para aplicar todos los temas modernos al tema principal
  static ThemeData applyModernComponentsTheme({
    required ThemeData baseTheme,
    bool enableModernButtons = true,
    bool enableModernCards = true,
    bool enableModernInputs = true,
    bool enableModernNavigation = true,
    bool enableModernProgress = true,
  }) {
    return baseTheme.copyWith(
      elevatedButtonTheme: enableModernButtons
          ? ElevatedButtonThemeData(
              style: _getPrimaryButtonStyle(baseTheme, AppButtonSize.medium, AppButtonState.normal),
            )
          : baseTheme.elevatedButtonTheme,

      cardTheme: enableModernCards
          ? getModernCardTheme(
              variant: AppCardVariant.filled,
              elevation: AppCardElevation.level1,
            )
          : baseTheme.cardTheme,

      inputDecorationTheme: enableModernInputs
          ? getModernInputDecorationTheme()
          : baseTheme.inputDecorationTheme,

      bottomNavigationBarTheme: enableModernNavigation
          ? getModernNavigationTheme()
          : baseTheme.bottomNavigationBarTheme,

      progressIndicatorTheme: enableModernProgress
          ? getModernProgressTheme()
          : baseTheme.progressIndicatorTheme,
    );
  }
}

/// Extensiones útiles para componentes modernos
extension ModernComponentsExtension on BuildContext {
  /// Obtiene el estilo de botón moderno actual
  ButtonStyle getModernButtonStyle(AppButtonVariant variant, AppButtonSize size) {
    return ModernComponentsTheme.getModernButtonStyle(
      context: this,
      variant: variant,
      size: size,
    );
  }

  /// Obtiene la configuración de tarjeta moderna actual
  CardThemeData getModernCardTheme(AppCardVariant variant, AppCardElevation elevation) {
    return ModernComponentsTheme.getModernCardTheme(
      variant: variant,
      elevation: elevation,
    );
  }

  /// Obtiene el tema de decoración de entrada moderno actual
  InputDecorationTheme getModernInputTheme(AppTextFieldVariant variant) {
    return ModernComponentsTheme.getModernInputDecorationTheme(variant: variant);
  }
}

/// Utilidades para animaciones comunes en componentes modernos
class ModernAnimations {
  /// Duración estándar para animaciones de componentes
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);

  /// Curvas de animación comunes
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;

  /// Crea una animación de escala para interacciones
  static Animation<double> createScaleAnimation({
    required AnimationController controller,
    double begin = 1.0,
    double end = 0.95,
  }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: easeInOut),
    );
  }

  /// Crea una animación de elevación para tarjetas
  static Animation<double> createElevationAnimation({
    required AnimationController controller,
    double begin = 0.0,
    double end = 8.0,
  }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: easeOut),
    );
  }

  /// Crea una animación de rotación para íconos
  static Animation<double> createRotationAnimation({
    required AnimationController controller,
    double begin = 0.0,
    double end = 0.5,
  }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: easeInOut),
    );
  }
}

/// Configuración recomendada para componentes modernos
class ModernComponentsConfig {
  /// Configuración recomendada para aplicaciones móviles
  static const mobile = ModernComponentsSettings(
    buttonAnimationDuration: Duration(milliseconds: 200),
    cardAnimationDuration: Duration(milliseconds: 250),
    navigationAnimationDuration: Duration(milliseconds: 300),
    enableHapticFeedback: true,
    enableHoverEffects: false,
  );

  /// Configuración recomendada para aplicaciones desktop
  static const desktop = ModernComponentsSettings(
    buttonAnimationDuration: Duration(milliseconds: 150),
    cardAnimationDuration: Duration(milliseconds: 200),
    navigationAnimationDuration: Duration(milliseconds: 250),
    enableHapticFeedback: false,
    enableHoverEffects: true,
  );
}

/// Configuraciones para componentes modernos
class ModernComponentsSettings {
  final Duration buttonAnimationDuration;
  final Duration cardAnimationDuration;
  final Duration navigationAnimationDuration;
  final bool enableHapticFeedback;
  final bool enableHoverEffects;

  const ModernComponentsSettings({
    required this.buttonAnimationDuration,
    required this.cardAnimationDuration,
    required this.navigationAnimationDuration,
    required this.enableHapticFeedback,
    required this.enableHoverEffects,
  });
}