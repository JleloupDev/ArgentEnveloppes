import 'package:flutter_test/flutter_test.dart';
import 'package:argentenveloppes/domain/entities/category.dart';

void main() {
  group('Category', () {
    test('copyWith returns a new instance with updated values', () {
      final category = Category(id: '1', name: 'Food');
      final updated = category.copyWith(name: 'Transport');
      expect(updated.id, '1');
      expect(updated.name, 'Transport');
    });

    test('equality and hashCode', () {
      final a = Category(id: '1', name: 'A');
      final b = Category(id: '1', name: 'A');
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('toString returns correct format', () {
      final category = Category(id: '1', name: 'Test');
      expect(category.toString(), 'Category(id: 1, name: Test)');
    });
  });
}
