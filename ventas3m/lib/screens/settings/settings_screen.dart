import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../profile/profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuraciones'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSettingsCard(
            context,
            'Perfil',
            Icons.person,
            Theme.of(context).colorScheme.primary,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
          ),
          _buildSettingsCard(
            context,
            'Gestión de Proyectos',
            Icons.folder,
            Theme.of(context).colorScheme.secondary,
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Gestión de Proyectos - Próximamente')),
              );
            },
          ),
          _buildSettingsCard(
            context,
            'Configuración de la App',
            Icons.app_settings_alt,
            Theme.of(context).colorScheme.tertiary,
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configuración de la App - Próximamente')),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildThemeToggleCard(context),
          const SizedBox(height: 16),
          _buildLogoutCard(context),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  Widget _buildThemeToggleCard(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isDark ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary,
          child: Icon(
            isDark ? Icons.dark_mode : Icons.light_mode,
            color: Colors.white,
          ),
        ),
        title: Text(
          'Modo ${isDark ? 'Oscuro' : 'Claro'}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          'Cambiar entre tema ${isDark ? 'oscuro' : 'claro'}',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Switch(
          value: isDark,
          onChanged: (value) {
            themeProvider.toggleDarkMode();
          },
          activeThumbColor: Theme.of(context).colorScheme.primary,
        ),
        onTap: () {
          themeProvider.toggleDarkMode();
        },
      ),
    );
  }

  Widget _buildLogoutCard(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.error,
          child: const Icon(Icons.logout, color: Colors.white),
        ),
        title: const Text(
          'Cerrar Sesión',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () async {
          await authProvider.logout();
          if (context.mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          }
        },
      ),
    );
  }
}