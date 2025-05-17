import '../entities/transaction.dart';
import '../repositories/budget_repository.dart';

class GetTransactions {
  final BudgetRepository repository;

  GetTransactions(this.repository);

  Future<List<Transaction>> call(String envelopeId) {
    return repository.getTransactionsByEnvelope(envelopeId);
  }
}
