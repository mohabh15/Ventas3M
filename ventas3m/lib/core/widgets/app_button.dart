import 'package:flutter/material.dart';

enum AppButtonVariant {
  primary,
  secondary,
  outline,
}

enum AppButtonSize {
  small,
  medium,
  large,
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.leadingIcon,
    this.trailingIcon,
    this.width,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isButtonDisabled = isDisabled || onPressed == null;

    Widget buttonChild() {
      if (isLoading) {
        return SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              variant == AppButtonVariant.primary
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.primary,
            ),
          ),
        );
      }

      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leadingIcon != null) ...[
            leadingIcon!,
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: _getFontSize(),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
          if (trailingIcon != null) ...[
            const SizedBox(width: 8),
            trailingIcon!,
          ],
        ],
      );
    }

    ButtonStyle? buttonStyle;
    switch (variant) {
      case AppButtonVariant.primary:
        buttonStyle = theme.elevatedButtonTheme.style;
        break;
      case AppButtonVariant.secondary:
        buttonStyle = theme.textButtonTheme.style;
        break;
      case AppButtonVariant.outline:
        buttonStyle = theme.outlinedButtonTheme.style;
        break;
    }

    final finalButtonStyle = buttonStyle?.copyWith(
      minimumSize: WidgetStateProperty.all(
        Size(width ?? 0, _getHeight()),
      ),
      padding: WidgetStateProperty.all(
        padding ?? EdgeInsets.symmetric(
          horizontal: _getHorizontalPadding(),
          vertical: _getVerticalPadding(),
        ),
      ),
    );

    Widget buildButton() {
      switch (variant) {
        case AppButtonVariant.primary:
          return ElevatedButton(
            onPressed: isButtonDisabled ? null : onPressed,
            style: finalButtonStyle,
            child: buttonChild(),
          );
        case AppButtonVariant.secondary:
          return TextButton(
            onPressed: isButtonDisabled ? null : onPressed,
            style: finalButtonStyle,
            child: buttonChild(),
          );
        case AppButtonVariant.outline:
          return OutlinedButton(
            onPressed: isButtonDisabled ? null : onPressed,
            style: finalButtonStyle,
            child: buttonChild(),
          );
      }
    }

    return SizedBox(
      width: width,
      child: buildButton(),
    );
  }

  double _getFontSize() {
    switch (size) {
      case AppButtonSize.small:
        return 12;
      case AppButtonSize.medium:
        return 14;
      case AppButtonSize.large:
        return 16;
    }
  }

  double _getHeight() {
    switch (size) {
      case AppButtonSize.small:
        return 32;
      case AppButtonSize.medium:
        return 40;
      case AppButtonSize.large:
        return 48;
    }
  }

  double _getHorizontalPadding() {
    switch (size) {
      case AppButtonSize.small:
        return 12;
      case AppButtonSize.medium:
        return 16;
      case AppButtonSize.large:
        return 20;
    }
  }

  double _getVerticalPadding() {
    switch (size) {
      case AppButtonSize.small:
        return 6;
      case AppButtonSize.medium:
        return 10;
      case AppButtonSize.large:
        return 12;
    }
  }
}