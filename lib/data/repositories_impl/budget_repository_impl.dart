import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/envelope.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/local_storage_datasource.dart';
import '../models/category_model.dart';
import '../models/envelope_model.dart';
import '../models/transaction_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final LocalStorageDataSource _localDataSource;
  final Uuid _uuid = const Uuid();

  BudgetRepositoryImpl(this._localDataSource);

  @override
  Future<List<Envelope>> getAllEnvelopes() async {
    final envelopeModels = await _localDataSource.getEnvelopes();
    return envelopeModels.map((model) => model.toDomain()).toList();
  }

  @override
  Future<void> createEnvelope(Envelope envelope) async {
    final envelopeModels = await _localDataSource.getEnvelopes();
    
    // Generate a new ID if one doesn't exist
    final newEnvelope = envelope.id.isEmpty
        ? EnvelopeModel.fromDomain(Envelope(
            id: _uuid.v4(),
            name: envelope.name,
            budget: envelope.budget,
            spent: envelope.spent,
            categoryId: envelope.categoryId,
          ))
        : EnvelopeModel.fromDomain(envelope);
    
    envelopeModels.add(newEnvelope);
    await _localDataSource.saveEnvelopes(envelopeModels);
  }

  @override
  Future<void> deleteEnvelope(String envelopeId) async {
    // Delete the envelope
    final envelopeModels = await _localDataSource.getEnvelopes();
    final updatedEnvelopes = envelopeModels
        .where((envelope) => envelope.id != envelopeId)
        .toList();
    await _localDataSource.saveEnvelopes(updatedEnvelopes);
    
    // Delete all associated transactions
    final transactionModels = await _localDataSource.getTransactions();
    final updatedTransactions = transactionModels
        .where((transaction) => transaction.envelopeId != envelopeId)
        .toList();
    await _localDataSource.saveTransactions(updatedTransactions);
  }

  @override
  Future<List<Transaction>> getTransactionsByEnvelope(String envelopeId) async {
    final transactionModels = await _localDataSource.getTransactions();
    final filteredTransactions = transactionModels
        .where((transaction) => transaction.envelopeId == envelopeId)
        .toList();
    
    return filteredTransactions.map((model) => model.toDomain()).toList();
  }

  @override
  Future<void> addTransaction(Transaction transaction) async {
    // Add the transaction
    final transactionModels = await _localDataSource.getTransactions();
      final newTransaction = transaction.id.isEmpty
        ? TransactionModel.fromDomain(Transaction(
            id: _uuid.v4(),
            envelopeId: transaction.envelopeId,
            amount: transaction.amount,
            type: transaction.type,
            comment: transaction.comment,
            date: transaction.date,
          ))
        : TransactionModel.fromDomain(transaction);
    
    transactionModels.add(newTransaction);
    await _localDataSource.saveTransactions(transactionModels);
    
    // Update the envelope's spent amount
    final envelopeModels = await _localDataSource.getEnvelopes();
    final envelopeIndex = envelopeModels
        .indexWhere((envelope) => envelope.id == transaction.envelopeId);
    
    if (envelopeIndex != -1) {
      final envelope = envelopeModels[envelopeIndex];
      
      // Calculate the new spent amount
      double newSpent = envelope.spent;
      if (transaction.type == TransactionType.expense) {
        newSpent += transaction.amount;
      } else {
        newSpent -= transaction.amount;
        // Ensure we don't go negative
        if (newSpent < 0) newSpent = 0;
      }
      
      // Update the envelope
      final updatedEnvelope = EnvelopeModel(
        id: envelope.id,
        name: envelope.name,
        budget: envelope.budget,
        spent: newSpent,
        categoryId: envelope.categoryId,
      );
      
      envelopeModels[envelopeIndex] = updatedEnvelope;
      await _localDataSource.saveEnvelopes(envelopeModels);
    }
  }

  @override
  Future<List<Category>> getCategories() async {
    final categoryModels = await _localDataSource.getCategories();
    return categoryModels.map((model) => model.toDomain()).toList();
  }

  @override
  Future<void> createCategory(Category category) async {
    final categoryModels = await _localDataSource.getCategories();
    
    final newCategory = category.id.isEmpty
        ? CategoryModel.fromDomain(Category(
            id: _uuid.v4(),
            name: category.name,
          ))
        : CategoryModel.fromDomain(category);
    
    categoryModels.add(newCategory);
    await _localDataSource.saveCategories(categoryModels);
  }

  @override
  Future<void> exportAsCsv() async {
    final envelopes = await getAllEnvelopes();
    final transactions = await _getAllTransactions();
    final categories = await getCategories();
    
    // Create directory if it doesn't exist
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    
    // Export categories
    final categoryRows = [
      ['ID', 'Name'],
      ...categories.map((category) => [category.id, category.name]),
    ];
    final categoryFile = File('$path/argentveloppes_categories.csv');
    final categoryString = const ListToCsvConverter().convert(categoryRows);
    await categoryFile.writeAsString(categoryString);
    
    // Export envelopes
    final envelopeRows = [
      ['ID', 'Name', 'Budget', 'Spent', 'Category ID'],
      ...envelopes.map((envelope) => [
            envelope.id, 
            envelope.name, 
            envelope.budget.toString(), 
            envelope.spent.toString(), 
            envelope.categoryId ?? ''
          ]),
    ];
    final envelopeFile = File('$path/argentveloppes_envelopes.csv');
    final envelopeString = const ListToCsvConverter().convert(envelopeRows);
    await envelopeFile.writeAsString(envelopeString);
      // Export transactions
    final transactionRows = [
      ['ID', 'Envelope ID', 'Amount', 'Type', 'Comment', 'Date'],
      ...transactions.map((transaction) => [
            transaction.id,
            transaction.envelopeId,
            transaction.amount.toString(),
            transaction.type == TransactionType.expense ? 'expense' : 'income',
            transaction.comment ?? '',
            transaction.date.toIso8601String(),
          ]),
    ];
    final transactionFile = File('$path/argentveloppes_transactions.csv');
    final transactionString = const ListToCsvConverter().convert(transactionRows);
    await transactionFile.writeAsString(transactionString);
  }

  @override
  Future<void> importFromCsv(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('File does not exist', filePath);
    }
    
    final content = await file.readAsString();
    final List<List<dynamic>> rows = const CsvToListConverter().convert(content);
    
    if (rows.isEmpty) {
      return;
    }
    
    // First row is headers
    final headers = rows.first.map((e) => e.toString().toLowerCase()).toList();
    final dataRows = rows.skip(1).toList();
    
    // Determine file type based on headers
    if (headers.contains('category id') || 
        (headers.contains('budget') && headers.contains('spent'))) {
      await _importEnvelopes(headers, dataRows);
    } else if (headers.contains('envelope id') && headers.contains('type')) {
      await _importTransactions(headers, dataRows);
    } else if (headers.length == 2 && headers.contains('id') && headers.contains('name')) {
      await _importCategories(headers, dataRows);
    } else {
      throw Exception('Unknown CSV format');
    }
  }

  Future<void> _importEnvelopes(List<String> headers, List<List<dynamic>> rows) async {
    final existingEnvelopes = await _localDataSource.getEnvelopes();
    final Map<String, EnvelopeModel> envelopesMap = {
      for (var e in existingEnvelopes) e.id: e
    };
    
    final idIndex = headers.indexOf('id');
    final nameIndex = headers.indexOf('name');
    final budgetIndex = headers.indexOf('budget');
    final spentIndex = headers.indexOf('spent');
    final categoryIdIndex = headers.indexOf('category id');
    
    if (idIndex == -1 || nameIndex == -1 || budgetIndex == -1 || spentIndex == -1) {
      throw Exception('Invalid envelope CSV format');
    }
    
    for (final row in rows) {
      if (row.length <= [idIndex, nameIndex, budgetIndex, spentIndex].reduce((a, b) => a > b ? a : b)) {
        continue;
      }
      
      final id = row[idIndex].toString();
      final name = row[nameIndex].toString();
      final budget = double.tryParse(row[budgetIndex].toString()) ?? 0.0;
      final spent = double.tryParse(row[spentIndex].toString()) ?? 0.0;
      String? categoryId;
      
      if (categoryIdIndex != -1 && row.length > categoryIdIndex) {
        final catId = row[categoryIdIndex].toString();
        if (catId.isNotEmpty) {
          categoryId = catId;
        }
      }
      
      envelopesMap[id] = EnvelopeModel(
        id: id,
        name: name,
        budget: budget,
        spent: spent,
        categoryId: categoryId,
      );
    }
    
    await _localDataSource.saveEnvelopes(envelopesMap.values.toList());
  }

  Future<void> _importTransactions(List<String> headers, List<List<dynamic>> rows) async {
    final existingTransactions = await _localDataSource.getTransactions();
    final Map<String, TransactionModel> transactionsMap = {
      for (var t in existingTransactions) t.id: t
    };
    
    final idIndex = headers.indexOf('id');
    final envelopeIdIndex = headers.indexOf('envelope id');
    final amountIndex = headers.indexOf('amount');
    final typeIndex = headers.indexOf('type');
    final descriptionIndex = headers.indexOf('description');
    final dateIndex = headers.indexOf('date');
    
    if (idIndex == -1 || envelopeIdIndex == -1 || amountIndex == -1 || 
        typeIndex == -1 || descriptionIndex == -1 || dateIndex == -1) {
      throw Exception('Invalid transaction CSV format');
    }
    
    for (final row in rows) {
      if (row.length <= [idIndex, envelopeIdIndex, amountIndex, typeIndex, 
          descriptionIndex, dateIndex].reduce((a, b) => a > b ? a : b)) {
        continue;
      }
      
      final id = row[idIndex].toString();
      final envelopeId = row[envelopeIdIndex].toString();
      final amount = double.tryParse(row[amountIndex].toString()) ?? 0.0;
      final typeStr = row[typeIndex].toString().toLowerCase();
      final description = row[descriptionIndex].toString();
      
      DateTime date;
      try {
        date = DateTime.parse(row[dateIndex].toString());
      } catch (e) {
        date = DateTime.now();
      }
        transactionsMap[id] = TransactionModel(
        id: id,
        envelopeId: envelopeId,
        amount: amount,
        type: typeStr == 'expense' ? 'expense' : 'income',
        comment: description, // CSV import uses description as comment
        date: date,
      );
    }
    
    await _localDataSource.saveTransactions(transactionsMap.values.toList());
    
    // Update envelope spent amounts based on transactions
    await _recalculateEnvelopeSpending();
  }

  Future<void> _importCategories(List<String> headers, List<List<dynamic>> rows) async {
    final existingCategories = await _localDataSource.getCategories();
    final Map<String, CategoryModel> categoriesMap = {
      for (var c in existingCategories) c.id: c
    };
    
    final idIndex = headers.indexOf('id');
    final nameIndex = headers.indexOf('name');
    
    if (idIndex == -1 || nameIndex == -1) {
      throw Exception('Invalid category CSV format');
    }
    
    for (final row in rows) {
      if (row.length <= (idIndex > nameIndex ? idIndex : nameIndex)) {
        continue;
      }
      
      final id = row[idIndex].toString();
      final name = row[nameIndex].toString();
      
      categoriesMap[id] = CategoryModel(
        id: id,
        name: name,
      );
    }
    
    await _localDataSource.saveCategories(categoriesMap.values.toList());
  }

  Future<void> _recalculateEnvelopeSpending() async {
    final envelopes = await _localDataSource.getEnvelopes();
    final transactions = await _localDataSource.getTransactions();
    
    // Group transactions by envelope ID
    final Map<String, List<TransactionModel>> transactionsByEnvelope = {};
    for (final transaction in transactions) {
      if (!transactionsByEnvelope.containsKey(transaction.envelopeId)) {
        transactionsByEnvelope[transaction.envelopeId] = [];
      }
      transactionsByEnvelope[transaction.envelopeId]!.add(transaction);
    }
    
    // Recalculate spent amount for each envelope
    final updatedEnvelopes = <EnvelopeModel>[];
    for (final envelope in envelopes) {
      double spent = 0.0;
      
      if (transactionsByEnvelope.containsKey(envelope.id)) {
        for (final transaction in transactionsByEnvelope[envelope.id]!) {
          if (transaction.type == 'expense') {
            spent += transaction.amount;
          } else {
            spent -= transaction.amount;
          }
        }
      }
      
      // Ensure spent doesn't go below zero
      if (spent < 0) spent = 0;
      
      updatedEnvelopes.add(EnvelopeModel(
        id: envelope.id,
        name: envelope.name,
        budget: envelope.budget,
        spent: spent,
        categoryId: envelope.categoryId,
      ));
    }
    
    await _localDataSource.saveEnvelopes(updatedEnvelopes);
  }

  @override
  Future<void> backupToJson() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final now = DateTime.now();
    final timestamp = '${now.year}-${now.month}-${now.day}_${now.hour}-${now.minute}-${now.second}';
    final backupFile = File('$path/argentveloppes_backup_$timestamp.json');
    
    // Get all data
    final envelopes = await _localDataSource.getEnvelopes();
    final transactions = await _localDataSource.getTransactions();
    final categories = await _localDataSource.getCategories();
    
    // Create backup object
    final backupData = {
      'timestamp': now.toIso8601String(),
      'envelopes': envelopes.map((e) => e.toJson()).toList(),
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'categories': categories.map((c) => c.toJson()).toList(),
    };
    
    // Write to file
    await backupFile.writeAsString(jsonEncode(backupData));
  }

  @override
  Future<void> restoreFromJson(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('Backup file does not exist', filePath);
    }
    
    final String content = await file.readAsString();
    final Map<String, dynamic> backupData = jsonDecode(content);
    
    // Clear existing data
    await _localDataSource.clearAllData();
    
    // Restore categories
    final List<dynamic> categoriesJson = backupData['categories'] as List<dynamic>? ?? [];
    final categories = categoriesJson
        .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
        .toList();
    await _localDataSource.saveCategories(categories);
    
    // Restore envelopes
    final List<dynamic> envelopesJson = backupData['envelopes'] as List<dynamic>? ?? [];
    final envelopes = envelopesJson
        .map((json) => EnvelopeModel.fromJson(json as Map<String, dynamic>))
        .toList();
    await _localDataSource.saveEnvelopes(envelopes);
    
    // Restore transactions
    final List<dynamic> transactionsJson = backupData['transactions'] as List<dynamic>? ?? [];
    final transactions = transactionsJson
        .map((json) => TransactionModel.fromJson(json as Map<String, dynamic>))
        .toList();
    await _localDataSource.saveTransactions(transactions);
    
    // Recalculate envelope spending to ensure consistency
    await _recalculateEnvelopeSpending();
  }
  
  // Helper method to get all transactions
  Future<List<Transaction>> _getAllTransactions() async {
    final transactionModels = await _localDataSource.getTransactions();
    return transactionModels.map((model) => model.toDomain()).toList();
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    final categoryModels = await _localDataSource.getCategories();
    final updatedCategories = categoryModels
        .where((category) => category.id != categoryId)
        .toList();
    
    await _localDataSource.saveCategories(updatedCategories);
    
    // Mettre à jour les enveloppes associées à cette catégorie
    // On les déplace vers "sans catégorie" (categoryId = null)
    final envelopeModels = await _localDataSource.getEnvelopes();
    bool hasUpdates = false;
    
    for (int i = 0; i < envelopeModels.length; i++) {
      if (envelopeModels[i].categoryId == categoryId) {
        envelopeModels[i] = EnvelopeModel(
          id: envelopeModels[i].id,
          name: envelopeModels[i].name,
          budget: envelopeModels[i].budget,
          spent: envelopeModels[i].spent,
          categoryId: null, // Mettre à "sans catégorie"
        );
        hasUpdates = true;
      }
    }
    
    if (hasUpdates) {
      await _localDataSource.saveEnvelopes(envelopeModels);
    }
  }

  @override
  Future<void> clearAllData() async {
    await _localDataSource.clearAllData();
  }
}
