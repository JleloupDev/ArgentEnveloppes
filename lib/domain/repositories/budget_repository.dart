import '../entities/category.dart';
import '../entities/envelope.dart';
import '../entities/transaction.dart';

abstract class BudgetRepository {
  Future<List<Envelope>> getAllEnvelopes();
  Future<void> createEnvelope(Envelope envelope);
  Future<void> deleteEnvelope(String envelopeId);

  Future<List<Transaction>> getTransactionsByEnvelope(String envelopeId);
  Future<void> addTransaction(Transaction transaction);
  Future<List<Category>> getCategories();
  Future<void> createCategory(Category category);
  Future<void> deleteCategory(String categoryId);

  Future<void> exportAsCsv();
  Future<void> importFromCsv(String filePath);

  Future<void> backupToJson();
  Future<void> restoreFromJson(String filePath);
  
  /// Supprime toutes les données du stockage local
  Future<void> clearAllData();
}
