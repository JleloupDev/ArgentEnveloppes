import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category.dart';

// Provider pour la liste des catégories
final categoriesProvider = StateNotifierProvider<CategoriesNotifier, List<Category>>((ref) {
  return CategoriesNotifier();
});

class CategoriesNotifier extends StateNotifier<List<Category>> {
  CategoriesNotifier() : super([
    // Catégories par défaut pour la démo
    Category(id: '1', name: 'Alimentation'),
    Category(id: '2', name: 'Transport'),
    Category(id: '3', name: 'Loisirs'),
  ]);

  void addCategory(Category category) {
    state = [...state, category];
  }

  void updateCategory(Category updatedCategory) {
    state = [
      for (final category in state)
        if (category.id == updatedCategory.id) updatedCategory else category,
    ];
  }

  void deleteCategory(String categoryId) {
    state = state.where((category) => category.id != categoryId).toList();
  }
}
