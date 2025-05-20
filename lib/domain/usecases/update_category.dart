import '../entities/category.dart';
import '../repositories/budget_repository.dart';

class UpdateCategory {
  final BudgetRepository repository;

  UpdateCategory(this.repository);

  Future<void> call(Category category) async {
    // Récupère les catégories existantes
    final categories = await repository.getCategories();
    
    // Vérifie si la catégorie existe
    final existingIndex = categories.indexWhere((c) => c.id == category.id);
    if (existingIndex == -1) {
      throw Exception('Catégorie non trouvée');
    }
    
    // Supprime l'ancienne catégorie
    await repository.deleteCategory(category.id);
    
    // Ajoute la mise à jour
    await repository.createCategory(category);
  }
}
