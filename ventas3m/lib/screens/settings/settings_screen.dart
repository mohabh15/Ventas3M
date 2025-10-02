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
        backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildGroupedCard(
            context,
            'Cuenta',
            [
              _buildSettingsTile(
                context,
                'Perfil',
                Icons.person,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  );
                },
              ),
              const Divider(),
              _buildLogoutTile(context),
            ],
          ),
          const SizedBox(height: 16),
          _buildGroupedCard(
            context,
            'Aplicación',
            [
              _buildSettingsTile(
                context,
                'Gestión de Proyectos',
                Icons.folder,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gestión de Proyectos - Próximamente')),
                  );
                },
              ),
              const Divider(),
              _buildSettingsTile(
                context,
                'Configuración de la App',
                Icons.app_settings_alt,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Configuración de la App - Próximamente')),
                  );
                },
              ),
              const Divider(),
              _buildThemeToggleTile(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedCard(
    BuildContext context,
    String groupTitle,
    List<Widget> children,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              groupTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        size: 24,
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
    );
  }

  Widget _buildThemeToggleTile(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;

    return ListTile(
      leading: Icon(
        isDark ? Icons.dark_mode : Icons.light_mode,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        size: 24,
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
    );
  }

  Widget _buildLogoutTile(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return ListTile(
      leading: Icon(
        Icons.logout,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        size: 24,
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
    );
  }
}