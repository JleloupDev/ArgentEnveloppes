import 'package:flutter/material.dart';
import '../pages/dashboard_page.dart';
import '../pages/category_management_page.dart';
import '../pages/envelope_detail_page.dart';
import '../pages/add_transaction_page.dart';

/// Classe pour gérer la navigation web
class AppRouter {  /// Routes principales de l'application
  static const String dashboard = '/';
  static const String categories = '/categories';
  static const String envelopes = '/envelopes';
  static const String envelopeDetail = '/envelope';
  static const String addTransaction = '/transaction/add';
  
  /// Génère les routes pour la navigation
  static Map<String, Widget Function(BuildContext)> getRoutes() {
    return {
      dashboard: (context) => const DashboardPage(),
      categories: (context) => const CategoryManagementPage(),
      // La page envelope sera gérée par onGenerateRoute car elle a besoin d'un paramètre
    };
  }
    /// Gère la génération dynamique des routes avec des paramètres
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // Support pour l'ancienne et la nouvelle façon de naviguer vers les détails d'une enveloppe
    if (settings.name?.startsWith(envelopeDetail) == true) {
      // Extraire l'ID de l'enveloppe de l'URL dans le cas d'un URI
      final uri = Uri.parse(settings.name!);
      final envelopeId = uri.queryParameters['id'] ?? '';
      
      // Si l'ID est vide, vérifier si l'ID est passé comme argument
      final id = envelopeId.isNotEmpty ? envelopeId : settings.arguments as String? ?? '';
      
      return MaterialPageRoute(
        builder: (context) => EnvelopeDetailPage(envelopeId: id),
      );
    }
    
    // Support pour le chemin '/envelope-detail' (pour la compatibilité)
    if (settings.name == '/envelope-detail') {
      final String envelopeId = settings.arguments as String? ?? '';
      
      return MaterialPageRoute(
        builder: (context) => EnvelopeDetailPage(envelopeId: envelopeId),
      );
    }
    
    // Route pour l'ajout de transaction
    if (settings.name?.startsWith('/transaction/add') == true) {
      final uri = Uri.parse(settings.name!);
      final envelopeId = uri.queryParameters['envelopeId'] ?? '';
      
      // Si l'ID est vide, vérifier si l'ID est passé comme argument
      final id = envelopeId.isNotEmpty ? envelopeId : settings.arguments as String? ?? '';
      
      return MaterialPageRoute(
        builder: (context) => AddTransactionPage(envelopeId: id),
      );
    }
    
    // Route par défaut si rien ne correspond
    return MaterialPageRoute(
      builder: (context) => const DashboardPage(),
    );
  }
}
