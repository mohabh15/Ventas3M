import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';

/// Sistema avanzado de tipografía responsive
class AdvancedTypography {
  /// Escala tipográfica adaptativa basada en el dispositivo
  static TextTheme getAdaptiveTextTheme(BuildContext context) {
    final baseTheme = Theme.of(context).textTheme;
    final isMobile = ResponsiveUtils.isMobile(context);
    final isTablet = ResponsiveUtils.isTablet(context);

    // Factor de escala basado en el dispositivo
    double scaleFactor;
    if (isMobile) {
      scaleFactor = ResponsiveUtils.isCompactMobile(context) ? 0.85 : 0.95;
    } else if (isTablet) {
      scaleFactor = 1.05;
    } else {
      scaleFactor = 1.1;
    }

    return baseTheme.copyWith(
      // Display styles - para títulos muy grandes
      displayLarge: _createDisplayLarge(context, scaleFactor),
      displayMedium: _createDisplayMedium(context, scaleFactor),
      displaySmall: _createDisplaySmall(context, scaleFactor),

      // Headline styles - para títulos principales
      headlineLarge: _createHeadlineLarge(context, scaleFactor),
      headlineMedium: _createHeadlineMedium(context, scaleFactor),
      headlineSmall: _createHeadlineSmall(context, scaleFactor),

      // Title styles - para subtítulos
      titleLarge: _createTitleLarge(context, scaleFactor),
      titleMedium: _createTitleMedium(context, scaleFactor),
      titleSmall: _createTitleSmall(context, scaleFactor),

      // Body styles - para texto principal
      bodyLarge: _createBodyLarge(context, scaleFactor),
      bodyMedium: _createBodyMedium(context, scaleFactor),
      bodySmall: _createBodySmall(context, scaleFactor),

      // Label styles - para etiquetas y botones
      labelLarge: _createLabelLarge(context, scaleFactor),
      labelMedium: _createLabelMedium(context, scaleFactor),
      labelSmall: _createLabelSmall(context, scaleFactor),
    );
  }

  /// Crea estilo para display large con ajustes responsivos
  static TextStyle _createDisplayLarge(BuildContext context, double scaleFactor) {
    return TextStyle(
      fontFamily: 'Lufga',
      fontSize: (57 * scaleFactor).clamp(48.0, 72.0),
      fontWeight: FontWeight.w700,
      height: 1.1,
      letterSpacing: -0.25,
      color: _getResponsiveTextColor(context),
    );
  }

  static TextStyle _createDisplayMedium(BuildContext context, double scaleFactor) {
    return TextStyle(
      fontFamily: 'Lufga',
      fontSize: (45 * scaleFactor).clamp(36.0, 60.0),
      fontWeight: FontWeight.w600,
      height: 1.15,
      letterSpacing: 0.0,
      color: _getResponsiveTextColor(context),
    );
  }

  static TextStyle _createDisplaySmall(BuildContext context, double scaleFactor) {
    return TextStyle(
      fontFamily: 'Lufga',
      fontSize: (36 * scaleFactor).clamp(28.0, 48.0),
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: 0.0,
      color: _getResponsiveTextColor(context),
    );
  }

  static TextStyle _createHeadlineLarge(BuildContext context, double scaleFactor) {
    return TextStyle(
      fontFamily: 'Lufga',
      fontSize: (32 * scaleFactor).clamp(24.0, 40.0),
      fontWeight: FontWeight.w600,
      height: 1.25,
      letterSpacing: 0.0,
      color: _getResponsiveTextColor(context),
    );
  }

  static TextStyle _createHeadlineMedium(BuildContext context, double scaleFactor) {
    return TextStyle(
      fontFamily: 'Lufga',
      fontSize: (28 * scaleFactor).clamp(20.0, 36.0),
      fontWeight: FontWeight.w600,
      height: 1.3,
      letterSpacing: 0.0,
      color: _getResponsiveTextColor(context),
    );
  }

  static TextStyle _createHeadlineSmall(BuildContext context, double scaleFactor) {
    return TextStyle(
      fontFamily: 'Lufga',
      fontSize: (24 * scaleFactor).clamp(18.0, 32.0),
      fontWeight: FontWeight.w600,
      height: 1.35,
      letterSpacing: 0.0,
      color: _getResponsiveTextColor(context),
    );
  }

  static TextStyle _createTitleLarge(BuildContext context, double scaleFactor) {
    return TextStyle(
      fontFamily: 'Lufga',
      fontSize: (22 * scaleFactor).clamp(16.0, 28.0),
      fontWeight: FontWeight.w500,
      height: 1.4,
      letterSpacing: 0.0,
      color: _getResponsiveTextColor(context),
    );
  }

  static TextStyle _createTitleMedium(BuildContext context, double scaleFactor) {
    return TextStyle(
      fontFamily: 'Lufga',
      fontSize: (16 * scaleFactor).clamp(14.0, 20.0),
      fontWeight: FontWeight.w500,
      height: 1.4,
      letterSpacing: 0.15,
      color: _getResponsiveTextColor(context),
    );
  }

  static TextStyle _createTitleSmall(BuildContext context, double scaleFactor) {
    return TextStyle(
      fontFamily: 'Lufga',
      fontSize: (14 * scaleFactor).clamp(12.0, 18.0),
      fontWeight: FontWeight.w500,
      height: 1.4,
      letterSpacing: 0.1,
      color: _getResponsiveTextColor(context),
    );
  }

  static TextStyle _createBodyLarge(BuildContext context, double scaleFactor) {
    return TextStyle(
      fontFamily: 'Lufga',
      fontSize: (16 * scaleFactor).clamp(14.0, 20.0),
      fontWeight: FontWeight.w400,
      height: 1.5,
      letterSpacing: 0.5,
      color: _getResponsiveTextColor(context),
    );
  }

  static TextStyle _createBodyMedium(BuildContext context, double scaleFactor) {
    return TextStyle(
      fontFamily: 'Lufga',
      fontSize: (14 * scaleFactor).clamp(12.0, 18.0),
      fontWeight: FontWeight.w400,
      height: 1.5,
      letterSpacing: 0.25,
      color: _getResponsiveTextColor(context),
    );
  }

  static TextStyle _createBodySmall(BuildContext context, double scaleFactor) {
    return TextStyle(
      fontFamily: 'Lufga',
      fontSize: (12 * scaleFactor).clamp(10.0, 16.0),
      fontWeight: FontWeight.w400,
      height: 1.4,
      letterSpacing: 0.4,
      color: _getResponsiveTextColor(context, isSecondary: true),
    );
  }

  static TextStyle _createLabelLarge(BuildContext context, double scaleFactor) {
    return TextStyle(
      fontFamily: 'Lufga',
      fontSize: (14 * scaleFactor).clamp(12.0, 18.0),
      fontWeight: FontWeight.w500,
      height: 1.4,
      letterSpacing: 0.1,
      color: _getResponsiveTextColor(context),
    );
  }

  static TextStyle _createLabelMedium(BuildContext context, double scaleFactor) {
    return TextStyle(
      fontFamily: 'Lufga',
      fontSize: (12 * scaleFactor).clamp(10.0, 16.0),
      fontWeight: FontWeight.w500,
      height: 1.3,
      letterSpacing: 0.5,
      color: _getResponsiveTextColor(context),
    );
  }

  static TextStyle _createLabelSmall(BuildContext context, double scaleFactor) {
    return TextStyle(
      fontFamily: 'Lufga',
      fontSize: (11 * scaleFactor).clamp(9.0, 14.0),
      fontWeight: FontWeight.w500,
      height: 1.2,
      letterSpacing: 0.5,
      color: _getResponsiveTextColor(context, isSecondary: true),
    );
  }

  /// Obtiene el color de texto apropiado basado en el contexto
  static Color _getResponsiveTextColor(BuildContext context, {bool isSecondary = false}) {
    final theme = Theme.of(context);

    if (isSecondary) {
      return theme.colorScheme.onSurfaceVariant;
    }

    return theme.colorScheme.onSurface;
  }

  /// Utilidades para texto responsivo
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    return ResponsiveUtils.getResponsiveFontSize(context, baseSize);
  }

  static double getOptimalLineHeight(double fontSize, TextContext context) {
    switch (context) {
      case TextContext.headline:
        return fontSize * 0.05 + 1.1; // Más compacto para títulos
      case TextContext.body:
        return fontSize * 0.08 + 1.2; // Más legible para texto largo
      case TextContext.caption:
        return fontSize * 0.1 + 1.1; // Muy compacto para captions
      case TextContext.button:
        return fontSize * 0.03 + 1.1; // Compacto para botones
    }
  }

  static double getOptimalLetterSpacing(double fontSize, TextContext context) {
    switch (context) {
      case TextContext.headline:
        return fontSize * -0.01; // Espaciado negativo para títulos grandes
      case TextContext.body:
        return fontSize * 0.02; // Espaciado normal para legibilidad
      case TextContext.caption:
        return fontSize * 0.03; // Más espaciado para texto pequeño
      case TextContext.button:
        return fontSize * 0.015; // Espaciado sutil para botones
    }
  }
}

/// Contextos de texto para optimización automática
enum TextContext {
  headline,
  body,
  caption,
  button,
}

/// Widget de texto avanzado con características responsivas
class AdvancedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextContext context;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool enableResponsiveSizing;
  final double? customFontSize;

  const AdvancedText(
    this.text, {
    super.key,
    this.style,
    this.context = TextContext.body,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.enableResponsiveSizing = true,
    this.customFontSize,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle responsiveStyle = style ?? _getDefaultStyle(this.context);

    if (enableResponsiveSizing && customFontSize == null) {
      final baseFontSize = responsiveStyle.fontSize ?? 14.0;
      final responsiveFontSize = ResponsiveUtils.getResponsiveFontSize(context, baseFontSize);
      responsiveStyle = responsiveStyle.copyWith(
        fontSize: responsiveFontSize,
        height: AdvancedTypography.getOptimalLineHeight(responsiveFontSize, this.context),
        letterSpacing: AdvancedTypography.getOptimalLetterSpacing(responsiveFontSize, this.context),
      );
    } else if (customFontSize != null) {
      responsiveStyle = responsiveStyle.copyWith(
        fontSize: customFontSize,
        height: AdvancedTypography.getOptimalLineHeight(customFontSize!, this.context),
        letterSpacing: AdvancedTypography.getOptimalLetterSpacing(customFontSize!, this.context),
      );
    }

    return Text(
      text,
      style: responsiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  TextStyle _getDefaultStyle(TextContext textContext) {
    switch (textContext) {
      case TextContext.headline:
        return const TextStyle(
          fontFamily: 'Lufga',
          fontWeight: FontWeight.w700,
        );
      case TextContext.body:
        return const TextStyle(
          fontFamily: 'Lufga',
          fontWeight: FontWeight.w400,
        );
      case TextContext.caption:
        return const TextStyle(
          fontFamily: 'Lufga',
          fontWeight: FontWeight.w400,
        );
      case TextContext.button:
        return const TextStyle(
          fontFamily: 'Lufga',
          fontWeight: FontWeight.w600,
        );
    }
  }
}

/// Widget para títulos responsivos con jerarquía automática
class ResponsiveTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final TitleSize size;
  final TextAlign? textAlign;
  final bool enableResponsiveSizing;

  const ResponsiveTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.size = TitleSize.medium,
    this.textAlign,
    this.enableResponsiveSizing = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: textAlign == TextAlign.center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        AdvancedText(
          title,
          context: TextContext.headline,
          textAlign: textAlign,
          enableResponsiveSizing: enableResponsiveSizing,
          customFontSize: _getTitleSize(context, size),
        ),
        if (subtitle != null) ...[
          SizedBox(height: _getSubtitleSpacing(context, size)),
          AdvancedText(
            subtitle!,
            context: TextContext.body,
            textAlign: textAlign,
            enableResponsiveSizing: enableResponsiveSizing,
            customFontSize: _getSubtitleSize(context, size),
          ),
        ],
      ],
    );
  }

  double _getTitleSize(BuildContext context, TitleSize size) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final baseSize = _getBaseTitleSize(size);

    if (isMobile) {
      return (baseSize * 0.9).clamp(20.0, 48.0);
    } else {
      return baseSize;
    }
  }

  double _getSubtitleSize(BuildContext context, TitleSize size) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final baseSize = _getBaseSubtitleSize(size);

    if (isMobile) {
      return (baseSize * 0.9).clamp(12.0, 20.0);
    } else {
      return baseSize;
    }
  }

  double _getBaseTitleSize(TitleSize size) {
    switch (size) {
      case TitleSize.small:
        return 20;
      case TitleSize.medium:
        return 24;
      case TitleSize.large:
        return 32;
      case TitleSize.xlarge:
        return 40;
    }
  }

  double _getBaseSubtitleSize(TitleSize size) {
    switch (size) {
      case TitleSize.small:
        return 14;
      case TitleSize.medium:
        return 16;
      case TitleSize.large:
        return 18;
      case TitleSize.xlarge:
        return 20;
    }
  }

  double _getSubtitleSpacing(BuildContext context, TitleSize size) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final baseSpacing = _getBaseSubtitleSpacing(size);

    return isMobile ? baseSpacing * 0.8 : baseSpacing;
  }

  double _getBaseSubtitleSpacing(TitleSize size) {
    switch (size) {
      case TitleSize.small:
        return 4;
      case TitleSize.medium:
        return 8;
      case TitleSize.large:
        return 12;
      case TitleSize.xlarge:
        return 16;
    }
  }
}

/// Tamaños de título disponibles
enum TitleSize {
  small,
  medium,
  large,
  xlarge,
}

/// Widget para texto de cuerpo responsivo
class ResponsiveBodyText extends StatelessWidget {
  final String text;
  final BodyTextSize size;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool enableResponsiveSizing;

  const ResponsiveBodyText(
    this.text, {
    super.key,
    this.size = BodyTextSize.medium,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.enableResponsiveSizing = true,
  });

  @override
  Widget build(BuildContext context) {
    return AdvancedText(
      text,
      context: TextContext.body,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      enableResponsiveSizing: enableResponsiveSizing,
      customFontSize: _getBodyTextSize(context, size),
    );
  }

  double _getBodyTextSize(BuildContext context, BodyTextSize size) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final baseSize = _getBaseBodyTextSize(size);

    if (isMobile) {
      return (baseSize * 0.95).clamp(12.0, 18.0);
    } else {
      return baseSize;
    }
  }

  double _getBaseBodyTextSize(BodyTextSize size) {
    switch (size) {
      case BodyTextSize.small:
        return 12;
      case BodyTextSize.medium:
        return 14;
      case BodyTextSize.large:
        return 16;
      case BodyTextSize.xlarge:
        return 18;
    }
  }
}

/// Tamaños de texto de cuerpo disponibles
enum BodyTextSize {
  small,
  medium,
  large,
  xlarge,
}

/// Widget para captions responsivos
class ResponsiveCaption extends StatelessWidget {
  final String text;
  final CaptionSize size;
  final TextAlign? textAlign;
  final bool enableResponsiveSizing;

  const ResponsiveCaption(
    this.text, {
    super.key,
    this.size = CaptionSize.medium,
    this.textAlign,
    this.enableResponsiveSizing = true,
  });

  @override
  Widget build(BuildContext context) {
    return AdvancedText(
      text,
      context: TextContext.caption,
      textAlign: textAlign,
      enableResponsiveSizing: enableResponsiveSizing,
      customFontSize: _getCaptionSize(context, size),
    );
  }

  double _getCaptionSize(BuildContext context, CaptionSize size) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final baseSize = _getBaseCaptionSize(size);

    if (isMobile) {
      return (baseSize * 0.9).clamp(10.0, 14.0);
    } else {
      return baseSize;
    }
  }

  double _getBaseCaptionSize(CaptionSize size) {
    switch (size) {
      case CaptionSize.small:
        return 10;
      case CaptionSize.medium:
        return 12;
      case CaptionSize.large:
        return 14;
    }
  }
}

/// Tamaños de caption disponibles
enum CaptionSize {
  small,
  medium,
  large,
}