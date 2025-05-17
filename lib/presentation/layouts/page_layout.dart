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

  const PageLayout({
    super.key,
    required this.title,
    this.currentNavIndex = 0,
    required this.body,
    this.showBackButton = false,
    this.actions,
    this.floatingActionButton,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWebWide = kIsWeb && screenWidth > 768;

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
            // Contenu principal avec défilement
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(                  padding: isWebWide
                      ? EdgeInsets.symmetric(
                          horizontal: max(0, (screenWidth - 1200) / 2),
                          vertical: AppSizes.m,
                        )
                      : const EdgeInsets.all(AppSizes.m),
                  child: body,
                ),
              ),
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
