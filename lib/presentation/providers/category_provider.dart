import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category.dart';

/// State notifier pour gérer l'état des catégories
class CategoryNotifier extends StateNotifier<List<Category>> {
  CategoryNotifier() : super([]);

  void setCategories(List<Category> categories) {
    state = categories;
  }

  void addCategory(Category category) {
    state = [...state, category];
  }

  void removeCategory(String id) {
    state = state.where((category) => category.id != id).toList();
  }

  void updateCategory(Category updatedCategory) {
    state = state.map((category) => 
      category.id == updatedCategory.id ? updatedCategory : category
    ).toList();
  }
}

/// Provider pour les catégories
final categoryProvider = StateNotifierProvider<CategoryNotifier, List<Category>>(
  (ref) => CategoryNotifier(),
);
