import 'package:flutter_test/flutter_test.dart';
import 'package:argentveloppes/domain/entities/category.dart';

void main() {
  group('Category', () {
    test('should create a valid Category instance', () {
      const category = Category(id: '1', name: 'Alimentation');
      
      expect(category.id, '1');
      expect(category.name, 'Alimentation');
    });
    
    test('should maintain immutability', () {
      const category1 = Category(id: '1', name: 'Alimentation');
      const category2 = Category(id: '1', name: 'Alimentation');
      
      // Check that identical properties result in equal objects
      expect(category1, equals(category2));
    });
    
    test('should handle empty id', () {
      const category = Category(id: '', name: 'Nouvelle catégorie');
      
      expect(category.id, '');
      expect(category.name, 'Nouvelle catégorie');
    });
  });
}
