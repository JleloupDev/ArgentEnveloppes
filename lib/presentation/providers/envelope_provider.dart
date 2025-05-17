import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/envelope.dart';

/// State notifier pour gérer l'état des enveloppes
class EnvelopeNotifier extends StateNotifier<List<Envelope>> {
  EnvelopeNotifier() : super([]);

  void setEnvelopes(List<Envelope> envelopes) {
    state = envelopes;
  }

  void addEnvelope(Envelope envelope) {
    state = [...state, envelope];
  }

  void removeEnvelope(String id) {
    state = state.where((envelope) => envelope.id != id).toList();
  }

  void updateEnvelope(Envelope updatedEnvelope) {
    state = state.map((envelope) => 
      envelope.id == updatedEnvelope.id ? updatedEnvelope : envelope
    ).toList();
  }

  /// Retourne les enveloppes filtrées par catégorie
  List<Envelope> getByCategory(String categoryId) {
    return state.where((envelope) => envelope.categoryId == categoryId).toList();
  }

  /// Retourne le total du budget pour toutes les enveloppes
  double get totalBudget => 
    state.fold<double>(0, (sum, envelope) => sum + envelope.budget);

  /// Retourne le total des dépenses pour toutes les enveloppes
  double get totalSpent => 
    state.fold<double>(0, (sum, envelope) => sum + envelope.spent);
    
  /// Retourne le budget restant total
  double get totalRemaining => totalBudget - totalSpent;
}

/// Provider pour les enveloppes
final envelopeProvider = StateNotifierProvider<EnvelopeNotifier, List<Envelope>>(
  (ref) => EnvelopeNotifier(),
);
