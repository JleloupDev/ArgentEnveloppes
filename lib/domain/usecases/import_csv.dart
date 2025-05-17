import '../repositories/budget_repository.dart';

class ImportCsv {
  final BudgetRepository repository;

  ImportCsv(this.repository);

  Future<void> call(String filePath) {
    return repository.importFromCsv(filePath);
  }
}
