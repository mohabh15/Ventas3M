import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Elemento de navegación moderno con estados mejorados
class NavigationItem {
  final String label;
  final IconData icon;
  final IconData? activeIcon;
  final String? badge;
  final bool showBadge;
  final Color? badgeColor;

  const NavigationItem({
    required this.label,
    required this.icon,
    this.activeIcon,
    this.badge,
    this.showBadge = false,
    this.badgeColor,
  });
}

/// NavBar flotante moderno con diseño mejorado
class ModernNavBar extends StatefulWidget {
  final List<NavigationItem> items;
  final int currentIndex;
  final Function(int) onTap;
  final bool showLabels;
  final bool showIndicators;
  final double elevation;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final Duration animationDuration;

  const ModernNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.showLabels = true,
    this.showIndicators = true,
    this.elevation = 12,
    this.backgroundColor,
    this.padding,
    this.animationDuration = const Duration(milliseconds: 250),
  });

  @override
  State<ModernNavBar> createState() => _ModernNavBarState();
}

class _ModernNavBarState extends State<ModernNavBar> with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _badgeAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeAnimations() {
    _animationControllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: widget.animationDuration,
        vsync: this,
      ),
    );

    _scaleAnimations = _animationControllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    _badgeAnimations = _animationControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.elasticOut),
      );
    }).toList();

    // Activar animación del elemento actual
    if (widget.currentIndex < _animationControllers.length) {
      _animationControllers[widget.currentIndex].forward();
    }
  }

  @override
  void didUpdateWidget(ModernNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      // Animar transición entre elementos
      _animationControllers[oldWidget.currentIndex].reverse();
      if (widget.currentIndex < _animationControllers.length) {
        _animationControllers[widget.currentIndex].forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: bottomPadding + 10,
      ),
      child: Container(
        height: 70,
        padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? AppColors.cardBackground.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.15),
              blurRadius: widget.elevation,
              offset: Offset(0, widget.elevation * 0.6),
              spreadRadius: 2,
            ),
          ],
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(widget.items.length, (index) {
            return _ModernNavBarItem(
              item: widget.items[index],
              isSelected: widget.currentIndex == index,
              onTap: () => widget.onTap(index),
              showLabel: widget.showLabels,
              showIndicator: widget.showIndicators,
              scaleAnimation: _scaleAnimations[index],
              badgeAnimation: _badgeAnimations[index],
            );
          }),
        ),
      ),
    );
  }
}

/// Elemento individual del NavBar moderno
class _ModernNavBarItem extends StatefulWidget {
  final NavigationItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showLabel;
  final bool showIndicator;
  final Animation<double> scaleAnimation;
  final Animation<double> badgeAnimation;

  const _ModernNavBarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.showLabel,
    required this.showIndicator,
    required this.scaleAnimation,
    required this.badgeAnimation,
  });

  @override
  State<_ModernNavBarItem> createState() => _ModernNavBarItemState();
}

class _ModernNavBarItemState extends State<_ModernNavBarItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([widget.scaleAnimation, widget.badgeAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isSelected ? widget.scaleAnimation.value : 1.0,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: widget.isSelected ? 16 : 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.isSelected
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Indicador superior para elemento activo
                  if (widget.showIndicator && widget.isSelected)
                    Container(
                      width: 20,
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    )
                  else
                    const SizedBox(height: 3),

                  const SizedBox(height: 4),

                  // Stack para ícono y badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        widget.isSelected && widget.item.activeIcon != null
                            ? widget.item.activeIcon!
                            : widget.item.icon,
                        color: widget.isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: widget.isSelected ? 26 : 24,
                      ),

                      // Badge
                      if (widget.item.showBadge && widget.item.badge != null)
                        Positioned(
                          top: -6,
                          right: -6,
                          child: Transform.scale(
                            scale: widget.badgeAnimation.value,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: widget.item.badgeColor ?? AppColors.error,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.cardBackground,
                                  width: 2,
                                ),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                widget.item.badge!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 2),

                  // Etiqueta
                  if (widget.showLabel)
                    Text(
                      widget.item.label,
                      style: TextStyle(
                        color: widget.isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontSize: widget.isSelected ? 12 : 11,
                        fontWeight: widget.isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        fontFamily: 'Lufga',
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Sistema de pestañas moderno
class ModernTabBar extends StatefulWidget {
  final List<String> tabs;
  final int currentIndex;
  final Function(int) onTap;
  final Color? indicatorColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final bool isScrollable;
  final EdgeInsetsGeometry? padding;
  final double indicatorHeight;
  final TabController? controller;

  const ModernTabBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.isScrollable = false,
    this.padding,
    this.indicatorHeight = 3,
    this.controller,
  });

  @override
  State<ModernTabBar> createState() => _ModernTabBarState();
}

class _ModernTabBarState extends State<ModernTabBar> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _indicatorController;
  late Animation<double> _indicatorAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = widget.controller ?? TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: widget.currentIndex,
    );

    _indicatorController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _indicatorAnimation = Tween<double>(
      begin: _getIndicatorPosition(widget.currentIndex),
      end: _getIndicatorPosition(widget.currentIndex),
    ).animate(CurvedAnimation(
      parent: _indicatorController,
      curve: Curves.easeInOut,
    ));

    _initializeIndicator();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _tabController.dispose();
    }
    _indicatorController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ModernTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _animateIndicator(widget.currentIndex);
    }
  }

  void _initializeIndicator() {
    _indicatorController.forward();
  }

  void _animateIndicator(int newIndex) {
    _indicatorAnimation = Tween<double>(
      begin: _indicatorAnimation.value,
      end: _getIndicatorPosition(newIndex),
    ).animate(CurvedAnimation(
      parent: _indicatorController,
      curve: Curves.easeInOut,
    ));

    _indicatorController.forward(from: 0);
  }

  double _getIndicatorPosition(int index) {
    // Calcula la posición del indicador basada en el índice
    return (index * 100.0) + 50.0; // Simplificado
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: widget.onTap,
        isScrollable: widget.isScrollable,
        indicator: BoxDecoration(
          color: widget.indicatorColor ?? AppColors.primary,
          borderRadius: BorderRadius.circular(6),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        indicatorPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 47 - widget.indicatorHeight,
        ),
        labelColor: widget.labelColor ?? AppColors.primary,
        unselectedLabelColor: widget.unselectedLabelColor ?? AppColors.textSecondary,
        labelStyle: const TextStyle(
          fontFamily: 'Lufga',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Lufga',
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        tabs: widget.tabs.map((tab) => Tab(text: tab)).toList(),
        padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }
}

/// Drawer lateral moderno para navegación desktop
class ModernDrawer extends StatefulWidget {
  final List<NavigationItem> items;
  final int currentIndex;
  final Function(int) onTap;
  final String? title;
  final Widget? header;
  final Widget? footer;
  final double width;
  final bool showDividers;
  final Duration animationDuration;

  const ModernDrawer({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.title,
    this.header,
    this.footer,
    this.width = 280,
    this.showDividers = true,
    this.animationDuration = const Duration(milliseconds: 250),
  });

  @override
  State<ModernDrawer> createState() => _ModernDrawerState();
}

class _ModernDrawerState extends State<ModernDrawer> with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeAnimations() {
    _animationControllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: widget.animationDuration,
        vsync: this,
      ),
    );

    _slideAnimations = _animationControllers.map((controller) {
      return Tween<double>(begin: -20.0, end: 0.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          if (widget.header != null)
            Container(
              padding: const EdgeInsets.all(20),
              child: widget.header!,
            )
          else if (widget.title != null)
            Container(
              padding: const EdgeInsets.all(20),
              child: Text(
                widget.title!,
                style: TextStyle(
                  fontFamily: 'Lufga',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

          // Elementos de navegación
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _slideAnimations[index],
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_slideAnimations[index].value, 0),
                      child: _ModernDrawerItem(
                        item: widget.items[index],
                        isSelected: widget.currentIndex == index,
                        onTap: () => widget.onTap(index),
                        showDivider: widget.showDividers && index < widget.items.length - 1,
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Footer
          if (widget.footer != null)
            Container(
              padding: const EdgeInsets.all(20),
              child: widget.footer!,
            ),
        ],
      ),
    );
  }
}

/// Elemento individual del drawer moderno
class _ModernDrawerItem extends StatefulWidget {
  final NavigationItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showDivider;

  const _ModernDrawerItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.showDivider,
  });

  @override
  State<_ModernDrawerItem> createState() => _ModernDrawerItemState();
}

class _ModernDrawerItemState extends State<_ModernDrawerItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: ListTile(
            leading: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  widget.item.icon,
                  color: widget.isSelected
                      ? AppColors.primary
                      : _isHovered
                          ? AppColors.primary.withValues(alpha: 0.7)
                          : AppColors.textSecondary,
                  size: 24,
                ),
                if (widget.item.showBadge && widget.item.badge != null)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: widget.item.badgeColor ?? AppColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.cardBackground,
                          width: 2,
                        ),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        widget.item.badge!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(
              widget.item.label,
              style: TextStyle(
                fontFamily: 'Lufga',
                fontSize: 14,
                fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                color: widget.isSelected
                    ? AppColors.primary
                    : _isHovered
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
              ),
            ),
            onTap: widget.onTap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            tileColor: widget.isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : _isHovered
                    ? AppColors.hover
                    : Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          ),
        ),

        // Divisor
        if (widget.showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
              color: AppColors.divider,
              height: 1,
            ),
          ),
      ],
    );
  }
}

/// Indicadores de estado y badges para navegación
class NavigationBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final bool showPulse;

  const NavigationBadge({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    this.padding,
    this.borderRadius = 12,
    this.showPulse = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: backgroundColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showPulse)
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: textColor,
                shape: BoxShape.circle,
              ),
            ),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Navegación por pestañas flotante
class FloatingTabBar extends StatefulWidget {
  final List<String> tabs;
  final int currentIndex;
  final Function(int) onTap;
  final Color? backgroundColor;
  final double height;
  final EdgeInsetsGeometry? margin;

  const FloatingTabBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor,
    this.height = 60,
    this.margin,
  });

  @override
  State<FloatingTabBar> createState() => _FloatingTabBarState();
}

class _FloatingTabBarState extends State<FloatingTabBar> with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeAnimations() {
    _animationControllers = List.generate(
      widget.tabs.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      margin: widget.margin ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(widget.tabs.length, (index) {
          return Expanded(
            child: GestureDetector(
              onTap: () => widget.onTap(index),
              child: AnimatedBuilder(
                animation: _animationControllers[index],
                builder: (context, child) {
                  final isSelected = widget.currentIndex == index;
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        widget.tabs[index],
                        style: TextStyle(
                          fontFamily: 'Lufga',
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? AppColors.textOnPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }),
      ),
    );
  }
}