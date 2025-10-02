import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/settings_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'core/theme/responsive_theme.dart';
import 'widgets/auth_wrapper.dart';
import 'router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        //provider firebase
        StreamProvider.value(value: FirebaseAuth.instance.authStateChanges() , initialData: null),
        // SettingsProvider debe ir primero ya que otros providers pueden depender de él
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        // ThemeProvider va segundo y se conecta con SettingsProvider
        ChangeNotifierProvider(create: (context) {
          final themeProvider = ThemeProvider();
          // Conectar con SettingsProvider para sincronización
          themeProvider.setSettingsProvider(context.read<SettingsProvider>());
          return themeProvider;
        }),
        // AuthProvider va último ya que puede necesitar acceso a otros providers
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Ventas 3M',
      debugShowCheckedModeBanner: false,
      theme: ResponsiveAppTheme.getResponsiveTheme(
        context: context,
        isDark: themeProvider.isDark,
        highContrast: themeProvider.highContrast,
      ),
      home: const AuthWrapper(),
      routes: AppRouter.routes,
    );
  }
}

