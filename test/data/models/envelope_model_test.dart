import 'package:flutter_test/flutter_test.dart';
import 'package:argentveloppes/data/models/envelope_model.dart';
import 'package:argentveloppes/domain/entities/envelope.dart';

void main() {
  group('EnvelopeModel', () {
    test('should convert from domain entity to model', () {
      // Given
      const envelope = Envelope(
        id: '1',
        name: 'Courses',
        budget: 500.0,
        spent: 300.0,
        categoryId: 'cat1',
      );
      
      // When
      final model = EnvelopeModel.fromDomain(envelope);
      
      // Then
      expect(model.id, '1');
      expect(model.name, 'Courses');
      expect(model.budget, 500.0);
      expect(model.spent, 300.0);
      expect(model.categoryId, 'cat1');
    });

    test('should convert from model to domain entity', () {
      // Given
      final model = EnvelopeModel(
        id: '1',
        name: 'Courses',
        budget: 500.0,
        spent: 300.0,
        categoryId: 'cat1',
      );
      
      // When
      final envelope = model.toDomain();
      
      // Then
      expect(envelope.id, '1');
      expect(envelope.name, 'Courses');
      expect(envelope.budget, 500.0);
      expect(envelope.spent, 300.0);
      expect(envelope.categoryId, 'cat1');
      
      // Also test computed properties are correctly derived
      expect(envelope.remaining, 200.0);
      expect(envelope.percentUsed, 0.6);
      expect(envelope.isOverspent, false);
    });

    test('should convert from json to model', () {
      // Given
      final json = {
        'id': '1',
        'name': 'Courses',
        'budget': 500.0,
        'spent': 300.0,
        'categoryId': 'cat1',
      };
      
      // When
      final model = EnvelopeModel.fromJson(json);
      
      // Then
      expect(model.id, '1');
      expect(model.name, 'Courses');
      expect(model.budget, 500.0);
      expect(model.spent, 300.0);
      expect(model.categoryId, 'cat1');
    });

    test('should convert from model to json', () {
      // Given
      final model = EnvelopeModel(
        id: '1',
        name: 'Courses',
        budget: 500.0,
        spent: 300.0,
        categoryId: 'cat1',
      );
      
      // When
      final json = model.toJson();
      
      // Then
      expect(json['id'], '1');
      expect(json['name'], 'Courses');
      expect(json['budget'], 500.0);
      expect(json['spent'], 300.0);
      expect(json['categoryId'], 'cat1');
    });
    
    test('should handle null categoryId', () {
      // Given
      const envelope = Envelope(
        id: '1',
        name: 'Courses',
        budget: 500.0,
        spent: 300.0,
        categoryId: null,
      );
      
      // When
      final model = EnvelopeModel.fromDomain(envelope);
      final json = model.toJson();
      
      // Then
      expect(model.categoryId, null);
      expect(json['categoryId'], null);
    });
  });
}
