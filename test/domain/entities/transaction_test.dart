import 'package:flutter_test/flutter_test.dart';
import 'package:argentenveloppes/domain/entities/transaction.dart';

void main() {
  group('Transaction', () {
    test('copyWith returns a new instance with updated values', () {
      final t = Transaction(
        id: '1',
        envelopeId: 'env1',
        amount: 50.0,
        type: TransactionType.expense,
        comment: 'test',
        date: DateTime(2024, 1, 1),
      );
      final updated = t.copyWith(amount: 100.0, comment: 'updated');
      expect(updated.amount, 100.0);
      expect(updated.comment, 'updated');
      expect(updated.id, '1');
    });

    test('equality and hashCode', () {
      final a = Transaction(
        id: '1',
        envelopeId: 'env1',
        amount: 10.0,
        type: TransactionType.income,
        date: DateTime(2024, 1, 1),
      );
      final b = Transaction(
        id: '1',
        envelopeId: 'env1',
        amount: 10.0,
        type: TransactionType.income,
        date: DateTime(2024, 1, 1),
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('toString returns correct format', () {
      final t = Transaction(
        id: '1',
        envelopeId: 'env1',
        amount: 10.0,
        type: TransactionType.expense,
        date: DateTime(2024, 1, 1),
      );
      expect(t.toString(), contains('Transaction(id: 1, envelopeId: env1'));
    });
  });
}
