import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';
import 'responsive_theme.dart';

// Tema principal de la aplicación de ventas 3M
class AppTheme {
  // Tema claro (modo principal)
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Esquema de colores principal
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

    // Tipografía
    textTheme: appTextTheme,

    // Configuración de componentes principales
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      elevation: 2,
      shadowColor: AppColors.shadow,
      surfaceTintColor: AppColors.primary,
      titleTextStyle: TextStyle(
        fontFamily: 'Lufga',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnPrimary,
      ),
      iconTheme: IconThemeData(
        color: AppColors.textOnPrimary,
        size: 24,
      ),
    ),

    // Tarjetas
    cardTheme: CardThemeData(
      color: AppColors.cardBackground,
      elevation: 4,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border, width: 1),
      ),
      margin: EdgeInsets.all(8),
    ),

    // Botones elevados
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 2,
        shadowColor: AppColors.shadow,
        surfaceTintColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontFamily: 'Lufga',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),

    // Botones de texto
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontFamily: 'Lufga',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),

    // Botones outline
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontFamily: 'Lufga',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),

    // Campos de texto
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      labelStyle: const TextStyle(
        fontFamily: 'Lufga',
        color: AppColors.textSecondary,
        fontSize: 16,
      ),
      hintStyle: const TextStyle(
        fontFamily: 'Lufga',
        color: AppColors.textDisabled,
        fontSize: 14,
      ),
      errorStyle: const TextStyle(
        fontFamily: 'Lufga',
        color: AppColors.error,
        fontSize: 12,
      ),
    ),

    // Navegación
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.cardBackground,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      elevation: 8,
      selectedLabelStyle: TextStyle(
        fontFamily: 'Lufga',
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: 'Lufga',
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),

    // Fondo general
    scaffoldBackgroundColor: AppColors.background,

    // Divisor
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    ),

    // Lista
    listTileTheme: const ListTileThemeData(
      tileColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),

    // Diálogos
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.cardBackground,
      elevation: 8,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // SnackBar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceVariant,
      contentTextStyle: const TextStyle(
        fontFamily: 'Lufga',
        color: AppColors.textPrimary,
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),

    // Switch
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.surfaceVariant;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0x80000000);
        }
        return AppColors.border;
      }),
    ),

    // Checkbox
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(AppColors.textOnPrimary),
      side: const BorderSide(color: AppColors.border, width: 1.5),
    ),

    // Radio
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return Colors.transparent;
      }),
    ),

    // Progress indicator
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.surfaceVariant,
    ),

    // FloatingActionButton
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      elevation: 6,
    ),
  );

  // Tema oscuro (modo alternativo)
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Esquema de colores oscuro
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

    // Tipografía (mismo que claro pero optimizada para oscuro)
    textTheme: appTextTheme,

    // AppBar oscuro
    appBarTheme: const AppBarTheme(
      backgroundColor: AppDarkColors.surface,
      foregroundColor: AppDarkColors.textPrimary,
      elevation: 2,
      shadowColor: AppDarkColors.shadow,
      surfaceTintColor: AppDarkColors.primary,
      titleTextStyle: TextStyle(
        fontFamily: 'Lufga',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppDarkColors.textPrimary,
      ),
      iconTheme: IconThemeData(
        color: AppDarkColors.textPrimary,
        size: 24,
      ),
    ),

    // Tarjetas oscuras
    cardTheme: CardThemeData(
      color: AppDarkColors.cardBackground,
      elevation: 4,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppDarkColors.border, width: 1),
      ),
      margin: EdgeInsets.all(8),
    ),

    // Botones elevados oscuros
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppDarkColors.primary,
        foregroundColor: AppDarkColors.textOnPrimary,
        elevation: 2,
        shadowColor: AppDarkColors.shadow,
        surfaceTintColor: AppDarkColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontFamily: 'Lufga',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),

    // Botones de texto oscuros
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppDarkColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontFamily: 'Lufga',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),

    // Botones outline oscuros
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppDarkColors.primary,
        side: const BorderSide(color: AppDarkColors.primary, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontFamily: 'Lufga',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),

    // Campos de texto oscuros
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppDarkColors.surfaceVariant,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppDarkColors.border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppDarkColors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppDarkColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppDarkColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppDarkColors.error, width: 2),
      ),
      labelStyle: const TextStyle(
        fontFamily: 'Lufga',
        color: AppDarkColors.textSecondary,
        fontSize: 16,
      ),
      hintStyle: const TextStyle(
        fontFamily: 'Lufga',
        color: AppDarkColors.textDisabled,
        fontSize: 14,
      ),
      errorStyle: const TextStyle(
        fontFamily: 'Lufga',
        color: AppDarkColors.error,
        fontSize: 12,
      ),
    ),

    // Navegación oscura
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppDarkColors.cardBackground,
      selectedItemColor: AppDarkColors.primary,
      unselectedItemColor: AppDarkColors.textSecondary,
      elevation: 8,
      selectedLabelStyle: TextStyle(
        fontFamily: 'Lufga',
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: 'Lufga',
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),

    // Fondo oscuro
    scaffoldBackgroundColor: AppDarkColors.background,

    // Divisor oscuro
    dividerTheme: const DividerThemeData(
      color: AppDarkColors.divider,
      thickness: 1,
      space: 1,
    ),

    // Lista oscura
    listTileTheme: const ListTileThemeData(
      tileColor: AppDarkColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),

    // Diálogos oscuros
    dialogTheme: DialogThemeData(
      backgroundColor: AppDarkColors.cardBackground,
      elevation: 8,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // SnackBar oscuro
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppDarkColors.surfaceVariant,
      contentTextStyle: const TextStyle(
        fontFamily: 'Lufga',
        color: AppDarkColors.textPrimary,
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),

    // Switch oscuro
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppDarkColors.primary;
        }
        return AppDarkColors.surfaceVariant;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0x80000000);
        }
        return AppDarkColors.border;
      }),
    ),

    // Checkbox oscuro
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppDarkColors.primary;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(AppDarkColors.textOnPrimary),
      side: const BorderSide(color: AppDarkColors.border, width: 1.5),
    ),

    // Radio oscuro
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppDarkColors.primary;
        }
        return Colors.transparent;
      }),
    ),

    // Progress indicator oscuro
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppDarkColors.primary,
      linearTrackColor: AppDarkColors.surfaceVariant,
    ),

    // FloatingActionButton oscuro
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppDarkColors.primary,
      foregroundColor: AppDarkColors.textOnPrimary,
      elevation: 6,
    ),
  );

  // Tema de alto contraste (para accesibilidad)
  static ThemeData get highContrastTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Esquema de colores de alto contraste
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

    // Tipografía de alto contraste
    textTheme: TextTheme(
      // Títulos principales - mayor contraste
      headlineLarge: const TextStyle(
        fontFamily: 'Lufga',
        fontSize: 32,
        fontWeight: FontWeight.w900,
        height: 1.2,
        color: Colors.black,
        shadows: [Shadow(color: Colors.white, blurRadius: 2)],
      ),
      headlineMedium: const TextStyle(
        fontFamily: 'Lufga',
        fontSize: 28,
        fontWeight: FontWeight.w800,
        height: 1.25,
        color: Colors.black,
        shadows: [Shadow(color: Colors.white, blurRadius: 2)],
      ),
      headlineSmall: const TextStyle(
        fontFamily: 'Lufga',
        fontSize: 24,
        fontWeight: FontWeight.w800,
        height: 1.3,
        color: Colors.black,
        shadows: [Shadow(color: Colors.white, blurRadius: 2)],
      ),

      // Subtítulos
      titleLarge: const TextStyle(
        fontFamily: 'Lufga',
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: Colors.black,
      ),
      titleMedium: const TextStyle(
        fontFamily: 'Lufga',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.4,
        color: Colors.black,
      ),
      titleSmall: const TextStyle(
        fontFamily: 'Lufga',
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1.4,
        color: Colors.black,
      ),

      // Texto de cuerpo
      bodyLarge: const TextStyle(
        fontFamily: 'Lufga',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.5,
        color: Colors.black,
      ),
      bodyMedium: const TextStyle(
        fontFamily: 'Lufga',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.5,
        color: Colors.black,
      ),

      // Texto de botones
      labelLarge: const TextStyle(
        fontFamily: 'Lufga',
        fontSize: 14,
        fontWeight: FontWeight.w800,
        height: 1.4,
        letterSpacing: 0.2,
        color: Colors.black,
      ),

      // Captions y texto pequeño
      bodySmall: const TextStyle(
        fontFamily: 'Lufga',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: Colors.black,
      ),

      // Estados especiales
      displayLarge: const TextStyle(
        fontFamily: 'Lufga',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: Colors.black,
      ),
      displayMedium: const TextStyle(
        fontFamily: 'Lufga',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: Colors.black,
      ),
      displaySmall: const TextStyle(
        fontFamily: 'Lufga',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: Colors.black,
      ),
    ),

    // AppBar de alto contraste
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 4,
      surfaceTintColor: Colors.white,
      titleTextStyle: TextStyle(
        fontFamily: 'Lufga',
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: Colors.black,
        shadows: [Shadow(color: Colors.white, blurRadius: 2)],
      ),
      iconTheme: IconThemeData(
        color: Colors.black,
        size: 24,
      ),
    ),

    // Tarjetas de alto contraste
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 8,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.black, width: 2),
      ),
      margin: EdgeInsets.all(8),
    ),

    // Botones de alto contraste
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 4,
        surfaceTintColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.black, width: 2),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontFamily: 'Lufga',
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
    ),

    // Campos de texto de alto contraste
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.black, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.black, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.black, width: 3),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFB71C1C), width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFB71C1C), width: 3),
      ),
      labelStyle: const TextStyle(
        fontFamily: 'Lufga',
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      hintStyle: const TextStyle(
        fontFamily: 'Lufga',
        color: Color(0xFF666666),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      errorStyle: const TextStyle(
        fontFamily: 'Lufga',
        color: Color(0xFFB71C1C),
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    ),

    // Navegación de alto contraste
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Colors.black,
      unselectedItemColor: Color(0xFF666666),
      elevation: 8,
      selectedLabelStyle: TextStyle(
        fontFamily: 'Lufga',
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: 'Lufga',
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Fondo de alto contraste
    scaffoldBackgroundColor: Colors.white,

    // Divisor de alto contraste
    dividerTheme: const DividerThemeData(
      color: Colors.black,
      thickness: 2,
      space: 2,
    ),

    // Lista de alto contraste
    listTileTheme: const ListTileThemeData(
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        side: BorderSide(color: Colors.black, width: 1),
      ),
    ),

    // Diálogos de alto contraste
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      elevation: 12,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.black, width: 3),
      ),
    ),

    // SnackBar de alto contraste
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Color(0xFFF5F5F5),
      contentTextStyle: const TextStyle(
        fontFamily: 'Lufga',
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.black, width: 1),
      ),
    ),

    // Switch de alto contraste
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.black;
        }
        return Colors.white;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return Color(0xFFCCCCCC);
        }
        return Color(0xFF666666);
      }),
    ),

    // Checkbox de alto contraste
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.black;
        }
        return Colors.white;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
      side: const BorderSide(color: Colors.black, width: 2),
    ),

    // Radio de alto contraste
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.black;
        }
        return Colors.white;
      }),
    ),

    // Progress indicator de alto contraste
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Colors.black,
      linearTrackColor: Color(0xFFE0E0E0),
    ),

    // FloatingActionButton de alto contraste
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 8,
    ),
  );

  // Método para obtener tema según configuración
  static ThemeData getTheme({required bool isDark, required bool highContrast}) {
    if (highContrast) {
      return highContrastTheme;
    } else if (isDark) {
      return darkTheme;
    } else {
      return lightTheme;
    }
  }

  // Método para obtener tema responsivo según configuración y contexto
  static ThemeData getResponsiveTheme({
    required BuildContext context,
    required bool isDark,
    required bool highContrast,
  }) {
    return ResponsiveAppTheme.getResponsiveTheme(
      context: context,
      isDark: isDark,
      highContrast: highContrast,
    );
  }

  // Método para obtener tema responsivo usando el tema actual como base
  static ThemeData getResponsiveThemeFromCurrent({
    required BuildContext context,
    required ThemeData currentTheme,
  }) {
    // Determinar si es tema oscuro y alto contraste basado en el tema actual
    final isDark = currentTheme.brightness == Brightness.dark;
    final highContrast = _isHighContrastTheme(currentTheme);

    return ResponsiveAppTheme.getResponsiveTheme(
      context: context,
      isDark: isDark,
      highContrast: highContrast,
    );
  }

  // Método auxiliar para detectar tema de alto contraste
  static bool _isHighContrastTheme(ThemeData theme) {
    // Detectar alto contraste por colores extremos (negro sobre blanco)
    return theme.colorScheme.primary == Colors.black &&
           theme.colorScheme.onPrimary == Colors.white &&
           theme.colorScheme.surface == Colors.white &&
           theme.colorScheme.onSurface == Colors.black;
  }

  // Método para obtener tema responsivo para modo claro
  static ThemeData getResponsiveLightTheme(BuildContext context) {
    return ResponsiveAppTheme.getResponsiveTheme(
      context: context,
      isDark: false,
      highContrast: false,
    );
  }

  // Método para obtener tema responsivo para modo oscuro
  static ThemeData getResponsiveDarkTheme(BuildContext context) {
    return ResponsiveAppTheme.getResponsiveTheme(
      context: context,
      isDark: true,
      highContrast: false,
    );
  }

  // Método para obtener tema responsivo para alto contraste
  static ThemeData getResponsiveHighContrastTheme(BuildContext context) {
    return ResponsiveAppTheme.getResponsiveTheme(
      context: context,
      isDark: false,
      highContrast: true,
    );
  }
}