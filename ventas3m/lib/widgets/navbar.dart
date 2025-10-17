import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../core/theme/colors.dart';
import '../providers/navigation_provider.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/sales/sales_screen.dart';
import '../screens/products/products_screen.dart';
import '../screens/banking/banking_screen.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  NavBarState createState() => NavBarState();
}

class NavBarState extends State<NavBar> {
  static const List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    SalesScreen(),
    ProductsScreen(),
    BankingScreen(),
  ];

  void _onItemTapped(BuildContext context, int index) {
    Provider.of<NavigationProvider>(context, listen: false).setSelectedIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    // Verificar si hay usuario autenticado antes de mostrar la navbar
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      return const SizedBox.shrink(); // No mostrar nada si no hay usuario
    }

    // Obtiene el padding de la zona segura inferior del dispositivo
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Consumer<NavigationProvider>(
      builder: (context, navProvider, child) => Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: navProvider.selectedIndex,
          children: _widgetOptions,
        ),
        bottomNavigationBar: Padding(
        // Utiliza el padding inferior del sistema
        padding: EdgeInsets.only(
          left: 15,
          right: 15,
          bottom: bottomPadding + 5,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, 0, Icons.home_rounded, 'Dashboard'),
              _buildNavItem(context, 1, Icons.bar_chart_rounded, 'Ventas'),
              _buildNavItem(context, 2, Icons.inventory_2_rounded, 'Productos'),
              _buildNavItem(context, 3, Icons.account_balance, 'Banca'),
            ],
          ),
        ),
      ),
    )
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label) {
    final isSelected = Provider.of<NavigationProvider>(context).selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(context, index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 16 : 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.onSecondary : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              size: isSelected ? 28 : 24,
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  label,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}