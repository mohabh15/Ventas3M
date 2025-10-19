import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../providers/event_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/team_balance_provider.dart';

class EditEventModal extends StatefulWidget {
  const EditEventModal({super.key, required this.event});

  final Event event;

  @override
  State<EditEventModal> createState() => _EditEventModalState();
}

class _EditEventModalState extends State<EditEventModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late final TextEditingController _interestedController;

  String? _selectedResponsible;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _descriptionController = TextEditingController(text: widget.event.description);
    _locationController = TextEditingController(text: widget.event.location ?? '');
    _interestedController = TextEditingController(text: widget.event.interested.join(', '));
    _selectedResponsible = widget.event.responsible;
    _selectedDate = widget.event.date;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _interestedController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Editar Evento',
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

                  // Título
                  TextFormField(
                    controller: _titleController,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Título',
                      hintText: 'Título del evento',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.title, color: theme.colorScheme.primary),
                      labelStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                      hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.colorScheme.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el título del evento';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Descripción
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      hintText: 'Descripción del evento',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.description, color: theme.colorScheme.primary),
                      labelStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                      hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.colorScheme.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese la descripción del evento';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Fecha
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Fecha',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.calendar_today, color: theme.colorScheme.primary),
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
                      child: Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: TextStyle(color: theme.colorScheme.onSurface),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Ubicación (opcional)
                  TextFormField(
                    controller: _locationController,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Ubicación (opcional)',
                      hintText: 'Lugar del evento',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.location_on, color: theme.colorScheme.primary),
                      labelStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                      hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
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

                  // Responsable (opcional)
                  Builder(
                    builder: (context) {
                      final teamProvider = Provider.of<TeamBalanceProvider>(context);
                      final members = teamProvider.teamBalances;
                      return DropdownButtonFormField<String>(
                        initialValue: _selectedResponsible,
                        decoration: InputDecoration(
                          labelText: 'Responsable (opcional)',
                          hintText: 'Seleccionar responsable',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(Icons.person, color: theme.colorScheme.primary),
                          labelStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                          hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.colorScheme.outline),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                          ),
                        ),
                        items: members.map((member) {
                          return DropdownMenuItem<String>(
                            value: member.name,
                            child: Text(member.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedResponsible = value;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Interesados (opcional)
                  TextFormField(
                    controller: _interestedController,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Interesados (opcional)',
                      hintText: 'Nombres separados por comas',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.group, color: theme.colorScheme.primary),
                      labelStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                      hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
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
                      ElevatedButton.icon(
                        onPressed: _submitForm,
                        icon: const Icon(Icons.save),
                        label: const Text('Actualizar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          elevation: isDark ? 3 : 4,
                          shadowColor: isDark ? Colors.black26 : theme.shadowColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      );
    }

    void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id ?? 'guest';

    final interested = _interestedController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final updatedEvent = widget.event.copyWith(
      title: _titleController.text,
      description: _descriptionController.text,
      date: _selectedDate,
      updatedAt: DateTime.now(),
      location: _locationController.text.isEmpty ? null : _locationController.text,
      responsible: _selectedResponsible,
      interested: interested,
    );

    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final success = await eventProvider.updateEvent(updatedEvent, userId);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
    } else {
      // Mostrar error si falla
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar el evento')),
      );
    }
  }
}