import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/envelope.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/transaction.dart' as domain;
import '../../domain/repositories/budget_repository.dart';
import '../../data/repositories_impl/budget_repository_impl.dart';
import '../../data/datasources/firestore_data_source.dart';

// Provider for the budget repository
final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepositoryImpl(dataSource: FirestoreDataSourceImpl());
});

// Provider for envelopes using Firestore
final envelopesProvider = StreamProvider<List<Envelope>>((ref) {
  final repository = ref.watch(budgetRepositoryProvider);
  return repository.watchEnvelopes();
});

// Provider for categories using Firestore  
final categoriesProvider = StreamProvider<List<Category>>((ref) {
  final repository = ref.watch(budgetRepositoryProvider);
  return repository.watchCategories();
});

// Provider for transactions using Firestore
final transactionsProvider = StreamProvider<List<domain.Transaction>>((ref) {
  final repository = ref.watch(budgetRepositoryProvider);
  return repository.watchTransactions();
});

// Provider for budget statistics
final budgetStatsProvider = Provider<AsyncValue<BudgetStats>>((ref) {
  final envelopesAsync = ref.watch(envelopesProvider);
  
  return envelopesAsync.when(
    data: (envelopes) {
      final totalBudget = envelopes.fold<double>(0, (sum, envelope) => sum + envelope.budget);
      final totalSpent = envelopes.fold<double>(0, (sum, envelope) => sum + envelope.spent);
      final totalRemaining = totalBudget - totalSpent;
      
      return AsyncValue.data(BudgetStats(
        totalBudget: totalBudget,
        totalSpent: totalSpent,
        totalRemaining: totalRemaining,
      ));
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Notifier for envelope operations
final envelopeNotifierProvider = Provider<EnvelopeNotifier>((ref) {
  final repository = ref.watch(budgetRepositoryProvider);
  return EnvelopeNotifier(repository);
});

class EnvelopeNotifier {
  final BudgetRepository _repository;

  EnvelopeNotifier(this._repository);

  Future<void> createEnvelope(Envelope envelope) async {
    await _repository.createEnvelope(envelope);
  }

  Future<void> updateEnvelope(Envelope envelope) async {
    await _repository.updateEnvelope(envelope);
  }

  Future<void> deleteEnvelope(String envelopeId) async {
    await _repository.deleteEnvelope(envelopeId);
  }

  Future<void> addTransaction(String envelopeId, double amount, bool isExpense) async {
    // Get current envelopes to find the one to update
    final envelopes = await _repository.getEnvelopes();
    final envelope = envelopes.firstWhere((e) => e.id == envelopeId);
    
    // Update the envelope's spent amount
    final updatedEnvelope = envelope.copyWith(
      spent: isExpense 
        ? envelope.spent + amount 
        : envelope.spent - amount,
    );
    
    await _repository.updateEnvelope(updatedEnvelope);
  }
}

// Notifier for category operations
final categoryNotifierProvider = Provider<CategoryNotifier>((ref) {
  final repository = ref.watch(budgetRepositoryProvider);
  return CategoryNotifier(repository);
});

class CategoryNotifier {
  final BudgetRepository _repository;

  CategoryNotifier(this._repository);

  Future<void> createCategory(Category category) async {
    await _repository.createCategory(category);
  }

  Future<void> updateCategory(Category category) async {
    await _repository.updateCategory(category);
  }

  Future<void> deleteCategory(String categoryId) async {
    await _repository.deleteCategory(categoryId);
  }
}

// Notifier for transaction operations
final transactionNotifierProvider = Provider<TransactionNotifier>((ref) {
  final repository = ref.watch(budgetRepositoryProvider);
  return TransactionNotifier(repository);
});

class TransactionNotifier {
  final BudgetRepository _repository;

  TransactionNotifier(this._repository);

  Future<void> createTransaction(domain.Transaction transaction) async {
    await _repository.createTransaction(transaction);
  }

  Future<void> updateTransaction(domain.Transaction transaction) async {
    await _repository.updateTransaction(transaction);
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _repository.deleteTransaction(transactionId);
  }
}

class BudgetStats {
  final double totalBudget;
  final double totalSpent;
  final double totalRemaining;

  BudgetStats({
    required this.totalBudget,
    required this.totalSpent,
    required this.totalRemaining,
  });
}
