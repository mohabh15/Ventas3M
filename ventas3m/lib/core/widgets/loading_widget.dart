import 'package:flutter/material.dart';

enum LoadingSize {
  small,
  medium,
  large,
  adaptive,
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
    this.size = LoadingSize.adaptive,
    this.strokeWidth,
    this.color,
    this.backgroundColor,
    this.value,
    this.semanticsLabel,
    this.semanticsValue,
  });

  final LoadingSize size;
  final double? strokeWidth;
  final Color? color;
  final Color? backgroundColor;
  final double? value;
  final String? semanticsLabel;
  final String? semanticsValue;

  @override
  Widget build(BuildContext context) {
    final responsiveSize = _getResponsiveSize(context);
    final responsiveStrokeWidth = _getResponsiveStrokeWidth(context);

    return SizedBox(
      width: responsiveSize,
      height: responsiveSize,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth ?? responsiveStrokeWidth,
        color: color,
        backgroundColor: backgroundColor,
        value: value,
        semanticsLabel: semanticsLabel,
        semanticsValue: semanticsValue,
      ),
    );
  }

  double _getResponsiveSize(BuildContext context) {
    switch (size) {
      case LoadingSize.small:
        return 16;
      case LoadingSize.medium:
        return 24;
      case LoadingSize.large:
        return 32;
      case LoadingSize.adaptive:
        return _getAdaptiveSize(context);
    }
  }

  double _getAdaptiveSize(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    if (screenWidth < 600) {
      return 20;
    } else if (screenWidth < 1200) {
      return 24;
    } else {
      return 28;
    }
  }

  double _getResponsiveStrokeWidth(BuildContext context) {
    switch (size) {
      case LoadingSize.small:
        return 2;
      case LoadingSize.medium:
        return 3;
      case LoadingSize.large:
        return 4;
      case LoadingSize.adaptive:
        return _getAdaptiveStrokeWidth(context);
    }
  }

  double _getAdaptiveStrokeWidth(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final devicePixelRatio = mediaQuery.devicePixelRatio;

    double baseStrokeWidth = 3;

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
}