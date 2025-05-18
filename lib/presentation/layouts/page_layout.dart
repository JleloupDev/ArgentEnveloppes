import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:math' show max;
import '../../core/constants/app_constants.dart';
import '../../core/constants/blue_theme.dart'; // Importer le thème bleu
import '../widgets/app_nav_bar.dart';
import '../widgets/app_footer.dart';

class PageLayout extends StatelessWidget {
  final String title;
  final int currentNavIndex;
  final Widget body;
  final bool showBackButton;
  final List<Widget>? actions;
  final FloatingActionButton? floatingActionButton;
  final VoidCallback? onBackPressed;
  final bool useScrollView; // Nouveau paramètre pour choisir entre les deux modes

  const PageLayout({
    super.key,
    required this.title,
    this.currentNavIndex = 0,
    required this.body,
    this.showBackButton = false,
    this.actions,
    this.floatingActionButton,
    this.onBackPressed,
    this.useScrollView = true, // Par défaut, utiliser le ScrollView
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWebWide = kIsWeb && screenWidth > 768;
    final isDashboard = currentNavIndex == 0; // Vérifier si c'est le tableau de bord

    Widget contentWidget;
    
    if (useScrollView) {
      // Mode avec défilement pour les pages standard
      contentWidget = SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          padding: isWebWide
              ? EdgeInsets.symmetric(
                  horizontal: max(0, (screenWidth - 1200) / 2),
                  vertical: AppSizes.m,
                )
              : const EdgeInsets.all(AppSizes.m),
          // Utiliser une couleur de fond différente pour le tableau de bord
          color: isDashboard ? BlueTheme.background : AppColors.background,
          child: body,
        ),
      );
    } else {
      // Mode sans défilement pour les pages avec leur propre gestion de défilement
      contentWidget = Container(
        padding: isWebWide
            ? EdgeInsets.symmetric(
                horizontal: max(0, (screenWidth - 1200) / 2),
              )
            : EdgeInsets.zero,
        // Utiliser une couleur de fond différente pour le tableau de bord
        color: isDashboard ? BlueTheme.background : AppColors.background,
        child: body,
      );
    }    // Utiliser différentes couleurs selon que c'est le tableau de bord ou non
    return Scaffold(
      appBar: AppNavBar(
        title: title,
        currentIndex: currentNavIndex,
        showBackButton: showBackButton,
        actions: actions,
        onBackPressed: onBackPressed,
        // Utiliser une couleur différente pour la barre d'app du tableau de bord
        backgroundColor: isDashboard ? BlueTheme.appBarBackground : AppColors.primary,
      ),      body: SafeArea(
        child: Stack(
          children: [
            // Contenu principal
            Column(
              children: [
                Expanded(
                  child: contentWidget,
                ),
                // Espacement pour le footer
                if (kIsWeb) const SizedBox(height: 40),
              ],
            ),
            
            // Footer en position absolue en bas (uniquement pour le web)
            if (kIsWeb)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: const AppFooter(),
              ),
          ],
        ),
      ),
      floatingActionButton: floatingActionButton,
      // Appliquer la couleur de fond du thème bleu pour le dashboard
      backgroundColor: isDashboard ? BlueTheme.background : AppColors.background,
    );
  }
}