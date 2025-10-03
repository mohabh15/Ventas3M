import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Spinner de carga moderno y suave
class ModernLoadingSpinner extends StatefulWidget {
  final double size;
  final Color? color;
  final double strokeWidth;
  final bool showBackground;
  final Color? backgroundColor;
  final Duration duration;

  const ModernLoadingSpinner({
    super.key,
    this.size = 40,
    this.color,
    this.strokeWidth = 3,
    this.showBackground = false,
    this.backgroundColor,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ModernLoadingSpinner> createState() => _ModernLoadingSpinnerState();
}

class _ModernLoadingSpinnerState extends State<ModernLoadingSpinner> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _rotationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_rotationAnimation, _scaleAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 2 * 3.14159,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.showBackground
                    ? (widget.backgroundColor ?? AppColors.surface)
                    : Colors.transparent,
              ),
              child: Padding(
                padding: EdgeInsets.all(widget.strokeWidth),
                child: CircularProgressIndicator(
                  strokeWidth: widget.strokeWidth,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.color ?? AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Indicador de carga tipo pulse
class PulseLoader extends StatefulWidget {
  final double size;
  final Color color;
  final int dotCount;
  final Duration duration;

  const PulseLoader({
    super.key,
    this.size = 24,
    this.color = Colors.blue,
    this.dotCount = 3,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<PulseLoader> createState() => _PulseLoaderState();
}

class _PulseLoaderState extends State<PulseLoader> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeAnimations() {
    _controllers = List.generate(widget.dotCount, (index) {
      final controller = AnimationController(
        duration: widget.duration,
        vsync: this,
      );
      Future.delayed(Duration(milliseconds: index * 200), () {
        if (mounted) controller.repeat();
      });
      return controller;
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.5,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.dotCount, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              width: widget.size * _animations[index].value,
              height: widget.size * _animations[index].value,
              margin: EdgeInsets.symmetric(horizontal: widget.size * 0.2),
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}

/// Skeleton loader para tarjetas
class CardSkeleton extends StatelessWidget {
  final double height;
  final bool showAvatar;
  final bool showActions;
  final int lines;

  const CardSkeleton({
    super.key,
    this.height = 120,
    this.showAvatar = false,
    this.showActions = false,
    this.lines = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (showAvatar) ...[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              const SizedBox(width: 12),
            ],

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Línea de título
                  Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  if (lines > 1) ...[
                    const SizedBox(height: 8),
                    // Líneas de contenido
                    ...List.generate(lines - 1, (index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: index < lines - 2 ? 6 : 0),
                        child: Container(
                          height: 12,
                          width: (index == lines - 2) ? 0.7 : 1.0,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),

            if (showActions) ...[
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Skeleton loader para listas
class ListSkeleton extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final bool showAvatar;
  final bool showActions;

  const ListSkeleton({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.showAvatar = false,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CardSkeleton(
            height: itemHeight,
            showAvatar: showAvatar,
            showActions: showActions,
            lines: 2,
          ),
        );
      },
    );
  }
}

/// Estado vacío moderno con ilustraciones
class EmptyState extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? illustration;
  final Widget? action;
  final CrossAxisAlignment alignment;

  const EmptyState({
    super.key,
    required this.title,
    this.description,
    this.illustration,
    this.action,
    this.alignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Ilustración
        if (illustration != null) ...[
          illustration!,
          const SizedBox(height: 24),
        ] else ...[
          // Ilustración por defecto
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.inbox_outlined,
              size: 48,
              color: AppColors.textDisabled,
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Título
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Lufga',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),

        // Descripción
        if (description != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              description!,
              style: TextStyle(
                fontFamily: 'Lufga',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],

        // Acción
        if (action != null) ...[
          const SizedBox(height: 24),
          action!,
        ],
      ],
    );
  }
}

/// Placeholder para contenido cargando
class ContentPlaceholder extends StatelessWidget {
  final String title;
  final double height;
  final EdgeInsetsGeometry? margin;

  const ContentPlaceholder({
    super.key,
    required this.title,
    this.height = 200,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ModernLoadingSpinner(
            size: 32,
            color: AppColors.textDisabled,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textDisabled,
            ),
          ),
        ],
      ),
    );
  }
}

/// Overlay de carga para cubrir contenido
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? loadingText;
  final Color? backgroundColor;
  final double opacity;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingText,
    this.backgroundColor,
    this.opacity = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: (backgroundColor ?? AppColors.surface).withValues(alpha: opacity),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ModernLoadingSpinner(
                      size: 32,
                      color: AppColors.primary,
                    ),
                    if (loadingText != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        loadingText!,
                        style: TextStyle(
                          fontFamily: 'Lufga',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Pull to refresh moderno
class PullToRefreshIndicator extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final RefreshIndicatorTriggerMode mode;
  final double displacement;
  final Color? color;
  final Color? backgroundColor;

  const PullToRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.mode = RefreshIndicatorTriggerMode.onEdge,
    this.displacement = 40,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      triggerMode: mode,
      displacement: displacement,
      color: color ?? AppColors.primary,
      backgroundColor: backgroundColor ?? AppColors.cardBackground,
      strokeWidth: 3,
      child: child,
    );
  }
}

/// Indicador de progreso lineal moderno
class ModernLinearProgress extends StatefulWidget {
  final double value;
  final Color? color;
  final Color? backgroundColor;
  final double height;
  final bool showPercentage;
  final bool animated;

  const ModernLinearProgress({
    super.key,
    required this.value,
    this.color,
    this.backgroundColor,
    this.height = 6,
    this.showPercentage = false,
    this.animated = true,
  });

  @override
  State<ModernLinearProgress> createState() => _ModernLinearProgressState();
}

class _ModernLinearProgressState extends State<ModernLinearProgress> with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.animated) {
      _progressController = AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      );

      _progressAnimation = Tween<double>(
        begin: 0.0,
        end: widget.value,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ));

      _progressController.forward();
    }
  }

  @override
  void didUpdateWidget(ModernLinearProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animated && oldWidget.value != widget.value) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.value,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ));

      _progressController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    if (widget.animated) {
      _progressController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentValue = widget.animated ? _progressAnimation.value : widget.value;

    return Column(
      children: [
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? AppColors.surface,
            borderRadius: BorderRadius.circular(widget.height / 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.height / 2),
            child: LinearProgressIndicator(
              value: currentValue,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.color ?? AppColors.primary,
              ),
            ),
          ),
        ),

        if (widget.showPercentage) ...[
          const SizedBox(height: 8),
          Text(
            '${(currentValue * 100).toInt()}%',
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

/// Shimmer effect para skeleton loaders
class Shimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final LinearGradient gradient;

  const Shimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.gradient = const LinearGradient(
      colors: [
        Color(0xFFE0E0E0),
        Color(0xFFF5F5F5),
        Color(0xFFE0E0E0),
      ],
      stops: [0.1, 0.5, 0.9],
      begin: Alignment(-1.0, -0.3),
      end: Alignment(1.0, 0.3),
    ),
  });

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();

    _shimmerAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOutSine,
    ));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return widget.gradient.createShader(
              Rect.fromLTWH(
                _shimmerAnimation.value * bounds.width,
                0,
                bounds.width,
                bounds.height,
              ),
            );
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Skeleton loader con shimmer effect
class ShimmerSkeleton extends StatelessWidget {
  final double height;
  final double width;
  final BorderRadiusGeometry? borderRadius;

  const ShimmerSkeleton({
    super.key,
    this.height = 16,
    this.width = double.infinity,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: borderRadius ?? BorderRadius.circular(4),
        ),
      ),
    );
  }
}

/// Estado de error moderno
class ErrorState extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? illustration;
  final Widget? action;
  final bool showRetry;

  const ErrorState({
    super.key,
    required this.title,
    this.description,
    this.illustration,
    this.action,
    this.showRetry = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Ilustración
        if (illustration != null) ...[
          illustration!,
          const SizedBox(height: 24),
        ] else ...[
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Título
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Lufga',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.error,
          ),
          textAlign: TextAlign.center,
        ),

        // Descripción
        if (description != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              description!,
              style: TextStyle(
                fontFamily: 'Lufga',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],

        // Acción
        if (action != null) ...[
          const SizedBox(height: 24),
          action!,
        ] else if (showRetry) ...[
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textOnPrimary,
            ),
          ),
        ],
      ],
    );
  }
}