import '../entities/category.dart';
import '../repositories/budget_repository.dart';

class CreateCategory {
  final BudgetRepository repository;

  CreateCategory(this.repository);

  Future<void> call(Category category) {
    return repository.createCategory(category);
  }
}
