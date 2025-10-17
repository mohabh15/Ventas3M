import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../providers/auth_provider.dart';
import '../widgets/navbar.dart';
import '../screens/login/login_screen.dart';
import '../core/widgets/loading_widget.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<firebase_auth.User?>(
      stream: firebase_auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final authProvider = Provider.of<AuthProvider>(context);

        // Mostrar loading mientras se verifica la autenticación o el stream está cargando
        if (authProvider.isLoading || snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: LoadingWidget(),
          );
        }

        // Verificar estado de Firebase Auth desde el stream
        final firebaseUser = snapshot.data;

        // Mostrar login si no está autenticado en Firebase
        if (firebaseUser == null) {
          return const LoginScreen();
        }

        // Mostrar la app principal si está autenticado
        return const NavBar();
      },
    );
  }
}