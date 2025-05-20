import 'package:flutter_test/flutter_test.dart';
import 'package:argentveloppes/core/utils/app_utils.dart';

void main() {
  group('AppUtils', () {
    test('formatCurrency should format amount correctly', () {
      // Act
      final result1 = AppUtils.formatCurrency(1234.56);
      final result2 = AppUtils.formatCurrency(42);
      final result3 = AppUtils.formatCurrency(0);
      final result4 = AppUtils.formatCurrency(999999.99);
        // Assert
      // Vérifions que le résultat contient les chiffres et le symbole € correctement
      expect(result1.contains('1'), true);
      expect(result1.contains('234,56'), true);
      expect(result1.contains('€'), true);
      
      expect(result2.contains('42,00'), true);
      expect(result2.contains('€'), true);
      
      expect(result3.contains('0,00'), true);
      expect(result3.contains('€'), true);
      
      expect(result4.contains('999'), true);
      expect(result4.contains('999,99'), true);
      expect(result4.contains('€'), true);
    });
    
    test('formatDate should format date correctly', () {
      // Arrange
      final date1 = DateTime(2023, 5, 15);
      final date2 = DateTime(2023, 12, 25);
      
      // Act
      final result1 = AppUtils.formatDate(date1);
      final result2 = AppUtils.formatDate(date2);
      
      // Assert
      expect(result1, '15/05/2023');
      expect(result2, '25/12/2023');
    });
  });
}
