import 'dart:math';
import 'package:flutter/material.dart';

/// Génère des couleurs aléatoires pastel qui sont visuellement agréables
class ColorGenerator {
  static final Random _random = Random();
  static final List<Color> _predefinedColors = [
    const Color(0xFFB5EAD7), // Menthe
    const Color(0xFFC7CEEA), // Lavande
    const Color(0xFFFFDACB), // Pêche
    const Color(0xFFE2F0CB), // Citron
    const Color(0xFFFFC0CB), // Rose
    const Color(0xFFFFE3C8), // Abricot
    const Color(0xFFD7EAFD), // Ciel
    const Color(0xFFE0BBE4), // Lilas
    const Color(0xFFF5DDDA), // Corail
    const Color(0xFFFEDDC6), // Sable
  ];

  /// Renvoie une couleur aléatoire prédéfinie pour une catégorie
  static Color getColorForId(String id) {
    // Utiliser l'id comme seed pour obtenir une couleur cohérente pour le même id
    final seed = id.codeUnits.fold<int>(0, (prev, codeUnit) => prev + codeUnit);
    final random = Random(seed);
    return _predefinedColors[random.nextInt(_predefinedColors.length)];
  }

  /// Renvoie une nouvelle couleur pastel aléatoire
  static Color getRandomColor() {
    return _predefinedColors[_random.nextInt(_predefinedColors.length)];
  }
}
