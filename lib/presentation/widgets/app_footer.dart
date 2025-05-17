import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    // Seulement afficher le footer sur le web
    if (!kIsWeb) return const SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.l,
        horizontal: AppSizes.m,
      ),
      color: AppColors.primary,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Argentveloppes',
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.m),
              const Text(
                'Application de gestion de budget personnel utilisant la méthode des enveloppes budgétaires',
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.l),
              const Divider(
                color: AppColors.primaryLight,
                thickness: 1,
                height: 1,
              ),
              const SizedBox(height: AppSizes.m),
              Text(
                '© ${DateTime.now().year} Argentveloppes - Tous droits réservés',
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
