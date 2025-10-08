import 'package:flutter/foundation.dart';
import '../services/team_balance_service.dart';
import '../models/team_member_balance.dart';
import '../providers/settings_provider.dart';

class TeamBalanceProvider with ChangeNotifier {
  final TeamBalanceService _teamBalanceService = TeamBalanceService();
  final SettingsProvider? _settingsProvider;

  List<TeamMemberBalance> _teamBalances = [];
  bool _isLoading = false;
  String? _error;
  Stream<List<TeamMemberBalance>>? _balancesStream;

  TeamBalanceProvider(this._settingsProvider) {
    _settingsProvider?.addListener(_onProjectChanged);
    // Cargar datos iniciales después de un pequeño delay para evitar conflictos de construcción
    Future.delayed(Duration.zero, () {
      if (_settingsProvider?.activeProjectId != null) {
        loadTeamBalances();
      }
    });
  }

  // Getters
  List<TeamMemberBalance> get teamBalances => _teamBalances;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Obtener balances del proyecto actual
  Future<void> loadTeamBalances() async {
    final projectId = _settingsProvider?.activeProjectId;
    if (projectId == null || projectId.isEmpty) {
      _error = 'No hay proyecto seleccionado';
      notifyListeners();
      return;
    }

    // Evitar múltiples llamadas simultáneas
    if (_isLoading) return;

    _setLoading(true);
    try {
      _teamBalances = await _teamBalanceService.getTeamBalances(projectId);
      _error = null;
      _setupBalancesStream(projectId);
    } catch (e) {
      _error = 'Error al cargar balances del equipo: $e';
      _teamBalances = [];
    } finally {
      _setLoading(false);
    }
  }

  // Configurar stream para escuchar cambios en tiempo real
  void _setupBalancesStream(String projectId) {
    _balancesStream?.drain();
    _balancesStream = _teamBalanceService.listenToTeamBalances(projectId);
    _balancesStream?.listen((balances) {
      _teamBalances = balances;
      notifyListeners();
    });
  }

  // Actualizar balance de un miembro
  Future<void> updateMemberBalance(String balanceId, double newBalance) async {
    try {
      await _teamBalanceService.updateMemberBalance(balanceId, newBalance);
      // Los cambios se reflejarán automáticamente a través del stream
    } catch (e) {
      _error = 'Error al actualizar balance: $e';
      notifyListeners();
    }
  }

  // Crear o actualizar balance de un miembro
  Future<void> setMemberBalance(String memberEmail, double balance, {String? name, String? role}) async {
    final projectId = _settingsProvider?.activeProjectId;
    if (projectId == null) {
      _error = 'No hay proyecto seleccionado';
      notifyListeners();
      return;
    }

    try {
      await _teamBalanceService.setMemberBalance(projectId, memberEmail, balance, name: name, role: role);
      // Los cambios se reflejarán automáticamente a través del stream
    } catch (e) {
      _error = 'Error al establecer balance del miembro: $e';
      notifyListeners();
    }
  }

  // Obtener estadísticas del equipo
  Future<Map<String, dynamic>> getTeamBalanceStats() async {
    final projectId = _settingsProvider?.activeProjectId;
    if (projectId == null) {
      return {
        'totalBalance': 0.0,
        'memberCount': 0,
        'averageBalance': 0.0,
        'positiveBalances': 0,
        'negativeBalances': 0,
      };
    }

    try {
      return await _teamBalanceService.getTeamBalanceStats(projectId);
    } catch (e) {
      _error = 'Error al obtener estadísticas: $e';
      notifyListeners();
      return {
        'totalBalance': 0.0,
        'memberCount': 0,
        'averageBalance': 0.0,
        'positiveBalances': 0,
        'negativeBalances': 0,
      };
    }
  }

  // Callback cuando cambia el proyecto activo
  void _onProjectChanged() {
    final projectId = _settingsProvider?.activeProjectId;
    if (projectId != null && projectId.isNotEmpty) {
      loadTeamBalances();
    } else {
      _teamBalances = [];
      _balancesStream?.drain();
      notifyListeners();
    }
  }

  // Método para limpiar recursos
  @override
  void dispose() {
    _settingsProvider?.removeListener(_onProjectChanged);
    _balancesStream?.drain();
    super.dispose();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}