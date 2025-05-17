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
    if (settings.name?.startsWith(envelopeDetail) == true) {
      // Extraire l'ID de l'enveloppe de l'URL
      final uri = Uri.parse(settings.name!);
      final envelopeId = uri.queryParameters['id'] ?? '';
      
      return MaterialPageRoute(
        builder: (context) => EnvelopeDetailPage(envelopeId: envelopeId),
      );
    }
    
    // Route pour l'ajout de transaction
    if (settings.name?.startsWith('/transaction/add') == true) {
      final uri = Uri.parse(settings.name!);
      final envelopeId = uri.queryParameters['envelopeId'] ?? '';
      
      return MaterialPageRoute(
        builder: (context) => AddTransactionPage(envelopeId: envelopeId),
      );
    }
    
    // Route par défaut si rien ne correspond
    return MaterialPageRoute(
      builder: (context) => const DashboardPage(),
    );
  }
}
