import 'package:flutter/material.dart';
import 'colors.dart';
import '../utils/responsive_utils.dart';

/// Clase para manejar tipografía responsiva
class ResponsiveTypography {
  /// Obtiene el tema de texto responsivo basado en el contexto
  static TextTheme getResponsiveTextTheme(BuildContext context) {
    final responsiveSize = ResponsiveUtils.getCurrentSize(context);
    final densityMultiplier = ResponsiveDensityHandler.getDensityMultiplier(context);
    final textScaler = MediaQuery.textScalerOf(context);

    // Función auxiliar para calcular tamaños responsivos
    double getResponsiveFontSize(double baseSize) {
      double size = textScaler.scale(baseSize * densityMultiplier);

      // Ajustes según el tamaño de dispositivo
      switch (responsiveSize) {
        case ResponsiveSize.mobile:
          size *= 0.9;
          break;
        case ResponsiveSize.tablet:
          size *= 1.0;
          break;
        case ResponsiveSize.desktop:
          size *= 1.1;
          break;
      }

      return size;
    }

    double getResponsiveHeight(double baseHeight) {
      double height = baseHeight * densityMultiplier;

      // Ajustes según el tamaño de dispositivo
      switch (responsiveSize) {
        case ResponsiveSize.mobile:
          height *= 0.95;
          break;
        case ResponsiveSize.tablet:
          height *= 1.0;
          break;
        case ResponsiveSize.desktop:
          height *= 1.05;
          break;
      }

      return height;
    }

    return TextTheme(
      // Títulos principales
      headlineLarge: TextStyle(
        fontFamily: 'Lufga',
        fontSize: getResponsiveFontSize(32),
        fontWeight: FontWeight.w700,
        height: getResponsiveHeight(1.2),
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Lufga',
        fontSize: getResponsiveFontSize(28),
        fontWeight: FontWeight.w600,
        height: getResponsiveHeight(1.25),
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Lufga',
        fontSize: getResponsiveFontSize(24),
        fontWeight: FontWeight.w600,
        height: getResponsiveHeight(1.3),
      ),

      // Subtítulos
      titleLarge: TextStyle(
        fontFamily: 'Lufga',
        fontSize: getResponsiveFontSize(22),
        fontWeight: FontWeight.w500,
        height: getResponsiveHeight(1.3),
      ),
      titleMedium: TextStyle(
        fontFamily: 'Lufga',
        fontSize: getResponsiveFontSize(16),
        fontWeight: FontWeight.w500,
        height: getResponsiveHeight(1.4),
      ),
      titleSmall: TextStyle(
        fontFamily: 'Lufga',
        fontSize: getResponsiveFontSize(14),
        fontWeight: FontWeight.w500,
        height: getResponsiveHeight(1.4),
      ),

      // Texto de cuerpo
      bodyLarge: TextStyle(
        fontFamily: 'Lufga',
        fontSize: getResponsiveFontSize(16),
        fontWeight: FontWeight.w400,
        height: getResponsiveHeight(1.5),
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Lufga',
        fontSize: getResponsiveFontSize(14),
        fontWeight: FontWeight.w400,
        height: getResponsiveHeight(1.5),
      ),

      // Texto de botones
      labelLarge: TextStyle(
        fontFamily: 'Lufga',
        fontSize: getResponsiveFontSize(14),
        fontWeight: FontWeight.w600,
        height: getResponsiveHeight(1.4),
        letterSpacing: 0.1,
      ),

      // Captions y texto pequeño
      bodySmall: TextStyle(
        fontFamily: 'Lufga',
        fontSize: getResponsiveFontSize(12),
        fontWeight: FontWeight.w400,
        height: getResponsiveHeight(1.4),
      ),

      // Estados especiales
      displayLarge: TextStyle(
        fontFamily: 'Lufga',
        fontSize: getResponsiveFontSize(20),
        fontWeight: FontWeight.w500,
        height: getResponsiveHeight(1.3),
      ),
      displayMedium: TextStyle(
        fontFamily: 'Lufga',
        fontSize: getResponsiveFontSize(18),
        fontWeight: FontWeight.w500,
        height: getResponsiveHeight(1.3),
      ),
      displaySmall: TextStyle(
        fontFamily: 'Lufga',
        fontSize: getResponsiveFontSize(16),
        fontWeight: FontWeight.w500,
        height: getResponsiveHeight(1.3),
      ),
    );
  }

  /// Obtiene el tamaño de fuente responsivo para un estilo específico
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final responsiveSize = ResponsiveUtils.getCurrentSize(context);
    final densityMultiplier = ResponsiveDensityHandler.getDensityMultiplier(context);
    final textScaler = MediaQuery.textScalerOf(context);

    double size = textScaler.scale(baseSize * densityMultiplier);

    // Ajustes según el tamaño de dispositivo
    switch (responsiveSize) {
      case ResponsiveSize.mobile:
        size *= 0.9;
        break;
      case ResponsiveSize.tablet:
        size *= 1.0;
        break;
      case ResponsiveSize.desktop:
        size *= 1.1;
        break;
    }

    return size;
  }
}

/// Clase para manejar temas responsivos
class ResponsiveAppTheme {
  /// Obtiene el tema responsivo basado en el contexto y configuración
  static ThemeData getResponsiveTheme({
    required BuildContext context,
    required bool isDark,
    required bool highContrast,
  }) {
    final baseTheme = _getBaseTheme(isDark: isDark, highContrast: highContrast);

    return baseTheme.copyWith(
      textTheme: ResponsiveTypography.getResponsiveTextTheme(context),
      appBarTheme: _getResponsiveAppBarTheme(context, isDark),
      cardTheme: _getResponsiveCardTheme(context),
      elevatedButtonTheme: _getResponsiveElevatedButtonTheme(context, baseTheme.elevatedButtonTheme),
      outlinedButtonTheme: _getResponsiveOutlinedButtonTheme(context, baseTheme.outlinedButtonTheme),
      textButtonTheme: _getResponsiveTextButtonTheme(context, baseTheme.textButtonTheme),
      inputDecorationTheme: _getResponsiveInputDecorationTheme(context, baseTheme.inputDecorationTheme),
    );
  }

  /// Obtiene el tema base según configuración de modo
  static ThemeData _getBaseTheme({required bool isDark, required bool highContrast}) {
    if (highContrast) {
      return _getHighContrastTheme();
    } else if (isDark) {
      return _getDarkTheme();
    } else {
      return _getLightTheme();
    }
  }

  /// Tema claro base
  static ThemeData _getLightTheme() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.textOnPrimary,
      primaryContainer: Color(0xFFD3E4FD),
      onPrimaryContainer: Color(0xFF001B3E),
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFA5D6A7),
      onSecondaryContainer: Color(0xFF052100),
      tertiary: AppColors.tertiary,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFFFE0B2),
      onTertiaryContainer: Color(0xFF271900),
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surfaceVariant,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.border,
      outlineVariant: AppColors.divider,
      shadow: AppColors.shadow,
      inverseSurface: Color(0xFF2F3033),
      onInverseSurface: Color(0xFFF4F0E7),
      inversePrimary: Color(0xFFA4C8FF),
      surfaceTint: AppColors.primary,
    ),
    scaffoldBackgroundColor: AppColors.background,
  );

  /// Tema oscuro base
  static ThemeData _getDarkTheme() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppDarkColors.primary,
      onPrimary: AppDarkColors.textOnPrimary,
      primaryContainer: Color(0xFF004A77),
      onPrimaryContainer: Color(0xFFD3E4FD),
      secondary: AppDarkColors.secondary,
      onSecondary: Colors.black,
      secondaryContainer: Color(0xFF205528),
      onSecondaryContainer: Color(0xFFA5D6A7),
      tertiary: AppDarkColors.tertiary,
      onTertiary: Colors.black,
      tertiaryContainer: Color(0xFF5C3C00),
      onTertiaryContainer: Color(0xFFFFE0B2),
      error: AppDarkColors.error,
      onError: Colors.black,
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: AppDarkColors.surface,
      onSurface: AppDarkColors.textPrimary,
      surfaceContainerHighest: AppDarkColors.surfaceVariant,
      onSurfaceVariant: AppDarkColors.textSecondary,
      outline: AppDarkColors.border,
      outlineVariant: AppDarkColors.divider,
      shadow: AppDarkColors.shadow,
      inverseSurface: Color(0xFFE2E2E6),
      onInverseSurface: Color(0xFF1C1B1F),
      inversePrimary: Color(0xFF0061A4),
      surfaceTint: AppDarkColors.primary,
    ),
    scaffoldBackgroundColor: AppDarkColors.background,
  );

  /// Tema de alto contraste base
  static ThemeData _getHighContrastTheme() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Colors.black,
      onPrimary: Colors.white,
      primaryContainer: Colors.white,
      onPrimaryContainer: Colors.black,
      secondary: Colors.black,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFF0F0F0),
      onSecondaryContainer: Colors.black,
      tertiary: Color(0xFF8B4513),
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFFFE0B2),
      onTertiaryContainer: Color(0xFF271900),
      error: Color(0xFFB71C1C),
      onError: Colors.white,
      errorContainer: Color(0xFFFFCDD2),
      onErrorContainer: Color(0xFFB71C1C),
      surface: Colors.white,
      onSurface: Colors.black,
      surfaceContainerHighest: Color(0xFFF5F5F5),
      onSurfaceVariant: Colors.black,
      outline: Colors.black,
      outlineVariant: Color(0xFF666666),
      shadow: Colors.black26,
      inverseSurface: Colors.black,
      onInverseSurface: Colors.white,
      inversePrimary: Colors.black,
      surfaceTint: Colors.black,
    ),
    scaffoldBackgroundColor: Colors.white,
  );

  /// AppBar responsiva
  static AppBarTheme _getResponsiveAppBarTheme(
    BuildContext context,
    bool isDark,
  ) {
    final responsiveSize = ResponsiveUtils.getCurrentSize(context);

    double elevation;
    double iconSize;
    double titleFontSize;

    switch (responsiveSize) {
      case ResponsiveSize.mobile:
        elevation = 2;
        iconSize = 20;
        titleFontSize = 18;
        break;
      case ResponsiveSize.tablet:
        elevation = 3;
        iconSize = 24;
        titleFontSize = 20;
        break;
      case ResponsiveSize.desktop:
        elevation = 4;
        iconSize = 28;
        titleFontSize = 22;
        break;
    }

    return AppBarTheme(
      elevation: elevation,
      iconTheme: IconThemeData(
        color: isDark ? Colors.white : Colors.black,
        size: iconSize,
      ),
      titleTextStyle: TextStyle(
        fontFamily: 'Lufga',
        fontSize: titleFontSize,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }

  /// Tarjetas responsivas
  static CardThemeData _getResponsiveCardTheme(
    BuildContext context,
  ) {
    final responsiveSize = ResponsiveUtils.getCurrentSize(context);

    double elevation = ResponsiveCardProperties.getElevation(responsiveSize);
    double borderRadius = ResponsiveCardProperties.getBorderRadius(responsiveSize);
    EdgeInsetsGeometry margin = EdgeInsets.all(ResponsiveCardProperties.getMargin(responsiveSize));

    return CardThemeData(
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      margin: margin,
    );
  }

  /// Botones elevados responsivos
  static ElevatedButtonThemeData _getResponsiveElevatedButtonTheme(
    BuildContext context,
    ElevatedButtonThemeData? baseTheme,
  ) {
    final responsiveSize = ResponsiveUtils.getCurrentSize(context);

    EdgeInsets padding;
    double fontSize;

    switch (responsiveSize) {
      case ResponsiveSize.mobile:
        padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10);
        fontSize = 13;
        break;
      case ResponsiveSize.tablet:
        padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
        fontSize = 14;
        break;
      case ResponsiveSize.desktop:
        padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 14);
        fontSize = 15;
        break;
    }

    return ElevatedButtonThemeData(
      style: baseTheme?.style?.copyWith(
        padding: WidgetStateProperty.all(padding),
        textStyle: WidgetStateProperty.all(
          TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }

  /// Botones outline responsivos
  static OutlinedButtonThemeData _getResponsiveOutlinedButtonTheme(
    BuildContext context,
    OutlinedButtonThemeData? baseTheme,
  ) {
    final responsiveSize = ResponsiveUtils.getCurrentSize(context);

    EdgeInsets padding;
    double fontSize;

    switch (responsiveSize) {
      case ResponsiveSize.mobile:
        padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10);
        fontSize = 13;
        break;
      case ResponsiveSize.tablet:
        padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
        fontSize = 14;
        break;
      case ResponsiveSize.desktop:
        padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 14);
        fontSize = 15;
        break;
    }

    return OutlinedButtonThemeData(
      style: baseTheme?.style?.copyWith(
        padding: WidgetStateProperty.all(padding),
        textStyle: WidgetStateProperty.all(
          TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }

  /// Botones de texto responsivos
  static TextButtonThemeData _getResponsiveTextButtonTheme(
    BuildContext context,
    TextButtonThemeData? baseTheme,
  ) {
    final responsiveSize = ResponsiveUtils.getCurrentSize(context);

    EdgeInsets padding;
    double fontSize;

    switch (responsiveSize) {
      case ResponsiveSize.mobile:
        padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10);
        fontSize = 13;
        break;
      case ResponsiveSize.tablet:
        padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
        fontSize = 14;
        break;
      case ResponsiveSize.desktop:
        padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 14);
        fontSize = 15;
        break;
    }

    return TextButtonThemeData(
      style: baseTheme?.style?.copyWith(
        padding: WidgetStateProperty.all(padding),
        textStyle: WidgetStateProperty.all(
          TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }

  /// Campos de texto responsivos
  static InputDecorationThemeData _getResponsiveInputDecorationTheme(
    BuildContext context,
    InputDecorationThemeData? baseTheme,
  ) {
    final responsiveSize = ResponsiveUtils.getCurrentSize(context);

    EdgeInsetsGeometry contentPadding;
    double fontSize;

    switch (responsiveSize) {
      case ResponsiveSize.mobile:
        contentPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 14);
        fontSize = 14;
        break;
      case ResponsiveSize.tablet:
        contentPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
        fontSize = 16;
        break;
      case ResponsiveSize.desktop:
        contentPadding = const EdgeInsets.symmetric(horizontal: 20, vertical: 18);
        fontSize = 17;
        break;
    }

    return InputDecorationThemeData(
      filled: baseTheme?.filled ?? false,
      fillColor: baseTheme?.fillColor,
      contentPadding: contentPadding,
      border: baseTheme?.border,
      enabledBorder: baseTheme?.enabledBorder,
      focusedBorder: baseTheme?.focusedBorder,
      errorBorder: baseTheme?.errorBorder,
      focusedErrorBorder: baseTheme?.focusedErrorBorder,
      labelStyle: TextStyle(
        fontFamily: 'Lufga',
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        color: baseTheme?.labelStyle?.color,
      ),
      hintStyle: TextStyle(
        fontFamily: 'Lufga',
        fontSize: fontSize - 2,
        fontWeight: FontWeight.w400,
        color: baseTheme?.hintStyle?.color,
      ),
      errorStyle: baseTheme?.errorStyle,
    );
  }
}