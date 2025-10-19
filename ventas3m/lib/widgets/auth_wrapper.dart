import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../providers/auth_provider.dart';
import '../widgets/navbar.dart';
import '../screens/login/login_screen.dart';
import '../core/widgets/loading_widget.dart';
import 'notification_permission_dialog.dart';
import '../services/notification_preferences_service.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showNotificationDialog = false;
  late NotificationPreferencesService _preferencesService;

  @override
  void initState() {
    super.initState();
    _initializeNotificationPreferences();
  }

  Future<void> _initializeNotificationPreferences() async {
    _preferencesService = await NotificationPreferencesService.create();
    await _preferencesService.initializeDefaultSettings();
    await _checkNotificationPermissionStatus();
  }

  Future<void> _checkNotificationPermissionStatus() async {
    final hasAskedForPermission = await _preferencesService.hasAskedForNotificationPermission();

    if (!hasAskedForPermission) {
      // Pequeño delay para asegurar que la navegación haya terminado
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _showNotificationDialog = true;
          });
        }
      });
    }
  }

  Future<void> _markNotificationPermissionAsAsked() async {
    await _preferencesService.setHasAskedForNotificationPermission(true);
  }

  void _showNotificationPermissionDialog() {
    NotificationPermissionDialog.show(context).then((result) {
      setState(() {
        _showNotificationDialog = false;
      });
      _markNotificationPermissionAsAsked();
    });
  }

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
        if (_showNotificationDialog) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showNotificationPermissionDialog();
          });
        }

        return const NavBar();
      },
    );
  }
}