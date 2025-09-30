import 'package:flutter/material.dart';
import '../widgets/app_text_field.dart';
import '../widgets/loading_widget.dart';

enum ResponsiveSize {
  mobile,
  tablet,
  desktop,
}

enum ResponsiveDensity {
  compact,
  normal,
  comfortable,
}

class ResponsiveBreakpoints {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1200;

  static ResponsiveSize getSize(double width) {
    if (width < mobileBreakpoint) {
      return ResponsiveSize.mobile;
    } else if (width < tabletBreakpoint) {
      return ResponsiveSize.tablet;
    } else {
      return ResponsiveSize.desktop;
    }
  }

  static bool isMobile(double width) => getSize(width) == ResponsiveSize.mobile;
  static bool isTablet(double width) => getSize(width) == ResponsiveSize.tablet;
  static bool isDesktop(double width) => getSize(width) == ResponsiveSize.desktop;
}

class ResponsiveCardPadding {
  static EdgeInsetsGeometry getPadding(ResponsiveSize size) {
    switch (size) {
      case ResponsiveSize.mobile:
        return const EdgeInsets.all(12);
      case ResponsiveSize.tablet:
        return const EdgeInsets.all(16);
      case ResponsiveSize.desktop:
        return const EdgeInsets.all(20);
    }
  }

  static EdgeInsetsGeometry getSmallPadding(ResponsiveSize size) {
    switch (size) {
      case ResponsiveSize.mobile:
        return const EdgeInsets.all(8);
      case ResponsiveSize.tablet:
        return const EdgeInsets.all(12);
      case ResponsiveSize.desktop:
        return const EdgeInsets.all(16);
    }
  }

  static EdgeInsetsGeometry getLargePadding(ResponsiveSize size) {
    switch (size) {
      case ResponsiveSize.mobile:
        return const EdgeInsets.all(20);
      case ResponsiveSize.tablet:
        return const EdgeInsets.all(24);
      case ResponsiveSize.desktop:
        return const EdgeInsets.all(32);
    }
  }
}

class ResponsiveCardProperties {
  static double getElevation(ResponsiveSize size) {
    switch (size) {
      case ResponsiveSize.mobile:
        return 2;
      case ResponsiveSize.tablet:
        return 4;
      case ResponsiveSize.desktop:
        return 6;
    }
  }

  static double getBorderRadius(ResponsiveSize size) {
    switch (size) {
      case ResponsiveSize.mobile:
        return 8;
      case ResponsiveSize.tablet:
        return 12;
      case ResponsiveSize.desktop:
        return 16;
    }
  }

  static double getMargin(ResponsiveSize size) {
    switch (size) {
      case ResponsiveSize.mobile:
        return 8;
      case ResponsiveSize.tablet:
        return 12;
      case ResponsiveSize.desktop:
        return 16;
    }
  }
}

class ResponsiveUtils {
  static ResponsiveSize getCurrentSize(BuildContext context) {
    return ResponsiveBreakpoints.getSize(MediaQuery.of(context).size.width);
  }

  static bool isMobile(BuildContext context) =>
      ResponsiveBreakpoints.isMobile(MediaQuery.of(context).size.width);

  static bool isTablet(BuildContext context) =>
      ResponsiveBreakpoints.isTablet(MediaQuery.of(context).size.width);

  static bool isDesktop(BuildContext context) =>
      ResponsiveBreakpoints.isDesktop(MediaQuery.of(context).size.width);

  static EdgeInsetsGeometry getResponsivePadding(BuildContext context, {
    bool small = false,
    bool large = false,
  }) {
    final size = getCurrentSize(context);

    if (small) return ResponsiveCardPadding.getSmallPadding(size);
    if (large) return ResponsiveCardPadding.getLargePadding(size);
    return ResponsiveCardPadding.getPadding(size);
  }

  static double getResponsiveElevation(BuildContext context) {
    return ResponsiveCardProperties.getElevation(getCurrentSize(context));
  }

  static double getResponsiveBorderRadius(BuildContext context) {
    return ResponsiveCardProperties.getBorderRadius(getCurrentSize(context));
  }

  static double getResponsiveMargin(BuildContext context) {
    return ResponsiveCardProperties.getMargin(getCurrentSize(context));
  }
}

class ResponsiveTextField {
  static double getFontSize(
    BuildContext context, {
    required AppTextFieldSize size,
    double? customScale,
  }) {
    if (customScale != null) {
      return customScale;
    }

    double baseFontSize;
    switch (size) {
      case AppTextFieldSize.small:
        baseFontSize = 14;
        break;
      case AppTextFieldSize.medium:
        baseFontSize = 16;
        break;
      case AppTextFieldSize.large:
        baseFontSize = 18;
        break;
    }

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final textScaler = mediaQuery.textScaler;

    double responsiveFontSize = baseFontSize * textScaler.scale(baseFontSize);

    // Ajustar según el ancho de pantalla para mejor legibilidad
    if (screenWidth < 600) {
      responsiveFontSize *= 0.95;
    } else if (screenWidth > 1200) {
      responsiveFontSize *= 1.05;
    }

    return responsiveFontSize;
  }

  static double getLabelFontSize(
    BuildContext context, {
    required AppTextFieldSize size,
    double? customScale,
  }) {
    if (customScale != null) {
      return customScale * 0.875;
    }

    double baseLabelFontSize;
    switch (size) {
      case AppTextFieldSize.small:
        baseLabelFontSize = 12;
        break;
      case AppTextFieldSize.medium:
        baseLabelFontSize = 14;
        break;
      case AppTextFieldSize.large:
        baseLabelFontSize = 16;
        break;
    }

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final textScaler = mediaQuery.textScaler;

    double responsiveLabelFontSize = baseLabelFontSize * textScaler.scale(baseLabelFontSize);

    if (screenWidth < 600) {
      responsiveLabelFontSize *= 0.95;
    } else if (screenWidth > 1200) {
      responsiveLabelFontSize *= 1.05;
    }

    return responsiveLabelFontSize;
  }

  static EdgeInsetsGeometry getContentPadding(
    BuildContext context, {
    required AppTextFieldSize size,
    EdgeInsetsGeometry? customPadding,
  }) {
    if (customPadding != null) {
      return customPadding;
    }

    EdgeInsetsGeometry basePadding;
    switch (size) {
      case AppTextFieldSize.small:
        basePadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 12);
        break;
      case AppTextFieldSize.medium:
        basePadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
        break;
      case AppTextFieldSize.large:
        basePadding = const EdgeInsets.symmetric(horizontal: 20, vertical: 20);
        break;
    }

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final textScaler = mediaQuery.textScaler;

    double horizontalMultiplier = 1.0;
    double verticalMultiplier = 1.0;

    if (screenWidth < 600) {
      horizontalMultiplier = 0.85;
      verticalMultiplier = 0.9;
    } else if (screenWidth > 1200) {
      horizontalMultiplier = 1.15;
      verticalMultiplier = 1.1;
    }

    final textScaleValue = textScaler.scale(14.0) / 14.0; // Obtener el factor de escala
    if (textScaleValue > 1.0) {
      horizontalMultiplier *= textScaleValue;
      verticalMultiplier *= textScaleValue;
    }

    if (basePadding is EdgeInsets) {
      return EdgeInsets.symmetric(
        horizontal: (basePadding.horizontal / 2 * horizontalMultiplier).round().toDouble(),
        vertical: (basePadding.vertical / 2 * verticalMultiplier).round().toDouble(),
      );
    }

    return basePadding;
  }
}

class ResponsiveDensityHandler {
  static ResponsiveDensity getCurrentDensity(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final pixelRatio = mediaQuery.devicePixelRatio;

    // Considerar múltiples factores para determinar la densidad
    if (screenWidth < 400 || screenHeight < 600 || pixelRatio > 2.5) {
      return ResponsiveDensity.compact;
    } else if (screenWidth > 1400 || screenHeight > 1000 || pixelRatio < 1.5) {
      return ResponsiveDensity.comfortable;
    } else {
      return ResponsiveDensity.normal;
    }
  }

  static double getDensityMultiplier(BuildContext context) {
    switch (getCurrentDensity(context)) {
      case ResponsiveDensity.compact:
        return 0.85;
      case ResponsiveDensity.normal:
        return 1.0;
      case ResponsiveDensity.comfortable:
        return 1.15;
    }
  }

  static EdgeInsetsGeometry getAdjustedPadding(
    BuildContext context,
    EdgeInsetsGeometry basePadding,
  ) {
    final multiplier = getDensityMultiplier(context);

    if (basePadding is EdgeInsets) {
      return EdgeInsets.symmetric(
        horizontal: (basePadding.horizontal / 2 * multiplier).round().toDouble(),
        vertical: (basePadding.vertical / 2 * multiplier).round().toDouble(),
      );
    }

    return basePadding;
  }

  static double getAdjustedFontSize(
    BuildContext context,
    double baseFontSize,
  ) {
    final multiplier = getDensityMultiplier(context);
    return baseFontSize * multiplier;
  }
}

class ResponsiveLoadingWidget {
  static double getSize(BuildContext context, {LoadingSize? size}) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    if (size != null) {
      switch (size) {
        case LoadingSize.small:
          return 16;
        case LoadingSize.medium:
          return 24;
        case LoadingSize.large:
          return 32;
        case LoadingSize.adaptive:
          break;
      }
    }

    // Lógica adaptativa basada en el contexto
    if (screenWidth < 600) {
      return 20;
    } else if (screenWidth < 1200) {
      return 24;
    } else {
      return 28;
    }
  }

  static double getStrokeWidth(BuildContext context, {LoadingSize? size}) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final devicePixelRatio = mediaQuery.devicePixelRatio;

    double baseStrokeWidth;

    if (size != null) {
      switch (size) {
        case LoadingSize.small:
          baseStrokeWidth = 2;
          break;
        case LoadingSize.medium:
          baseStrokeWidth = 3;
          break;
        case LoadingSize.large:
          baseStrokeWidth = 4;
          break;
        case LoadingSize.adaptive:
          baseStrokeWidth = 3;
          break;
      }
    } else {
      baseStrokeWidth = 3;
    }

    // Ajustar según el tamaño de pantalla
    if (screenWidth < 600) {
      baseStrokeWidth = 2.5;
    } else if (screenWidth > 1200) {
      baseStrokeWidth = 3.5;
    }

    // Ajustar por densidad de píxeles para mejor visibilidad
    if (devicePixelRatio > 2.5) {
      baseStrokeWidth *= 0.9;
    } else if (devicePixelRatio < 1.5) {
      baseStrokeWidth *= 1.1;
    }

    return baseStrokeWidth;
  }

  static LoadingSize getAdaptiveSize(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    if (screenWidth < 600) {
      return LoadingSize.small;
    } else if (screenWidth < 1200) {
      return LoadingSize.medium;
    } else {
      return LoadingSize.large;
    }
  }

  static LoadingWidget createResponsive({
    Key? key,
    LoadingSize size = LoadingSize.adaptive,
    double? strokeWidth,
    Color? color,
    Color? backgroundColor,
    double? value,
    String? semanticsLabel,
    String? semanticsValue,
  }) {
    return LoadingWidget(
      key: key,
      size: size,
      strokeWidth: strokeWidth,
      color: color,
      backgroundColor: backgroundColor,
      value: value,
      semanticsLabel: semanticsLabel,
      semanticsValue: semanticsValue,
    );
  }

  static LoadingWidget createForContext(
    BuildContext context, {
    Key? key,
    bool useAdaptiveSize = true,
    double? strokeWidth,
    Color? color,
    Color? backgroundColor,
    double? value,
    String? semanticsLabel,
    String? semanticsValue,
  }) {
    final adaptiveSize = useAdaptiveSize ? getAdaptiveSize(context) : LoadingSize.medium;

    return LoadingWidget(
      key: key,
      size: adaptiveSize,
      strokeWidth: strokeWidth ?? getStrokeWidth(context, size: adaptiveSize),
      color: color,
      backgroundColor: backgroundColor,
      value: value,
      semanticsLabel: semanticsLabel,
      semanticsValue: semanticsValue,
    );
  }
}