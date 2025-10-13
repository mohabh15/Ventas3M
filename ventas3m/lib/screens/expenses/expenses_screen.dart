import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/expense.dart';
import '../../models/project.dart';
import '../../models/payment_method.dart';
import '../../models/expense_recurrence_type.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/gradient_app_bar.dart';
import '../../services/firebase_service.dart';
import '../../services/formatting_service.dart';
import 'add_edit_expense_modal.dart';
import 'expense_details_modal.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  // Controladores y estado
  final TextEditingController _searchController = TextEditingController();
  String? _selectedProject;
  String? _selectedCategory;
  String? _selectedPaymentMethod;
  DateTimeRange? _dateRange;
  bool? _showOnlyRecurring;

  // Servicios
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // TODO: Implementar búsqueda por texto cuando esté disponible en ExpenseProvider
    _applyFilters();
  }

  void _applyFilters() {
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    final filters = <String, dynamic>{};

    if (_selectedProject != null && _selectedProject!.isNotEmpty) {
      filters['projectId'] = _selectedProject;
    }

    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      filters['category'] = _selectedCategory;
    }

    if (_selectedPaymentMethod != null && _selectedPaymentMethod!.isNotEmpty) {
      filters['paymentMethod'] = PaymentMethod.values.firstWhere(
        (method) => method.toString() == _selectedPaymentMethod,
      );
    }

    if (_showOnlyRecurring != null) {
      filters['isRecurring'] = _showOnlyRecurring;
    }

    if (_dateRange != null) {
      filters['startDate'] = _dateRange!.start;
      filters['endDate'] = _dateRange!.end;
    }

    expenseProvider.setFilter(filters);
  }

  @override
  Widget build(BuildContext context) {
    // Calcular la altura de la barra de navegación inferior
    //final bottomPadding = MediaQuery.of(context).padding.bottom;
    //final marginBottom = bottomPadding + 16.0; // Margen de 16px encima de la navbar

    return Scaffold(
      appBar: GradientAppBar(
        title: 'Gestión de Gastos',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFiltersModal,
            tooltip: 'Filtros',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchModal,
            tooltip: 'Buscar',
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          if (expenseProvider.isLoading) {
            return const LoadingWidget();
          }

          return Column(
            children: [
              // Estadísticas resumidas
              _buildStatsCard(expenseProvider),

              // Lista de gastos
              Expanded(
                child: expenseProvider.filteredExpenses.isEmpty
                    ? _buildEmptyState()
                    : _buildExpensesList(expenseProvider.filteredExpenses),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseModal,
        tooltip: 'Añadir Gasto',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatsCard(ExpenseProvider expenseProvider) {
    final totalExpenses = expenseProvider.totalFilteredExpenses;
    final expensesCount = expenseProvider.filteredExpenses.length;
    final averageExpense = expensesCount > 0 ? totalExpenses / expensesCount : 0.0;

    // Calcular categoría con más gastos
    final expensesByCategory = <String, double>{};
    for (var expense in expenseProvider.filteredExpenses) {
      expensesByCategory[expense.category] =
          (expensesByCategory[expense.category] ?? 0) + expense.amount;
    }

    final topCategory = expensesByCategory.isNotEmpty
        ? expensesByCategory.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : 'Sin categoría';

    return AppCard(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen del Período',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Gastos',
                    FormattingService.formatCurrency(totalExpenses),
                    Icons.euro,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Promedio',
                    FormattingService.formatCurrency(averageExpense),
                    Icons.trending_up,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Cantidad',
                    expensesCount.toString(),
                    Icons.receipt,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Categoría Principal',
                    topCategory,
                    Icons.category,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay gastos registrados',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Presiona el botón + para añadir un gasto',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesList(List<Expense> expenses) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return _buildExpenseCard(expense);
      },
    );
  }

  Widget _buildExpenseCard(Expense expense) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => _showExpenseDetails(expense),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Primera fila: Descripción, monto y menú
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.description,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        expense.formattedDate,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      expense.formattedAmount,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      onSelected: (value) => _handleMenuAction(value, expense),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'duplicate',
                          child: Row(
                            children: [
                              Icon(Icons.copy),
                              SizedBox(width: 8),
                              Text('Duplicar'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Eliminar'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Información adicional
            Row(
              children: [
                _buildInfoChip(
                  icon: Icons.category,
                  text: expense.category,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  icon: Icons.payment,
                  text: expense.paymentMethod.displayName,
                ),
                if (expense.hasProject) ...[
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    icon: Icons.folder,
                    text: 'Proyecto',
                  ),
                ],
                if (expense.isRecurring) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      expense.recurrenceType?.displayName ?? 'Recurrente',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.orange[700],
                      ),
                    ),
                  ),
                ],
              ],
            ),

            // Notas si existen
            if (expense.hasNotes) ...[
              const SizedBox(height: 8),
              Text(
                expense.notes!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha:  0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showFiltersModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[900]
              : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filtros',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // Filtro por proyecto
              Consumer<SettingsProvider>(
                builder: (context, settingsProvider, child) {
                  return FutureBuilder<List<Project>>(
                    future: _firebaseService.getProjects(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return DropdownButtonFormField<String>(
                          initialValue: '',
                          decoration: InputDecoration(
                            labelText: 'Proyecto',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: '',
                              child: Text('Cargando...'),
                            ),
                          ],
                          onChanged: null,
                        );
                      }

                      final projects = snapshot.data!;
                      return DropdownButtonFormField<String>(
                        initialValue: _selectedProject,
                        decoration: const InputDecoration(
                          labelText: 'Proyecto',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: '',
                            child: Text('Todos los proyectos'),
                          ),
                          ...projects.map((project) => DropdownMenuItem(
                                value: project.id,
                                child: Text(project.name),
                              )),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedProject = value);
                          _applyFilters();
                        },
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 16),

              // Filtro por categoría
              Consumer<ExpenseProvider>(
                builder: (context, expenseProvider, child) {
                  final categories = expenseProvider.categories;
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text('Todas las categorías'),
                      ),
                      ...categories.map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          )),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedCategory = value);
                      _applyFilters();
                    },
                  );
                },
              ),

              const SizedBox(height: 16),

              // Filtro por método de pago
              DropdownButtonFormField<String>(
                initialValue: _selectedPaymentMethod,
                decoration: const InputDecoration(
                  labelText: 'Método de Pago',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: '',
                    child: Text('Todos los métodos'),
                  ),
                  ...PaymentMethod.values.map((method) => DropdownMenuItem(
                        value: method.toString(),
                        child: Text(method.displayName),
                      )),
                ],
                onChanged: (value) {
                  setState(() => _selectedPaymentMethod = value);
                  _applyFilters();
                },
              ),

              const SizedBox(height: 16),

              // Filtro por gastos recurrentes
              SwitchListTile(
                title: const Text('Solo gastos recurrentes'),
                value: _showOnlyRecurring ?? false,
                onChanged: (value) {
                  setState(() => _showOnlyRecurring = value);
                  _applyFilters();
                },
              ),

              const SizedBox(height: 16),

              // Botón para seleccionar rango de fechas
              ElevatedButton.icon(
                onPressed: _selectDateRange,
                icon: const Icon(Icons.date_range),
                label: Text(_dateRange == null
                    ? 'Seleccionar fechas'
                    : '${FormattingService.formatDate(_dateRange!.start)} - ${FormattingService.formatDate(_dateRange!.end)}'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),

              const SizedBox(height: 16),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearFilters,
                      child: const Text('Limpiar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Aplicar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSearchModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[900]
              : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Buscar Gastos',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Buscar por descripción...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _dateRange,
    );

    if (picked != null) {
      setState(() => _dateRange = picked);
      _applyFilters();
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedProject = null;
      _selectedCategory = null;
      _selectedPaymentMethod = null;
      _dateRange = null;
      _showOnlyRecurring = null;
      _searchController.clear();
    });
    _applyFilters();
  }

  Future<void> _showAddExpenseModal() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddEditExpenseModal(),
    );

    // Manejar resultado del modal
    if (result != null && mounted) {
      final success = result['success'] as bool? ?? false;
      final message = result['message'] as String? ?? '';

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
          ),
        );
        // Recargar gastos para mostrar los cambios
        context.read<ExpenseProvider>().loadExpenses();
      }
    }
  }

  void _showExpenseDetails(Expense expense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExpenseDetailsModal(expense: expense),
    );
  }

  void _handleMenuAction(String action, Expense expense) {
    switch (action) {
      case 'edit':
        _showEditExpenseModal(expense);
        break;
      case 'duplicate':
        _duplicateExpense(expense);
        break;
      case 'delete':
        _deleteExpense(expense);
        break;
    }
  }

  Future<void> _showEditExpenseModal(Expense expense) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEditExpenseModal(expense: expense),
    );

    // Manejar resultado del modal
    if (result != null && mounted) {
      final success = result['success'] as bool? ?? false;
      final message = result['message'] as String? ?? '';

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
          ),
        );
        // Recargar gastos para mostrar los cambios
        context.read<ExpenseProvider>().loadExpenses();
      }
    }
  }

  void _duplicateExpense(Expense expense) {
    // TODO: Implementar duplicación de gasto
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Duplicar: ${expense.description}')),
    );
  }

  void _deleteExpense(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Gasto'),
        content: Text('¿Estás seguro de que quieres eliminar el gasto "${expense.description}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<ExpenseProvider>(context, listen: false)
                  .deleteExpense(expense.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gasto "${expense.description}" eliminado')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}