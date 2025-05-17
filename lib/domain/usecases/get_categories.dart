import '../entities/category.dart';
import '../repositories/budget_repository.dart';

class GetCategories {
  final BudgetRepository repository;

  GetCategories(this.repository);

  Future<List<Category>> call() {
    return repository.getCategories();
  }
}