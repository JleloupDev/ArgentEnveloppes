import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

/// Classe utilitaire pour les fonctions communes
class AppUtils {
  /// Formatte un montant avec le symbole €
  static String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(amount);
  }
  
  /// Formatte un pourcentage
  static String formatPercentage(double percentage) {
    return NumberFormat.percentPattern('fr_FR').format(percentage);
  }
  
  /// Formatte une date
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
  
  /// Formatte une date avec l'heure
  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
  
  /// Génère un nouvel UUID
  static String generateUuid() {
    return const Uuid().v4();
  }
}
