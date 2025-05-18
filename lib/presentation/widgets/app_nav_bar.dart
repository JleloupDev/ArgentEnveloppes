import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AppNavBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final int currentIndex;
  final bool showBackButton;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppNavBar({
    super.key,
    this.title = 'Argentveloppes',
    this.currentIndex = 0,
    this.showBackButton = false,
    this.actions,
    this.onBackPressed,
    this.backgroundColor,
    this.foregroundColor,
  });
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.primary,
      foregroundColor: foregroundColor ?? AppColors.textLight,
      elevation: 4,
      shadowColor: Colors.black26,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: showBackButton 
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
      actions: actions,
      bottom: kIsWeb ? _buildWebNavBar(context) : null,
    );
  }
    /// Barre de navigation web inspirée de la maquette
  PreferredSizeWidget? _buildWebNavBar(BuildContext context) {
    // Uniquement afficher pour les écrans web de taille suffisante
    if (!kIsWeb || MediaQuery.of(context).size.width < 600) {
      return null;
    }
    
    return PreferredSize(
      preferredSize: const Size.fromHeight(48),
      child: Container(
        height: 48,
        color: backgroundColor ?? AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.m),
        child: Row(
          children: [
            _buildNavItem(context, 'Tableau de bord', 0, '/'),
            _buildNavItem(context, 'Catégories', 1, '/categories'),
            _buildNavItem(context, 'Enveloppes', 2, '/envelopes'),
          ],
        ),
      ),
    );
  }
  
  /// Élément de navigation
  Widget _buildNavItem(BuildContext context, String label, int index, String route) {
    final bool isActive = currentIndex == index;
    
    return InkWell(
      onTap: () {
        if (!isActive) {
          Navigator.pushNamed(context, route);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.m),
        height: 48,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? AppColors.textLight : Colors.transparent,
              width: 2.0,
            ),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.textLight,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize {
    if (kIsWeb) {
      return const Size.fromHeight(kToolbarHeight + 48);
    }
    return const Size.fromHeight(kToolbarHeight);
  }
}
