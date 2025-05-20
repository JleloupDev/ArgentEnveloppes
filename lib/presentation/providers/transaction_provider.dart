import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/transaction.dart';

/// State notifier pour gérer l'état des transactions
class TransactionNotifier extends StateNotifier<List<Transaction>> {
  TransactionNotifier() : super([]);

  void setTransactions(List<Transaction> transactions) {
    state = transactions;
  }

  void addTransaction(Transaction transaction) {
    state = [...state, transaction];
  }

  void removeTransaction(String id) {
    state = state.where((transaction) => transaction.id != id).toList();
  }

  /// Retourne les transactions filtrées par enveloppe
  List<Transaction> getByEnvelope(String envelopeId) {
    return state.where((transaction) => transaction.envelopeId == envelopeId)
      .toList();
  }
}

/// Provider pour les transactions
final transactionProvider = StateNotifierProvider<TransactionNotifier, List<Transaction>>(
  (ref) => TransactionNotifier(),
);
