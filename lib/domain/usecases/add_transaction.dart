import '../entities/transaction.dart';
import '../repositories/budget_repository.dart';

class AddTransaction {
  final BudgetRepository repository;

  AddTransaction(this.repository);

  Future<void> call(Transaction transaction) {
    return repository.addTransaction(transaction);
  }
}
