import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/envelope.dart';

// Provider pour la liste des enveloppes
final envelopesProvider = StateNotifierProvider<EnvelopesNotifier, List<Envelope>>((ref) {
  return EnvelopesNotifier();
});

class EnvelopesNotifier extends StateNotifier<List<Envelope>> {
  EnvelopesNotifier() : super([
    // Enveloppes par défaut pour la démo
    Envelope(
      id: '1',
      name: 'Courses',
      budget: 200.0,
      spent: 150.0,
      categoryId: '1',
    ),
    Envelope(
      id: '2',
      name: 'Essence',
      budget: 200.0,
      spent: 180.0,
      categoryId: '2',
    ),
    Envelope(
      id: '3',
      name: 'Restaurants',
      budget: 200.0,
      spent: 250.0,
      categoryId: '1',
    ),
  ]);

  void addEnvelope(Envelope envelope) {
    state = [...state, envelope];
  }

  void updateEnvelope(Envelope updatedEnvelope) {
    state = [
      for (final envelope in state)
        if (envelope.id == updatedEnvelope.id) updatedEnvelope else envelope,
    ];
  }

  void deleteEnvelope(String envelopeId) {
    state = state.where((envelope) => envelope.id != envelopeId).toList();
  }

  void addTransaction(String envelopeId, double amount, bool isExpense) {
    state = [
      for (final envelope in state)
        if (envelope.id == envelopeId)
          envelope.copyWith(
            spent: isExpense 
              ? envelope.spent + amount 
              : envelope.spent - amount,
          )
        else envelope,
    ];
  }
}

// Provider pour les statistiques du budget
final budgetStatsProvider = Provider<BudgetStats>((ref) {
  final envelopes = ref.watch(envelopesProvider);
  
  final totalBudget = envelopes.fold<double>(0, (sum, envelope) => sum + envelope.budget);
  final totalSpent = envelopes.fold<double>(0, (sum, envelope) => sum + envelope.spent);
  final totalRemaining = totalBudget - totalSpent;
  
  return BudgetStats(
    totalBudget: totalBudget,
    totalSpent: totalSpent,
    totalRemaining: totalRemaining,
  );
});

class BudgetStats {
  final double totalBudget;
  final double totalSpent;
  final double totalRemaining;

  BudgetStats({
    required this.totalBudget,
    required this.totalSpent,
    required this.totalRemaining,
  });
}
