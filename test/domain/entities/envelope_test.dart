import 'package:flutter_test/flutter_test.dart';
import 'package:argentenveloppes/domain/entities/envelope.dart';

void main() {
  group('Envelope', () {
    test('copyWith returns a new instance with updated values', () {
      final envelope = Envelope(id: '1', name: 'Groceries', budget: 100, spent: 20, categoryId: 'cat1');
      final updated = envelope.copyWith(name: 'Bills', spent: 50);
      expect(updated.name, 'Bills');
      expect(updated.spent, 50);
      expect(updated.id, '1');
      expect(updated.categoryId, 'cat1');
    });

    test('remaining returns correct value', () {
      final envelope = Envelope(id: '1', name: 'Test', budget: 100, spent: 40);
      expect(envelope.remaining, 60);
    });

    test('consumptionPercentage returns correct value', () {
      final envelope = Envelope(id: '1', name: 'Test', budget: 200, spent: 50);
      expect(envelope.consumptionPercentage, closeTo(25, 0.01));
    });

    test('status returns correct EnvelopeStatus', () {
      final good = Envelope(id: '1', name: 'A', budget: 100, spent: 50);
      final warning = Envelope(id: '2', name: 'B', budget: 100, spent: 90);
      final exceeded = Envelope(id: '3', name: 'C', budget: 100, spent: 120);
      expect(good.status, EnvelopeStatus.good);
      expect(warning.status, EnvelopeStatus.warning);
      expect(exceeded.status, EnvelopeStatus.exceeded);
    });

    test('equality and hashCode', () {
      final a = Envelope(id: '1', name: 'A', budget: 10, spent: 2);
      final b = Envelope(id: '1', name: 'A', budget: 10, spent: 2);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('toString returns correct format', () {
      final envelope = Envelope(id: '1', name: 'Test', budget: 10, spent: 2);
      expect(envelope.toString(), contains('Envelope(id: 1, name: Test'));
    });
  });
}
