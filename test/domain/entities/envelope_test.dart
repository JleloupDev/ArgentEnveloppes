import 'package:flutter_test/flutter_test.dart';
import 'package:argentveloppes/domain/entities/envelope.dart';

void main() {
  group('Envelope', () {
    test('should create a valid Envelope instance', () {
      const envelope = Envelope(
        id: '1', 
        name: 'Courses', 
        budget: 500.0,
        spent: 300.0,
        categoryId: 'cat1'
      );
      
      expect(envelope.id, '1');
      expect(envelope.name, 'Courses');
      expect(envelope.budget, 500.0);
      expect(envelope.spent, 300.0);
      expect(envelope.categoryId, 'cat1');
    });

    test('should calculate remaining budget correctly', () {
      const envelope = Envelope(
        id: '1', 
        name: 'Courses', 
        budget: 500.0,
        spent: 300.0,
      );
      
      expect(envelope.remaining, 200.0);
    });

    test('should calculate percentage used correctly', () {
      const envelope = Envelope(
        id: '1', 
        name: 'Courses', 
        budget: 500.0,
        spent: 250.0,
      );
      
      expect(envelope.percentUsed, 0.5);
    });

    test('should identify overspent envelopes', () {
      const normalEnvelope = Envelope(
        id: '1', 
        name: 'Courses', 
        budget: 500.0,
        spent: 499.9,
      );
      
      const overspentEnvelope = Envelope(
        id: '2', 
        name: 'Restaurants', 
        budget: 200.0,
        spent: 250.0,
      );
      
      expect(normalEnvelope.isOverspent, false);
      expect(overspentEnvelope.isOverspent, true);
    });

    test('should identify envelopes near limit', () {
      const safeEnvelope = Envelope(
        id: '1', 
        name: 'Courses', 
        budget: 500.0,
        spent: 350.0, // 70%
      );
      
      const nearLimitEnvelope = Envelope(
        id: '2', 
        name: 'Restaurants', 
        budget: 200.0,
        spent: 180.0, // 90%
      );
      
      const overLimitEnvelope = Envelope(
        id: '3', 
        name: 'Cinéma', 
        budget: 100.0,
        spent: 120.0, // 120%
      );
      
      expect(safeEnvelope.isNearLimit, false);
      expect(nearLimitEnvelope.isNearLimit, true);
      expect(overLimitEnvelope.isNearLimit, false); // Already over
    });
  });
}
