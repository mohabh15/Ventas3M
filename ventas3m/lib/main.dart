import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:async';
import 'firebase_options.dart';
import 'providers/settings_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/sales_provider.dart';
import 'providers/products_provider.dart';
import 'providers/product_stock_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/debt_provider.dart';
import 'providers/team_balance_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/event_provider.dart';
import 'core/theme/responsive_theme.dart';
import 'router/app_router.dart';

Future<void> main() async {
  // Configurar handler de errores de zona
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Inicializar datos de localización para formateo de fechas y números
    await initializeDateFormatting('es_ES', null);

    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Configurar handler global de errores de Flutter
    FlutterError.onError = (FlutterErrorDetails details) {
      // Filtrar errores específicos de Firestore que queremos ignorar
      if (details.exceptionAsString().contains('cloud_firestore/permission-denied')) {
        // Ignorar errores de permisos de Firestore silenciosamente
        return;
      }
      // Para otros errores, usar el comportamiento por defecto
      FlutterError.dumpErrorToConsole(details);
    };

    runApp(
      MultiProvider(
        providers: [
          //provider firebase
          StreamProvider.value(value: FirebaseAuth.instance.authStateChanges() , initialData: null),
          // SettingsProvider debe ir primero ya que otros providers pueden depender de él
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          // NavigationProvider para gestionar la navegación
          ChangeNotifierProvider(create: (_) => NavigationProvider()),
          // AuthProvider va antes de otros providers que dependen de autenticación
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          // ThemeProvider va segundo y se conecta con SettingsProvider
          ChangeNotifierProvider(create: (context) {
            final themeProvider = ThemeProvider();
            // Conectar con SettingsProvider para sincronización
            themeProvider.setSettingsProvider(context.read<SettingsProvider>());
            return themeProvider;
          }),
          // SalesProvider para gestionar las ventas
          ChangeNotifierProvider(create: (_) => SalesProvider()),
          // EventProvider para gestionar los eventos
          ChangeNotifierProvider(create: (_) => EventProvider()),
          ChangeNotifierProvider(create: (context) {
            final productProvider = ProductsProvider();
            // Conectar con SettingsProvider para sincronización
            productProvider.setSettingsProvider(context.read<SettingsProvider>());
            productProvider.loadProducts(); //cargar productos al iniciar
            return productProvider;
          }),
          // ProductStockProvider para gestionar el stock de productos
          ChangeNotifierProvider(create: (context) {
            final stockProvider = ProductStockProvider();
            // Conectar con SettingsProvider para sincronización
            stockProvider.setSettingsProvider(context.read<SettingsProvider>());
            return stockProvider;
          }),
          // ExpenseProvider para gestionar los gastos
          ChangeNotifierProvider(create: (_) => ExpenseProvider()),
          // DebtProvider para gestionar las deudas
          ChangeNotifierProvider(create: (_) => DebtProvider()),
          // TeamBalanceProvider para gestionar balances del equipo
          ChangeNotifierProvider(create: (context) {
            final teamBalanceProvider = TeamBalanceProvider(context.read<SettingsProvider>());
            return teamBalanceProvider;
          }),
        ],
        child: const MyApp(),
      ),
    );
  }, (error, stackTrace) {
    // Filtrar errores específicos de Firestore que queremos ignorar
    if (error.toString().contains('cloud_firestore/permission-denied')) {
      // Ignorar errores de permisos de Firestore silenciosamente
      return;
    }
    // Para otros errores, imprimir en consola
    //print('Error no manejado: $error');
    //print('Stack trace: $stackTrace');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp.router(
      title: 'Ventas 3M',
      debugShowCheckedModeBanner: false,
      theme: ResponsiveAppTheme.getResponsiveTheme(
        context: context,
        isDark: themeProvider.isDark,
        highContrast: themeProvider.highContrast,
      ),
      routerConfig: AppRouter.router,
    );
  }
}
