import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/team_member_balance.dart';

class TeamBalanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference
  CollectionReference get _balancesCollection => _firestore.collection('team_balances');

  // Crear balances iniciales para todos los miembros de un proyecto
  Future<void> createInitialBalances(String projectId, List<String> memberEmails) async {
    try {
      final batch = _firestore.batch();

      for (String email in memberEmails) {
        // Verificar si ya existe un balance para este miembro
        final existingBalance = await _balancesCollection
            .where('projectId', isEqualTo: projectId)
            .where('email', isEqualTo: email)
            .get();

        if (existingBalance.docs.isEmpty) {
          final balanceData = TeamMemberBalance(
            id: '', // Se generará automáticamente
            userId: email,
            name: _getMemberNameFromEmail(email),
            email: email,
            balance: 0.0,
            role: 'Miembro',
            lastUpdated: DateTime.now(),
            projectId: projectId,
          );

          final docRef = _balancesCollection.doc();
          batch.set(docRef, balanceData.toJson()..['id'] = docRef.id);
        }
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Error al crear balances iniciales: $e');
    }
  }

  // Obtener todos los balances de un proyecto
  Future<List<TeamMemberBalance>> getTeamBalances(String projectId) async {
    try {
      final snapshot = await _balancesCollection
          .where('projectId', isEqualTo: projectId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>..['id'] = doc.id;
        return TeamMemberBalance.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener balances del equipo: $e');
    }
  }

  // Obtener balance de un miembro específico
  Future<TeamMemberBalance?> getMemberBalance(String projectId, String memberEmail) async {
    try {
      final snapshot = await _balancesCollection
          .where('projectId', isEqualTo: projectId)
          .where('email', isEqualTo: memberEmail)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      final data = snapshot.docs.first.data() as Map<String, dynamic>
        ..['id'] = snapshot.docs.first.id;
      return TeamMemberBalance.fromJson(data);
    } catch (e) {
      throw Exception('Error al obtener balance del miembro: $e');
    }
  }

  // Actualizar balance de un miembro
  Future<void> updateMemberBalance(String balanceId, double newBalance) async {
    try {
      await _balancesCollection.doc(balanceId).update({
        'balance': newBalance,
        'lastUpdated': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Error al actualizar balance: $e');
    }
  }

  // Crear o actualizar balance de un miembro
  Future<void> setMemberBalance(String projectId, String memberEmail, double balance, {String? name, String? role}) async {
    try {
      final existingBalance = await getMemberBalance(projectId, memberEmail);

      if (existingBalance != null) {
        // Actualizar balance existente
        await updateMemberBalance(existingBalance.id, balance);
      } else {
        // Crear nuevo balance
        final balanceData = TeamMemberBalance(
          id: '', // Se generará automáticamente
          userId: memberEmail,
          name: name ?? _getMemberNameFromEmail(memberEmail),
          email: memberEmail,
          balance: balance,
          role: role ?? 'Miembro',
          lastUpdated: DateTime.now(),
          projectId: projectId,
        );

        final docRef = _balancesCollection.doc();
        await docRef.set(balanceData.toJson()..['id'] = docRef.id);
      }
    } catch (e) {
      throw Exception('Error al establecer balance del miembro: $e');
    }
  }

  // Eliminar balance de un miembro
  Future<void> deleteMemberBalance(String balanceId) async {
    try {
      await _balancesCollection.doc(balanceId).delete();
    } catch (e) {
      throw Exception('Error al eliminar balance: $e');
    }
  }

  // Obtener balance total del equipo
   Future<double> getTotalTeamBalance(String projectId) async {
     try {
       final balances = await getTeamBalances(projectId);
       return balances.fold<double>(0.0, (double sum, balance) => sum + balance.balance.toDouble());
     } catch (e) {
       throw Exception('Error al calcular balance total: $e');
     }
   }

  // Escuchar cambios en balances del equipo en tiempo real
  Stream<List<TeamMemberBalance>> listenToTeamBalances(String projectId) {
    return _balancesCollection
        .where('projectId', isEqualTo: projectId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>..['id'] = doc.id;
        return TeamMemberBalance.fromJson(data);
      }).toList();
    });
  }

  // Método auxiliar para obtener nombre del miembro desde email
  String _getMemberNameFromEmail(String email) {
    // Intentar obtener nombre de la estructura del email
    final username = email.split('@').first;
    return username.replaceAll('.', ' ').replaceAll('-', ' ').toUpperCase();
  }

  // Validar si un miembro pertenece a un proyecto
  Future<bool> isMemberInProject(String projectId, String memberEmail) async {
    try {
      final snapshot = await _firestore
          .collection('projects')
          .where('id', isEqualTo: projectId)
          .where('members', arrayContains: memberEmail)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Error al validar miembro del proyecto: $e');
    }
  }

  // Obtener estadísticas del equipo
  Future<Map<String, dynamic>> getTeamBalanceStats(String projectId) async {
    try {
      final balances = await getTeamBalances(projectId);

      if (balances.isEmpty) {
        return {
          'totalBalance': 0.0,
          'memberCount': 0,
          'averageBalance': 0.0,
          'positiveBalances': 0,
          'negativeBalances': 0,
        };
      }

      final totalBalance = balances.fold<double>(0.0, (double sum, balance) => sum + balance.balance.toDouble());
       final positiveBalances = balances.where((balance) => balance.balance.toDouble() > 0).length;
       final negativeBalances = balances.where((balance) => balance.balance.toDouble() < 0).length;

      return {
        'totalBalance': totalBalance,
        'memberCount': balances.length,
        'averageBalance': totalBalance / balances.length,
        'positiveBalances': positiveBalances,
        'negativeBalances': negativeBalances,
      };
    } catch (e) {
      throw Exception('Error al obtener estadísticas: $e');
    }
  }
}