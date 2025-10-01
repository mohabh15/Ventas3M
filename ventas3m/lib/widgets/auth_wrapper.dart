import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/navbar.dart';
import '../screens/login/login_screen.dart';
import '../core/widgets/loading_widget.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Mostrar loading mientras se verifica la autenticación
    if (authProvider.isLoading) {
      return const Scaffold(
        body: LoadingWidget(),
      );
    }

    // Mostrar login si no está autenticado
    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }

    // Mostrar la app principal si está autenticado
    return const NavBar();
  }
}