import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/expense.dart';
import '../../models/expense_recurrence_type.dart';
import '../../models/payment_method.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/formatting_service.dart';

class AddEditExpenseModal extends StatefulWidget {
  final Expense? expense;

  const AddEditExpenseModal({super.key, this.expense});

  @override
  State<AddEditExpenseModal> createState() => _AddEditExpenseModalState();
}

class _AddEditExpenseModalState extends State<AddEditExpenseModal> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = '';
  String? _selectedProjectId;
  String? _selectedProviderId;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  bool _isRecurring = false;
  ExpenseRecurrenceType? _recurrenceType;

  bool _isLoading = false;
  final List<String> _expenseCategories = [
    'Alimentación',
    'Transporte',
    'Materiales',
    'Servicios',
    'Mantenimiento',
    'Publicidad',
    'Oficina',
    'Combustible',
    'Herramientas',
    'Otros'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _loadExpenseData();
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadExpenseData() {
    final expense = widget.expense!;
    _descriptionController.text = expense.description;
    _amountController.text = expense.amount.toStringAsFixed(2);
    _selectedDate = expense.date;
    _selectedCategory = expense.category;
    _selectedProjectId = expense.projectId;
    _selectedProviderId = expense.providerId;
    _selectedPaymentMethod = expense.paymentMethod;
    _isRecurring = expense.isRecurring;
    _recurrenceType = expense.recurrenceType;
    _notesController.text = expense.notes ?? '';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }


  bool _validateForm() {
    if (_descriptionController.text.trim().isEmpty) {
      _showError('La descripción es obligatoria');
      return false;
    }

    if (_amountController.text.trim().isEmpty) {
      _showError('El monto es obligatorio');
      return false;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showError('El monto debe ser un número positivo');
      return false;
    }

    if (_selectedCategory.trim().isEmpty) {
      _showError('La categoría es obligatoria');
      return false;
    }

    if (_isRecurring && _recurrenceType == null) {
      _showError('Debe seleccionar el tipo de recurrencia');
      return false;
    }

    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Expense _createExpenseFromForm() {
    final amount = double.parse(_amountController.text);

    return Expense.create(
      description: _descriptionController.text.trim(),
      amount: amount,
      date: _selectedDate,
      category: _selectedCategory,
      projectId: _selectedProjectId,
      providerId: _selectedProviderId,
      paymentMethod: _selectedPaymentMethod,
      isRecurring: _isRecurring,
      recurrenceType: _recurrenceType,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      createdBy: context.read<AuthProvider>().currentUser?.id,
    );
  }

  Future<void> _saveExpense() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final expenseProvider = context.read<ExpenseProvider>();
      final expense = _createExpenseFromForm();

      if (widget.expense == null) {
        await expenseProvider.createExpense(expense);
      } else {
        await expenseProvider.updateExpense(widget.expense!.id, expense.copyWith(
          id: widget.expense!.id,
          createdAt: widget.expense!.createdAt,
          updatedAt: DateTime.now(),
        ));
      }

      if (mounted) {
        Navigator.of(context).pop({
          'success': true,
          'expense': expense,
          'message': widget.expense == null ? 'Gasto creado exitosamente' : 'Gasto actualizado exitosamente',
        });
      }
    } catch (e) {
      if (mounted) {
        _showError('Error al guardar gasto: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
                      widget.expense == null ? 'Añadir Gasto' : 'Editar Gasto',
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

                // Descripción
                TextFormField(
                  controller: _descriptionController,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Descripción *',
                    hintText: 'Descripción del gasto',
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
                    if (value == null || value.trim().isEmpty) {
                      return 'La descripción es obligatoria';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Monto y Fecha
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText: 'Monto *',
                          hintText: '0.00',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(Icons.attach_money, color: theme.colorScheme.primary),
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
                            return 'Requerido';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Monto inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.colorScheme.outline),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                FormattingService.formatDate(_selectedDate),
                                style: TextStyle(color: theme.colorScheme.onSurface),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Categoría
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Categoría *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.category, color: theme.colorScheme.primary),
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
                  items: _expenseCategories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(
                        category,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                      ),
                    );
                  }).toList(),
                  initialValue: _selectedCategory.isEmpty ? null : _selectedCategory,
                  onChanged: (category) {
                    setState(() {
                      _selectedCategory = category ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor seleccione una categoría';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Proyecto relacionado
                Consumer<SettingsProvider>(
                  builder: (context, settingsProvider, child) {
                    return DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Proyecto relacionado',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.folder, color: theme.colorScheme.primary),
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
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Sin proyecto'),
                        ),
                        if (settingsProvider.activeProjectId != null)
                          DropdownMenuItem(
                            value: settingsProvider.activeProjectId,
                            child: Text(
                              'Proyecto activo',
                              style: TextStyle(color: theme.colorScheme.onSurface),
                            ),
                          ),
                      ],
                      initialValue: _selectedProjectId,
                      onChanged: (projectId) {
                        setState(() {
                          _selectedProjectId = projectId;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Método de Pago
                DropdownButtonFormField<PaymentMethod>(
                  decoration: InputDecoration(
                    labelText: 'Método de Pago',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.payment, color: theme.colorScheme.primary),
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
                  items: PaymentMethod.values.map((method) {
                    return DropdownMenuItem(
                      value: method,
                      child: Text(
                        method.displayName,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                      ),
                    );
                  }).toList(),
                  initialValue: _selectedPaymentMethod,
                  onChanged: (method) {
                    if (method != null) {
                      setState(() {
                        _selectedPaymentMethod = method;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Gasto recurrente
                SwitchListTile(
                  title: Text(
                    'Gasto recurrente',
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                  subtitle: Text(
                    'Se repite periódicamente',
                    style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                  ),
                  value: _isRecurring,
                  onChanged: (value) {
                    setState(() {
                      _isRecurring = value;
                      if (!value) {
                        _recurrenceType = null;
                      }
                    });
                  },
                  activeThumbColor: theme.colorScheme.primary,
                ),

                // Tipo de recurrencia
                if (_isRecurring) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<ExpenseRecurrenceType>(
                    decoration: InputDecoration(
                      labelText: 'Tipo de recurrencia *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.repeat, color: theme.colorScheme.primary),
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
                    items: ExpenseRecurrenceType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(
                          type.displayName,
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                      );
                    }).toList(),
                    initialValue: _recurrenceType,
                    onChanged: (type) {
                      setState(() {
                        _recurrenceType = type;
                      });
                    },
                    validator: (value) {
                      if (_isRecurring && value == null) {
                        return 'Debe seleccionar el tipo de recurrencia';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Notas
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Notas',
                    hintText: 'Información adicional del gasto...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.note, color: theme.colorScheme.primary),
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

                const SizedBox(height: 24),

                // Vista previa
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: isDark ? 0.3 : 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.5 : 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vista previa del gasto',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Descripción:',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            _descriptionController.text.isEmpty
                                ? 'Sin descripción'
                                : _descriptionController.text,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Monto:',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            _amountController.text.isEmpty
                                ? FormattingService.formatCurrency(0.0)
                                : FormattingService.formatCurrency(double.tryParse(_amountController.text) ?? 0.0),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Categoría:',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            _selectedCategory.isEmpty ? 'Sin categoría' : _selectedCategory,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Botones de acción
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
                    Consumer<ExpenseProvider>(
                      builder: (context, expenseProvider, child) {
                        return ElevatedButton.icon(
                          onPressed: _isLoading ? null : _saveExpense,
                          icon: _isLoading
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: isDark ? Colors.white : theme.colorScheme.onPrimary,
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: Text(widget.expense == null ? 'Crear Gasto' : 'Actualizar Gasto'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            elevation: isDark ? 3 : 4,
                            shadowColor: isDark ? Colors.black26 : theme.shadowColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
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
}