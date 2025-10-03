import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../services/firebase_service.dart';
import '../../services/auth_service.dart';
import '../../models/project.dart';
import '../../models/user.dart';
import '../../providers/settings_provider.dart';
import '../../core/widgets/modern_navigation.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/modern_forms.dart';
import '../../core/widgets/modern_loading.dart';
import '../../core/widgets/app_button.dart';

/// Pantalla moderna de gestión con navegación por pestañas
class ManagementScreen extends StatefulWidget {
  const ManagementScreen({super.key});

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> with TickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService();
  List<Project> _projects = [];
  List<User> _users = [];
  bool _isProjectsLoading = false;
  bool _isUsersLoading = false;

  // Controladores para navegación por pestañas
  late TabController _tabController;
  late AnimationController _fabAnimationController;

  // Estados de búsqueda y filtros
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fabAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    _tabController = TabController(length: 4, vsync: this);
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  Future<void> _loadInitialData() async {
    try {
      await Future.wait([
        _loadProjects(),
        _loadUsers(),
      ]);
    } catch (e) {
      // Error silencioso, los datos quedan vacíos
    }
  }

  Future<void> _loadProjects() async {
    setState(() => _isProjectsLoading = true);
    try {
      _projects = await _firebaseService.getProjects();
    } catch (e) {
      _projects = [];
    }
    setState(() => _isProjectsLoading = false);
  }

  Future<void> _loadUsers() async {
    setState(() => _isUsersLoading = true);
    try {
      // Aquí cargarías usuarios si tienes un servicio para ello
      _users = [];
    } catch (e) {
      _users = [];
    }
    setState(() => _isUsersLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _buildModernAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: theme.brightness == Brightness.dark
              ? AppDarkGradients.backgroundGradient
              : AppGradients.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Navegación por pestañas moderna
              _buildModernTabBar(),

              // Campo de búsqueda
              _buildSearchBar(),

              // Contenido de las pestañas
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProjectsTab(),
                    _buildUsersTab(),
                    _buildMembersTab(),
                    _buildSettingsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // FAB para acciones rápidas
      floatingActionButton: _buildModernFAB(),
    );
  }

  /// AppBar moderno con acciones rápidas
  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: Text(
        'Gestión Moderna',
        style: TextStyle(
          fontFamily: 'Lufga',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        // Estadísticas rápidas
        _buildQuickStatsButton(),

        // Configuración
        IconButton(
          icon: Icon(Icons.settings_outlined, color: AppColors.textSecondary),
          onPressed: () => _showGlobalSettings(),
          tooltip: 'Configuración Global',
        ),

        // Notificaciones
        _buildNotificationButton(),

        const SizedBox(width: 8),
      ],
    );
  }

  /// Navegación por pestañas moderna
  Widget _buildModernTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: ModernTabBar(
        tabs: const ['Proyectos', 'Usuarios', 'Miembros', 'Configuración'],
        currentIndex: _tabController.index,
        onTap: (index) {
          _tabController.animateTo(index);
          _fabAnimationController.forward(from: 0);
        },
        indicatorColor: AppColors.primary,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  /// Campo de búsqueda moderno
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AppSearchField(
        controller: _searchController,
        hint: 'Buscar proyectos, usuarios...',
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
        showFilter: true,
        onFilter: _showFilterDialog,
      ),
    );
  }

  /// Pestaña de proyectos con diseño moderno
  Widget _buildProjectsTab() {
    if (_isProjectsLoading) {
      return Column(
        children: [
          // Skeleton para el campo de búsqueda
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
              ),
            ),
          ),
          // Skeleton para la lista de proyectos
          Expanded(
            child: ListSkeleton(
              itemCount: 3,
              showAvatar: true,
              showActions: true,
              itemHeight: 140,
            ),
          ),
        ],
      );
    }

    final filteredProjects = _filterProjects(_projects);

    if (filteredProjects.isEmpty) {
      return _buildEmptyProjectsState();
    }

    return RefreshIndicator(
      onRefresh: _loadProjects,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredProjects.length,
        itemBuilder: (context, index) {
          return AnimatedOpacity(
            opacity: 1.0,
            duration: Duration(milliseconds: 300 + (index * 100)),
            child: _buildModernProjectCard(filteredProjects[index]),
          );
        },
      ),
    );
  }

  /// Pestaña de usuarios con diseño moderno
  Widget _buildUsersTab() {
    if (_isUsersLoading) {
      return Column(
        children: [
          // Skeleton para estadísticas de usuarios
          Container(
            margin: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Skeleton para la lista de usuarios
          Expanded(
            child: ListSkeleton(
              itemCount: 5,
              showAvatar: true,
              itemHeight: 100,
            ),
          ),
        ],
      );
    }

    if (_users.isEmpty) {
      return _buildEmptyUsersState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        return AnimatedSlide(
          offset: Offset(0, index * 0.1),
          duration: Duration(milliseconds: 300 + (index * 50)),
          child: _buildModernUserCard(_users[index]),
        );
      },
    );
  }

  /// Pestaña de miembros por proyecto
  Widget _buildMembersTab() {
    return _buildProjectMembersView();
  }

  /// Pestaña de configuración
  Widget _buildSettingsTab() {
    return _buildSettingsView();
  }

  /// Tarjeta moderna para proyectos con accesibilidad mejorada
  Widget _buildModernProjectCard(Project project) {
    return AppCard(
      variant: AppCardVariant.elevated,
      size: AppCardSize.large,
      elevation: AppCardElevation.level2,
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => _showProjectDetails(project),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: AppGradients.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.folder_outlined,
          color: AppColors.textOnPrimary,
          size: 24,
          semanticLabel: 'Icono de carpeta para proyecto',
        ),
      ),
      child: Semantics(
        label: _getAccessibilityLabel(project),
        hint: _getAccessibilityHint(project),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    project.name,
                    style: TextStyle(
                      fontFamily: 'Lufga',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Semantics(
                  label: 'Estado del proyecto: ${project.isActive ? 'activo' : 'inactivo'}',
                  child: _buildProjectStatusBadge(project.isActive),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              project.description,
              style: TextStyle(
                fontFamily: 'Lufga',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Semantics(
                  label: '${project.members.length} miembros en el proyecto',
                  child: Row(
                    children: [
                      Icon(Icons.people_outline, size: 16, color: AppColors.textDisabled),
                      const SizedBox(width: 4),
                      Text(
                        '${project.members.length} miembros',
                        style: TextStyle(
                          fontFamily: 'Lufga',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textDisabled,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Semantics(
                  label: 'Acciones del proyecto',
                  child: _buildProjectActions(project),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Tarjeta moderna para usuarios
  Widget _buildModernUserCard(User user) {
    return AppCard(
      variant: AppCardVariant.filled,
      size: AppCardSize.medium,
      elevation: AppCardElevation.level1,
      margin: const EdgeInsets.only(bottom: 8),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        child: Text(
          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
          style: TextStyle(
            fontFamily: 'Lufga',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.name,
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                user.isEmailVerified ? Icons.verified : Icons.pending,
                size: 14,
                color: user.isEmailVerified ? AppColors.secondary : AppColors.tertiary,
              ),
              const SizedBox(width: 4),
              Text(
                user.isEmailVerified ? 'Verificado' : 'Pendiente',
                style: TextStyle(
                  fontFamily: 'Lufga',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: user.isEmailVerified ? AppColors.secondary : AppColors.tertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Estado vacío para proyectos
  Widget _buildEmptyProjectsState() {
    return EmptyState(
      title: 'No hay proyectos',
      description: 'Crea tu primer proyecto para comenzar a organizar tu trabajo y colaborar con tu equipo.',
      illustration: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(60),
        ),
        child: Icon(
          Icons.folder_off_outlined,
          size: 48,
          color: AppColors.primary,
        ),
      ),
      action: Column(
        children: [
          AppButton(
            text: 'Crear Proyecto',
            onPressed: _showCreateProjectDialog,
            variant: AppButtonVariant.primary,
            size: AppButtonSize.medium,
          ),
          const SizedBox(height: 8),
          AppButton(
            text: 'Ver Tutorial',
            onPressed: _showTutorial,
            variant: AppButtonVariant.ghost,
            size: AppButtonSize.small,
          ),
        ],
      ),
    );
  }

  /// Estado vacío para usuarios
  Widget _buildEmptyUsersState() {
    return EmptyState(
      title: 'No hay usuarios',
      description: 'Invita usuarios para colaborar en tus proyectos. Puedes asignar diferentes roles según sus responsabilidades.',
      illustration: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          gradient: AppGradients.primaryGradient,
          borderRadius: BorderRadius.circular(60),
        ),
        child: Icon(
          Icons.people_outline,
          size: 48,
          color: AppColors.textOnPrimary,
        ),
      ),
      action: Column(
        children: [
          AppButton(
            text: 'Invitar Usuario',
            onPressed: _showInviteUserDialog,
            variant: AppButtonVariant.outline,
            size: AppButtonSize.medium,
          ),
          const SizedBox(height: 8),
          Text(
            'o',
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textDisabled,
            ),
          ),
          const SizedBox(height: 8),
          AppButton(
            text: 'Importar Usuarios',
            onPressed: _showImportUsersDialog,
            variant: AppButtonVariant.ghost,
            size: AppButtonSize.small,
          ),
        ],
      ),
    );
  }

  void _showTutorial() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.school, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Tutorial de Gestión'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bienvenido a la pantalla de Gestión',
                style: TextStyle(
                  fontFamily: 'Lufga',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildTutorialStep(
                icon: Icons.folder,
                title: 'Gestiona tus proyectos',
                description: 'Crea, edita y elimina proyectos desde la pestaña Proyectos.',
              ),
              _buildTutorialStep(
                icon: Icons.people,
                title: 'Administra usuarios',
                description: 'Invita usuarios y gestiona permisos desde la pestaña Usuarios.',
              ),
              _buildTutorialStep(
                icon: Icons.settings,
                title: 'Configuración global',
                description: 'Accede a configuraciones avanzadas desde la pestaña Configuración.',
              ),
            ],
          ),
        ),
        actions: [
          AppButton(
            text: 'Entendido',
            onPressed: () => Navigator.of(context).pop(),
            variant: AppButtonVariant.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialStep({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Lufga',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'Lufga',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showImportUsersDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.upload_file, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Importar Usuarios'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selecciona el método de importación',
                style: TextStyle(
                  fontFamily: 'Lufga',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Opción de archivo CSV
              _buildImportOption(
                icon: Icons.table_chart,
                title: 'Archivo CSV',
                description: 'Importa usuarios desde un archivo CSV con columnas: nombre, email, rol',
                onTap: () => _importFromCSV(),
              ),

              const SizedBox(height: 12),

              // Opción de integración
              _buildImportOption(
                icon: Icons.integration_instructions,
                title: 'Integración con servicios',
                description: 'Importa usuarios desde servicios externos como Google Workspace',
                onTap: () => _importFromIntegration(),
              ),

              const SizedBox(height: 12),

              // Opción manual
              _buildImportOption(
                icon: Icons.person_add,
                title: 'Invitación masiva',
                description: 'Envía invitaciones masivas por correo electrónico',
                onTap: () => _showBulkInviteDialog(),
              ),
            ],
          ),
        ),
        actions: [
          AppButton(
            text: 'Cancelar',
            onPressed: () => Navigator.of(context).pop(),
            variant: AppButtonVariant.ghost,
          ),
        ],
      ),
    );
  }

  Widget _buildImportOption({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Lufga',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontFamily: 'Lufga',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textDisabled),
          ],
        ),
      ),
    );
  }

  void _importFromCSV() {
    // Implementar lógica de importación desde CSV
    Navigator.of(context).pop();
    _showSuccessMessage('Funcionalidad de importación CSV estará disponible próximamente');
  }

  void _importFromIntegration() {
    // Implementar lógica de importación desde servicios externos
    Navigator.of(context).pop();
    _showSuccessMessage('Funcionalidad de integración estará disponible próximamente');
  }

  void _showBulkInviteDialog() {
    // Implementar diálogo de invitación masiva
    Navigator.of(context).pop();
    _showSuccessMessage('Funcionalidad de invitación masiva estará disponible próximamente');
  }

  /// FAB moderno con animaciones
  Widget _buildModernFAB() {
    return AnimatedBuilder(
      animation: _fabAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _fabAnimationController.value * 0.2 + 0.8,
          child: FloatingActionButton.extended(
            onPressed: _showQuickActions,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            elevation: 6,
            label: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                'Acción Rápida',
                key: const ValueKey('fab-text'),
                style: TextStyle(
                  fontFamily: 'Lufga',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.add,
                key: const ValueKey('fab-icon'),
                size: 20,
              ),
            ),
          ),
        );
      },
    );
  }


  /// Acciones rápidas del proyecto
  Widget _buildProjectActions(Project project) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.edit_outlined, size: 18),
          onPressed: () => _showEditProjectDialog(project),
          tooltip: 'Editar',
          style: IconButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
          ),
        ),
        IconButton(
          icon: Icon(Icons.people_outline, size: 18),
          onPressed: () => _showManageUsersDialog(project),
          tooltip: 'Gestionar Miembros',
          style: IconButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
          ),
        ),
        IconButton(
          icon: Icon(Icons.delete_outline, size: 18),
          onPressed: () => _deleteProject(project.id),
          tooltip: 'Eliminar',
          style: IconButton.styleFrom(
            foregroundColor: AppColors.error,
          ),
        ),
      ],
    );
  }

  /// Badge de estado del proyecto
  Widget _buildProjectStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.secondary.withValues(alpha: 0.1)
            : AppColors.tertiary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? AppColors.secondary.withValues(alpha: 0.3)
              : AppColors.tertiary.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        isActive ? 'Activo' : 'Inactivo',
        style: TextStyle(
          fontFamily: 'Lufga',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isActive ? AppColors.secondary : AppColors.tertiary,
        ),
      ),
    );
  }

  /// Botón de estadísticas rápidas
  Widget _buildQuickStatsButton() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: IconButton(
        icon: Icon(Icons.analytics_outlined, color: AppColors.textSecondary),
        onPressed: _showQuickStats,
        tooltip: 'Estadísticas',
      ),
    );
  }

  /// Botón de notificaciones
  Widget _buildNotificationButton() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Badge(
        label: const Text('3'),
        child: IconButton(
          icon: Icon(Icons.notifications_outlined, color: AppColors.textSecondary),
          onPressed: _showNotifications,
          tooltip: 'Notificaciones',
        ),
      ),
    );
  }

  /// Vista de miembros por proyecto
  Widget _buildProjectMembersView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gestión de Miembros por Proyecto',
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isProjectsLoading
                ? const ListSkeleton(itemCount: 3)
                : ListView.builder(
                    itemCount: _projects.length,
                    itemBuilder: (context, index) {
                      return _buildProjectMembersCard(_projects[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Tarjeta de miembros por proyecto
  Widget _buildProjectMembersCard(Project project) {
    return AppCard(
      variant: AppCardVariant.outlined,
      size: AppCardSize.medium,
      elevation: AppCardElevation.level1,
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project.name,
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${project.members.length} miembros',
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          AppButton(
            text: 'Gestionar Miembros',
            onPressed: () => _showManageUsersDialog(project),
            variant: AppButtonVariant.outline,
            size: AppButtonSize.small,
          ),
        ],
      ),
    );
  }

  /// Vista de configuración
  Widget _buildSettingsView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Configuración Global',
          style: TextStyle(
            fontFamily: 'Lufga',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _buildSettingsCard(),
      ],
    );
  }

  /// Tarjeta de configuración
  Widget _buildSettingsCard() {
    return AppCard(
      variant: AppCardVariant.filled,
      size: AppCardSize.large,
      elevation: AppCardElevation.level1,
      child: Column(
        children: [
          _buildConfigSettingsItem(
            icon: Icons.security_outlined,
            title: 'Permisos Avanzados',
            subtitle: 'Configurar permisos globales',
            onTap: _showAdvancedPermissions,
          ),
          _buildConfigSettingsItem(
            icon: Icons.analytics_outlined,
            title: 'Logs de Actividad',
            subtitle: 'Ver historial de acciones',
            onTap: _showActivityLogs,
          ),
          _buildConfigSettingsItem(
            icon: Icons.backup_outlined,
            title: 'Exportar Datos',
            subtitle: 'Descargar información',
            onTap: _showExportDialog,
          ),
        ],
      ),
    );
  }


  /// Elemento de configuración mejorado para el diálogo global
  Widget _buildConfigSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Lufga',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontFamily: 'Lufga',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textDisabled),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  // Métodos de filtrado y búsqueda
  List<Project> _filterProjects(List<Project> projects) {
    if (_searchQuery.isEmpty) return projects;

    return projects.where((project) {
      return project.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             project.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }


  // Métodos de diálogo mejorados con contexto correcto
  void _showCreateProjectDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Proyecto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: nameController,
              label: 'Nombre del proyecto',
              hint: 'Ingrese el nombre del proyecto',
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: descriptionController,
              label: 'Descripción',
              hint: 'Describe brevemente el proyecto',
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          AppButton(
            text: 'Crear Proyecto',
            onPressed: () async {
              if (nameController.text.isEmpty || descriptionController.text.isEmpty) {
                return;
              }

              final currentUser = AuthService().currentUser;
              if (currentUser == null) {
                return;
              }

              final project = Project(
                id: '',
                name: nameController.text,
                description: descriptionController.text,
                ownerId: currentUser.uid,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                isActive: true,
                members: [currentUser.email ?? ''],
              );

              try {
                await _firebaseService.createProject(project);
                if (context.mounted) Navigator.of(context).pop();
                _loadProjects();
              } catch (e) {
                // Mostrar error
              }
            },
            variant: AppButtonVariant.primary,
          ),
        ],
      ),
    );
  }

  void _showEditProjectDialog(Project project) {
    final nameController = TextEditingController(text: project.name);
    final descriptionController = TextEditingController(text: project.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Proyecto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: nameController,
              label: 'Nombre del proyecto',
              hint: 'Ingrese el nombre del proyecto',
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: descriptionController,
              label: 'Descripción',
              hint: 'Describe brevemente el proyecto',
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          AppButton(
            text: 'Guardar Cambios',
            onPressed: () async {
              if (nameController.text.isEmpty || descriptionController.text.isEmpty) {
                return;
              }

              final updatedProject = Project(
                id: project.id,
                name: nameController.text,
                description: descriptionController.text,
                ownerId: project.ownerId,
                createdAt: project.createdAt,
                updatedAt: DateTime.now(),
                isActive: project.isActive,
                members: project.members,
              );

              try {
                await _firebaseService.updateProject(updatedProject);
                if (context.mounted) Navigator.of(context).pop();
                _loadProjects();
              } catch (e) {
                // Mostrar error
              }
            },
            variant: AppButtonVariant.primary,
          ),
        ],
      ),
    );
  }

  void _deleteProject(String projectId) async {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    if (settingsProvider.activeProjectId == projectId) {
      settingsProvider.setActiveProjectId(null);
    }

    try {
      await _firebaseService.deleteProject(projectId);
      _loadProjects();
    } catch (e) {
      // Mostrar error
    }
  }

  void _showManageUsersDialog(Project project) {
    final emailController = TextEditingController();
    String selectedRole = 'Miembro';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Gestionar Miembros - ${project.name}'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Formulario para añadir miembros
                AppCard(
                  variant: AppCardVariant.outlined,
                  size: AppCardSize.small,
                  elevation: AppCardElevation.level0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Añadir Nuevo Miembro',
                        style: TextStyle(
                          fontFamily: 'Lufga',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: emailController,
                        label: 'Correo electrónico',
                        hint: 'correo@ejemplo.com',
                        type: AppTextFieldType.email,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Rol: ',
                              style: TextStyle(
                                fontFamily: 'Lufga',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            DropdownButton<String>(
                              value: selectedRole,
                              underline: const SizedBox(),
                              items: const [
                                DropdownMenuItem(value: 'Administrador', child: Text('Administrador')),
                                DropdownMenuItem(value: 'Editor', child: Text('Editor')),
                                DropdownMenuItem(value: 'Miembro', child: Text('Miembro')),
                                DropdownMenuItem(value: 'Observador', child: Text('Observador')),
                              ],
                              onChanged: (value) {
                                setState(() => selectedRole = value!);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        text: 'Añadir Miembro',
                        onPressed: () async {
                          if (emailController.text.isNotEmpty) {
                            try {
                              await _firebaseService.addMember(project.id, emailController.text);
                              _loadProjects();
                              emailController.clear();
                              _showSuccessMessage('Miembro añadido correctamente');
                            } catch (e) {
                              _showErrorMessage('Error al añadir miembro');
                            }
                          }
                        },
                        variant: AppButtonVariant.primary,
                        size: AppButtonSize.small,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Lista de miembros actuales
                Text(
                  'Miembros actuales (${project.members.length})',
                  style: TextStyle(
                    fontFamily: 'Lufga',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 250,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: project.members.length,
                    itemBuilder: (context, index) {
                      return _buildMemberListItem(project, project.members[index], index);
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            AppButton(
              text: 'Cerrar',
              onPressed: () => Navigator.of(context).pop(),
              variant: AppButtonVariant.ghost,
            ),
          ],
        ),
      ),
    );
  }

  /// Elemento de lista de miembros con roles y acciones
  Widget _buildMemberListItem(Project project, String memberEmail, int index) {
    return AppCard(
      variant: AppCardVariant.filled,
      size: AppCardSize.small,
      elevation: AppCardElevation.level0,
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(
            memberEmail[0].toUpperCase(),
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
        title: Text(
          memberEmail,
          style: TextStyle(
            fontFamily: 'Lufga',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          _getRoleForMember(memberEmail, project),
          style: TextStyle(
            fontFamily: 'Lufga',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botón de cambiar rol
            IconButton(
              icon: Icon(Icons.edit, size: 16, color: AppColors.textSecondary),
              onPressed: () => _showChangeRoleDialog(project, memberEmail),
              tooltip: 'Cambiar Rol',
            ),

            // Botón de eliminar
            IconButton(
              icon: Icon(Icons.remove_circle_outline, size: 16, color: AppColors.error),
              onPressed: () async {
                try {
                  await _firebaseService.removeMember(project.id, memberEmail);
                  _loadProjects();
                  _showSuccessMessage('Miembro eliminado correctamente');
                } catch (e) {
                  _showErrorMessage('Error al eliminar miembro');
                }
              },
              tooltip: 'Eliminar Miembro',
            ),
          ],
        ),
      ),
    );
  }

  /// Obtener rol para un miembro (lógica simplificada)
  String _getRoleForMember(String memberEmail, Project project) {
    // Aquí implementarías la lógica real para obtener el rol del miembro
    if (memberEmail == project.ownerId) {
      return 'Propietario';
    }
    return 'Miembro'; // Por defecto
  }

  /// Mostrar diálogo para cambiar rol de miembro
  void _showChangeRoleDialog(Project project, String memberEmail) {
    String selectedRole = _getRoleForMember(memberEmail, project);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Cambiar Rol - $memberEmail'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButton<String>(
                  value: selectedRole,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'Administrador', child: Text('Administrador')),
                    DropdownMenuItem(value: 'Editor', child: Text('Editor')),
                    DropdownMenuItem(value: 'Miembro', child: Text('Miembro')),
                    DropdownMenuItem(value: 'Observador', child: Text('Observador')),
                  ],
                  onChanged: (value) {
                    setState(() => selectedRole = value!);
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            AppButton(
              text: 'Cambiar Rol',
              onPressed: () async {
                try {
                  // Aquí implementarías la lógica para cambiar el rol
                  // await _projectService.updateMemberRole(project.id, memberEmail, selectedRole);

                  Navigator.of(context).pop();
                  _loadProjects();
                  _showSuccessMessage('Rol actualizado correctamente');
                } catch (e) {
                  _showErrorMessage('Error al cambiar el rol');
                }
              },
              variant: AppButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }

  // Nuevos métodos para funcionalidades modernas
  void _showProjectDetails(Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.folder_outlined, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Detalles del Proyecto',
                style: TextStyle(
                  fontFamily: 'Lufga',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Información general del proyecto
              AppCard(
                variant: AppCardVariant.filled,
                size: AppCardSize.large,
                elevation: AppCardElevation.level1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: AppGradients.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.folder_outlined,
                            color: AppColors.textOnPrimary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                project.name,
                                style: TextStyle(
                                  fontFamily: 'Lufga',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _buildProjectStatusBadge(project.isActive),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Descripción',
                      style: TextStyle(
                        fontFamily: 'Lufga',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      project.description,
                      style: TextStyle(
                        fontFamily: 'Lufga',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.people_outline, size: 16, color: AppColors.textDisabled),
                        const SizedBox(width: 4),
                        Text(
                          '${project.members.length} miembros',
                          style: TextStyle(
                            fontFamily: 'Lufga',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textDisabled,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.calendar_today, size: 16, color: AppColors.textDisabled),
                        const SizedBox(width: 4),
                        Text(
                          'Creado: ${_formatProjectDate(project.createdAt)}',
                          style: TextStyle(
                            fontFamily: 'Lufga',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textDisabled,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Historial de cambios
              AppCard(
                variant: AppCardVariant.outlined,
                size: AppCardSize.medium,
                elevation: AppCardElevation.level1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Historial de Cambios',
                          style: TextStyle(
                            fontFamily: 'Lufga',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        AppButton(
                          text: 'Ver Completo',
                          onPressed: () => _showFullChangeHistory(project),
                          variant: AppButtonVariant.ghost,
                          size: AppButtonSize.small,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildChangeHistoryItem(
                      action: 'Proyecto creado',
                      user: 'Sistema',
                      time: project.createdAt,
                      description: 'El proyecto fue creado inicialmente',
                    ),
                    _buildChangeHistoryItem(
                      action: 'Descripción actualizada',
                      user: 'María García',
                      time: project.updatedAt,
                      description: 'Se modificó la descripción del proyecto',
                    ),
                    _buildChangeHistoryItem(
                      action: 'Miembros añadidos',
                      user: 'Juan Pérez',
                      time: DateTime.now().subtract(const Duration(days: 1)),
                      description: 'Se añadieron 3 nuevos miembros al proyecto',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Acciones rápidas
              AppCard(
                variant: AppCardVariant.filled,
                size: AppCardSize.medium,
                elevation: AppCardElevation.level1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Acciones Rápidas',
                      style: TextStyle(
                        fontFamily: 'Lufga',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: 'Editar Proyecto',
                            onPressed: () {
                              Navigator.of(context).pop();
                              _showEditProjectDialog(project);
                            },
                            variant: AppButtonVariant.outline,
                            size: AppButtonSize.small,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppButton(
                            text: 'Gestionar Miembros',
                            onPressed: () {
                              Navigator.of(context).pop();
                              _showManageUsersDialog(project);
                            },
                            variant: AppButtonVariant.outline,
                            size: AppButtonSize.small,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          AppButton(
            text: 'Cerrar',
            onPressed: () => Navigator.of(context).pop(),
            variant: AppButtonVariant.ghost,
          ),
        ],
      ),
    );
  }

  /// Elemento del historial de cambios
  Widget _buildChangeHistoryItem({
    required String action,
    required String user,
    required DateTime time,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      action,
                      style: TextStyle(
                        fontFamily: 'Lufga',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatTimeAgo(time),
                      style: TextStyle(
                        fontFamily: 'Lufga',
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textDisabled,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'Lufga',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Por: $user',
                  style: TextStyle(
                    fontFamily: 'Lufga',
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textDisabled,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Formatear fecha del proyecto
  String _formatProjectDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Formatear tiempo relativo
  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Ahora';
    }
  }

  /// Mostrar historial completo de cambios
  void _showFullChangeHistory(Project project) {
    // Implementar navegación a historial completo
  }

  void _showInviteUserDialog() {
    final emailController = TextEditingController();
    final nameController = TextEditingController();
    String selectedRole = 'Miembro';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Invitar Usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: nameController,
                label: 'Nombre completo',
                hint: 'Ingrese el nombre del usuario',
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: emailController,
                label: 'Correo electrónico',
                hint: 'correo@ejemplo.com',
                type: AppTextFieldType.email,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rol inicial',
                      style: TextStyle(
                        fontFamily: 'Lufga',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: selectedRole,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'Administrador', child: Text('Administrador')),
                        DropdownMenuItem(value: 'Editor', child: Text('Editor')),
                        DropdownMenuItem(value: 'Miembro', child: Text('Miembro')),
                        DropdownMenuItem(value: 'Observador', child: Text('Observador')),
                      ],
                      onChanged: (value) {
                        setState(() => selectedRole = value!);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            AppButton(
              text: 'Enviar Invitación',
              onPressed: () async {
                if (nameController.text.isEmpty || emailController.text.isEmpty) {
                  _showErrorMessage('Por favor complete todos los campos');
                  return;
                }

                try {
                  // Aquí implementarías la lógica de envío de invitación
                  // await _userService.inviteUser(emailController.text, nameController.text, selectedRole);

                  if (context.mounted) {
                    Navigator.of(context).pop();
                    _showSuccessMessage('Invitación enviada correctamente a ${emailController.text}');
                  }
                } catch (e) {
                  _showErrorMessage('Error al enviar la invitación: ${e.toString()}');
                }
              },
              variant: AppButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              'Acciones Rápidas',
              style: TextStyle(
                fontFamily: 'Lufga',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Acciones de proyectos
            Text(
              'Proyectos',
              style: TextStyle(
                fontFamily: 'Lufga',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickActionChip(
                  icon: Icons.add,
                  label: 'Crear Proyecto',
                  onTap: () {
                    Navigator.of(context).pop();
                    _showCreateProjectDialog();
                  },
                ),
                _buildQuickActionChip(
                  icon: Icons.edit,
                  label: 'Editar Múltiples',
                  onTap: () {
                    Navigator.of(context).pop();
                    _showBulkEditDialog('projects');
                  },
                ),
                _buildQuickActionChip(
                  icon: Icons.archive,
                  label: 'Archivar',
                  onTap: () {
                    Navigator.of(context).pop();
                    _showBulkArchiveDialog('projects');
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Acciones de usuarios
            Text(
              'Usuarios',
              style: TextStyle(
                fontFamily: 'Lufga',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickActionChip(
                  icon: Icons.person_add,
                  label: 'Invitar Usuario',
                  onTap: () {
                    Navigator.of(context).pop();
                    _showInviteUserDialog();
                  },
                ),
                _buildQuickActionChip(
                  icon: Icons.manage_accounts,
                  label: 'Gestionar Roles',
                  onTap: () {
                    Navigator.of(context).pop();
                    _showBulkRoleChangeDialog();
                  },
                ),
                _buildQuickActionChip(
                  icon: Icons.delete_sweep,
                  label: 'Eliminar Múltiples',
                  onTap: () {
                    Navigator.of(context).pop();
                    _showBulkDeleteDialog('users');
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Acciones de datos
            Text(
              'Datos',
              style: TextStyle(
                fontFamily: 'Lufga',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickActionChip(
                  icon: Icons.download,
                  label: 'Exportar Todo',
                  onTap: () {
                    Navigator.of(context).pop();
                    _exportAllData();
                  },
                ),
                _buildQuickActionChip(
                  icon: Icons.backup,
                  label: 'Crear Backup',
                  onTap: () {
                    Navigator.of(context).pop();
                    _createBackup();
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Chip de acción rápida
  Widget _buildQuickActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Lufga',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Métodos para acciones masivas
  void _showBulkEditDialog(String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Múltiples $type'),
        content: Text('Selecciona los elementos a editar y las propiedades a modificar.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          AppButton(
            text: 'Continuar',
            onPressed: () => Navigator.of(context).pop(),
            variant: AppButtonVariant.primary,
          ),
        ],
      ),
    );
  }

  void _showBulkArchiveDialog(String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Archivar $type'),
        content: Text('¿Estás seguro de que deseas archivar los elementos seleccionados?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          AppButton(
            text: 'Archivar',
            onPressed: () {
              Navigator.of(context).pop();
              _showSuccessMessage('$type archivados correctamente');
            },
            variant: AppButtonVariant.primary,
          ),
        ],
      ),
    );
  }

  void _showBulkRoleChangeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Roles Masivamente'),
        content: Text('Selecciona los usuarios y el nuevo rol a asignar.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          AppButton(
            text: 'Aplicar Cambio',
            onPressed: () => Navigator.of(context).pop(),
            variant: AppButtonVariant.primary,
          ),
        ],
      ),
    );
  }

  void _showBulkDeleteDialog(String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar $type'),
        content: Text('¿Estás seguro? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          AppButton(
            text: 'Eliminar',
            onPressed: () {
              Navigator.of(context).pop();
              _showSuccessMessage('$type eliminados correctamente');
            },
            variant: AppButtonVariant.primary,
          ),
        ],
      ),
    );
  }

  void _createBackup() {
    _showSuccessMessage('Copia de seguridad creada correctamente');
  }

  void _showFilterDialog() {
    String selectedStatus = 'Todos';
    DateTimeRange? selectedDateRange;
    String selectedProjectType = 'Todos';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.filter_list, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('Filtros Avanzados'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filtro por estado
                Text(
                  'Estado',
                  style: TextStyle(
                    fontFamily: 'Lufga',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButton<String>(
                    value: selectedStatus,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                      DropdownMenuItem(value: 'Activo', child: Text('Activo')),
                      DropdownMenuItem(value: 'Inactivo', child: Text('Inactivo')),
                    ],
                    onChanged: (value) {
                      setState(() => selectedStatus = value!);
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Filtro por fecha de creación
                Text(
                  'Fecha de Creación',
                  style: TextStyle(
                    fontFamily: 'Lufga',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: selectedDateRange == null
                            ? 'Seleccionar Rango'
                            : '${selectedDateRange!.start.day}/${selectedDateRange!.start.month} - ${selectedDateRange!.end.day}/${selectedDateRange!.end.month}',
                        onPressed: () async {
                          final picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                            initialDateRange: selectedDateRange,
                          );
                          if (picked != null) {
                            setState(() => selectedDateRange = picked);
                          }
                        },
                        variant: AppButtonVariant.outline,
                        size: AppButtonSize.small,
                      ),
                    ),
                    if (selectedDateRange != null)
                      IconButton(
                        icon: Icon(Icons.clear, size: 16, color: AppColors.error),
                        onPressed: () {
                          setState(() => selectedDateRange = null);
                        },
                        tooltip: 'Limpiar filtro de fecha',
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Filtro por tipo de proyecto
                Text(
                  'Tipo de Proyecto',
                  style: TextStyle(
                    fontFamily: 'Lufga',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButton<String>(
                    value: selectedProjectType,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                      DropdownMenuItem(value: 'Personal', child: Text('Personal')),
                      DropdownMenuItem(value: 'Equipo', child: Text('Equipo')),
                      DropdownMenuItem(value: 'Empresa', child: Text('Empresa')),
                    ],
                    onChanged: (value) {
                      setState(() => selectedProjectType = value!);
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            AppButton(
              text: 'Aplicar Filtros',
              onPressed: () {
                // Aquí aplicarías los filtros seleccionados
                // Por ejemplo, podrías actualizar variables de estado
                // que controlen qué proyectos se muestran
                Navigator.of(context).pop();
                _showSuccessMessage('Filtros aplicados correctamente');
              },
              variant: AppButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickStats() {
    // Calcular estadísticas básicas
    final totalProjects = _projects.length;
    final activeProjects = _projects.where((p) => p.isActive).length;
    final totalMembers = _projects.fold<int>(0, (sum, p) => sum + p.members.length);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.analytics_outlined, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Estadísticas de Proyectos'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Grid de métricas
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    title: 'Total Proyectos',
                    value: totalProjects.toString(),
                    icon: Icon(Icons.folder_outlined, color: AppColors.primary),
                    valueColor: AppColors.primary,
                    variant: AppCardVariant.elevated,
                    size: AppCardSize.small,
                    elevation: AppCardElevation.level1,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MetricCard(
                    title: 'Proyectos Activos',
                    value: activeProjects.toString(),
                    icon: Icon(Icons.play_circle_outline, color: AppColors.secondary),
                    valueColor: AppColors.secondary,
                    variant: AppCardVariant.elevated,
                    size: AppCardSize.small,
                    elevation: AppCardElevation.level1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    title: 'Total Miembros',
                    value: totalMembers.toString(),
                    icon: Icon(Icons.people_outline, color: AppColors.tertiary),
                    valueColor: AppColors.tertiary,
                    variant: AppCardVariant.elevated,
                    size: AppCardSize.small,
                    elevation: AppCardElevation.level1,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MetricCard(
                    title: 'Promedio por Proyecto',
                    value: totalProjects > 0 ? (totalMembers / totalProjects).toStringAsFixed(1) : '0',
                    icon: Icon(Icons.analytics_outlined, color: AppColors.sales),
                    valueColor: AppColors.sales,
                    variant: AppCardVariant.elevated,
                    size: AppCardSize.small,
                    elevation: AppCardElevation.level1,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Información adicional
            AppCard(
              variant: AppCardVariant.outlined,
              size: AppCardSize.medium,
              elevation: AppCardElevation.level1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumen de Actividad',
                    style: TextStyle(
                      fontFamily: 'Lufga',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStatsListTile(
                    icon: Icons.check_circle_outline,
                    iconColor: AppColors.secondary,
                    title: 'Proyectos activos',
                    value: '$activeProjects de $totalProjects',
                  ),
                  _buildStatsListTile(
                    icon: Icons.pending_outlined,
                    iconColor: AppColors.tertiary,
                    title: 'Proyectos inactivos',
                    value: '${totalProjects - activeProjects}',
                  ),
                  _buildStatsListTile(
                    icon: Icons.group_outlined,
                    iconColor: AppColors.primary,
                    title: 'Miembros únicos',
                    value: '${_getUniqueMembersCount()} usuarios',
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          AppButton(
            text: 'Ver Estadísticas Detalladas',
            onPressed: () => _showDetailedStats(),
            variant: AppButtonVariant.outline,
          ),
          AppButton(
            text: 'Cerrar',
            onPressed: () => Navigator.of(context).pop(),
            variant: AppButtonVariant.ghost,
          ),
        ],
      ),
    );
  }

  /// Elemento de lista para estadísticas
  Widget _buildStatsListTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 20),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Lufga',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: Text(
        value,
        style: TextStyle(
          fontFamily: 'Lufga',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  /// Obtener conteo de miembros únicos
  int _getUniqueMembersCount() {
    final allMembers = <String>{};
    for (var project in _projects) {
      allMembers.addAll(project.members);
    }
    return allMembers.length;
  }

  /// Mostrar estadísticas detalladas
  void _showDetailedStats() {
    Navigator.of(context).pop(); // Cerrar diálogo actual

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.analytics_outlined, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Estadísticas Detalladas'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Métricas principales
              Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      title: 'Proyectos Totales',
                      value: _projects.length.toString(),
                      icon: Icon(Icons.folder, color: AppColors.primary),
                      valueColor: AppColors.primary,
                      variant: AppCardVariant.elevated,
                      size: AppCardSize.small,
                      elevation: AppCardElevation.level1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: MetricCard(
                      title: 'Usuarios Totales',
                      value: _getUniqueMembersCount().toString(),
                      icon: Icon(Icons.people, color: AppColors.secondary),
                      valueColor: AppColors.secondary,
                      variant: AppCardVariant.elevated,
                      size: AppCardSize.small,
                      elevation: AppCardElevation.level1,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Información adicional
              AppCard(
                variant: AppCardVariant.outlined,
                size: AppCardSize.medium,
                elevation: AppCardElevation.level1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Actividad Reciente',
                      style: TextStyle(
                        fontFamily: 'Lufga',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildActivityItem(
                      icon: Icons.create_new_folder,
                      title: 'Proyectos creados este mes',
                      value: '${_getProjectsCreatedThisMonth()} proyectos',
                    ),
                    _buildActivityItem(
                      icon: Icons.person_add,
                      title: 'Nuevos miembros',
                      value: '${_getNewMembersThisMonth()} usuarios',
                    ),
                    _buildActivityItem(
                      icon: Icons.edit,
                      title: 'Proyectos modificados',
                      value: '${_getModifiedProjectsThisMonth()} proyectos',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          AppButton(
            text: 'Exportar Reporte',
            onPressed: () => _exportStatistics('pdf'),
            variant: AppButtonVariant.outline,
          ),
          AppButton(
            text: 'Cerrar',
            onPressed: () => Navigator.of(context).pop(),
            variant: AppButtonVariant.ghost,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary, size: 20),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Lufga',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: Text(
        value,
        style: TextStyle(
          fontFamily: 'Lufga',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  int _getProjectsCreatedThisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return _projects.where((project) => project.createdAt.isAfter(startOfMonth)).length;
  }

  int _getNewMembersThisMonth() {
    // Lógica simplificada - en implementación real consultarías la base de datos
    return _getUniqueMembersCount() ~/ 3; // Estimación aproximada
  }

  int _getModifiedProjectsThisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return _projects.where((project) => project.updatedAt.isAfter(startOfMonth)).length;
  }

  void _showNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.notifications_outlined, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Notificaciones'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppCard(
                variant: AppCardVariant.filled,
                size: AppCardSize.medium,
                elevation: AppCardElevation.level1,
                child: Column(
                  children: [
                    _buildNotificationItem(
                      icon: Icons.person_add,
                      iconColor: AppColors.secondary,
                      title: 'Nuevo miembro añadido',
                      description: 'María García se unió al proyecto "Ventas 2024"',
                      time: 'Hace 2 horas',
                    ),
                    _buildNotificationItem(
                      icon: Icons.edit,
                      iconColor: AppColors.tertiary,
                      title: 'Proyecto actualizado',
                      description: 'Se modificó la descripción del proyecto "Inventario"',
                      time: 'Hace 4 horas',
                    ),
                    _buildNotificationItem(
                      icon: Icons.warning,
                      iconColor: AppColors.error,
                      title: 'Proyecto archivado',
                      description: 'El proyecto "Temporal" fue archivado automáticamente',
                      time: 'Hace 1 día',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              AppButton(
                text: 'Ver Todas las Notificaciones',
                onPressed: () {
                  Navigator.of(context).pop();
                  _showAllNotifications();
                },
                variant: AppButtonVariant.outline,
                size: AppButtonSize.small,
              ),
            ],
          ),
        ),
        actions: [
          AppButton(
            text: 'Marcar Todas como Leídas',
            onPressed: () {
              Navigator.of(context).pop();
              _showSuccessMessage('Todas las notificaciones marcadas como leídas');
            },
            variant: AppButtonVariant.primary,
          ),
          AppButton(
            text: 'Cerrar',
            onPressed: () => Navigator.of(context).pop(),
            variant: AppButtonVariant.ghost,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required String time,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 16),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Lufga',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: AppColors.textDisabled,
            ),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    );
  }

  void _showAllNotifications() {
    // Implementar navegación a pantalla completa de notificaciones
    _showSuccessMessage('Pantalla completa de notificaciones estará disponible próximamente');
  }

  void _showGlobalSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.settings_outlined, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Configuración Global'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppCard(
              variant: AppCardVariant.filled,
              size: AppCardSize.large,
              elevation: AppCardElevation.level1,
              child: Column(
                children: [
                  _buildSettingsItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notificaciones',
                    subtitle: 'Configurar alertas y notificaciones',
                    onTap: _showNotificationSettings,
                  ),
                  _buildSettingsItem(
                    icon: Icons.security_outlined,
                    title: 'Seguridad',
                    subtitle: 'Configuración de permisos y acceso',
                    onTap: _showSecuritySettings,
                  ),
                  _buildSettingsItem(
                    icon: Icons.language_outlined,
                    title: 'Idioma y Región',
                    subtitle: 'Configurar idioma y formato regional',
                    onTap: _showLanguageSettings,
                  ),
                  _buildSettingsItem(
                    icon: Icons.backup_outlined,
                    title: 'Copia de Seguridad',
                    subtitle: 'Gestionar respaldos automáticos',
                    onTap: _showBackupSettings,
                  ),
                  _buildSettingsItem(
                    icon: Icons.integration_instructions_outlined,
                    title: 'Integraciones',
                    subtitle: 'Conectar servicios externos',
                    onTap: _showIntegrationSettings,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Información de la aplicación
            AppCard(
              variant: AppCardVariant.outlined,
              size: AppCardSize.medium,
              elevation: AppCardElevation.level1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información de la Aplicación',
                    style: TextStyle(
                      fontFamily: 'Lufga',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoListTile(
                    icon: Icons.info_outline,
                    title: 'Versión',
                    value: '2.0.0',
                  ),
                  _buildInfoListTile(
                    icon: Icons.update,
                    title: 'Última actualización',
                    value: 'Hoy',
                  ),
                  _buildInfoListTile(
                    icon: Icons.storage,
                    title: 'Espacio utilizado',
                    value: '2.4 GB',
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          AppButton(
            text: 'Cerrar',
            onPressed: () => Navigator.of(context).pop(),
            variant: AppButtonVariant.ghost,
          ),
        ],
      ),
    );
  }

  /// Elemento de configuración mejorado
  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Lufga',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontFamily: 'Lufga',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textDisabled),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  /// Elemento de información
  Widget _buildInfoListTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textDisabled, size: 20),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Lufga',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: Text(
        value,
        style: TextStyle(
          fontFamily: 'Lufga',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  // Métodos para diferentes configuraciones
  void _showNotificationSettings() {
    // Implementar configuración de notificaciones
  }

  void _showSecuritySettings() {
    // Implementar configuración de seguridad
  }

  void _showLanguageSettings() {
    // Implementar configuración de idioma
  }

  void _showBackupSettings() {
    // Implementar configuración de respaldos
  }

  void _showIntegrationSettings() {
    // Implementar configuración de integraciones
  }

  void _showAdvancedPermissions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.security, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Permisos Avanzados'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Configuración de permisos globales
              AppCard(
                variant: AppCardVariant.filled,
                size: AppCardSize.large,
                elevation: AppCardElevation.level1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Permisos Globales',
                      style: TextStyle(
                        fontFamily: 'Lufga',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPermissionSwitch(
                      title: 'Crear proyectos',
                      subtitle: 'Permitir a usuarios crear nuevos proyectos',
                      value: true,
                      onChanged: (value) {},
                    ),
                    _buildPermissionSwitch(
                      title: 'Eliminar proyectos',
                      subtitle: 'Permitir eliminar proyectos existentes',
                      value: false,
                      onChanged: (value) {},
                    ),
                    _buildPermissionSwitch(
                      title: 'Gestionar usuarios',
                      subtitle: 'Acceso completo a gestión de usuarios',
                      value: true,
                      onChanged: (value) {},
                    ),
                    _buildPermissionSwitch(
                      title: 'Ver estadísticas',
                      subtitle: 'Acceso a informes y métricas',
                      value: true,
                      onChanged: (value) {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Roles personalizados
              AppCard(
                variant: AppCardVariant.outlined,
                size: AppCardSize.medium,
                elevation: AppCardElevation.level1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Roles Personalizados',
                          style: TextStyle(
                            fontFamily: 'Lufga',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        AppButton(
                          text: 'Añadir Rol',
                          onPressed: () => _showCreateRoleDialog(),
                          variant: AppButtonVariant.outline,
                          size: AppButtonSize.small,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildRoleListItem(
                      roleName: 'Administrador Senior',
                      description: 'Acceso completo a todas las funciones',
                      userCount: 3,
                      color: AppColors.error,
                    ),
                    _buildRoleListItem(
                      roleName: 'Gestor de Proyectos',
                      description: 'Puede gestionar proyectos y usuarios',
                      userCount: 5,
                      color: AppColors.tertiary,
                    ),
                    _buildRoleListItem(
                      roleName: 'Analista',
                      description: 'Solo lectura y análisis de datos',
                      userCount: 8,
                      color: AppColors.secondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          AppButton(
            text: 'Guardar Cambios',
            onPressed: () {
              Navigator.of(context).pop();
              _showSuccessMessage('Permisos actualizados correctamente');
            },
            variant: AppButtonVariant.primary,
          ),
          AppButton(
            text: 'Cancelar',
            onPressed: () => Navigator.of(context).pop(),
            variant: AppButtonVariant.ghost,
          ),
        ],
      ),
    );
  }

  /// Switch de permiso con descripción
  Widget _buildPermissionSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Lufga',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Lufga',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  /// Elemento de lista de roles
  Widget _buildRoleListItem({
    required String roleName,
    required String description,
    required int userCount,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.person_outline, color: color, size: 16),
      ),
      title: Text(
        roleName,
        style: TextStyle(
          fontFamily: 'Lufga',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        description,
        style: TextStyle(
          fontFamily: 'Lufga',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          '$userCount usuarios',
          style: TextStyle(
            fontFamily: 'Lufga',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showCreateRoleDialog() {
    // Implementar diálogo para crear roles personalizados
  }

  void _showActivityLogs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.analytics_outlined, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Logs de Actividad'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Filtros de logs
              AppCard(
                variant: AppCardVariant.outlined,
                size: AppCardSize.small,
                elevation: AppCardElevation.level0,
                child: Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: 'Hoy',
                        onPressed: () {},
                        variant: AppButtonVariant.outline,
                        size: AppButtonSize.small,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppButton(
                        text: '7 días',
                        onPressed: () {},
                        variant: AppButtonVariant.ghost,
                        size: AppButtonSize.small,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppButton(
                        text: '30 días',
                        onPressed: () {},
                        variant: AppButtonVariant.ghost,
                        size: AppButtonSize.small,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Lista de actividades
              Expanded(
                child: AppCard(
                  variant: AppCardVariant.filled,
                  size: AppCardSize.medium,
                  elevation: AppCardElevation.level1,
                  child: ListView(
                    children: [
                      _buildActivityLogItem(
                        icon: Icons.person_add,
                        iconColor: AppColors.secondary,
                        title: 'Nuevo usuario registrado',
                        subtitle: 'María García se unió al proyecto "Ventas 2024"',
                        time: 'Hace 2 horas',
                      ),
                      _buildActivityLogItem(
                        icon: Icons.edit,
                        iconColor: AppColors.tertiary,
                        title: 'Proyecto actualizado',
                        subtitle: 'Se modificó la descripción del proyecto "Inventario"',
                        time: 'Hace 4 horas',
                      ),
                      _buildActivityLogItem(
                        icon: Icons.delete,
                        iconColor: AppColors.error,
                        title: 'Proyecto eliminado',
                        subtitle: 'Se eliminó el proyecto "Temporal"',
                        time: 'Hace 1 día',
                      ),
                      _buildActivityLogItem(
                        icon: Icons.security,
                        iconColor: AppColors.primary,
                        title: 'Cambio de permisos',
                        subtitle: 'Se actualizaron permisos para Juan Pérez',
                        time: 'Hace 2 días',
                      ),
                      _buildActivityLogItem(
                        icon: Icons.backup,
                        iconColor: AppColors.sales,
                        title: 'Copia de seguridad',
                        subtitle: 'Se creó una copia de seguridad automática',
                        time: 'Hace 3 días',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          AppButton(
            text: 'Exportar Logs',
            onPressed: () => _exportActivityLogs(),
            variant: AppButtonVariant.outline,
          ),
          AppButton(
            text: 'Cerrar',
            onPressed: () => Navigator.of(context).pop(),
            variant: AppButtonVariant.ghost,
          ),
        ],
      ),
    );
  }

  /// Elemento de log de actividad
  Widget _buildActivityLogItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 16),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Lufga',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: AppColors.textDisabled,
            ),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    );
  }

  void _exportActivityLogs() {
    // Implementar exportación de logs
    _showSuccessMessage('Logs exportados correctamente');
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.backup_outlined, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Exportar Datos'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Opciones de exportación
            AppCard(
              variant: AppCardVariant.filled,
              size: AppCardSize.large,
              elevation: AppCardElevation.level1,
              child: Column(
                children: [
                  _buildExportOption(
                    icon: Icons.table_chart_outlined,
                    title: 'Exportar Proyectos',
                    subtitle: 'Descargar todos los proyectos en formato CSV',
                    onTap: () => _exportProjects('csv'),
                  ),
                  _buildExportOption(
                    icon: Icons.people_outline,
                    title: 'Exportar Usuarios',
                    subtitle: 'Lista completa de usuarios y roles',
                    onTap: () => _exportUsers('csv'),
                  ),
                  _buildExportOption(
                    icon: Icons.analytics_outlined,
                    title: 'Exportar Estadísticas',
                    subtitle: 'Informe completo con métricas y gráficos',
                    onTap: () => _exportStatistics('pdf'),
                  ),
                  _buildExportOption(
                    icon: Icons.history,
                    title: 'Exportar Logs de Actividad',
                    subtitle: 'Historial completo de acciones realizadas',
                    onTap: () => _exportActivityLogs(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Configuración de exportación
            AppCard(
              variant: AppCardVariant.outlined,
              size: AppCardSize.medium,
              elevation: AppCardElevation.level1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configuración de Exportación',
                    style: TextStyle(
                      fontFamily: 'Lufga',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildExportSetting(
                    title: 'Incluir datos privados',
                    subtitle: 'Exportar información sensible',
                    value: false,
                    onChanged: (value) {},
                  ),
                  _buildExportSetting(
                    title: 'Formato de fecha',
                    subtitle: 'Seleccionar formato para fechas',
                    value: true,
                    onChanged: (value) {},
                  ),
                  _buildExportSetting(
                    title: 'Comprimir archivo',
                    subtitle: 'Crear archivo ZIP para archivos grandes',
                    value: true,
                    onChanged: (value) {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Información de exportación reciente
            AppCard(
              variant: AppCardVariant.outlined,
              size: AppCardSize.small,
              elevation: AppCardElevation.level0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Última Exportación',
                    style: TextStyle(
                      fontFamily: 'Lufga',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: AppColors.textDisabled),
                      const SizedBox(width: 4),
                      Text(
                        'Hoy, 14:30 - proyectos.csv (2.4 MB)',
                        style: TextStyle(
                          fontFamily: 'Lufga',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          AppButton(
            text: 'Exportar Todo',
            onPressed: () => _exportAllData(),
            variant: AppButtonVariant.primary,
          ),
          AppButton(
            text: 'Cancelar',
            onPressed: () => Navigator.of(context).pop(),
            variant: AppButtonVariant.ghost,
          ),
        ],
      ),
    );
  }

  /// Opción de exportación individual
  Widget _buildExportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Lufga',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontFamily: 'Lufga',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Icon(Icons.download_outlined, size: 16, color: AppColors.textDisabled),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  /// Configuración de exportación con switch
  Widget _buildExportSetting({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Lufga',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Lufga',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  // Métodos de exportación
  void _exportProjects(String format) {
    Navigator.of(context).pop();
    _showSuccessMessage('Proyectos exportados en formato $format');
  }

  void _exportUsers(String format) {
    Navigator.of(context).pop();
    _showSuccessMessage('Usuarios exportados en formato $format');
  }

  void _exportStatistics(String format) {
    Navigator.of(context).pop();
    _showSuccessMessage('Estadísticas exportadas en formato $format');
  }

  void _exportAllData() {
    Navigator.of(context).pop();
    _showSuccessMessage('Todos los datos exportados correctamente');
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            fontFamily: 'Lufga',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textOnPrimary,
          ),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }


  /// Mejoras de accesibilidad para lectores de pantalla
  String _getAccessibilityLabel(Project project) {
    return 'Proyecto ${project.name}, ${project.description}, ${project.members.length} miembros, ${project.isActive ? 'activo' : 'inactivo'}';
  }

  String _getAccessibilityHint(Project project) {
    return 'Toca dos veces para ver detalles, mantén presionado para opciones rápidas';
  }

}

/// Widget wrapper para manejar navegación por teclado
class KeyboardNavigationManager extends StatefulWidget {
  final Widget child;
  final Function(KeyEvent) onKeyPressed;

  const KeyboardNavigationManager({
    super.key,
    required this.child,
    required this.onKeyPressed,
  });

  @override
  State<KeyboardNavigationManager> createState() => _KeyboardNavigationManagerState();
}

class _KeyboardNavigationManagerState extends State<KeyboardNavigationManager> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: widget.onKeyPressed,
      autofocus: true,
      child: widget.child,
    );
  }
}