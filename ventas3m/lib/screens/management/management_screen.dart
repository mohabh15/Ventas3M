import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_service.dart';
import '../../services/auth_service.dart';
import '../../models/project.dart';
import '../../providers/settings_provider.dart';

class ManagementScreen extends StatefulWidget {
  const ManagementScreen({super.key});

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Project> _projects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() => _isLoading = true);
    try {
      _projects = await _firebaseService.getProjects();
    } catch (e) {
      // Do nothing, _projects remains empty
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    //final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración de Proyectos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateProjectDialog,
            tooltip: 'Crear Proyecto',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _projects.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'No tienes proyectos. Crea tu primer proyecto.',
                                  style: TextStyle(fontSize: 18),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _showCreateProjectDialog,
                                  child: const Text('Crear Proyecto'),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _projects.length,
                            itemBuilder: (context, index) {
                              final project = _projects[index];
                              return Card(
                                elevation: 4,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        project.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(project.description),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () => _showEditProjectDialog(project),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () => _deleteProject(project.id),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.people),
                                            onPressed: () => _showManageUsersDialog(project),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final currentUser = AuthService().currentUser;
              if (currentUser == null) {
                // Mostrar error o no permitir
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
              await _firebaseService.createProject(project);
              if(context.mounted) Navigator.of(context).pop();
              _loadProjects();
            },
            child: const Text('Crear'),
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
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
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
              await _firebaseService.updateProject(updatedProject);
              if(context.mounted) Navigator.of(context).pop();
              _loadProjects();
            },
            child: const Text('Guardar'),
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
    await _firebaseService.deleteProject(projectId);
    _loadProjects();
  }

  void _showManageUsersDialog(Project project) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Gestionar Miembros - ${project.name}'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Correo electrónico'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (emailController.text.isNotEmpty) {
                          await _firebaseService.addMember(project.id, emailController.text);
                          _loadProjects();
                          emailController.clear();
                        }
                      },
                      child: const Text('Añadir Miembro'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (emailController.text.isNotEmpty) {
                          await _firebaseService.removeMember(project.id, emailController.text);
                          _loadProjects();
                          emailController.clear();
                        }
                      },
                      child: const Text('Quitar Miembro'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Miembros actuales:'),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: project.members.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(project.members[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}