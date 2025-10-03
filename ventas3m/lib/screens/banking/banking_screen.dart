import 'package:flutter/material.dart';
import '../../core/widgets/gradient_app_bar.dart';

class BankingScreen extends StatefulWidget {
  const BankingScreen({super.key});

  @override
  State<BankingScreen> createState() => _BankingScreenState();
}

class _BankingScreenState extends State<BankingScreen> {
  @override
  Widget build(BuildContext context) {
    // Calcular la altura de la barra de navegación inferior
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: GradientAppBar(
        title: 'Banca',
      ),
      body: Stack(
        children: [
          const Center(
            child: Text('Banking Screen'),
          ),
          // Botón flotante posicionado relativo a la navbar
          Positioned(
            right: 16.0,
            bottom: bottomPadding + 16.0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0D47A1), // Azul oscuro
                    Color(0xFF1976D2), // Azul primario
                    Color(0xFF42A5F5), // Azul claro
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: FloatingActionButton(
                heroTag: 'banking_fab',
                onPressed: () {
                  // TODO: Implementar navegación a pantalla de agregar transacción
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}