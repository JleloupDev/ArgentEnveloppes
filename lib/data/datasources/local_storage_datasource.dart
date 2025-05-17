import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category_model.dart';
import '../models/envelope_model.dart';
import '../models/transaction_model.dart';

class LocalStorageDataSource {
  static const String _envelopesKey = 'envelopes';
  static const String _transactionsKey = 'transactions';
  static const String _categoriesKey = 'categories';

  // Get all envelopes from local storage
  Future<List<EnvelopeModel>> getEnvelopes() async {
    final prefs = await SharedPreferences.getInstance();
    final envelopesJson = prefs.getStringList(_envelopesKey) ?? [];
    
    return envelopesJson
        .map((json) => EnvelopeModel.fromJson(jsonDecode(json)))
        .toList();
  }

  // Save all envelopes to local storage
  Future<void> saveEnvelopes(List<EnvelopeModel> envelopes) async {
    final prefs = await SharedPreferences.getInstance();
    final envelopesJson = envelopes
        .map((envelope) => jsonEncode(envelope.toJson()))
        .toList();
    
    await prefs.setStringList(_envelopesKey, envelopesJson);
  }

  // Get all transactions from local storage
  Future<List<TransactionModel>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = prefs.getStringList(_transactionsKey) ?? [];
    
    return transactionsJson
        .map((json) => TransactionModel.fromJson(jsonDecode(json)))
        .toList();
  }

  // Save all transactions to local storage
  Future<void> saveTransactions(List<TransactionModel> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = transactions
        .map((transaction) => jsonEncode(transaction.toJson()))
        .toList();
    
    await prefs.setStringList(_transactionsKey, transactionsJson);
  }

  // Get all categories from local storage
  Future<List<CategoryModel>> getCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = prefs.getStringList(_categoriesKey) ?? [];
    
    return categoriesJson
        .map((json) => CategoryModel.fromJson(jsonDecode(json)))
        .toList();
  }

  // Save all categories to local storage
  Future<void> saveCategories(List<CategoryModel> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = categories
        .map((category) => jsonEncode(category.toJson()))
        .toList();
    
    await prefs.setStringList(_categoriesKey, categoriesJson);
  }

  // Clear all data from local storage
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_envelopesKey);
    await prefs.remove(_transactionsKey);
    await prefs.remove(_categoriesKey);
  }
}
