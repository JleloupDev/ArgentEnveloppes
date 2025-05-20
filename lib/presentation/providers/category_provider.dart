import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category.dart';
import '../providers/usecase_provider.dart';

// Provider pour obtenir les catégories via un use case
final categoriesProvider = FutureProvider<List<Category>>((ref) {
  final getCategoriesUseCase = ref.watch(getCategoriesUseCaseProvider);
  return getCategoriesUseCase();
});

// StateNotifierProvider pour maintenir l'état des catégories
final categoryProvider = StateNotifierProvider<CategoryNotifier, List<Category>>((ref) {
  final notifier = CategoryNotifier();
  
  // Observer les changements de catégories depuis le repository
  ref.listen(categoriesProvider, (previous, next) {
    next.whenData((categories) {
      notifier.setCategories(categories);
    });
  });
  
  return notifier;
});

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