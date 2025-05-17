import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/create_category.dart';
import '../../domain/usecases/create_envelope.dart';
import '../../domain/usecases/add_transaction.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/update_category.dart';
import '../../domain/usecases/delete_category.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../data/repositories_impl/budget_repository_impl.dart';
import '../../data/datasources/local_storage_datasource.dart';

// Provider pour la source de données
final localStorageDataSourceProvider = Provider<LocalStorageDataSource>((ref) {
  return LocalStorageDataSource();
});

// Provider pour l'implémentation du repository
final budgetRepositoryImplProvider = Provider<BudgetRepository>((ref) {
  final dataSource = ref.watch(localStorageDataSourceProvider);
  return BudgetRepositoryImpl(dataSource);
});

// Provider pour accéder au repository
final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  // Implémentation du repository à injecter
  return ref.watch(budgetRepositoryImplProvider);
});

// Providers pour les use cases
final createCategoryUseCaseProvider = Provider<CreateCategory>((ref) {
  return CreateCategory(ref.watch(budgetRepositoryProvider));
});

final getCategoriesUseCaseProvider = Provider<GetCategories>((ref) {
  return GetCategories(ref.watch(budgetRepositoryProvider));
});

final createEnvelopeUseCaseProvider = Provider<CreateEnvelope>((ref) {
  return CreateEnvelope(ref.watch(budgetRepositoryProvider));
});

final addTransactionUseCaseProvider = Provider<AddTransaction>((ref) {
  return AddTransaction(ref.watch(budgetRepositoryProvider));
});

final updateCategoryUseCaseProvider = Provider<UpdateCategory>((ref) {
  return UpdateCategory(ref.watch(budgetRepositoryProvider));
});

final deleteCategoryUseCaseProvider = Provider<DeleteCategory>((ref) {
  return DeleteCategory(ref.watch(budgetRepositoryProvider));
});