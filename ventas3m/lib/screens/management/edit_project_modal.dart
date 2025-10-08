import 'package:flutter/material.dart';
import '../../models/project.dart';
import '../../models/provider.dart';
import '../../services/firebase_service.dart';

class EditProjectModal extends StatefulWidget {
  final Project project;

  const EditProjectModal({super.key, required this.project});

  @override
  State<EditProjectModal> createState() => _EditProjectModalState();
}

class _EditProjectModalState extends State<EditProjectModal> {
  final FirebaseService _firebaseService = FirebaseService();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late List<Provider> _providers;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project.name);
    _descriptionController = TextEditingController(text: widget.project.description);
    _providers = List.from(widget.project.providers);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header con título y botón de cerrar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Editar Proyecto',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Información del proyecto
              TextField(
                controller: _nameController,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Nombre del Proyecto',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.business, color: theme.colorScheme.primary),
                  labelStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _descriptionController,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.description, color: theme.colorScheme.primary),
                  labelStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Gestión de proveedores
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Proveedores',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showAddProviderDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Añadir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Lista de proveedores
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: _providers.isEmpty
                    ? Center(
                        child: Text(
                          'No hay proveedores añadidos',
                          style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6)),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _providers.length,
                        itemBuilder: (context, index) {
                          final provider = _providers[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: theme.colorScheme.surface,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              title: Text(
                                provider.name,
                                style: TextStyle(color: theme.colorScheme.onSurface),
                              ),
                              subtitle: Text(
                                provider.contactEmail,
                                style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: theme.colorScheme.primary),
                                    onPressed: () => _showEditProviderDialog(provider, index),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: theme.colorScheme.error),
                                    onPressed: () => _removeProvider(index),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 24),

              // Botones de Acción
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveProject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      elevation: 3,
                      shadowColor: theme.shadowColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.onPrimary,
                            ),
                          )
                        : const Text('Guardar Proyecto'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddProviderDialog() {
    final theme = Theme.of(context);
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Añadir Proveedor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                labelStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Email de contacto',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                labelStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                labelStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: addressController,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Dirección',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                labelStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && emailController.text.isNotEmpty) {
                final newProvider = Provider(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  contactEmail: emailController.text,
                  phone: phoneController.text,
                  address: addressController.text,
                  projectId: widget.project.id,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  isActive: true,
                );
                setState(() {
                  _providers.add(newProvider);
                });
                Navigator.of(context).pop();
              }
            },
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
  }

  void _showEditProviderDialog(Provider provider, int index) {
    final theme = Theme.of(context);
    final nameController = TextEditingController(text: provider.name);
    final emailController = TextEditingController(text: provider.contactEmail);
    final phoneController = TextEditingController(text: provider.phone);
    final addressController = TextEditingController(text: provider.address);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Proveedor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                labelStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Email de contacto',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                labelStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                labelStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: addressController,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Dirección',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                labelStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && emailController.text.isNotEmpty) {
                final updatedProvider = provider.copyWith(
                  name: nameController.text,
                  contactEmail: emailController.text,
                  phone: phoneController.text,
                  address: addressController.text,
                  updatedAt: DateTime.now(),
                );
                setState(() {
                  _providers[index] = updatedProvider;
                });
                Navigator.of(context).pop();
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _removeProvider(int index) {
    setState(() {
      _providers.removeAt(index);
    });
  }

  Future<void> _saveProject() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre del proyecto es requerido')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedProject = Project(
        id: widget.project.id,
        name: _nameController.text,
        description: _descriptionController.text,
        ownerId: widget.project.ownerId,
        createdAt: widget.project.createdAt,
        updatedAt: DateTime.now(),
        isActive: widget.project.isActive,
        members: widget.project.members,
        providers: _providers,
      );

      await _firebaseService.updateProject(updatedProject);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proyecto actualizado correctamente')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar proyecto: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}