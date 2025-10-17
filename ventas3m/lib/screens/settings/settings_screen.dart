import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/firebase_service.dart';
import '../../models/project.dart';
import '../profile/profile_screen.dart';
import '../management/management_screen.dart';
import '../../core/widgets/gradient_app_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<Project> _projects = [];
  bool _isLoadingProjects = false;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() => _isLoadingProjects = true);
    try {
      final firebaseService = FirebaseService();
      _projects = await firebaseService.getProjects();
      // ignore: use_build_context_synchronously
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      final activeProjectId = settingsProvider.activeProjectId;
      if (activeProjectId != null && !_projects.any((p) => p.id == activeProjectId)) {
        settingsProvider.setActiveProjectId(null);
      }
    } catch (e) {
      // Handle error if needed
    } finally {
      setState(() => _isLoadingProjects = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: 'Configuraciones',
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
            'Proyectos',
            [
              _buildSettingsTile(
                context,
                'Gestión de Proyectos',
                Icons.folder,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ManagementScreen()),
                  );
                },
              ),
              const Divider(),
              _buildProjectSelectorTile(context),
            ],
          ),
          const SizedBox(height: 16),
          _buildGroupedCard(
            context,
            'Aplicación',
            [
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

  Widget _buildProjectSelectorTile(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final activeProjectId = settingsProvider.activeProjectId;

    return ListTile(
      leading: Icon(
        Icons.business,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        size: 24,
      ),
      title: const Text(
        'Proyecto Activo',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: _isLoadingProjects
          ? const Text('Cargando proyectos...')
          : _projects.isEmpty
              ? const Text(
                  'No hay proyectos disponibles',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                )
              : Text(
                  activeProjectId != null
                      ? _projects.firstWhere((p) => p.id == activeProjectId, orElse: () => Project(id: '', name: 'Desconocido', description: '', ownerId: '', createdAt: DateTime.now(), updatedAt: DateTime.now(), isActive: false, members: [], providers: [])).name
                      : 'Ninguno seleccionado',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
      trailing: _isLoadingProjects
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : _projects.isEmpty
              ? const Text(
                  'No disponible',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                )
              : DropdownButton<String>(
                  value: activeProjectId,
                  hint: const Text('Seleccionar'),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Ninguno'),
                    ),
                    ..._projects.map((project) => DropdownMenuItem<String>(
                          value: project.id,
                          child: Text(project.name),
                        )),
                  ],
                  onChanged: (value) {
                    settingsProvider.setActiveProjectId(value);
                  },
                  underline: const SizedBox(),
                ),
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
          context.go('/login');
        }
      },
    );
  }
}