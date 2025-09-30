import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';

enum AppCardVariant {
  filled,
  outlined,
  elevated,
}

enum AppCardSize {
  small,
  medium,
  large,
  responsive,
}

class AppCard extends StatelessWidget {
  final Widget child;
  final AppCardVariant variant;
  final AppCardSize size;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? elevation;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;

  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.filled,
    this.size = AppCardSize.medium,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.elevation,
    this.borderRadius,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardTheme = theme.cardTheme;
    final responsiveElevation = elevation ?? ResponsiveUtils.getResponsiveElevation(context);
    final responsiveBorderRadius = borderRadius ?? ResponsiveUtils.getResponsiveBorderRadius(context);
    final responsiveMargin = margin ?? EdgeInsets.all(ResponsiveUtils.getResponsiveMargin(context));

    Widget buildCard() {

      switch (variant) {
        case AppCardVariant.filled:
          return Card(
            color: backgroundColor ?? cardTheme.color,
            elevation: responsiveElevation,
            surfaceTintColor: cardTheme.surfaceTintColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsiveBorderRadius),
              side: borderColor != null
                  ? BorderSide(color: borderColor!, width: 1)
                  : cardTheme.shape != null
                      ? (cardTheme.shape! as RoundedRectangleBorder).side
                      : BorderSide.none,
            ),
            margin: responsiveMargin,
            child: Padding(
              padding: padding ?? _getDefaultPadding(context),
              child: child,
            ),
          );

        case AppCardVariant.outlined:
          return Card(
            color: backgroundColor ?? Colors.transparent,
            elevation: elevation ?? 0,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsiveBorderRadius),
              side: BorderSide(
                color: borderColor ?? theme.colorScheme.outline,
                width: 1.5,
              ),
            ),
            margin: responsiveMargin,
            child: Padding(
              padding: padding ?? _getDefaultPadding(context),
              child: child,
            ),
          );

        case AppCardVariant.elevated:
          return Card(
            color: backgroundColor ?? cardTheme.color,
            elevation: responsiveElevation,
            surfaceTintColor: cardTheme.surfaceTintColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsiveBorderRadius),
            ),
            margin: responsiveMargin,
            child: Padding(
              padding: padding ?? _getDefaultPadding(context),
              child: child,
            ),
          );
      }
    }

    final card = buildCard();

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(responsiveBorderRadius),
        child: card,
      );
    }

    return card;
  }

  EdgeInsetsGeometry _getDefaultPadding(BuildContext context) {
    switch (size) {
      case AppCardSize.small:
        return ResponsiveCardPadding.getSmallPadding(ResponsiveUtils.getCurrentSize(context));
      case AppCardSize.medium:
        return ResponsiveCardPadding.getPadding(ResponsiveUtils.getCurrentSize(context));
      case AppCardSize.large:
        return ResponsiveCardPadding.getLargePadding(ResponsiveUtils.getCurrentSize(context));
      case AppCardSize.responsive:
        return ResponsiveUtils.getResponsivePadding(context);
    }
  }
}