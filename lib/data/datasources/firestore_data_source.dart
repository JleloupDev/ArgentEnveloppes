import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/envelope_model.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';

abstract class FirestoreDataSource {
  Future<List<EnvelopeModel>> getEnvelopes();
  Future<void> createEnvelope(EnvelopeModel envelope);
  Future<void> updateEnvelope(EnvelopeModel envelope);
  Future<void> deleteEnvelope(String envelopeId);
  
  Future<List<CategoryModel>> getCategories();
  Future<void> createCategory(CategoryModel category);
  Future<void> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String categoryId);
  
  Future<List<TransactionModel>> getTransactions();
  Future<void> createTransaction(TransactionModel transaction);
  Future<void> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String transactionId);
}

class FirestoreDataSourceImpl implements FirestoreDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestoreDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _userId {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }

  // Collection references with user isolation
  CollectionReference get _envelopesCollection =>
      _firestore.collection('users').doc(_userId).collection('envelopes');
  
  CollectionReference get _categoriesCollection =>
      _firestore.collection('users').doc(_userId).collection('categories');
  
  CollectionReference get _transactionsCollection =>
      _firestore.collection('users').doc(_userId).collection('transactions');

  // Envelope methods
  @override
  Future<List<EnvelopeModel>> getEnvelopes() async {
    try {
      final querySnapshot = await _envelopesCollection.get();
      return querySnapshot.docs
          .map((doc) => EnvelopeModel.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to get envelopes: $e');
    }
  }

  @override
  Future<void> createEnvelope(EnvelopeModel envelope) async {
    try {
      final data = envelope.toJson();
      data.remove('id'); // Remove id as Firestore will generate it
      await _envelopesCollection.add(data);
    } catch (e) {
      throw Exception('Failed to create envelope: $e');
    }
  }

  @override
  Future<void> updateEnvelope(EnvelopeModel envelope) async {
    try {
      final data = envelope.toJson();
      data.remove('id');
      await _envelopesCollection.doc(envelope.id).update(data);
    } catch (e) {
      throw Exception('Failed to update envelope: $e');
    }
  }

  @override
  Future<void> deleteEnvelope(String envelopeId) async {
    try {
      await _envelopesCollection.doc(envelopeId).delete();
    } catch (e) {
      throw Exception('Failed to delete envelope: $e');
    }
  }

  // Category methods
  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final querySnapshot = await _categoriesCollection.get();
      return querySnapshot.docs
          .map((doc) => CategoryModel.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  @override
  Future<void> createCategory(CategoryModel category) async {
    try {
      final data = category.toJson();
      data.remove('id');
      await _categoriesCollection.add(data);
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    try {
      final data = category.toJson();
      data.remove('id');
      await _categoriesCollection.doc(category.id).update(data);
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _categoriesCollection.doc(categoryId).delete();
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  // Transaction methods
  @override
  Future<List<TransactionModel>> getTransactions() async {
    try {
      final querySnapshot = await _transactionsCollection.get();
      return querySnapshot.docs
          .map((doc) => TransactionModel.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to get transactions: $e');
    }
  }

  @override
  Future<void> createTransaction(TransactionModel transaction) async {
    try {
      final data = transaction.toJson();
      data.remove('id');
      await _transactionsCollection.add(data);
    } catch (e) {
      throw Exception('Failed to create transaction: $e');
    }
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      final data = transaction.toJson();
      data.remove('id');
      await _transactionsCollection.doc(transaction.id).update(data);
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _transactionsCollection.doc(transactionId).delete();
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }
}
