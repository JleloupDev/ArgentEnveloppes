import '../repositories/budget_repository.dart';

class ExportCsv {
  final BudgetRepository repository;

  ExportCsv(this.repository);

  Future<void> call() {
    return repository.exportAsCsv();
  }
}
