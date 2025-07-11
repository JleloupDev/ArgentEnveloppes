import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/envelope.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/transaction.dart' as domain;
import '../../domain/repositories/budget_repository.dart';
import '../datasources/firestore_data_source.dart';
import '../models/envelope_model.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final FirestoreDataSource _dataSource;

  BudgetRepositoryImpl({FirestoreDataSource? dataSource})
      : _dataSource = dataSource ?? FirestoreDataSourceImpl();
  // Envelope operations
  @override
  Future<List<Envelope>> getEnvelopes() async {
    final envelopeModels = await _dataSource.getEnvelopes();
    return envelopeModels.map((model) => model.toDomain()).toList();
  }

  @override
  Future<void> createEnvelope(Envelope envelope) async {
    final model = EnvelopeModel.fromDomain(envelope);
    await _dataSource.createEnvelope(model);
  }

  @override
  Future<void> updateEnvelope(Envelope envelope) async {
    final model = EnvelopeModel.fromDomain(envelope);
    await _dataSource.updateEnvelope(model);
  }

  @override
  Future<void> deleteEnvelope(String envelopeId) async {
    await _dataSource.deleteEnvelope(envelopeId);
  }

  // Category operations
  @override
  Future<List<Category>> getCategories() async {
    final categoryModels = await _dataSource.getCategories();
    return categoryModels.map((model) => model.toDomain()).toList();
  }

  @override
  Future<void> createCategory(Category category) async {
    final model = CategoryModel.fromDomain(category);
    await _dataSource.createCategory(model);
  }

  @override
  Future<void> updateCategory(Category category) async {
    final model = CategoryModel.fromDomain(category);
    await _dataSource.updateCategory(model);
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    await _dataSource.deleteCategory(categoryId);
  }

  // Transaction operations
  @override
  Future<List<domain.Transaction>> getTransactions() async {
    final transactionModels = await _dataSource.getTransactions();
    return transactionModels.map((model) => model.toDomain()).toList();
  }

  @override
  Future<void> createTransaction(domain.Transaction transaction) async {
    final model = TransactionModel.fromDomain(transaction);
    await _dataSource.createTransaction(model);
  }

  @override
  Future<void> updateTransaction(domain.Transaction transaction) async {
    final model = TransactionModel.fromDomain(transaction);
    await _dataSource.updateTransaction(model);
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    await _dataSource.deleteTransaction(transactionId);
  }
  // Stream methods for real-time updates
  @override
  Stream<List<Envelope>> watchEnvelopes() {
    // Implementation using Firestore snapshots for real-time updates
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_getCurrentUserId())
        .collection('envelopes')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EnvelopeModel.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }).toDomain())
            .toList());
  }

  @override
  Stream<List<Category>> watchCategories() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_getCurrentUserId())
        .collection('categories')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CategoryModel.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }).toDomain())
            .toList());
  }

  @override
  Stream<List<domain.Transaction>> watchTransactions() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_getCurrentUserId())
        .collection('transactions')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }).toDomain())
            .toList());
  }

  String _getCurrentUserId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }
}