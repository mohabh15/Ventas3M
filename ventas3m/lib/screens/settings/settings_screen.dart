import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/firebase_service.dart';
import '../../models/project.dart';
import '../../core/widgets/modern_loading.dart';
import '../profile/profile_screen.dart';
import '../management/management_screen.dart';

/// Enumeración para las diferentes secciones de configuración
enum SettingsSection {
  account('Cuenta', Icons.person, 'Gestión de cuenta y perfil'),
  projects('Proyectos', Icons.folder, 'Configuración de proyectos'),
  app('Aplicación', Icons.app_settings_alt, 'Preferencias de aplicación'),
  notifications('Notificaciones', Icons.notifications, 'Configuración de notificaciones'),
  privacy('Privacidad', Icons.security, 'Configuración de privacidad'),
  security('Seguridad', Icons.lock, 'Configuración de seguridad'),
  advanced('Avanzado', Icons.tune, 'Configuración avanzada'),
  support('Soporte', Icons.help, 'Ayuda y soporte');

  const SettingsSection(this.title, this.icon, this.description);
  final String title;
  final IconData icon;
  final String description;
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin {
  List<Project> _projects = [];
  bool _isLoadingProjects = false;
  SettingsSection _currentSection = SettingsSection.account;
  late AnimationController _sectionController;
  late Animation<double> _sectionAnimation;

  @override
  void initState() {
    super.initState();
    _loadProjects();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _sectionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _sectionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sectionController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _sectionController.dispose();
    super.dispose();
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

  void _changeSection(SettingsSection section) {
    if (_currentSection != section) {
      setState(() {
        _currentSection = section;
        _sectionController.forward(from: 0.0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: _buildModernAppBar(context),
      body: Container(
        decoration: BoxDecoration(
          gradient: theme.brightness == Brightness.dark
              ? AppDarkGradients.backgroundGradient
              : AppGradients.backgroundGradient,
        ),
        child: Row(
          children: [
            // Panel lateral de navegación
            _buildNavigationPanel(),

            // Contenido principal
            Expanded(
              child: AnimatedBuilder(
                animation: _sectionAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _sectionAnimation,
                    child: _buildSectionContent(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildQuickActions(),
    );
  }

  /// AppBar moderno con acciones rápidas
  PreferredSizeWidget _buildModernAppBar(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Icon(
            _currentSection.icon,
            size: 28,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _currentSection.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Lufga',
                ),
              ),
              Text(
                _currentSection.description,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontFamily: 'Lufga',
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        _buildQuickActionButton(
          icon: Icons.search,
          onPressed: () => _showSearchDialog(),
        ),
        _buildQuickActionButton(
          icon: Icons.import_export,
          onPressed: () => _showExportImportDialog(),
        ),
        _buildQuickActionButton(
          icon: Icons.refresh,
          onPressed: () => _refreshSettings(),
        ),
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'reset',
              child: Row(
                children: [
                  Icon(Icons.restore),
                  SizedBox(width: 8),
                  Text('Resetear configuración'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'help',
              child: Row(
                children: [
                  Icon(Icons.help),
                  SizedBox(width: 8),
                  Text('Ayuda'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Panel lateral de navegación moderna
  Widget _buildNavigationPanel() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header del panel
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.settings,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  'Configuración',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontFamily: 'Lufga',
                  ),
                ),
                Text(
                  'Gestiona tus preferencias',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontFamily: 'Lufga',
                  ),
                ),
              ],
            ),
          ),

          // Lista de secciones
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: SettingsSection.values.length,
              itemBuilder: (context, index) {
                final section = SettingsSection.values[index];
                return _buildNavigationItem(section);
              },
            ),
          ),

          // Footer del panel
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
            ),
            child: _buildLogoutTile(context),
          ),
        ],
      ),
    );
  }

  /// Item de navegación moderno
  Widget _buildNavigationItem(SettingsSection section) {
    final isSelected = _currentSection == section;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.8)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            section.icon,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
        title: Text(
          section.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onSurface,
            fontFamily: 'Lufga',
          ),
        ),
        trailing: isSelected
            ? Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              )
            : null,
        onTap: () => _changeSection(section),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Contenido de cada sección
  Widget _buildSectionContent() {
    switch (_currentSection) {
      case SettingsSection.account:
        return _buildAccountSection();
      case SettingsSection.projects:
        return _buildProjectsSection();
      case SettingsSection.app:
        return _buildAppSection();
      case SettingsSection.notifications:
        return _buildNotificationsSection();
      case SettingsSection.privacy:
        return _buildPrivacySection();
      case SettingsSection.security:
        return _buildSecuritySection();
      case SettingsSection.advanced:
        return _buildAdvancedSection();
      case SettingsSection.support:
        return _buildSupportSection();
    }
  }

  /// Sección de cuenta
  Widget _buildAccountSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información Personal',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
              fontFamily: 'Lufga',
            ),
          ),
          const SizedBox(height: 16),
          _buildProfileCard(),
          const SizedBox(height: 24),
          Text(
            'Acciones Rápidas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
              fontFamily: 'Lufga',
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickActionsCard(),
        ],
      ),
    );
  }

  /// Sección de proyectos
  Widget _buildProjectsSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gestión de Proyectos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
              fontFamily: 'Lufga',
            ),
          ),
          const SizedBox(height: 16),
          _buildProjectsManagementCard(),
          const SizedBox(height: 24),
          Text(
            'Proyecto Activo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
              fontFamily: 'Lufga',
            ),
          ),
          const SizedBox(height: 16),
          _buildActiveProjectCard(),
        ],
      ),
    );
  }

  /// Sección de aplicación
  Widget _buildAppSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tema y Apariencia',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
              fontFamily: 'Lufga',
            ),
          ),
          const SizedBox(height: 16),
          _buildThemeCard(),
          const SizedBox(height: 24),
          Text(
            'Idioma y Región',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
              fontFamily: 'Lufga',
            ),
          ),
          const SizedBox(height: 16),
          _buildLanguageCard(),
        ],
      ),
    );
  }

  /// Sección de notificaciones
  Widget _buildNotificationsSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferencias de Notificación',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
              fontFamily: 'Lufga',
            ),
          ),
          const SizedBox(height: 16),
          _buildNotificationSettingsCard(),
        ],
      ),
    );
  }

  /// Sección de privacidad
  Widget _buildPrivacySection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configuración de Privacidad',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
              fontFamily: 'Lufga',
            ),
          ),
          const SizedBox(height: 16),
          _buildPrivacyCard(),
        ],
      ),
    );
  }

  /// Sección de seguridad
  Widget _buildSecuritySection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seguridad de la Cuenta',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
              fontFamily: 'Lufga',
            ),
          ),
          const SizedBox(height: 16),
          _buildSecurityCard(),
        ],
      ),
    );
  }

  /// Sección avanzada
  Widget _buildAdvancedSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configuración Avanzada',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
              fontFamily: 'Lufga',
            ),
          ),
          const SizedBox(height: 16),
          _buildAdvancedCard(),
        ],
      ),
    );
  }

  /// Sección de soporte
  Widget _buildSupportSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ayuda y Soporte',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
              fontFamily: 'Lufga',
            ),
          ),
          const SizedBox(height: 16),
          _buildSupportCard(),
        ],
      ),
    );
  }

  /// Tarjeta de perfil moderna
  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.person,
              size: 40,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Perfil de Usuario',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontFamily: 'Lufga',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gestiona tu información personal y preferencias',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontFamily: 'Lufga',
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileScreen()),
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar Perfil'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Tarjeta de acciones rápidas
  Widget _buildQuickActionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildQuickActionTile(
            icon: Icons.password,
            title: 'Cambiar Contraseña',
            subtitle: 'Actualiza tu contraseña de acceso',
            onTap: () => _showChangePasswordDialog(),
          ),
          const Divider(),
          _buildQuickActionTile(
            icon: Icons.security,
            title: 'Configuración de Seguridad',
            subtitle: 'Gestiona 2FA y opciones de seguridad',
            onTap: () => _changeSection(SettingsSection.security),
          ),
          const Divider(),
          _buildQuickActionTile(
            icon: Icons.backup,
            title: 'Backup de Datos',
            subtitle: 'Configura el respaldo automático',
            onTap: () => _showBackupDialog(),
          ),
        ],
      ),
    );
  }

  /// Tarjeta de gestión de proyectos
  Widget _buildProjectsManagementCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.folder,
                size: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Gestión de Proyectos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontFamily: 'Lufga',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManagementScreen()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Gestionar Proyectos'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }

  /// Tarjeta de proyecto activo
  Widget _buildActiveProjectCard() {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final activeProjectId = settingsProvider.activeProjectId;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.business,
                size: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Proyecto Activo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontFamily: 'Lufga',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoadingProjects)
            const ModernLoadingSpinner(size: 24)
          else if (_projects.isEmpty)
            Text(
              'No hay proyectos disponibles',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontFamily: 'Lufga',
              ),
            )
          else
            DropdownButtonFormField<String>(
              initialValue: activeProjectId,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              hint: const Text('Seleccionar proyecto'),
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
            ),
        ],
      ),
    );
  }

  /// Tarjeta de configuración de tema
  Widget _buildThemeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.palette,
                size: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Tema de la Aplicación',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontFamily: 'Lufga',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildThemeSelector(),
        ],
      ),
    );
  }

  /// Selector de tema moderno
  Widget _buildThemeSelector() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;

    return Column(
      children: [
        // Opción Claro
        _buildThemeOption(
          title: 'Modo Claro',
          subtitle: 'Tema claro para uso diurno',
          icon: Icons.light_mode,
          isSelected: !isDark,
          onTap: () => themeProvider.setThemePreset(ThemePreset.light),
        ),

        const SizedBox(height: 8),

        // Opción Oscuro
        _buildThemeOption(
          title: 'Modo Oscuro',
          subtitle: 'Tema oscuro para uso nocturno',
          icon: Icons.dark_mode,
          isSelected: isDark,
          onTap: () => themeProvider.setThemePreset(ThemePreset.dark),
        ),

        const SizedBox(height: 8),

        // Opción Sistema
        _buildThemeOption(
          title: 'Sistema',
          subtitle: 'Sigue la configuración del sistema',
          icon: Icons.settings_system_daydream,
          isSelected: themeProvider.isDark == false && themeProvider.highContrast == false,
          onTap: () => themeProvider.setThemePreset(ThemePreset.light),
        ),
      ],
    );
  }

  /// Opción de tema individual
  Widget _buildThemeOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5)
            : Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
            fontFamily: 'Lufga',
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontFamily: 'Lufga',
          ),
        ),
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              )
            : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Tarjeta de configuración de idioma
  Widget _buildLanguageCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.language,
                size: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Idioma y Región',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontFamily: 'Lufga',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: Provider.of<SettingsProvider>(context).language,
                  decoration: InputDecoration(
                    labelText: 'Idioma',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'es', child: Text('Español')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'fr', child: Text('Français')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      Provider.of<SettingsProvider>(context, listen: false).setLanguage(value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: Provider.of<SettingsProvider>(context).region,
                  decoration: InputDecoration(
                    labelText: 'Región',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'ES', child: Text('España')),
                    DropdownMenuItem(value: 'US', child: Text('Estados Unidos')),
                    DropdownMenuItem(value: 'FR', child: Text('Francia')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      Provider.of<SettingsProvider>(context, listen: false).setRegion(value);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Configuración de notificaciones
  Widget _buildNotificationSettingsCard() {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildNotificationToggle(
            title: 'Notificaciones Push',
            subtitle: 'Recibir notificaciones en el dispositivo',
            value: settingsProvider.pushNotifications,
            onChanged: (value) => settingsProvider.setNotificationSettings(pushNotifications: value),
          ),
          const SizedBox(height: 16),
          _buildNotificationToggle(
            title: 'Notificaciones por Email',
            subtitle: 'Recibir notificaciones por correo electrónico',
            value: settingsProvider.emailNotifications,
            onChanged: (value) => settingsProvider.setNotificationSettings(emailNotifications: value),
          ),
          const SizedBox(height: 16),
          _buildNotificationToggle(
            title: 'Notificaciones por SMS',
            subtitle: 'Recibir notificaciones por mensaje de texto',
            value: settingsProvider.smsNotifications,
            onChanged: (value) => settingsProvider.setNotificationSettings(smsNotifications: value),
          ),
          const SizedBox(height: 16),
          _buildNotificationToggle(
            title: 'Sonido de Notificación',
            subtitle: 'Reproducir sonido al recibir notificaciones',
            value: settingsProvider.notificationSound,
            onChanged: (value) => settingsProvider.setNotificationSettings(notificationSound: value),
          ),
          const SizedBox(height: 16),
          _buildNotificationToggle(
            title: 'Vibración',
            subtitle: 'Vibrar al recibir notificaciones',
            value: settingsProvider.notificationVibration,
            onChanged: (value) => settingsProvider.setNotificationSettings(notificationVibration: value),
          ),
        ],
      ),
    );
  }

  /// Toggle de notificación moderno
  Widget _buildNotificationToggle({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontFamily: 'Lufga',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontFamily: 'Lufga',
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  /// Configuración de privacidad
  Widget _buildPrivacyCard() {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildPrivacyToggle(
            title: 'Analytics',
            subtitle: 'Ayudar a mejorar la aplicación con datos de uso',
            value: settingsProvider.analyticsEnabled,
            onChanged: (value) => settingsProvider.setPrivacySettings(analyticsEnabled: value),
          ),
          const SizedBox(height: 16),
          _buildPrivacyToggle(
            title: 'Reportes de Fallos',
            subtitle: 'Enviar reportes automáticos de errores',
            value: settingsProvider.crashReportingEnabled,
            onChanged: (value) => settingsProvider.setPrivacySettings(crashReportingEnabled: value),
          ),
          const SizedBox(height: 16),
          _buildPrivacyToggle(
            title: 'Compartir Datos',
            subtitle: 'Compartir datos con terceros para mejorar el servicio',
            value: settingsProvider.dataSharingEnabled,
            onChanged: (value) => settingsProvider.setPrivacySettings(dataSharingEnabled: value),
          ),
          const SizedBox(height: 16),
          _buildPrivacyToggle(
            title: 'Autenticación Biométrica',
            subtitle: 'Usar huella digital o reconocimiento facial',
            value: settingsProvider.biometricEnabled,
            onChanged: (value) => settingsProvider.setPrivacySettings(biometricEnabled: value),
          ),
        ],
      ),
    );
  }

  /// Toggle de privacidad moderno
  Widget _buildPrivacyToggle({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontFamily: 'Lufga',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontFamily: 'Lufga',
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  /// Configuración de seguridad
  Widget _buildSecurityCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildQuickActionTile(
            icon: Icons.password,
            title: 'Cambiar Contraseña',
            subtitle: 'Actualiza tu contraseña de acceso',
            onTap: () => _showChangePasswordDialog(),
          ),
          const Divider(),
          _buildQuickActionTile(
            icon: Icons.security,
            title: 'Autenticación de Dos Factores',
            subtitle: 'Configura 2FA para mayor seguridad',
            onTap: () => _showTwoFactorDialog(),
          ),
          const Divider(),
          _buildQuickActionTile(
            icon: Icons.devices,
            title: 'Sesiones Activas',
            subtitle: 'Gestiona los dispositivos conectados',
            onTap: () => _showActiveSessionsDialog(),
          ),
        ],
      ),
    );
  }

  /// Configuración avanzada
  Widget _buildAdvancedCard() {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildAdvancedToggle(
            title: 'Backup Automático',
            subtitle: 'Realizar copias de seguridad automáticamente',
            value: settingsProvider.autoBackup,
            onChanged: (value) => settingsProvider.setAdvancedSettings(autoBackup: value),
          ),
          const SizedBox(height: 16),
          _buildAdvancedToggle(
            title: 'Sincronización Automática',
            subtitle: 'Sincronizar datos automáticamente',
            value: settingsProvider.autoSync,
            onChanged: (value) => settingsProvider.setAdvancedSettings(autoSync: value),
          ),
          const SizedBox(height: 16),
          _buildAdvancedToggle(
            title: 'Modo de Ahorro de Datos',
            subtitle: 'Reducir el uso de datos móviles',
            value: settingsProvider.dataSaverMode,
            onChanged: (value) => settingsProvider.setAdvancedSettings(dataSaverMode: value),
          ),
          const SizedBox(height: 16),
          _buildAdvancedToggle(
            title: 'Modo de Accesibilidad',
            subtitle: 'Optimizar para usuarios con necesidades especiales',
            value: settingsProvider.accessibilityMode,
            onChanged: (value) => settingsProvider.setAdvancedSettings(accessibilityMode: value),
          ),
        ],
      ),
    );
  }

  /// Toggle avanzado moderno
  Widget _buildAdvancedToggle({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontFamily: 'Lufga',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontFamily: 'Lufga',
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  /// Tarjeta de soporte
  Widget _buildSupportCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildQuickActionTile(
            icon: Icons.help,
            title: 'Centro de Ayuda',
            subtitle: 'Documentación y guías de uso',
            onTap: () => _showHelpDialog(),
          ),
          const Divider(),
          _buildQuickActionTile(
            icon: Icons.contact_support,
            title: 'Contacto con Soporte',
            subtitle: 'Envía una consulta al equipo de soporte',
            onTap: () => _showSupportDialog(),
          ),
          const Divider(),
          _buildQuickActionTile(
            icon: Icons.info,
            title: 'Acerca de',
            subtitle: 'Información de la aplicación',
            onTap: () => _showAboutDialog(),
          ),
        ],
      ),
    );
  }

  /// Tile de acción rápida moderno
  Widget _buildQuickActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
          fontFamily: 'Lufga',
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontFamily: 'Lufga',
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  /// Botón de acción rápida en AppBar
  Widget _buildQuickActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      tooltip: 'Acción rápida',
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  /// Botón flotante de acciones rápidas
  Widget _buildQuickActions() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton.extended(
          onPressed: () => _showQuickActionsMenu(),
          icon: const Icon(Icons.add),
          label: const Text('Acciones'),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ],
    );
  }

  /// Logout tile moderno
  Widget _buildLogoutTile(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          Icons.logout,
          color: Theme.of(context).colorScheme.error,
        ),
        title: Text(
          'Cerrar Sesión',
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontWeight: FontWeight.w500,
            fontFamily: 'Lufga',
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Theme.of(context).colorScheme.error,
          size: 16,
        ),
        onTap: () async {
          await authProvider.logout();
          if (context.mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          }
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Métodos de interacción (placeholders para funcionalidades futuras)
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar Configuración'),
        content: const Text('Funcionalidad de búsqueda próximamente'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showExportImportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar/Importar'),
        content: const Text('Funcionalidad de exportación próximamente'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _refreshSettings() {
    _loadProjects();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuración actualizada')),
    );
  }

  void _handleMenuAction(String value) {
    switch (value) {
      case 'reset':
        _showResetDialog();
        break;
      case 'help':
        _showHelpDialog();
        break;
    }
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resetear Configuración'),
        content: const Text('¿Estás seguro de que quieres resetear toda la configuración a valores por defecto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<SettingsProvider>(context, listen: false).resetToDefaults();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configuración reseteada')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Resetear'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Contraseña'),
        content: const Text('Funcionalidad de cambio de contraseña próximamente'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup de Datos'),
        content: const Text('Funcionalidad de backup próximamente'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showTwoFactorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Autenticación de Dos Factores'),
        content: const Text('Funcionalidad de 2FA próximamente'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showActiveSessionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sesiones Activas'),
        content: const Text('Gestión de sesiones próximamente'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ayuda'),
        content: const Text('Centro de ayuda próximamente'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contacto con Soporte'),
        content: const Text('Sistema de soporte próximamente'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Acerca de'),
        content: const Text('Información de la aplicación próximamente'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showQuickActionsMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.backup),
              title: const Text('Crear Backup'),
              onTap: () {
                Navigator.of(context).pop();
                _showBackupDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('Sincronizar'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sincronización iniciada')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Compartir Configuración'),
              onTap: () {
                Navigator.of(context).pop();
                _showExportImportDialog();
              },
            ),
          ],
        ),
      ),
    );
  }
}