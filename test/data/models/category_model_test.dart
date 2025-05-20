import 'package:flutter_test/flutter_test.dart';
import 'package:argentveloppes/data/models/category_model.dart';
import 'package:argentveloppes/domain/entities/category.dart';

void main() {
  group('CategoryModel', () {
    test('should convert from domain entity to model', () {
      // Given
      const category = Category(id: '1', name: 'Alimentation');
      
      // When
      final model = CategoryModel.fromDomain(category);
      
      // Then
      expect(model.id, '1');
      expect(model.name, 'Alimentation');
    });

    test('should convert from model to domain entity', () {
      // Given
      final model = CategoryModel(id: '1', name: 'Alimentation');
      
      // When
      final category = model.toDomain();
      
      // Then
      expect(category.id, '1');
      expect(category.name, 'Alimentation');
    });

    test('should convert from json to model', () {
      // Given
      final json = {
        'id': '1',
        'name': 'Alimentation',
      };
      
      // When
      final model = CategoryModel.fromJson(json);
      
      // Then
      expect(model.id, '1');
      expect(model.name, 'Alimentation');
    });

    test('should convert from model to json', () {
      // Given
      final model = CategoryModel(id: '1', name: 'Alimentation');
      
      // When
      final json = model.toJson();
      
      // Then
      expect(json['id'], '1');
      expect(json['name'], 'Alimentation');
    });
  });
}
