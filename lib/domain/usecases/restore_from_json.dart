import '../repositories/budget_repository.dart';

class RestoreFromJson {
  final BudgetRepository repository;

  RestoreFromJson(this.repository);

  Future<void> call(String filePath) {
    return repository.restoreFromJson(filePath);
  }
}
