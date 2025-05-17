import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:math' show max;
import '../../core/constants/app_constants.dart';
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
        child: body,
      );
    }

    return Scaffold(
      appBar: AppNavBar(
        title: title,
        currentIndex: currentNavIndex,
        showBackButton: showBackButton,
        actions: actions,
        onBackPressed: onBackPressed,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Contenu principal
            Expanded(
              child: contentWidget,
            ),
            
            // Footer pour le web uniquement
            const AppFooter(),
          ],
        ),
      ),
      floatingActionButton: floatingActionButton,
      backgroundColor: AppColors.background,
    );
  }
}