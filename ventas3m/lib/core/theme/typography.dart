import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';

TextTheme get appTextTheme => TextTheme(
  // Títulos principales
  headlineLarge: TextStyle(
    fontFamily: 'Lufga',
    fontSize: 35,
    fontWeight: FontWeight.w700,
    height: 1.2,
  ),
  headlineMedium: TextStyle(
    fontFamily: 'Lufga',
    fontSize: 31,
    fontWeight: FontWeight.w600,
    height: 1.25,
  ),
  headlineSmall: TextStyle(
    fontFamily: 'Lufga',
    fontSize: 26,
    fontWeight: FontWeight.w600,
    height: 1.3,
  ),

  // Subtítulos
  titleLarge: TextStyle(
    fontFamily: 'Lufga',
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1.3,
  ),
  titleMedium: TextStyle(
    fontFamily: 'Lufga',
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.4,
  ),
  titleSmall: TextStyle(
    fontFamily: 'Lufga',
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.4,
  ),

  // Texto de cuerpo
  bodyLarge: TextStyle(
    fontFamily: 'Lufga',
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.5,
  ),
  bodyMedium: TextStyle(
    fontFamily: 'Lufga',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
  ),

  // Texto de botones
  labelLarge: TextStyle(
    fontFamily: 'Lufga',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.1,
  ),

  // Captions y texto pequeño
  bodySmall: TextStyle(
    fontFamily: 'Lufga',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
  ),

  // Estados especiales
  displayLarge: TextStyle(
    fontFamily: 'Lufga',
    fontSize: 22,
    fontWeight: FontWeight.w500,
    height: 1.3,
  ),
  displayMedium: TextStyle(
    fontFamily: 'Lufga',
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 1.3,
  ),
  displaySmall: TextStyle(
    fontFamily: 'Lufga',
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.3,
  ),
);

/// Obtiene el tema de texto responsivo basado en el contexto
TextTheme getResponsiveTextTheme(BuildContext context) {
 final responsiveSize = ResponsiveUtils.getCurrentSize(context);
 final densityMultiplier = ResponsiveDensityHandler.getDensityMultiplier(context);
 final mediaQuery = MediaQuery.of(context);
 final textScaler = mediaQuery.textScaler;

 // Función auxiliar para calcular tamaños responsivos
 double getResponsiveFontSize(double baseSize) {
   double size = baseSize * densityMultiplier * textScaler.scale(baseSize);

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
     fontSize: getResponsiveFontSize(35),
     fontWeight: FontWeight.w700,
     height: getResponsiveHeight(1.2),
   ),
   headlineMedium: TextStyle(
     fontFamily: 'Lufga',
     fontSize: getResponsiveFontSize(31),
     fontWeight: FontWeight.w600,
     height: getResponsiveHeight(1.25),
   ),
   headlineSmall: TextStyle(
     fontFamily: 'Lufga',
     fontSize: getResponsiveFontSize(26),
     fontWeight: FontWeight.w600,
     height: getResponsiveHeight(1.3),
   ),

   // Subtítulos
   titleLarge: TextStyle(
     fontFamily: 'Lufga',
     fontSize: getResponsiveFontSize(24),
     fontWeight: FontWeight.w500,
     height: getResponsiveHeight(1.3),
   ),
   titleMedium: TextStyle(
     fontFamily: 'Lufga',
     fontSize: getResponsiveFontSize(18),
     fontWeight: FontWeight.w500,
     height: getResponsiveHeight(1.4),
   ),
   titleSmall: TextStyle(
     fontFamily: 'Lufga',
     fontSize: getResponsiveFontSize(15),
     fontWeight: FontWeight.w500,
     height: getResponsiveHeight(1.4),
   ),

   // Texto de cuerpo
   bodyLarge: TextStyle(
     fontFamily: 'Lufga',
     fontSize: getResponsiveFontSize(18),
     fontWeight: FontWeight.w400,
     height: getResponsiveHeight(1.5),
   ),
   bodyMedium: TextStyle(
     fontFamily: 'Lufga',
     fontSize: getResponsiveFontSize(15),
     fontWeight: FontWeight.w400,
     height: getResponsiveHeight(1.5),
   ),

   // Texto de botones
   labelLarge: TextStyle(
     fontFamily: 'Lufga',
     fontSize: getResponsiveFontSize(15),
     fontWeight: FontWeight.w600,
     height: getResponsiveHeight(1.4),
     letterSpacing: 0.1,
   ),

   // Captions y texto pequeño
   bodySmall: TextStyle(
     fontFamily: 'Lufga',
     fontSize: getResponsiveFontSize(13),
     fontWeight: FontWeight.w400,
     height: getResponsiveHeight(1.4),
   ),

   // Estados especiales
   displayLarge: TextStyle(
     fontFamily: 'Lufga',
     fontSize: getResponsiveFontSize(22),
     fontWeight: FontWeight.w500,
     height: getResponsiveHeight(1.3),
   ),
   displayMedium: TextStyle(
     fontFamily: 'Lufga',
     fontSize: getResponsiveFontSize(20),
     fontWeight: FontWeight.w500,
     height: getResponsiveHeight(1.3),
   ),
   displaySmall: TextStyle(
     fontFamily: 'Lufga',
     fontSize: getResponsiveFontSize(18),
     fontWeight: FontWeight.w500,
     height: getResponsiveHeight(1.3),
   ),
 );
}

/// Obtiene el tamaño de fuente responsivo para un estilo específico
double getResponsiveFontSize(BuildContext context, double baseSize) {
 final responsiveSize = ResponsiveUtils.getCurrentSize(context);
 final densityMultiplier = ResponsiveDensityHandler.getDensityMultiplier(context);
 final mediaQuery = MediaQuery.of(context);
 final textScaler = mediaQuery.textScaler;

 double size = baseSize * densityMultiplier * textScaler.scale(baseSize);

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

/// Crea diferentes escalas tipográficas para diferentes dispositivos
class TypographyScale {
 /// Escala móvil optimizada para pantallas pequeñas
 static TextTheme getMobileScale(BuildContext context) {
   final mediaQuery = MediaQuery.of(context);
   final textScaler = mediaQuery.textScaler;

   return TextTheme(
     headlineLarge: TextStyle(
       fontFamily: 'Lufga',
       fontSize: 31 * textScaler.scale(31),
       fontWeight: FontWeight.w700,
       height: 1.15,
     ),
     headlineMedium: TextStyle(
       fontFamily: 'Lufga',
       fontSize: 26 * textScaler.scale(26),
       fontWeight: FontWeight.w600,
       height: 1.2,
     ),
     headlineSmall: TextStyle(
       fontFamily: 'Lufga',
       fontSize: 22 * textScaler.scale(22),
       fontWeight: FontWeight.w600,
       height: 1.25,
     ),
     titleLarge: TextStyle(
       fontFamily: 'Lufga',
       fontSize: 20 * textScaler.scale(20),
       fontWeight: FontWeight.w500,
       height: 1.25,
     ),
     titleMedium: TextStyle(
       fontFamily: 'Lufga',
       fontSize: 15 * textScaler.scale(15),
       fontWeight: FontWeight.w500,
       height: 1.3,
     ),
     titleSmall: TextStyle(
       fontFamily: 'Lufga',
       fontSize: 13 * textScaler.scale(13),
       fontWeight: FontWeight.w500,
       height: 1.3,
     ),
     bodyLarge: TextStyle(
       fontFamily: 'Lufga',
       fontSize: 15 * textScaler.scale(15),
       fontWeight: FontWeight.w400,
       height: 1.4,
     ),
     bodyMedium: TextStyle(
       fontFamily: 'Lufga',
       fontSize: 13 * textScaler.scale(13),
       fontWeight: FontWeight.w400,
       height: 1.4,
     ),
     labelLarge: TextStyle(
       fontFamily: 'Lufga',
       fontSize: 13 * textScaler.scale(13),
       fontWeight: FontWeight.w600,
       height: 1.3,
       letterSpacing: 0.1,
     ),
     bodySmall: TextStyle(
       fontFamily: 'Lufga',
       fontSize: 11 * textScaler.scale(11),
       fontWeight: FontWeight.w400,
       height: 1.3,
     ),
     displayLarge: TextStyle(
       fontFamily: 'Lufga',
       fontSize: 18 * textScaler.scale(18),
       fontWeight: FontWeight.w500,
       height: 1.2,
     ),
     displayMedium: TextStyle(
       fontFamily: 'Lufga',
       fontSize: 15 * textScaler.scale(15),
       fontWeight: FontWeight.w500,
       height: 1.2,
     ),
     displaySmall: TextStyle(
       fontFamily: 'Lufga',
       fontSize: 13 * textScaler.scale(13),
       fontWeight: FontWeight.w500,
       height: 1.2,
     ),
   );
 }

 /// Escala tablet optimizada para pantallas medianas
 static TextTheme getTabletScale(BuildContext context) {
   final mediaQuery = MediaQuery.of(context);
   final textScaler = mediaQuery.textScaler;

   return TextTheme(
     headlineLarge: TextStyle(
       fontFamily: 'Lufga',
       fontSize: 35 * textScaler.scale(35),
       fontWeight: FontWeight.w700,
       height: 1.2,
     ),
     headlineMedium: TextStyle(
       fontFamily: 'Lufga',
       fontSize: 31 * textScaler.scale(31),
       fontWeight: FontWeight.w600,
       height: 1.25,
     ),
     headlineSmall: TextStyle(
       fontFamily: 'Lufga',
       fontSize: 26 * textScaler.scale(26),
       fontWeight: FontWeight.w600,
       height: 1.3,
     ),
     titleLarge: TextStyle(
       fontFamily: 'Lufga',
       fontSize: 24 * textScaler.scale(24),
       fontWeight: FontWeight.w500,
       height: 1.3,
     ),
     titleMedium: TextStyle(
       fontFamily: 'Lufga',
       fontSize: 18 * textScaler.scale(18),
       fontWeight: FontWeight.w500,
       height: 1.4,
     ),
     titleSmall: TextStyle(
       fontFamily: 'Lufga',
       fontSize: 15 * textScaler.scale(15),
       fontWeight: FontWeight.w500,
       height: 1.4,
     ),
     bodyLarge: TextStyle(
       fontFamily: 'Lufga',
       fontSize: 18 * textScaler.scale(18),
       fontWeight: FontWeight.w400,
       height: 1.5,
     ),
     bodyMedium: TextStyle(
       fontFamily: 'Lufga',
       fontSize: 15 * textScaler.scale(15),
       fontWeight: FontWeight.w400,
       height: 1.5,
     ),
     labelLarge: TextStyle(
       fontFamily: 'Lufga',
       fontSize: 15 * textScaler.scale(15),
       fontWeight: FontWeight.w600,
       height: 1.4,
       letterSpacing: 0.1,
     ),
     bodySmall: TextStyle(
       fontFamily: 'Lufga',
       fontSize: 13 * textScaler.scale(13),
       fontWeight: FontWeight.w400,
       height: 1.4,
     ),
     displayLarge: TextStyle(
       fontFamily: 'Lufga',
       fontSize: 22 * textScaler.scale(22),
       fontWeight: FontWeight.w500,
       height: 1.3,
     ),
     displayMedium: TextStyle(
       fontFamily: 'Lufga',
       fontSize: 20 * textScaler.scale(20),
       fontWeight: FontWeight.w500,
       height: 1.3,
     ),
     displaySmall: TextStyle(
       fontFamily: 'Lufga',
       fontSize: 18 * textScaler.scale(18),
       fontWeight: FontWeight.w500,
       height: 1.3,
     ),
   );
 }

 /// Escala escritorio optimizada para pantallas grandes
 static TextTheme getDesktopScale(BuildContext context) {
   final mediaQuery = MediaQuery.of(context);
   final textScaler = mediaQuery.textScaler;

   return TextTheme(
     headlineLarge: TextStyle(
       fontFamily: 'Lufga',
       fontSize: 39 * textScaler.scale(39),
       fontWeight: FontWeight.w700,
       height: 1.2,
     ),
     headlineMedium: TextStyle(
       fontFamily: 'Lufga',
       fontSize: 35 * textScaler.scale(35),
       fontWeight: FontWeight.w600,
       height: 1.25,
     ),
     headlineSmall: TextStyle(
       fontFamily: 'Lufga',
       fontSize: 31 * textScaler.scale(31),
       fontWeight: FontWeight.w600,
       height: 1.3,
     ),
     titleLarge: TextStyle(
       fontFamily: 'Lufga',
       fontSize: 26 * textScaler.scale(26),
       fontWeight: FontWeight.w500,
       height: 1.3,
     ),
     titleMedium: TextStyle(
       fontFamily: 'Lufga',
       fontSize: 20 * textScaler.scale(20),
       fontWeight: FontWeight.w500,
       height: 1.4,
     ),
     titleSmall: TextStyle(
       fontFamily: 'Lufga',
       fontSize: 18 * textScaler.scale(18),
       fontWeight: FontWeight.w500,
       height: 1.4,
     ),
     bodyLarge: TextStyle(
       fontFamily: 'Lufga',
       fontSize: 20 * textScaler.scale(20),
       fontWeight: FontWeight.w400,
       height: 1.5,
     ),
     bodyMedium: TextStyle(
       fontFamily: 'Lufga',
       fontSize: 18 * textScaler.scale(18),
       fontWeight: FontWeight.w400,
       height: 1.5,
     ),
     labelLarge: TextStyle(
       fontFamily: 'Lufga',
       fontSize: 18 * textScaler.scale(18),
       fontWeight: FontWeight.w600,
       height: 1.4,
       letterSpacing: 0.1,
     ),
     bodySmall: TextStyle(
       fontFamily: 'Lufga',
       fontSize: 15 * textScaler.scale(15),
       fontWeight: FontWeight.w400,
       height: 1.4,
     ),
     displayLarge: TextStyle(
       fontFamily: 'Lufga',
       fontSize: 24 * textScaler.scale(24),
       fontWeight: FontWeight.w500,
       height: 1.3,
     ),
     displayMedium: TextStyle(
       fontFamily: 'Lufga',
       fontSize: 22 * textScaler.scale(22),
       fontWeight: FontWeight.w500,
       height: 1.3,
     ),
     displaySmall: TextStyle(
       fontFamily: 'Lufga',
       fontSize: 20 * textScaler.scale(20),
       fontWeight: FontWeight.w500,
       height: 1.3,
     ),
   );
 }

 /// Obtiene la escala tipográfica apropiada según el dispositivo
 static TextTheme getScaleForDevice(BuildContext context) {
   final responsiveSize = ResponsiveUtils.getCurrentSize(context);

   switch (responsiveSize) {
     case ResponsiveSize.mobile:
       return getMobileScale(context);
     case ResponsiveSize.tablet:
       return getTabletScale(context);
     case ResponsiveSize.desktop:
       return getDesktopScale(context);
   }
 }
}