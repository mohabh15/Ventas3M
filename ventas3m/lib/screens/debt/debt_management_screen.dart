import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/settings_provider.dart';
import '../../providers/debt_provider.dart';
import '../../models/debt.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/gradient_app_bar.dart';
import '../../services/formatting_service.dart';
import '../../services/debt_service.dart';
import 'add_edit_debt_modal.dart';
import 'debt_details_modal.dart';

class DebtManagementScreen extends StatefulWidget {
  const DebtManagementScreen({super.key});

  @override
  State<DebtManagementScreen> createState() => _DebtManagementScreenState();
}

class _DebtManagementScreenState extends State<DebtManagementScreen> {
  // Controladores y estado
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;
  String? _selectedDebtor;
  String? _selectedCreditor;
  DateTimeRange? _dateRange;

  // Servicios
  final DebtService _debtService = DebtService();

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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Calcular la altura de la barra de navegación inferior
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final marginBottom = bottomPadding + 16.0; // Margen de 16px encima de la navbar

    return Scaffold(
      appBar: GradientAppBar(
        title: 'Gestión de Deudas',
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
      body: Stack(
        children: [
          // Contenido principal
          Consumer<SettingsProvider>(
            builder: (context, settingsProvider, child) {
              final projectId = settingsProvider.activeProjectId;
              if (projectId == null) {
                return const Center(
                  child: Text('No hay proyecto activo seleccionado'),
                );
              }

              return StreamBuilder<List<Debt>>(
                stream: _debtService.listenToProjectDebts(projectId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingWidget();
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 80,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error al cargar deudas',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final debts = snapshot.data ?? [];
                  final filteredDebts = _filterDebts(debts);

                  return Column(
                    children: [
                      // Estadísticas resumidas
                      _buildStatsCard(filteredDebts),

                      // Lista de deudas
                      Expanded(
                        child: filteredDebts.isEmpty
                            ? _buildEmptyState()
                            : _buildDebtsList(filteredDebts),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          // Botón flotante posicionado relativo a la navbar
          Positioned(
            right: 16.0,
            bottom: marginBottom,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0D47A1), // Azul oscuro
                    Color(0xFF1976D2), // Azul primario
                    Color(0xFF42A5F5), // Azul claro
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: FloatingActionButton(
                heroTag: 'debt_fab', // Tag único para evitar conflictos de Hero
                onPressed: _showAddDebtModal,
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(List<Debt> debts) {
    final totalDebts = debts.fold<double>(0, (sum, debt) => sum + debt.amount);
    final pendingDebts = debts.where((debt) => debt.isPending).length;
    final paidDebts = debts.where((debt) => debt.isPaid).length;
    final overdueDebts = debts.where((debt) => debt.isOverdue).length;

    return AppCard(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen de Deudas',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total',
                    FormattingService.formatCurrency(totalDebts),
                    Icons.account_balance_wallet,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Pendientes',
                    pendingDebts.toString(),
                    Icons.pending,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Pagadas',
                    paidDebts.toString(),
                    Icons.check_circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Vencidas',
                    overdueDebts.toString(),
                    Icons.warning,
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
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay deudas registradas',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Presiona el botón + para añadir una nueva deuda',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtsList(List<Debt> debts) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: debts.length,
      itemBuilder: (context, index) {
        final debt = debts[index];
        return _buildDebtCard(debt);
      },
    );
  }

  Widget _buildDebtCard(Debt debt) {
    // Obtener color según el estado
    Color statusColor;
    switch (debt.status) {
      case DebtStatus.pending:
        statusColor = Colors.orange;
        break;
      case DebtStatus.paid:
        statusColor = Colors.green;
        break;
      case DebtStatus.cancelled:
        statusColor = Colors.red;
        break;
      case DebtStatus.overdue:
        statusColor = Colors.red[700]!;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: InkWell(
        onTap: () => _showDebtDetails(debt),
        borderRadius: BorderRadius.circular(12),
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
                        debt.description,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        FormattingService.formatDate(debt.date),
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
                      FormattingService.formatCurrency(debt.amount),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      onSelected: (value) => _handleMenuAction(value, debt),
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
                          value: 'mark_paid',
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green),
                              SizedBox(width: 8),
                              Text('Marcar Pagada'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'mark_cancelled',
                          child: Row(
                            children: [
                              Icon(Icons.cancel, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Cancelar'),
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
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 30, // Altura mínima para mantener el diseño consistente
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        debt.status.displayName,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: statusColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      icon: Icons.person,
                      text: 'Deudor: ${debt.debtor}',
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      icon: Icons.swap_horiz,
                      text: 'Tipo: ${debt.debtType.displayName}',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
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
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  List<Debt> _filterDebts(List<Debt> debts) {
    return debts.where((debt) {
      // Filtro por búsqueda
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        if (!debt.description.toLowerCase().contains(query) &&
            !debt.debtor.toLowerCase().contains(query) &&
            !debt.creditor.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Filtro por estado
      if (_selectedStatus != null && _selectedStatus!.isNotEmpty) {
        if (debt.status.name != _selectedStatus) {
          return false;
        }
      }

      // Filtro por deudor
      if (_selectedDebtor != null && _selectedDebtor!.isNotEmpty) {
        if (debt.debtor != _selectedDebtor) {
          return false;
        }
      }

      // Filtro por acreedor
      if (_selectedCreditor != null && _selectedCreditor!.isNotEmpty) {
        if (debt.creditor != _selectedCreditor) {
          return false;
        }
      }

      // Filtro por rango de fechas
      if (_dateRange != null) {
        if (debt.date.isBefore(_dateRange!.start) ||
            debt.date.isAfter(_dateRange!.end)) {
          return false;
        }
      }

      return true;
    }).toList();
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

              // Filtro por estado
              DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: '',
                    child: Text('Todos los estados'),
                  ),
                  ...DebtStatus.values.map((status) => DropdownMenuItem(
                        value: status.name,
                        child: Text(status.displayName),
                      )),
                ],
                onChanged: (value) {
                  setState(() => _selectedStatus = value);
                },
              ),

              const SizedBox(height: 16),

              // Filtro por deudor
              FutureBuilder<List<String>>(
                future: _getUniqueDebtors(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return DropdownButtonFormField<String>(
                      initialValue: '',
                      decoration: InputDecoration(
                        labelText: 'Deudor',
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

                  final debtors = snapshot.data!;
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedDebtor,
                    decoration: const InputDecoration(
                      labelText: 'Deudor',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text('Todos los deudores'),
                      ),
                      ...debtors.map((debtor) => DropdownMenuItem(
                            value: debtor,
                            child: Text(debtor),
                          )),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedDebtor = value);
                    },
                  );
                },
              ),

              const SizedBox(height: 16),

              // Filtro por acreedor
              FutureBuilder<List<String>>(
                future: _getUniqueCreditors(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return DropdownButtonFormField<String>(
                      initialValue: '',
                      decoration: InputDecoration(
                        labelText: 'Acreedor',
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

                  final creditors = snapshot.data!;
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedCreditor,
                    decoration: const InputDecoration(
                      labelText: 'Acreedor',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text('Todos los acreedores'),
                      ),
                      ...creditors.map((creditor) => DropdownMenuItem(
                            value: creditor,
                            child: Text(creditor),
                          )),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedCreditor = value);
                    },
                  );
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
                'Buscar Deudas',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Buscar por descripción, deudor o acreedor...',
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

  Future<List<String>> _getUniqueDebtors() async {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final projectId = settingsProvider.activeProjectId;
    if (projectId == null) return [];

    try {
      final debts = await _debtService.getDebts();
      final debtors = debts
          .where((debt) => debt.projectId == projectId)
          .map((debt) => debt.debtor)
          .toSet()
          .toList();
      debtors.sort();
      return debtors;
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> _getUniqueCreditors() async {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final projectId = settingsProvider.activeProjectId;
    if (projectId == null) return [];

    try {
      final debts = await _debtService.getDebts();
      final creditors = debts
          .where((debt) => debt.projectId == projectId)
          .map((debt) => debt.creditor)
          .toSet()
          .toList();
      creditors.sort();
      return creditors;
    } catch (e) {
      return [];
    }
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
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedDebtor = null;
      _selectedCreditor = null;
      _dateRange = null;
      _searchController.clear();
    });
  }

  Future<void> _showAddDebtModal() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: const AddEditDebtModal(),
        );
      },
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
      }
    }
  }

  void _showDebtDetails(Debt debt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DebtDetailsModal(debt: debt);
      },
    );
  }

  void _handleMenuAction(String action, Debt debt) {
    switch (action) {
      case 'edit':
        _showEditDebtModal(debt);
        break;
      case 'mark_paid':
        _markDebtAsPaid(debt);
        break;
      case 'mark_cancelled':
        _markDebtAsCancelled(debt);
        break;
      case 'delete':
        _deleteDebt(debt);
        break;
    }
  }

  Future<void> _showEditDebtModal(Debt debt) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: AddEditDebtModal(debt: debt),
        );
      },
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
      }
    }
  }

  Future<void> _markDebtAsPaid(Debt debt) async {
    try {
      final debtProvider = Provider.of<DebtProvider>(context, listen: false);
      await debtProvider.markAsPaid(debt.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deuda "${debt.description}" marcada como pagada'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al marcar deuda como pagada: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markDebtAsCancelled(Debt debt) async {
    try {
      final debtProvider = Provider.of<DebtProvider>(context, listen: false);
      await debtProvider.markAsCancelled(debt.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deuda "${debt.description}" cancelada'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cancelar deuda: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deleteDebt(Debt debt) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Deuda'),
        content: Text('¿Estás seguro de que quieres eliminar la deuda "${debt.description}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Obtener el debtProvider fuera del contexto del callback asíncrono
              final debtProvider = Provider.of<DebtProvider>(context, listen: false);

              try {
                await debtProvider.deleteDebt(debt.id);
                if (mounted) {
                  Navigator.of(this.context).pop();
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(content: Text('Deuda "${debt.description}" eliminada')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(this.context).pop();
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      content: Text('Error al eliminar deuda: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}