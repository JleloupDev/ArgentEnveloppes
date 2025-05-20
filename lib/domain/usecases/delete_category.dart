import '../repositories/budget_repository.dart';

class DeleteCategory {
  final BudgetRepository repository;

  DeleteCategory(this.repository);

  Future<void> call(String categoryId) {
    return repository.deleteCategory(categoryId);
  }
}
