import 'package:flutter/material.dart';

// Paleta de colores empresarial 3M para aplicación de ventas
abstract class AppColors {
  // Colores empresariales principales
  static const Color primary = Color(0xFF1976D2);        // Azul empresarial
  static const Color secondary = Color(0xFF4CAF50);      // Verde éxito
  static const Color tertiary = Color(0xFFFF9800);       // Naranja advertencia
  static const Color error = Color(0xFFF44336);          // Rojo error
  static const Color surface = Color(0xFFF5F5F5);        // Gris claro superficie

  // Colores adicionales para ventas
  static const Color sales = Color(0xFF2196F3);          // Azul ventas
  static const Color products = Color(0xFF9C27B0);       // Púrpura productos
  static const Color expenses = Color(0xFFE91E63);       // Rosa gastos

  // Colores de superficie y fondo
  static const Color background = Color(0xFFFAFAFA);      // Fondo principal
  static const Color surfaceVariant = Color(0xFFE0E0E0); // Superficie variante
  static const Color cardBackground = Colors.white;      // Fondo tarjetas

  // Colores para texto
  static const Color textPrimary = Color(0xFF212121);    // Texto principal
  static const Color textSecondary = Color(0xFF424242);  // Texto secundario
  static const Color textDisabled = Color(0xFF666666);   // Texto deshabilitado
  static const Color textOnPrimary = Colors.white;       // Texto sobre primario

  // Estados de componentes
  static const Color hover = Color(0xFFE3F2FD);          // Hover azul claro
  static const Color focus = Color(0xFF1976D2);          // Focus azul
  static const Color disabled = Color(0xFFE0E0E0);       // Deshabilitado gris

  // Bordes y divisores
  static const Color border = Color(0xFFE0E0E0);         // Borde gris claro
  static const Color divider = Color(0xFFBDBDBD);        // Divisor gris medio

  // Sombras
  static const Color shadow = Color(0x1A000000);         // Sombra negra 10%
}

// Gradientes para la aplicación
abstract class AppGradients {
  // Gradiente primario (azul a verde)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [AppColors.primary, AppColors.secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Gradiente de botones (azul a naranja)
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [AppColors.primary, AppColors.tertiary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Gradiente de fondo (superficie a primario con opacidad)
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [AppColors.surface, Color(0x331976D2)], // Azul con 20% opacidad
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Gradiente de éxito (verde a azul)
  static const LinearGradient successGradient = LinearGradient(
    colors: [AppColors.secondary, AppColors.primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Gradiente de advertencia (naranja a rojo)
  static const LinearGradient warningGradient = LinearGradient(
    colors: [AppColors.tertiary, AppColors.error],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Gradiente de tarjetas (blanco a superficie)
  static const LinearGradient cardGradient = LinearGradient(
    colors: [AppColors.cardBackground, AppColors.surface],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Gradiente de ventas (azul ventas a primario)
  static const LinearGradient salesGradient = LinearGradient(
    colors: [AppColors.sales, AppColors.primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Gradiente de productos (púrpura a primario)
  static const LinearGradient productsGradient = LinearGradient(
    colors: [AppColors.products, AppColors.primary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Gradiente de gastos (rosa a error)
  static const LinearGradient expensesGradient = LinearGradient(
    colors: [AppColors.expenses, AppColors.error],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// Colores para modo oscuro
abstract class AppDarkColors {
  // Colores empresariales principales (modo oscuro)
   static const Color primary = Color(0xFF2196F3);        // Azul más claro para oscuro
   static const Color secondary = Color(0xFF66BB6A);      // Verde más claro para oscuro
   static const Color tertiary = Color(0xFFFFB74D);       // Naranja más claro para oscuro
   static const Color error = Color(0xFFEF5350);          // Rojo más claro para oscuro
   static const Color surface = Color(0xFF212121);        // Superficie oscura con mejor contraste

  // Colores adicionales para ventas (modo oscuro)
  static const Color sales = Color(0xFF42A5F5);          // Azul ventas oscuro
  static const Color products = Color(0xFFAB47BC);       // Púrpura productos oscuro
  static const Color expenses = Color(0xFFEC407A);       // Rosa gastos oscuro

  // Colores de superficie y fondo (modo oscuro)
  static const Color background = Color(0xFF000000);      // Fondo completamente negro
  static const Color surfaceVariant = Color(0xFF1C1B1F); // Superficie variante oscura
  static const Color cardBackground = Color(0xFF1E1E1E); // Fondo tarjetas oscuro

  // Colores para texto (modo oscuro)
  static const Color textPrimary = Color(0xFFFFFFFF);    // Texto principal blanco
  static const Color textSecondary = Color(0xFFE0E0E0);  // Texto secundario gris claro (mejor contraste)
  static const Color textDisabled = Color(0xFF9E9E9E);   // Texto deshabilitado gris claro (mejor contraste)
  static const Color textOnPrimary = Color(0xFF000000);  // Texto sobre primario negro

  // Estados de componentes (modo oscuro)
  static const Color hover = Color(0xFF1A237E);           // Hover azul oscuro
  static const Color focus = Color(0xFF2196F3);          // Focus azul claro
  static const Color disabled = Color(0xFF333333);       // Deshabilitado gris oscuro

  // Bordes y divisores (modo oscuro)
  static const Color border = Color(0xFF333333);         // Borde gris oscuro
  static const Color divider = Color(0xFF444444);        // Divisor gris más claro

  // Sombras (modo oscuro)
  static const Color shadow = Color(0x33000000);         // Sombra negra 20%

  // Colores específicos para avatares en tema oscuro
  static const Color avatarProfile = Color(0xFFBA68C8);   // Púrpura más claro
  static const Color avatarProjects = Color(0xFF81C784);  // Verde más claro
  static const Color avatarSettings = Color(0xFFFFB74D);  // Naranja más claro
  static const Color avatarTheme = Color(0xFF7986CB);     // Índigo más claro
  static const Color avatarLogout = Color(0xFFE57373);    // Rojo más claro
}

// Gradientes para modo oscuro
abstract class AppDarkGradients {
  // Gradiente primario oscuro (azul claro a verde claro)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [AppDarkColors.primary, AppDarkColors.secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Gradiente de botones oscuro (azul claro a naranja claro)
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [AppDarkColors.primary, AppDarkColors.tertiary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Gradiente de fondo oscuro (superficie oscura a primario con opacidad)
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [AppDarkColors.surface, Color(0x332196F3)], // Azul claro con 20% opacidad
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Gradiente de éxito oscuro (verde claro a azul claro)
  static const LinearGradient successGradient = LinearGradient(
    colors: [AppDarkColors.secondary, AppDarkColors.primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Gradiente de advertencia oscuro (naranja claro a rojo claro)
  static const LinearGradient warningGradient = LinearGradient(
    colors: [AppDarkColors.tertiary, AppDarkColors.error],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Gradiente de tarjetas oscuro (fondo tarjetas oscuro a superficie oscura)
  static const LinearGradient cardGradient = LinearGradient(
    colors: [AppDarkColors.cardBackground, AppDarkColors.surface],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Gradiente de ventas oscuro (azul ventas oscuro a primario oscuro)
  static const LinearGradient salesGradient = LinearGradient(
    colors: [AppDarkColors.sales, AppDarkColors.primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Gradiente de productos oscuro (púrpura oscuro a primario oscuro)
  static const LinearGradient productsGradient = LinearGradient(
    colors: [AppDarkColors.products, AppDarkColors.primary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Gradiente de gastos oscuro (rosa oscuro a error oscuro)
  static const LinearGradient expensesGradient = LinearGradient(
    colors: [AppDarkColors.expenses, AppDarkColors.error],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// Mapas de colores para acceso programático
const Map<String, Color> appColors = {
  'primary': AppColors.primary,
  'secondary': AppColors.secondary,
  'tertiary': AppColors.tertiary,
  'error': AppColors.error,
  'surface': AppColors.surface,
  'sales': AppColors.sales,
  'products': AppColors.products,
  'expenses': AppColors.expenses,
  'background': AppColors.background,
  'textPrimary': AppColors.textPrimary,
  'textSecondary': AppColors.textSecondary,
};

const Map<String, Color> appDarkColors = {
  'primary': AppDarkColors.primary,
  'secondary': AppDarkColors.secondary,
  'tertiary': AppDarkColors.tertiary,
  'error': AppDarkColors.error,
  'surface': AppDarkColors.surface,
  'sales': AppDarkColors.sales,
  'products': AppDarkColors.products,
  'expenses': AppDarkColors.expenses,
  'background': AppDarkColors.background,
  'textPrimary': AppDarkColors.textPrimary,
  'textSecondary': AppDarkColors.textSecondary,
};