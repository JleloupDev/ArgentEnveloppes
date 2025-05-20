import 'package:flutter/material.dart';

/// Couleurs de l'application
abstract class AppColors {
  // Couleurs primaires
  static const Color primary = Color(0xFF4CAF50);
  static const Color primaryLight = Color(0xFFA5D6A7);
  static const Color primaryDark = Color(0xFF388E3C);
  
  // Couleurs secondaires
  static const Color secondary = Color(0xFF2196F3);
  static const Color secondaryLight = Color(0xFF90CAF9);
  static const Color secondaryDark = Color(0xFF1976D2);
  
  // Couleurs sémantiques
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Couleurs neutres
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF9E9E9E);
}

/// Valeurs de dimensions
abstract class AppSizes {
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 16.0;
  static const double l = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  
  static const double borderRadius = 8.0;
  static const double buttonHeight = 48.0;
  static const double cardElevation = 2.0;
}

/// Clés de stockage
abstract class StorageKeys {
  static const String envelopes = 'envelopes';
  static const String transactions = 'transactions';
  static const String categories = 'categories';
}
