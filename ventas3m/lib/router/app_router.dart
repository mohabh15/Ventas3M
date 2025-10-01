import 'package:flutter/material.dart';
import '../screens/login/login_screen.dart';
import '../screens/register/register_screen.dart';
import '../screens/forgot_password/forgot_password_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/sales/sales_screen.dart';
import '../screens/products/products_screen.dart';

class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String sales = '/sales';
  static const String products = '/products';

  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    dashboard: (context) => const DashboardScreen(),
    profile: (context) => ProfileScreen(),
    settings: (context) => const SettingsScreen(),
    sales: (context) => const SalesScreen(),
    products: (context) => const ProductsScreen(),
  };
}