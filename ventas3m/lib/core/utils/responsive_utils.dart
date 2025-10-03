import 'package:flutter/material.dart';

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

enum DeviceType {
  phone,
  tablet,
  desktop,
  tv,
}

enum DeviceOrientation {
  portrait,
  landscape,
}

class ResponsiveBreakpoints {
  // Breakpoints optimizados para diferentes dispositivos
  static const double mobileBreakpoint = 768;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;
  static const double largeDesktopBreakpoint = 1920;

  // Breakpoints específicos para diferentes contextos
  static const double compactMobileBreakpoint = 375; // iPhone SE
  static const double standardMobileBreakpoint = 414; // iPhone Plus
  static const double largeMobileBreakpoint = 480; // Surface Duo, etc.

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

  // Nuevos métodos para breakpoints más granulares
  static bool isCompactMobile(double width) => width < compactMobileBreakpoint;
  static bool isStandardMobile(double width) =>
      width >= compactMobileBreakpoint && width < standardMobileBreakpoint;
  static bool isLargeMobile(double width) =>
      width >= standardMobileBreakpoint && width < mobileBreakpoint;
  static bool isSmallTablet(double width) =>
      width >= mobileBreakpoint && width < 900;
  static bool isLargeTablet(double width) =>
      width >= 900 && width < tabletBreakpoint;
  static bool isSmallDesktop(double width) =>
      width >= tabletBreakpoint && width < desktopBreakpoint;
  static bool isLargeDesktop(double width) => width >= desktopBreakpoint;
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

  // Nuevos métodos granulares
  static bool isCompactMobile(BuildContext context) =>
      ResponsiveBreakpoints.isCompactMobile(MediaQuery.of(context).size.width);

  static bool isStandardMobile(BuildContext context) =>
      ResponsiveBreakpoints.isStandardMobile(MediaQuery.of(context).size.width);

  static bool isLargeMobile(BuildContext context) =>
      ResponsiveBreakpoints.isLargeMobile(MediaQuery.of(context).size.width);

  static bool isSmallTablet(BuildContext context) =>
      ResponsiveBreakpoints.isSmallTablet(MediaQuery.of(context).size.width);

  static bool isLargeTablet(BuildContext context) =>
      ResponsiveBreakpoints.isLargeTablet(MediaQuery.of(context).size.width);

  static bool isSmallDesktop(BuildContext context) =>
      ResponsiveBreakpoints.isSmallDesktop(MediaQuery.of(context).size.width);

  static bool isLargeDesktop(BuildContext context) =>
      ResponsiveBreakpoints.isLargeDesktop(MediaQuery.of(context).size.width);

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

  // Nuevas utilidades avanzadas
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final mediaQuery = MediaQuery.of(context);
    final pixelRatio = mediaQuery.devicePixelRatio;

    // Ajuste basado en el tamaño de pantalla
    double multiplier = 1.0;

    if (isCompactMobile(context)) {
      multiplier = 0.85;
    } else if (isStandardMobile(context)) {
      multiplier = 0.9;
    } else if (isLargeMobile(context)) {
      multiplier = 0.95;
    } else if (isSmallTablet(context)) {
      multiplier = 1.0;
    } else if (isLargeTablet(context)) {
      multiplier = 1.05;
    } else if (isSmallDesktop(context)) {
      multiplier = 1.1;
    } else if (isLargeDesktop(context)) {
      multiplier = 1.15;
    }

    // Ajuste por orientación
    if (mediaQuery.orientation == Orientation.landscape && isMobile(context)) {
      multiplier *= 0.9;
    }

    // Ajuste por densidad de píxeles
    if (pixelRatio > 2.5) {
      multiplier *= 0.95;
    } else if (pixelRatio < 1.5) {
      multiplier *= 1.05;
    }

    return baseSize * multiplier;
  }

  static EdgeInsetsGeometry getResponsiveContentPadding(BuildContext context) {
    if (isCompactMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
    } else if (isStandardMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    } else if (isLargeMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
    } else if (isSmallTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 20);
    } else if (isLargeTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 28, vertical: 24);
    } else if (isSmallDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 28);
    } else {
      return const EdgeInsets.symmetric(horizontal: 40, vertical: 32);
    }
  }

  static int getResponsiveGridCrossAxisCount(BuildContext context) {
    if (isCompactMobile(context)) {
      return 1;
    } else if (isStandardMobile(context)) {
      return 2;
    } else if (isLargeMobile(context)) {
      return 2;
    } else if (isSmallTablet(context)) {
      return 2;
    } else if (isLargeTablet(context)) {
      return 3;
    } else if (isSmallDesktop(context)) {
      return 4;
    } else {
      return 5;
    }
  }

  static double getResponsiveGridChildAspectRatio(BuildContext context) {
    if (isMobile(context)) {
      return 0.75; // Más alto que ancho para móviles
    } else if (isTablet(context)) {
      return 0.8; // Ligeramente más alto
    } else {
      return 0.9; // Casi cuadrado para desktop
    }
  }

  static double getResponsiveIconSize(BuildContext context, {double? size}) {
    final baseSize = size ?? 24.0;
    return getResponsiveFontSize(context, baseSize);
  }

  static double getResponsiveButtonHeight(BuildContext context) {
    if (isCompactMobile(context)) {
      return 44; // Mínimo recomendado para touch targets
    } else if (isMobile(context)) {
      return 48;
    } else if (isTablet(context)) {
      return 52;
    } else {
      return 56;
    }
  }

  static double getResponsiveTouchTargetSize(BuildContext context) {
    // Mínimo 44px según guías de accesibilidad
    if (isCompactMobile(context)) {
      return 44;
    } else if (isMobile(context)) {
      return 48;
    } else {
      return 44;
    }
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


/// Clase avanzada para detección de dispositivo y capacidades
class DeviceCapabilities {
  static bool isTouchDevice(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    // Detectar si es un dispositivo táctil basado en el tamaño y plataforma
    return mediaQuery.size.width < 1024 ||
           mediaQuery.size.height < 768;
  }

  static bool isDesktopDevice(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  static bool supportsHover(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }


  static double getOptimalTextScaleFactor(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;

    // Ajustar escala de texto basada en el tamaño de pantalla
    if (width < 375) {
      return 0.85;
    } else if (width < 414) {
      return 0.9;
    } else if (width < 768) {
      return 0.95;
    } else if (width < 1024) {
      return 1.0;
    } else if (width < 1440) {
      return 1.05;
    } else {
      return 1.1;
    }
  }

  static bool shouldUseCompactLayout(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < 600;
  }

  static bool shouldUseTabletLayout(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1024;
  }

  static bool shouldUseDesktopLayout(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 1024;
  }
}

/// Gestor avanzado de navegación responsive
class ResponsiveNavigationManager {
  static NavigationType getOptimalNavigationType(BuildContext context) {
    if (DeviceCapabilities.isTouchDevice(context)) {
      if (ResponsiveUtils.isCompactMobile(context)) {
        return NavigationType.bottomNavigation;
      } else if (ResponsiveUtils.isTablet(context)) {
        return NavigationType.navigationRail;
      } else {
        return NavigationType.bottomNavigation;
      }
    } else {
      return NavigationType.permanentDrawer;
    }
  }

  static double getNavigationWidth(BuildContext context) {
    final navigationType = getOptimalNavigationType(context);

    switch (navigationType) {
      case NavigationType.bottomNavigation:
        return MediaQuery.of(context).size.width;
      case NavigationType.navigationRail:
        return 80;
      case NavigationType.permanentDrawer:
        return 280;
      case NavigationType.modalDrawer:
        return 320;
    }
  }

  static bool shouldShowLabels(BuildContext context) {
    final navigationType = getOptimalNavigationType(context);

    switch (navigationType) {
      case NavigationType.bottomNavigation:
        return !ResponsiveUtils.isCompactMobile(context);
      case NavigationType.navigationRail:
        return false; // Íconos extendidos
      case NavigationType.permanentDrawer:
        return true;
      case NavigationType.modalDrawer:
        return true;
    }
  }
}

/// Tipos de navegación disponibles
enum NavigationType {
  bottomNavigation,
  navigationRail,
  permanentDrawer,
  modalDrawer,
}

/// Gestor de layouts adaptativos
class ResponsiveLayoutManager {
  static LayoutType getOptimalLayoutType(BuildContext context, String screenName) {
    final width = MediaQuery.of(context).size.width;

    switch (screenName) {
      case 'dashboard':
        if (width < 768) {
          return LayoutType.singleColumn;
        } else if (width < 1024) {
          return LayoutType.twoColumn;
        } else {
          return LayoutType.threeColumn;
        }

      case 'products':
        if (width < 768) {
          return LayoutType.listView;
        } else {
          return LayoutType.gridView;
        }

      case 'sales':
        if (width < 768) {
          return LayoutType.compactForm;
        } else {
          return LayoutType.expandedForm;
        }

      default:
        return LayoutType.adaptive;
    }
  }

  static int getGridCrossAxisCount(BuildContext context, String screenName) {
    final width = MediaQuery.of(context).size.width;

    switch (screenName) {
      case 'products':
        if (width < 600) return 1;
        if (width < 900) return 2;
        if (width < 1200) return 3;
        if (width < 1600) return 4;
        return 5;

      case 'dashboard':
        if (width < 768) return 1;
        if (width < 1024) return 2;
        return 3;

      default:
        return ResponsiveUtils.getResponsiveGridCrossAxisCount(context);
    }
  }
}

/// Tipos de layout disponibles
enum LayoutType {
  singleColumn,
  twoColumn,
  threeColumn,
  listView,
  gridView,
  compactForm,
  expandedForm,
  adaptive,
}

/// Gestor de animaciones responsive
class ResponsiveAnimationManager {
  static Duration getOptimalAnimationDuration(BuildContext context, AnimationType type) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final isSlowDevice = MediaQuery.of(context).devicePixelRatio < 2.0;

    Duration baseDuration;
    switch (type) {
      case AnimationType.micro:
        baseDuration = const Duration(milliseconds: 150);
        break;
      case AnimationType.fast:
        baseDuration = const Duration(milliseconds: 200);
        break;
      case AnimationType.normal:
        baseDuration = const Duration(milliseconds: 300);
        break;
      case AnimationType.slow:
        baseDuration = const Duration(milliseconds: 500);
        break;
    }

    // Ajustar para dispositivos móviles o lentos
    if (isMobile || isSlowDevice) {
      return Duration(milliseconds: (baseDuration.inMilliseconds * 1.2).round());
    }

    return baseDuration;
  }

  static Curve getOptimalAnimationCurve(BuildContext context, AnimationType type) {
    final isMobile = ResponsiveUtils.isMobile(context);

    switch (type) {
      case AnimationType.micro:
        return Curves.easeOut;
      case AnimationType.fast:
        return isMobile ? Curves.easeOut : Curves.easeInOut;
      case AnimationType.normal:
        return Curves.easeInOut;
      case AnimationType.slow:
        return Curves.easeInOutCubic;
    }
  }
}

/// Tipos de animación
enum AnimationType {
  micro,
  fast,
  normal,
  slow,
}