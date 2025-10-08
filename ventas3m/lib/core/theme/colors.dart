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

// Colores para modo oscuro
abstract class AppDarkColors {
  // Colores empresariales principales (modo oscuro)
   static const Color primary = Color(0xFF2196F3);        // Azul más claro para oscuro
   static const Color secondary = Color(0xFF66BB6A);      // Verde más claro para oscuro
   static const Color tertiary = Color(0xFFFFB74D);       // Naranja más claro para oscuro
   static const Color error = Color(0xFFEF5350);          // Rojo más claro para oscuro
   static const Color surface = Color(0xFF212121);        // Superficie oscura con mejor contraste

  // Colores adicionales para ventas (modo oscuro) - Más vibrantes para mejor visibilidad
  static const Color sales = Color(0xFF4FC3F7);          // Azul ventas más claro y vibrante
  static const Color products = Color(0xFFE1BEE7);       // Púrpura productos más claro
  static const Color expenses = Color(0xFFF8BBD9);       // Rosa gastos más claro

  // Colores de superficie y fondo (modo oscuro)
  static const Color background = Color(0xFF000000);      // Fondo completamente negro
  static const Color surfaceVariant = Color(0xFF1C1B1F); // Superficie variante oscura
  static const Color cardBackground = Color(0xFF1E1E1E); // Fondo tarjetas oscuro

  // Colores para texto (modo oscuro) - Mejor contraste
  static const Color textPrimary = Color(0xFFFFFFFF);    // Texto principal blanco
  static const Color textSecondary = Color(0xFFF5F5F5);  // Texto secundario blanco más puro
  static const Color textDisabled = Color(0xFFBDBDBD);   // Texto deshabilitado gris más claro
  static const Color textOnPrimary = Color(0xFF000000);  // Texto sobre primario negro

  // Estados de componentes (modo oscuro)
  static const Color hover = Color(0xFF3949AB);           // Hover azul más claro para mejor contraste
  static const Color focus = Color(0xFF42A5F5);          // Focus azul más visible
  static const Color disabled = Color(0xFF424242);       // Deshabilitado gris más claro para mejor contraste

  // Bordes y divisores (modo oscuro) - Mejor contraste
  static const Color border = Color(0xFF424242);         // Borde gris más claro
  static const Color divider = Color(0xFF616161);        // Divisor gris más visible

  // Sombras (modo oscuro)
  static const Color shadow = Color(0x33000000);         // Sombra negra 20%

  // Colores específicos para avatares en tema oscuro
  static const Color avatarProfile = Color(0xFFBA68C8);   // Púrpura más claro
  static const Color avatarProjects = Color(0xFF81C784);  // Verde más claro
  static const Color avatarSettings = Color(0xFFFFB74D);  // Naranja más claro
  static const Color avatarTheme = Color(0xFF7986CB);     // Índigo más claro
  static const Color avatarLogout = Color(0xFFE57373);    // Rojo más claro
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