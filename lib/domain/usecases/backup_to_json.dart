import '../repositories/budget_repository.dart';

class BackupToJson {
  final BudgetRepository repository;

  BackupToJson(this.repository);

  Future<void> call() {
    return repository.backupToJson();
  }
}
