import 'package:flutter/material.dart';

/// Couleurs du thème bleu pour le tableau de bord
abstract class BlueTheme {
  // Couleurs primaires bleues
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryDark = Color(0xFF1976D2);
  
  // Couleurs d'accentuation
  static const Color accent = Color(0xFF03A9F4);
  static const Color accentLight = Color(0xFF4FC3F7);
  
  // Couleurs sémantiques
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Couleurs de fond et de texte
  static const Color background = Color(0xFFE3F2FD);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color appBarBackground = Color(0xFF1976D2);
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFFFFFFFF);
  
  // Couleurs des dégradés
  static const LinearGradient blueGradient = LinearGradient(
    colors: [primaryDark, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Styles de texte
  static const TextStyle titleStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: textLight,
  );
  
  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: primaryDark,
  );
  
  // Styles des boutons
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: textLight,
  );
  
  static ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryLight,
    foregroundColor: textDark,
  );
  
  // Décoration de boîte avec une ombre subtile
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );
}
