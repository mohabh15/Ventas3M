import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';

enum AppTextFieldVariant {
  standard,
  filled,
  outlined,
}

enum AppTextFieldSize {
  small,
  medium,
  large,
}

class AppTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;
  final String? suffixText;
  final AppTextFieldVariant variant;
  final AppTextFieldSize size;
  final EdgeInsetsGeometry? contentPadding;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final AutovalidateMode? autovalidateMode;
  final bool enableResponsiveSizing;
  final double? responsiveFontScale;
  final EdgeInsetsGeometry? responsiveContentPadding;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.textInputAction,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.variant = AppTextFieldVariant.outlined,
    this.size = AppTextFieldSize.medium,
    this.contentPadding,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.autovalidateMode,
    this.enableResponsiveSizing = true,
    this.responsiveFontScale,
    this.responsiveContentPadding,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _errorText = widget.errorText;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inputDecorationTheme = theme.inputDecorationTheme;

    InputDecoration buildInputDecoration() {
      return InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        errorText: _errorText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        prefixText: widget.prefixText,
        suffixText: widget.suffixText,
        filled: widget.variant == AppTextFieldVariant.filled,
        fillColor: widget.variant == AppTextFieldVariant.filled
            ? inputDecorationTheme.fillColor
            : null,
        contentPadding: widget.contentPadding ?? _getContentPadding(),
        border: _getBorder(),
        enabledBorder: _getEnabledBorder(),
        focusedBorder: _getFocusedBorder(),
        errorBorder: _getErrorBorder(),
        focusedErrorBorder: _getFocusedErrorBorder(),
        labelStyle: inputDecorationTheme.labelStyle,
        hintStyle: inputDecorationTheme.hintStyle,
        errorStyle: inputDecorationTheme.errorStyle,
        floatingLabelStyle: TextStyle(
          fontFamily: 'Lufga',
          color: theme.colorScheme.primary,
          fontSize: _getLabelFontSize(),
        ),
      );
    }

    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      textInputAction: widget.textInputAction,
      onChanged: (value) {
        setState(() {
          _errorText = null;
        });
        widget.onChanged?.call(value);
      },
      onEditingComplete: widget.onEditingComplete,
      onFieldSubmitted: widget.onSubmitted,
      validator: (value) {
        if (widget.validator != null) {
          final result = widget.validator!(value);
          setState(() {
            _errorText = result;
          });
          return result;
        }
        return null;
      },
      autofocus: widget.autofocus,
      textCapitalization: widget.textCapitalization,
      autovalidateMode: widget.autovalidateMode,
      decoration: buildInputDecoration(),
      style: TextStyle(
        fontFamily: 'Lufga',
        fontSize: _getFontSize(),
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  OutlineInputBorder _getBorder() {
    final theme = Theme.of(context);
    switch (widget.variant) {
      case AppTextFieldVariant.filled:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        );
      case AppTextFieldVariant.outlined:
      case AppTextFieldVariant.standard:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: theme.colorScheme.outline,
            width: 1,
          ),
        );
    }
  }

  OutlineInputBorder _getEnabledBorder() {
    final theme = Theme.of(context);
    switch (widget.variant) {
      case AppTextFieldVariant.filled:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        );
      case AppTextFieldVariant.outlined:
      case AppTextFieldVariant.standard:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: theme.colorScheme.outline,
            width: 1,
          ),
        );
    }
  }

  OutlineInputBorder _getFocusedBorder() {
    final theme = Theme.of(context);
    switch (widget.variant) {
      case AppTextFieldVariant.filled:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        );
      case AppTextFieldVariant.outlined:
      case AppTextFieldVariant.standard:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        );
    }
  }

  OutlineInputBorder _getErrorBorder() {
    final theme = Theme.of(context);
    switch (widget.variant) {
      case AppTextFieldVariant.filled:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 1,
          ),
        );
      case AppTextFieldVariant.outlined:
      case AppTextFieldVariant.standard:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 1,
          ),
        );
    }
  }

  OutlineInputBorder _getFocusedErrorBorder() {
    final theme = Theme.of(context);
    switch (widget.variant) {
      case AppTextFieldVariant.filled:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 2,
          ),
        );
      case AppTextFieldVariant.outlined:
      case AppTextFieldVariant.standard:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 2,
          ),
        );
    }
  }

  EdgeInsetsGeometry _getContentPadding() {
    // Si se proporciona padding responsivo personalizado, usarlo
    if (widget.responsiveContentPadding != null) {
      return widget.responsiveContentPadding!;
    }

    // Si el padding personalizado está definido, usarlo (compatibilidad hacia atrás)
    if (widget.contentPadding != null) {
      return widget.contentPadding!;
    }

    // Usar la utilidad responsiva para calcular el padding
    return ResponsiveTextField.getContentPadding(
      context,
      size: widget.size,
      customPadding: null,
    );
  }

  double _getFontSize() {
    return ResponsiveTextField.getFontSize(
      context,
      size: widget.size,
      customScale: widget.responsiveFontScale,
    );
  }

  double _getLabelFontSize() {
    return ResponsiveTextField.getLabelFontSize(
      context,
      size: widget.size,
      customScale: widget.responsiveFontScale,
    );
  }
}