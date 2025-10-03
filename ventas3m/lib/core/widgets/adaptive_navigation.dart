import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../utils/responsive_utils.dart';

/// Elemento de navegación adaptativo
class AdaptiveNavigationItem {
  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final String? badge;
  final bool showBadge;
  final Color? badgeColor;
  final Widget? trailing;

  const AdaptiveNavigationItem({
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.badge,
    this.showBadge = false,
    this.badgeColor,
    this.trailing,
  });
}

/// Sistema de navegación completamente adaptativo
class AdaptiveNavigation extends StatefulWidget {
  final List<AdaptiveNavigationItem> items;
  final int currentIndex;
  final Function(int) onDestinationSelected;
  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showLabels;
  final bool showBottomNavigation;
  final bool showNavigationRail;
  final bool showDrawer;
  final NavigationType? navigationType;
  final double? navigationRailWidth;
  final double? drawerWidth;

  const AdaptiveNavigation({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onDestinationSelected,
    this.title,
    this.leading,
    this.actions,
    this.showLabels = true,
    this.showBottomNavigation = true,
    this.showNavigationRail = true,
    this.showDrawer = true,
    this.navigationType,
    this.navigationRailWidth = 80,
    this.drawerWidth = 280,
  });

  @override
  State<AdaptiveNavigation> createState() => _AdaptiveNavigationState();
}

class _AdaptiveNavigationState extends State<AdaptiveNavigation> {
  late NavigationType _currentNavigationType;

  @override
  void initState() {
    super.initState();
    _currentNavigationType = widget.navigationType ?? ResponsiveNavigationManager.getOptimalNavigationType(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final optimalType = ResponsiveNavigationManager.getOptimalNavigationType(context);
    if (optimalType != _currentNavigationType) {
      setState(() {
        _currentNavigationType = optimalType;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentNavigationType) {
      case NavigationType.bottomNavigation:
        return _buildBottomNavigation();
      case NavigationType.navigationRail:
        return _buildNavigationRail();
      case NavigationType.permanentDrawer:
        return _buildPermanentDrawer();
      case NavigationType.modalDrawer:
        return _buildModalDrawer();
    }
  }

  Widget _buildBottomNavigation() {
    if (!widget.showBottomNavigation) {
      return const SizedBox.shrink();
    }

    final showLabels = ResponsiveNavigationManager.shouldShowLabels(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: widget.currentIndex,
        onDestinationSelected: widget.onDestinationSelected,
        height: ResponsiveUtils.getResponsiveTouchTargetSize(context) + 16,
        backgroundColor: Colors.transparent,
        elevation: 0,
        labelBehavior: showLabels
            ? NavigationDestinationLabelBehavior.alwaysShow
            : NavigationDestinationLabelBehavior.alwaysHide,
        destinations: widget.items.map((item) {
          return NavigationDestination(
            icon: _buildNavigationIcon(item.icon, item.selectedIcon, false),
            selectedIcon: _buildNavigationIcon(item.icon, item.selectedIcon, true),
            label: showLabels ? item.label : '',
            tooltip: item.label,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNavigationRail() {
    if (!widget.showNavigationRail) {
      return const SizedBox.shrink();
    }

    return Container(
      width: widget.navigationRailWidth,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header opcional
          if (widget.leading != null || widget.title != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (widget.leading != null) widget.leading!,
                  if (widget.title != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.title!,
                      style: TextStyle(
                        fontFamily: 'Lufga',
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ],
                ],
              ),
            ),
            Divider(color: AppColors.border.withValues(alpha: 0.5)),
          ],

          // Destinos de navegación
          Expanded(
            child: NavigationRail(
              selectedIndex: widget.currentIndex,
              onDestinationSelected: widget.onDestinationSelected,
              backgroundColor: Colors.transparent,
              elevation: 0,
              useIndicator: true,
              indicatorColor: AppColors.primary.withValues(alpha: 0.1),
              selectedIconTheme: IconThemeData(
                color: AppColors.primary,
                size: ResponsiveUtils.getResponsiveIconSize(context, size: 24),
              ),
              unselectedIconTheme: IconThemeData(
                color: AppColors.textSecondary,
                size: ResponsiveUtils.getResponsiveIconSize(context, size: 22),
              ),
              selectedLabelTextStyle: TextStyle(
                fontFamily: 'Lufga',
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
              unselectedLabelTextStyle: TextStyle(
                fontFamily: 'Lufga',
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 11),
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
              destinations: widget.items.map((item) {
                return NavigationRailDestination(
                  icon: _buildNavigationIcon(item.icon, item.selectedIcon, false),
                  selectedIcon: _buildNavigationIcon(item.icon, item.selectedIcon, true),
                  label: Text(item.label),
                );
              }).toList(),
            ),
          ),

          // Acciones opcionales
          if (widget.actions != null) ...[
            Divider(color: AppColors.border.withValues(alpha: 0.5)),
            ...widget.actions!,
          ],
        ],
      ),
    );
  }

  Widget _buildPermanentDrawer() {
    if (!widget.showDrawer) {
      return const SizedBox.shrink();
    }

    return Container(
      width: widget.drawerWidth,
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
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (widget.leading != null) ...[
                  widget.leading!,
                  const SizedBox(width: 12),
                ],
                if (widget.title != null)
                  Expanded(
                    child: Text(
                      widget.title!,
                      style: TextStyle(
                        fontFamily: 'Lufga',
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Elementos de navegación
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                final isSelected = widget.currentIndex == index;

                return _buildDrawerItem(item, isSelected, index);
              },
            ),
          ),

          // Acciones al pie
          if (widget.actions != null) ...[
            Divider(color: AppColors.border.withValues(alpha: 0.5)),
            ...widget.actions!.map((action) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: action,
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildModalDrawer() {
    return Drawer(
      width: widget.drawerWidth,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (widget.leading != null) ...[
                  widget.leading!,
                  const SizedBox(width: 12),
                ],
                if (widget.title != null)
                  Expanded(
                    child: Text(
                      widget.title!,
                      style: TextStyle(
                        fontFamily: 'Lufga',
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Elementos de navegación
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                final isSelected = widget.currentIndex == index;

                return _buildDrawerItem(item, isSelected, index);
              },
            ),
          ),

          // Acciones al pie
          if (widget.actions != null) ...[
            Divider(color: AppColors.border.withValues(alpha: 0.5)),
            ...widget.actions!.map((action) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: action,
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildDrawerItem(AdaptiveNavigationItem item, bool isSelected, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.3)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: ListTile(
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              isSelected && item.selectedIcon != null
                  ? item.selectedIcon!
                  : item.icon,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textSecondary,
              size: ResponsiveUtils.getResponsiveIconSize(context, size: 24),
            ),
            if (item.showBadge && item.badge != null)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: item.badgeColor ?? AppColors.error,
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
                    item.badge!,
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
          item.label,
          style: TextStyle(
            fontFamily: 'Lufga',
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? AppColors.primary
                : AppColors.textPrimary,
          ),
        ),
        trailing: item.trailing,
        onTap: () => widget.onDestinationSelected(index),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildNavigationIcon(IconData icon, IconData? selectedIcon, bool isSelected) {
    final effectiveIcon = (isSelected && selectedIcon != null) ? selectedIcon : icon;

    return Icon(
      effectiveIcon,
      size: ResponsiveUtils.getResponsiveIconSize(context, size: 24),
    );
  }
}

/// Scaffold adaptativo que maneja automáticamente la navegación
class AdaptiveNavigationScaffold extends StatefulWidget {
  final List<AdaptiveNavigationItem> navigationItems;
  final int currentIndex;
  final Function(int) onNavigationChanged;
  final List<Widget> screens;
  final String? appBarTitle;
  final Widget? floatingActionButton;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showAppBar;
  final bool showFloatingActionButton;

  const AdaptiveNavigationScaffold({
    super.key,
    required this.navigationItems,
    required this.currentIndex,
    required this.onNavigationChanged,
    required this.screens,
    this.appBarTitle,
    this.floatingActionButton,
    this.leading,
    this.actions,
    this.showAppBar = true,
    this.showFloatingActionButton = true,
  });

  @override
  State<AdaptiveNavigationScaffold> createState() => _AdaptiveNavigationScaffoldState();
}

class _AdaptiveNavigationScaffoldState extends State<AdaptiveNavigationScaffold> {
  late NavigationType _currentNavigationType;

  @override
  void initState() {
    super.initState();
    _currentNavigationType = ResponsiveNavigationManager.getOptimalNavigationType(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final optimalType = ResponsiveNavigationManager.getOptimalNavigationType(context);
    if (optimalType != _currentNavigationType) {
      setState(() {
        _currentNavigationType = optimalType;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentScreen = widget.screens[widget.currentIndex];

    switch (_currentNavigationType) {
      case NavigationType.bottomNavigation:
        return Scaffold(
          appBar: widget.showAppBar ? _buildAppBar() : null,
          body: currentScreen,
          bottomNavigationBar: AdaptiveNavigation(
            items: widget.navigationItems,
            currentIndex: widget.currentIndex,
            onDestinationSelected: widget.onNavigationChanged,
            showLabels: ResponsiveNavigationManager.shouldShowLabels(context),
          ),
          floatingActionButton: widget.showFloatingActionButton ? widget.floatingActionButton : null,
        );

      case NavigationType.navigationRail:
        return Scaffold(
          appBar: widget.showAppBar ? _buildAppBar() : null,
          body: Row(
            children: [
              AdaptiveNavigation(
                items: widget.navigationItems,
                currentIndex: widget.currentIndex,
                onDestinationSelected: widget.onNavigationChanged,
                title: widget.appBarTitle,
                leading: widget.leading,
                actions: widget.actions,
                showBottomNavigation: false,
                showDrawer: false,
                navigationType: NavigationType.navigationRail,
              ),
              Expanded(child: currentScreen),
            ],
          ),
          floatingActionButton: widget.showFloatingActionButton ? widget.floatingActionButton : null,
        );

      case NavigationType.permanentDrawer:
        return Scaffold(
          appBar: widget.showAppBar ? _buildAppBar() : null,
          body: Row(
            children: [
              AdaptiveNavigation(
                items: widget.navigationItems,
                currentIndex: widget.currentIndex,
                onDestinationSelected: widget.onNavigationChanged,
                title: widget.appBarTitle,
                leading: widget.leading,
                actions: widget.actions,
                showBottomNavigation: false,
                showNavigationRail: false,
                navigationType: NavigationType.permanentDrawer,
              ),
              Expanded(child: currentScreen),
            ],
          ),
          floatingActionButton: widget.showFloatingActionButton ? widget.floatingActionButton : null,
        );

      case NavigationType.modalDrawer:
        return Scaffold(
          appBar: widget.showAppBar ? _buildAppBar() : null,
          drawer: AdaptiveNavigation(
            items: widget.navigationItems,
            currentIndex: widget.currentIndex,
            onDestinationSelected: widget.onNavigationChanged,
            title: widget.appBarTitle,
            leading: widget.leading,
            actions: widget.actions,
            showBottomNavigation: false,
            showNavigationRail: false,
            navigationType: NavigationType.modalDrawer,
          ),
          body: currentScreen,
          floatingActionButton: widget.showFloatingActionButton ? widget.floatingActionButton : null,
        );
    }
  }

  PreferredSizeWidget? _buildAppBar() {
    if (!widget.showAppBar) return null;

    return AppBar(
      title: widget.appBarTitle != null
          ? Text(
              widget.appBarTitle!,
              style: TextStyle(
                fontFamily: 'Lufga',
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
                fontWeight: FontWeight.w700,
              ),
            )
          : null,
      leading: _currentNavigationType == NavigationType.modalDrawer
          ? Builder(
              builder: (context) => IconButton(
                icon: Icon(
                  Icons.menu,
                  size: ResponsiveUtils.getResponsiveIconSize(context, size: 24),
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            )
          : widget.leading,
      actions: widget.actions,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.primaryGradient,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
    );
  }
}

/// Extensiones útiles para navegación
extension NavigationTypeExtensions on NavigationType {
  bool get isBottomNavigation => this == NavigationType.bottomNavigation;
  bool get isNavigationRail => this == NavigationType.navigationRail;
  bool get isPermanentDrawer => this == NavigationType.permanentDrawer;
  bool get isModalDrawer => this == NavigationType.modalDrawer;

  bool get supportsLabels {
    switch (this) {
      case NavigationType.bottomNavigation:
        return true;
      case NavigationType.navigationRail:
        return false;
      case NavigationType.permanentDrawer:
        return true;
      case NavigationType.modalDrawer:
        return true;
    }
  }
}