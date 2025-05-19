import 'package:flutter_test/flutter_test.dart';
import 'package:argentveloppes/data/models/transaction_model.dart';
import 'package:argentveloppes/domain/entities/transaction.dart';

void main() {
  group('TransactionModel', () {
    final now = DateTime.now();
    final testDate = DateTime(now.year, now.month, now.day); // Remove milliseconds for comparison

    test('should convert from domain entity to model for expense transaction', () {
      // Given
      final transaction = Transaction(
        id: '1',
        envelopeId: 'env1',
        amount: 50.0,
        type: TransactionType.expense,
        comment: 'Courses au supermarché',
        date: testDate,
      );
      
      // When
      final model = TransactionModel.fromDomain(transaction);
      
      // Then
      expect(model.id, '1');
      expect(model.envelopeId, 'env1');
      expect(model.amount, 50.0);
      expect(model.type, 'expense');
      expect(model.comment, 'Courses au supermarché');
      expect(model.date, testDate);
    });

    test('should convert from domain entity to model for income transaction', () {
      // Given
      final transaction = Transaction(
        id: '2',
        envelopeId: 'env1',
        amount: 100.0,
        type: TransactionType.income,
        comment: 'Remboursement',
        date: testDate,
      );
      
      // When
      final model = TransactionModel.fromDomain(transaction);
      
      // Then
      expect(model.id, '2');
      expect(model.envelopeId, 'env1');
      expect(model.amount, 100.0);
      expect(model.type, 'income');
    });

    test('should convert from model to domain entity for expense', () {
      // Given
      final model = TransactionModel(
        id: '1',
        envelopeId: 'env1',
        amount: 50.0,
        type: 'expense',
        comment: 'Courses au supermarché',
        date: testDate,
      );
      
      // When
      final transaction = model.toDomain();
      
      // Then
      expect(transaction.id, '1');
      expect(transaction.envelopeId, 'env1');
      expect(transaction.amount, 50.0);
      expect(transaction.type, TransactionType.expense);
      expect(transaction.comment, 'Courses au supermarché');
      expect(transaction.date, testDate);
      
      // Check computed property
      expect(transaction.signedAmount, -50.0);
    });

    test('should convert from model to domain entity for income', () {
      // Given
      final model = TransactionModel(
        id: '2',
        envelopeId: 'env1',
        amount: 100.0,
        type: 'income',
        comment: 'Remboursement',
        date: testDate,
      );
      
      // When
      final transaction = model.toDomain();
      
      // Then
      expect(transaction.id, '2');
      expect(transaction.type, TransactionType.income);
      
      // Check computed property
      expect(transaction.signedAmount, 100.0);
    });

    test('should convert from json to model', () {
      // Given
      final json = {
        'id': '1',
        'envelopeId': 'env1',
        'amount': 50.0,
        'type': 'expense',
        'comment': 'Courses au supermarché',
        'date': testDate.toIso8601String(),
      };
      
      // When
      final model = TransactionModel.fromJson(json);
      
      // Then
      expect(model.id, '1');
      expect(model.envelopeId, 'env1');
      expect(model.amount, 50.0);
      expect(model.type, 'expense');
      expect(model.comment, 'Courses au supermarché');
      expect(model.date.year, testDate.year);
      expect(model.date.month, testDate.month);
      expect(model.date.day, testDate.day);
    });

    test('should convert from model to json', () {
      // Given
      final model = TransactionModel(
        id: '1',
        envelopeId: 'env1',
        amount: 50.0,
        type: 'expense',
        comment: 'Courses au supermarché',
        date: testDate,
      );
      
      // When
      final json = model.toJson();
      
      // Then
      expect(json['id'], '1');
      expect(json['envelopeId'], 'env1');
      expect(json['amount'], 50.0);
      expect(json['type'], 'expense');
      expect(json['comment'], 'Courses au supermarché');
      expect(json['date'], testDate.toIso8601String());
    });
    
    test('should handle null comment field', () {
      // Given
      final model = TransactionModel(
        id: '1',
        envelopeId: 'env1',
        amount: 50.0,
        type: 'expense',
        comment: null,
        date: testDate,
      );
      
      // When
      final json = model.toJson();
      final transaction = model.toDomain();
      
      // Then
      expect(json['comment'], null);
      expect(transaction.comment, null);
    });
  });
}
