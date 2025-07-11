import '../entities/envelope.dart';
import '../entities/category.dart';
import '../entities/transaction.dart' as domain;

abstract class BudgetRepository {
  // Envelope operations
  Future<List<Envelope>> getEnvelopes();
  Future<void> createEnvelope(Envelope envelope);
  Future<void> updateEnvelope(Envelope envelope);
  Future<void> deleteEnvelope(String envelopeId);
  
  // Category operations
  Future<List<Category>> getCategories();
  Future<void> createCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String categoryId);
  
  // Transaction operations
  Future<List<domain.Transaction>> getTransactions();
  Future<void> createTransaction(domain.Transaction transaction);
  Future<void> updateTransaction(domain.Transaction transaction);
  Future<void> deleteTransaction(String transactionId);
  
  // Stream for real-time updates
  Stream<List<Envelope>> watchEnvelopes();
  Stream<List<Category>> watchCategories();
  Stream<List<domain.Transaction>> watchTransactions();
}