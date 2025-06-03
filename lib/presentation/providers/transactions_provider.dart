import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/transaction.dart';

// Provider pour la liste des transactions
final transactionsProvider = StateNotifierProvider<TransactionsNotifier, List<Transaction>>((ref) {
  return TransactionsNotifier();
});

class TransactionsNotifier extends StateNotifier<List<Transaction>> {
  TransactionsNotifier() : super([
    // Transactions par défaut pour la démo
    Transaction(
      id: '1',
      envelopeId: '1',
      amount: 50.0,
      type: TransactionType.expense,
      comment: 'Courses supermarché',
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Transaction(
      id: '2',
      envelopeId: '1',
      amount: 100.0,
      type: TransactionType.expense,
      comment: 'Courses hebdomadaires',
      date: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Transaction(
      id: '3',
      envelopeId: '2',
      amount: 60.0,
      type: TransactionType.expense,
      comment: 'Plein d\'essence',
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ]);

  void addTransaction(Transaction transaction) {
    state = [...state, transaction];
  }

  void updateTransaction(Transaction updatedTransaction) {
    state = [
      for (final transaction in state)
        if (transaction.id == updatedTransaction.id) updatedTransaction else transaction,
    ];
  }

  void deleteTransaction(String transactionId) {
    state = state.where((transaction) => transaction.id != transactionId).toList();
  }

  List<Transaction> getTransactionsForEnvelope(String envelopeId) {
    return state.where((transaction) => transaction.envelopeId == envelopeId).toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Tri par date décroissante
  }
}
