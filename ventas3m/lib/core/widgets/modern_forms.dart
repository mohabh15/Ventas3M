import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../theme/colors.dart';

/// Variantes de campo de texto moderno
enum AppTextFieldVariant {
  outlined,     // Borde exterior
  filled,       // Fondo sólido
  underlined,   // Solo línea inferior
}

/// Estados del campo de texto
enum AppTextFieldState {
  normal,
  focused,
  error,
  success,
  disabled,
}

/// Tipos de campo de texto
enum AppTextFieldType {
  text,
  email,
  password,
  number,
  phone,
  multiline,
  search,
  date,
}

/// Campo de texto moderno mejorado
class AppTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final AppTextFieldVariant variant;
  final AppTextFieldType type;
  final TextEditingController? controller;
  final String? initialValue;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final Function()? onTap;
  final Function()? onTrailingIconTap;
  final bool enabled;
  final bool readOnly;
  final bool obscureText;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final bool enableSuggestions;
  final bool showCounter;
  final bool showClearButton;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusColor;
  final EdgeInsetsGeometry? contentPadding;
  final double borderRadius;
  final bool floatingLabel;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.leadingIcon,
    this.trailingIcon,
    this.variant = AppTextFieldVariant.outlined,
    this.type = AppTextFieldType.text,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onTrailingIconTap,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.showCounter = false,
    this.showClearButton = false,
    this.fillColor,
    this.borderColor,
    this.focusColor,
    this.contentPadding,
    this.borderRadius = 12,
    this.floatingLabel = true,
    this.validator,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> with TickerProviderStateMixin {
  late TextEditingController _controller;
  late AnimationController _focusController;
  late AnimationController _shakeController;
  late Animation<double> _focusAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _iconAnimation;

  AppTextFieldState _currentState = AppTextFieldState.normal;
  bool _obscureText = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _obscureText = widget.obscureText;
    _initializeAnimations();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _focusController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _focusAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _focusController,
      curve: Curves.easeInOut,
    ));

    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));

    _iconAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _focusController,
      curve: Curves.easeInOut,
    ));
  }

  void _updateState(AppTextFieldState newState) {
    if (_currentState != newState) {
      setState(() {
        _currentState = newState;
      });

      switch (newState) {
        case AppTextFieldState.focused:
          _focusController.forward();
          break;
        case AppTextFieldState.error:
          _shakeController.forward(from: 0);
          break;
        case AppTextFieldState.normal:
        case AppTextFieldState.success:
        case AppTextFieldState.disabled:
          _focusController.reverse();
          _shakeController.stop();
          break;
      }
    }
  }

  void _validateInput() {
    if (widget.validator != null) {
      final error = widget.validator!(_controller.text);
      setState(() {
        _errorText = error;
        _currentState = error != null ? AppTextFieldState.error : AppTextFieldState.success;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_focusAnimation, _shakeAnimation, _iconAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            _shakeAnimation.value * (sin(_shakeAnimation.value * pi * 8) * 2),
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Label flotante
              if (widget.label != null && widget.floatingLabel)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    widget.label!,
                    style: TextStyle(
                      fontFamily: 'Lufga',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: _getLabelColor(),
                    ),
                  ),
                ),

              // Campo de texto
              Container(
                decoration: _buildContainerDecoration(),
                child: TextField(
                  controller: _controller,
                  enabled: widget.enabled,
                  readOnly: widget.readOnly,
                  obscureText: _obscureText,
                  maxLength: widget.maxLength,
                  maxLines: widget.obscureText ? 1 : widget.maxLines,
                  minLines: widget.minLines,
                  keyboardType: _getKeyboardType(),
                  inputFormatters: widget.inputFormatters ?? _getInputFormatters(),
                  textCapitalization: widget.textCapitalization,
                  autocorrect: widget.autocorrect,
                  enableSuggestions: widget.enableSuggestions,
                  onChanged: (value) {
                    widget.onChanged?.call(value);
                    _validateInput();
                  },
                  onSubmitted: widget.onSubmitted,
                  onTap: () {
                    _updateState(AppTextFieldState.focused);
                    widget.onTap?.call();
                  },
                  onEditingComplete: () => _updateState(AppTextFieldState.normal),
                  decoration: _buildInputDecoration(),
                ),
              ),

              // Mensajes de ayuda y error
              if (widget.helperText != null || _errorText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    _errorText ?? widget.helperText ?? '',
                    style: TextStyle(
                      fontFamily: 'Lufga',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: _getHelperTextColor(),
                    ),
                  ),
                ),

              // Contador de caracteres
              if (widget.showCounter && widget.maxLength != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4),
                  child: Text(
                    '${_controller.text.length}/${widget.maxLength}',
                    style: TextStyle(
                      fontFamily: 'Lufga',
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textDisabled,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  BoxDecoration _buildContainerDecoration() {
    return BoxDecoration(
      color: _getBackgroundColor(),
      borderRadius: BorderRadius.circular(widget.borderRadius),
      border: _getBorder(),
      boxShadow: _getBoxShadow(),
    );
  }

  Border _getBorder() {
    final borderColor = _getBorderColor();
    final borderWidth = _getBorderWidth();

    return Border.all(
      color: borderColor,
      width: borderWidth,
    );
  }

  Color _getBackgroundColor() {
    if (!widget.enabled) {
      return AppColors.disabled.withValues(alpha: 0.1);
    }

    switch (widget.variant) {
      case AppTextFieldVariant.filled:
        return widget.fillColor ?? AppColors.surface;
      case AppTextFieldVariant.outlined:
      case AppTextFieldVariant.underlined:
        return Colors.transparent;
    }
  }

  Color _getBorderColor() {
    if (!widget.enabled) {
      return AppColors.disabled;
    }

    if (widget.borderColor != null) {
      return widget.borderColor!;
    }

    switch (_currentState) {
      case AppTextFieldState.error:
        return AppColors.error;
      case AppTextFieldState.success:
        return AppColors.secondary;
      case AppTextFieldState.focused:
        return widget.focusColor ?? AppColors.primary;
      default:
        return AppColors.border;
    }
  }

  double _getBorderWidth() {
    switch (_currentState) {
      case AppTextFieldState.focused:
        return 2;
      case AppTextFieldState.error:
      case AppTextFieldState.success:
        return 1.5;
      default:
        return 1;
    }
  }

  List<BoxShadow> _getBoxShadow() {
    if (widget.variant != AppTextFieldVariant.filled) {
      return [];
    }

    switch (_currentState) {
      case AppTextFieldState.focused:
        return [
          BoxShadow(
            color: (widget.focusColor ?? AppColors.primary).withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ];
      case AppTextFieldState.error:
        return [
          BoxShadow(
            color: AppColors.error.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ];
      default:
        return [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ];
    }
  }

  Color _getLabelColor() {
    if (!widget.enabled) {
      return AppColors.textDisabled;
    }

    switch (_currentState) {
      case AppTextFieldState.error:
        return AppColors.error;
      case AppTextFieldState.success:
        return AppColors.secondary;
      case AppTextFieldState.focused:
        return widget.focusColor ?? AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getHelperTextColor() {
    switch (_currentState) {
      case AppTextFieldState.error:
        return AppColors.error;
      case AppTextFieldState.success:
        return AppColors.secondary;
      default:
        return AppColors.textDisabled;
    }
  }

  TextInputType _getKeyboardType() {
    if (widget.keyboardType != null) {
      return widget.keyboardType!;
    }

    switch (widget.type) {
      case AppTextFieldType.email:
        return TextInputType.emailAddress;
      case AppTextFieldType.password:
        return TextInputType.visiblePassword;
      case AppTextFieldType.number:
        return TextInputType.number;
      case AppTextFieldType.phone:
        return TextInputType.phone;
      case AppTextFieldType.multiline:
        return TextInputType.multiline;
      case AppTextFieldType.date:
        return TextInputType.datetime;
      default:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter> _getInputFormatters() {
    switch (widget.type) {
      case AppTextFieldType.number:
        return [FilteringTextInputFormatter.digitsOnly];
      case AppTextFieldType.phone:
        return [FilteringTextInputFormatter.digitsOnly];
      default:
        return [];
    }
  }

  InputDecoration _buildInputDecoration() {
    return InputDecoration(
      hintText: widget.hint,
      errorText: widget.errorText,
      helperText: widget.helperText,
      prefixIcon: widget.leadingIcon != null ? _AnimatedIconWrapper(
        animation: _iconAnimation,
        child: widget.leadingIcon!,
      ) : null,
      suffixIcon: _buildSuffixIcon(),
      filled: widget.variant == AppTextFieldVariant.filled,
      fillColor: Colors.transparent,
      contentPadding: widget.contentPadding ?? const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: _getInputBorder(),
      enabledBorder: _getInputBorder(),
      focusedBorder: _getInputBorder(state: AppTextFieldState.focused),
      errorBorder: _getInputBorder(state: AppTextFieldState.error),
      focusedErrorBorder: _getInputBorder(state: AppTextFieldState.error),
      disabledBorder: _getInputBorder(),
      labelText: widget.label != null && !widget.floatingLabel ? widget.label : null,
      labelStyle: TextStyle(
        fontFamily: 'Lufga',
        color: AppColors.textSecondary,
        fontSize: 16,
      ),
      hintStyle: TextStyle(
        fontFamily: 'Lufga',
        color: AppColors.textDisabled,
        fontSize: 14,
      ),
      errorStyle: TextStyle(
        fontFamily: 'Lufga',
        color: AppColors.error,
        fontSize: 12,
      ),
      helperStyle: TextStyle(
        fontFamily: 'Lufga',
        color: AppColors.textDisabled,
        fontSize: 12,
      ),
      counterText: widget.showCounter ? null : '',
      counterStyle: TextStyle(
        fontFamily: 'Lufga',
        color: AppColors.textDisabled,
        fontSize: 10,
      ),
    );
  }

  Widget _buildSuffixIcon() {
    final icons = <Widget>[];

    // Botón de mostrar/ocultar contraseña
    if (widget.type == AppTextFieldType.password) {
      icons.add(
        IconButton(
          onPressed: () => setState(() => _obscureText = !_obscureText),
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: AppColors.textDisabled,
            size: 20,
          ),
        ),
      );
    }

    // Botón de limpiar
    if (widget.showClearButton && _controller.text.isNotEmpty) {
      icons.add(
        IconButton(
          onPressed: () => setState(() => _controller.clear()),
          icon: Icon(
            Icons.clear,
            color: AppColors.textDisabled,
            size: 20,
          ),
        ),
      );
    }

    // Ícono personalizado
    if (widget.trailingIcon != null) {
      icons.add(
        GestureDetector(
          onTap: widget.onTrailingIconTap,
          child: _AnimatedIconWrapper(
            animation: _iconAnimation,
            child: widget.trailingIcon!,
          ),
        ),
      );
    }

    if (icons.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: icons,
    );
  }

  InputBorder _getInputBorder({AppTextFieldState? state}) {
    final currentState = state ?? _currentState;
    final borderRadius = BorderRadius.circular(widget.borderRadius);

    switch (widget.variant) {
      case AppTextFieldVariant.outlined:
        return OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(
            color: _getBorderColorForState(currentState),
            width: _getBorderWidthForState(currentState),
          ),
        );

      case AppTextFieldVariant.filled:
        return OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(
            color: _getBorderColorForState(currentState),
            width: _getBorderWidthForState(currentState),
          ),
        );

      case AppTextFieldVariant.underlined:
        return UnderlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(
            color: _getBorderColorForState(currentState),
            width: _getBorderWidthForState(currentState),
          ),
        );
    }
  }

  Color _getBorderColorForState(AppTextFieldState state) {
    if (!widget.enabled) {
      return AppColors.disabled;
    }

    switch (state) {
      case AppTextFieldState.error:
        return AppColors.error;
      case AppTextFieldState.success:
        return AppColors.secondary;
      case AppTextFieldState.focused:
        return widget.focusColor ?? AppColors.primary;
      default:
        return AppColors.border;
    }
  }

  double _getBorderWidthForState(AppTextFieldState state) {
    switch (state) {
      case AppTextFieldState.focused:
        return 2;
      case AppTextFieldState.error:
      case AppTextFieldState.success:
        return 1.5;
      default:
        return 1;
    }
  }
}

/// Wrapper animado para íconos
class _AnimatedIconWrapper extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _AnimatedIconWrapper({
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: animation.value * 2 * 3.14159,
          child: child,
        );
      },
      child: child,
    );
  }
}

/// Área de texto moderna para comentarios y descripciones largas
class AppTextArea extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final String? initialValue;
  final Function(String)? onChanged;
  final int? maxLength;
  final int? minLines;
  final int? maxLines;
  final bool enabled;
  final bool showCounter;
  final EdgeInsetsGeometry? contentPadding;

  const AppTextArea({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.maxLength,
    this.minLines = 3,
    this.maxLines = 8,
    this.enabled = true,
    this.showCounter = false,
    this.contentPadding,
  });

  @override
  State<AppTextArea> createState() => _AppTextAreaState();
}

class _AppTextAreaState extends State<AppTextArea> with TickerProviderStateMixin {
  late TextEditingController _controller;
  late AnimationController _focusController;
  late Animation<double> _focusAnimation;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _initializeAnimations();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _focusController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _focusAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _focusController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _focusAnimation,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  widget.label!,
                  style: TextStyle(
                    fontFamily: 'Lufga',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

            Container(
              decoration: BoxDecoration(
                color: widget.enabled ? AppColors.surface : AppColors.disabled.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                enabled: widget.enabled,
                maxLength: widget.maxLength,
                minLines: widget.minLines,
                maxLines: widget.maxLines,
                onChanged: widget.onChanged,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  helperText: widget.helperText,
                  errorText: widget.errorText,
                  contentPadding: widget.contentPadding ?? const EdgeInsets.all(16),
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    fontFamily: 'Lufga',
                    color: AppColors.textDisabled,
                    fontSize: 14,
                  ),
                  helperStyle: TextStyle(
                    fontFamily: 'Lufga',
                    color: AppColors.textDisabled,
                    fontSize: 12,
                  ),
                  errorStyle: TextStyle(
                    fontFamily: 'Lufga',
                    color: AppColors.error,
                    fontSize: 12,
                  ),
                  counterText: widget.showCounter ? null : '',
                  counterStyle: TextStyle(
                    fontFamily: 'Lufga',
                    color: AppColors.textDisabled,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Campo de búsqueda moderno
class AppSearchField extends StatefulWidget {
  final String? hint;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final Function()? onClear;
  final Function()? onFilter;
  final bool showFilter;
  final bool showVoiceSearch;

  const AppSearchField({
    super.key,
    this.hint = 'Buscar...',
    this.controller,
    this.onChanged,
    this.onClear,
    this.onFilter,
    this.showFilter = false,
    this.showVoiceSearch = false,
  });

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> with TickerProviderStateMixin {
  late TextEditingController _controller;
  late AnimationController _searchController;
  late Animation<double> _searchAnimation;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _initializeAnimations();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _searchController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _searchController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _searchAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _searchController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _searchAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _searchAnimation.value,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                hintText: widget.hint,
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textDisabled,
                  size: 20,
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_controller.text.isNotEmpty)
                      IconButton(
                        onPressed: () {
                          _controller.clear();
                          widget.onClear?.call();
                        },
                        icon: const Icon(
                          Icons.clear,
                          color: AppColors.textDisabled,
                          size: 20,
                        ),
                      ),
                    if (widget.showFilter)
                      IconButton(
                        onPressed: widget.onFilter,
                        icon: const Icon(
                          Icons.filter_list,
                          color: AppColors.textDisabled,
                          size: 20,
                        ),
                      ),
                  ],
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                hintStyle: TextStyle(
                  fontFamily: 'Lufga',
                  color: AppColors.textDisabled,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}