import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';

/// Enum para diferentes tamaños de espaciado responsivo
enum SpacingSize {
  /// Espaciado extra pequeño (4px)
  extraSmall,

  /// Espaciado pequeño (8px)
  small,

  /// Espaciado medio (16px)
  medium,

  /// Espaciado grande (24px)
  large,

  /// Espaciado extra grande (32px)
  extraLarge,

  /// Espaciado responsivo basado en contexto
  responsive,
}

/// Enum para tamaños de botón adicionales
enum ButtonSize {
  /// Botón pequeño (32px altura)
  small,

  /// Botón mediano (48px altura)
  medium,

  /// Botón grande (56px altura)
  large,

  /// Botón responsivo basado en contexto
  responsive,
}

/// Enum para tamaños de tarjeta adicionales
enum CardSize {
  /// Tarjeta pequeña (padding 8px-12px)
  small,

  /// Tarjeta mediana (padding 12px-16px)
  medium,

  /// Tarjeta grande (padding 16px-24px)
  large,

  /// Tarjeta responsiva basada en contexto
  responsive,
}

/// Contexto para manejar espaciado responsivo
class SpacingContext {
  final BuildContext context;
  final ResponsiveSize deviceSize;
  final ResponsiveDensity density;

  const SpacingContext._({
    required this.context,
    required this.deviceSize,
    required this.density,
  });

  /// Crea un contexto de espaciado basado en el BuildContext
  factory SpacingContext.fromContext(BuildContext context) {
    return SpacingContext._(
      context: context,
      deviceSize: ResponsiveUtils.getCurrentSize(context),
      density: ResponsiveDensityHandler.getCurrentDensity(context),
    );
  }

  /// Obtiene el multiplicador de densidad para ajustes finos
  double get densityMultiplier => ResponsiveDensityHandler.getDensityMultiplier(context);

  /// Obtiene el tamaño actual del dispositivo
  ResponsiveSize get currentSize => deviceSize;
}

/// Gestor principal de espaciado responsivo
class ResponsiveSpacing {
  /// Obtiene el espaciado base según el tamaño especificado
  static double getBaseSpacing(SpacingSize size, BuildContext context) {
    final spacingContext = SpacingContext.fromContext(context);
    final baseSize = _getBaseSpacingValue(size);

    // Aplicar ajustes responsivos
    double adjustedSize = baseSize * spacingContext.densityMultiplier;

    // Ajustes según el tamaño de dispositivo
    switch (spacingContext.deviceSize) {
      case ResponsiveSize.mobile:
        adjustedSize *= 0.9;
        break;
      case ResponsiveSize.tablet:
        adjustedSize *= 1.0;
        break;
      case ResponsiveSize.desktop:
        adjustedSize *= 1.1;
        break;
    }

    return adjustedSize;
  }

  /// Obtiene el padding base según el tamaño especificado
  static EdgeInsetsGeometry getBasePadding(SpacingSize size, BuildContext context) {
    final spacing = getBaseSpacing(size, context);

    switch (size) {
      case SpacingSize.extraSmall:
        return EdgeInsets.all(spacing);
      case SpacingSize.small:
        return EdgeInsets.all(spacing);
      case SpacingSize.medium:
        return EdgeInsets.symmetric(
          horizontal: spacing * 1.2,
          vertical: spacing * 0.8,
        );
      case SpacingSize.large:
        return EdgeInsets.symmetric(
          horizontal: spacing * 1.4,
          vertical: spacing * 1.0,
        );
      case SpacingSize.extraLarge:
        return EdgeInsets.symmetric(
          horizontal: spacing * 1.6,
          vertical: spacing * 1.2,
        );
      case SpacingSize.responsive:
        return ResponsiveUtils.getResponsivePadding(context);
    }
  }

  /// Obtiene el tamaño de botón según el contexto
  static double getButtonSize(ButtonSize size, BuildContext context) {
    switch (size) {
      case ButtonSize.small:
        return 32.0;
      case ButtonSize.medium:
        return ResponsiveUtils.getResponsiveButtonHeight(context);
      case ButtonSize.large:
        return ResponsiveUtils.getResponsiveButtonHeight(context) + 8;
      case ButtonSize.responsive:
        return ResponsiveUtils.getResponsiveButtonHeight(context);
    }
  }

  /// Obtiene el tamaño de tarjeta según el contexto
  static double getCardSize(CardSize size, BuildContext context) {
    switch (size) {
      case CardSize.small:
        return 8.0;
      case CardSize.medium:
        return 12.0;
      case CardSize.large:
        return 16.0;
      case CardSize.responsive:
        return ResponsiveUtils.getResponsiveBorderRadius(context);
    }
  }

  /// Método privado para obtener valores base de espaciado
  static double _getBaseSpacingValue(SpacingSize size) {
    switch (size) {
      case SpacingSize.extraSmall:
        return 4.0;
      case SpacingSize.small:
        return 8.0;
      case SpacingSize.medium:
        return 16.0;
      case SpacingSize.large:
        return 24.0;
      case SpacingSize.extraLarge:
        return 32.0;
      case SpacingSize.responsive:
        return 16.0; // Valor por defecto
    }
  }

  /// Obtiene espaciado horizontal responsivo
  static double getHorizontalSpacing(SpacingSize size, BuildContext context) {
    final baseSpacing = getBaseSpacing(size, context);

    switch (size) {
      case SpacingSize.extraSmall:
      case SpacingSize.small:
        return baseSpacing;
      case SpacingSize.medium:
      case SpacingSize.large:
      case SpacingSize.extraLarge:
        return baseSpacing * 1.2;
      case SpacingSize.responsive:
        return baseSpacing;
    }
  }

  /// Obtiene espaciado vertical responsivo
  static double getVerticalSpacing(SpacingSize size, BuildContext context) {
    final baseSpacing = getBaseSpacing(size, context);

    switch (size) {
      case SpacingSize.extraSmall:
      case SpacingSize.small:
        return baseSpacing * 0.8;
      case SpacingSize.medium:
        return baseSpacing;
      case SpacingSize.large:
      case SpacingSize.extraLarge:
        return baseSpacing * 1.4;
      case SpacingSize.responsive:
        return baseSpacing;
    }
  }

  /// Obtiene espaciado para listas/grid responsivo
  static EdgeInsetsGeometry getListSpacing(SpacingSize size, BuildContext context) {
    final spacing = getBaseSpacing(size, context);

    return EdgeInsets.symmetric(
      horizontal: spacing * 0.5,
      vertical: spacing * 0.25,
    );
  }

  /// Obtiene espaciado para formularios responsivo
  static EdgeInsetsGeometry getFormSpacing(SpacingSize size, BuildContext context) {
    final spacing = getBaseSpacing(size, context);

    return EdgeInsets.symmetric(
      horizontal: spacing,
      vertical: spacing * 0.6,
    );
  }
}

/// Extensiones útiles para trabajar con espaciado responsivo
extension ResponsiveSpacingExtensions on BuildContext {
  /// Obtiene el espaciado base para este contexto
  double getBaseSpacing(SpacingSize size) {
    return ResponsiveSpacing.getBaseSpacing(size, this);
  }

  /// Obtiene el padding base para este contexto
  EdgeInsetsGeometry getBasePadding(SpacingSize size) {
    return ResponsiveSpacing.getBasePadding(size, this);
  }

  /// Obtiene espaciado horizontal para este contexto
  double getHorizontalSpacing(SpacingSize size) {
    return ResponsiveSpacing.getHorizontalSpacing(size, this);
  }

  /// Obtiene espaciado vertical para este contexto
  double getVerticalSpacing(SpacingSize size) {
    return ResponsiveSpacing.getVerticalSpacing(size, this);
  }
}