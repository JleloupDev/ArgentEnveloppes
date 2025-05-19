import 'package:flutter_test/flutter_test.dart';
import 'package:argentveloppes/domain/entities/transaction.dart';

void main() {
  group('Transaction', () {
    final now = DateTime.now();
    
    test('should create a valid expense Transaction instance', () {
      final transaction = Transaction(
        id: '1', 
        envelopeId: 'env1', 
        amount: 50.0,
        type: TransactionType.expense,
        comment: 'Courses au supermarché',
        date: now,
      );
      
      expect(transaction.id, '1');
      expect(transaction.envelopeId, 'env1');
      expect(transaction.amount, 50.0);
      expect(transaction.type, TransactionType.expense);
      expect(transaction.comment, 'Courses au supermarché');
      expect(transaction.date, now);
    });

    test('should create a valid income Transaction instance', () {
      final transaction = Transaction(
        id: '2', 
        envelopeId: 'env1', 
        amount: 100.0,
        type: TransactionType.income,
        comment: 'Remboursement',
        date: now,
      );
      
      expect(transaction.type, TransactionType.income);
    });

    test('should calculate signed amount correctly for expense', () {
      final expenseTransaction = Transaction(
        id: '1', 
        envelopeId: 'env1', 
        amount: 50.0,
        type: TransactionType.expense,
        date: now,
      );
      
      expect(expenseTransaction.signedAmount, -50.0);
    });

    test('should calculate signed amount correctly for income', () {
      final incomeTransaction = Transaction(
        id: '2', 
        envelopeId: 'env1', 
        amount: 100.0,
        type: TransactionType.income,
        date: now,
      );
      
      expect(incomeTransaction.signedAmount, 100.0);
    });

    test('should handle null comment field', () {
      final transaction = Transaction(
        id: '1', 
        envelopeId: 'env1', 
        amount: 50.0,
        type: TransactionType.expense,
        comment: null,
        date: now,
      );
      
      expect(transaction.comment, null);
    });
  });
}
