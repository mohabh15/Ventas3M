import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/widgets/gradient_app_bar.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/loading_widget.dart';
import '../../models/team_member_balance.dart';
import '../../models/project.dart';
import '../../providers/settings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firebase_service.dart';

class TeamBalanceScreen extends StatefulWidget {
  const TeamBalanceScreen({super.key});

  @override
  State<TeamBalanceScreen> createState() => _TeamBalanceScreenState();
}

class _TeamBalanceScreenState extends State<TeamBalanceScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<TeamMemberBalance> _teamBalances = [];
  List<String> _projectMembers = [];
  Project? _currentProject;
  bool _isLoading = true;
  String? _errorMessage;
  late SettingsProvider _settingsProvider;
  late AuthProvider _authProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();

    // Diferir la carga inicial hasta después del build para evitar setState() durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTeamBalances();

      // Escuchar cambios en el proyecto activo
      _settingsProvider.addListener(_onProjectChanged);
    });
  }

  @override
  void dispose() {
    _settingsProvider.removeListener(_onProjectChanged);
    super.dispose();
  }

  void _onProjectChanged() {
    _loadTeamBalances();
  }

  Future<void> _loadTeamBalances() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final projectId = _settingsProvider.activeProjectId;

      if (projectId == null) {
        setState(() {
          _errorMessage = 'No hay proyecto activo seleccionado';
          _isLoading = false;
        });
        return;
      }

      // Obtener información del proyecto
      final projects = await _firebaseService.getProjects();
      _currentProject = projects.firstWhere((project) => project.id == projectId);

      if (_currentProject == null) {
        setState(() {
          _errorMessage = 'Proyecto no encontrado';
          _isLoading = false;
        });
        return;
      }

      _projectMembers = _currentProject!.members;

      // Obtener balances del equipo desde Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('team_balances')
          .where('projectId', isEqualTo: projectId)
          .get();

      final balances = snapshot.docs.map((doc) {
        final data = doc.data()..['id'] = doc.id;
        return TeamMemberBalance.fromJson(data);
      }).toList();

      // Si no hay balances registrados, crear entradas iniciales para cada miembro
      if (balances.isEmpty && _projectMembers.isNotEmpty) {
        await _createInitialBalances();
      } else {
        setState(() {
          _teamBalances = balances;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar balances del equipo: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _createInitialBalances() async {
    try {
      final currentUser = _authProvider.currentUser;

      if (currentUser == null || _currentProject == null) return;

      final batch = FirebaseFirestore.instance.batch();
      final balancesRef = FirebaseFirestore.instance.collection('team_balances');

      for (String email in _projectMembers) {
        // Crear balance inicial para cada miembro
        final balanceData = TeamMemberBalance(
          id: '', // Se generará automáticamente
          userId: email,
          name: _getMemberName(email),
          email: email,
          balance: 0.0,
          role: _getMemberRole(email),
          lastUpdated: DateTime.now(),
          projectId: _currentProject!.id,
        );

        final docRef = balancesRef.doc();
        batch.set(docRef, balanceData.toJson()..['id'] = docRef.id);
      }

      await batch.commit();

      // Recargar balances después de crearlos
      await _loadTeamBalances();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al crear balances iniciales: $e';
        _isLoading = false;
      });
    }
  }

  String _getMemberName(String email) {
    // Si es el usuario actual, usar su nombre real
    final currentUser = _authProvider.currentUser;

    if (currentUser != null && currentUser.email == email) {
      return currentUser.name;
    }

    // Para otros miembros, intentar obtener nombre de la estructura del email
    // o usar el email como nombre temporal
    return email.split('@').first.replaceAll('.', ' ').toUpperCase();
  }

  String _getMemberRole(String email) {
    // Si es el usuario actual, intentar determinar su rol
    final currentUser = _authProvider.currentUser;

    if (currentUser != null && currentUser.email == email) {
      // Aquí podrías implementar lógica para determinar el rol del usuario
      return 'Miembro';
    }

    return 'Miembro';
  }

  Future<void> _updateMemberBalance(String balanceId, double newBalance) async {
    try {
      if (mounted) {
        setState(() {
          final index = _teamBalances.indexWhere((balance) => balance.id == balanceId);
          if (index != -1) {
            _teamBalances[index] = _teamBalances[index].copyWith(
              balance: newBalance,
              lastUpdated: DateTime.now(),
            );
          }
        });
      }

      // Actualizar en Firestore
      await FirebaseFirestore.instance.collection('team_balances').doc(balanceId).update({
        'balance': newBalance,
        'lastUpdated': DateTime.now(),
      });
    } catch (e) {
      // Recargar datos en caso de error
      await _loadTeamBalances();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar balance: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: 'Balance del Equipo',
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _errorMessage != null
              ? _buildErrorWidget()
              : _buildTeamBalanceList(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              text: 'Reintentar',
              onPressed: _loadTeamBalances,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamBalanceList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen total
          _buildTotalBalanceCard(),

          const SizedBox(height: 24),

          // Lista de miembros
          Text(
            'Miembros del Equipo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).textTheme.titleLarge?.color
                  : Colors.black87,
            ),
          ),

          const SizedBox(height: 16),

          ..._teamBalances.map((balance) => _buildMemberBalanceCard(balance)),
        ],
      ),
    );
  }

  Widget _buildTotalBalanceCard() {
     final totalBalance = _teamBalances.fold<double>(0.0, (accumulator, balance) => accumulator + balance.balance.toDouble());

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0D47A1),
            Color(0xFF1976D2),
            Color(0xFF42A5F5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Balance Total del Equipo',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '\$${totalBalance.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${_teamBalances.length} miembros',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberBalanceCard(TeamMemberBalance balance) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _getAvatarColor(balance.email),
            child: Text(
              balance.name[0].toUpperCase(),
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  balance.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).textTheme.titleMedium?.color
                        : Colors.black87,
                  ),
                ),
                Text(
                  balance.role,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).textTheme.bodySmall?.color
                        : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${balance.balance.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: balance.balance.toDouble() >= 0
                      ? Colors.green
                      : Colors.red,
                ),
              ),
              Text(
                'Última actualización: ${_formatDate(balance.lastUpdated)}',
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).textTheme.bodySmall?.color
                      : Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () => _showEditBalanceDialog(balance),
            icon: Icon(Icons.edit, size: 20),
            tooltip: 'Editar balance',
          ),
        ],
      ),
    );
  }

  Color _getAvatarColor(String email) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
    ];

    final index = email.hashCode % colors.length;
    return colors[index];
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'Hoy';
    if (difference == 1) return 'Ayer';
    if (difference < 7) return 'Hace $difference días';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _showEditBalanceDialog(TeamMemberBalance balance) async {
    final TextEditingController controller = TextEditingController(
      text: balance.balance.toStringAsFixed(2),
    );

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Balance - ${balance.name}'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Monto',
              prefixText: '\$',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Guardar'),
              onPressed: () {
                final newBalance = double.tryParse(controller.text) ?? balance.balance;
                _updateMemberBalance(balance.id, newBalance);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}