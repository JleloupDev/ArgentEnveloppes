import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/blue_theme.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AppFooter extends StatelessWidget {
  final bool alwaysShow; // Propriété pour contrôler si le footer est toujours affiché

  const AppFooter({
    super.key, 
    this.alwaysShow = false,
  });

  @override
  Widget build(BuildContext context) {
    // Seulement afficher le footer sur le web ou si alwaysShow est true
    if (!kIsWeb && !alwaysShow) return const SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.s, // Plus petit
        horizontal: AppSizes.m,
      ),
      color: BlueTheme.appBarBackground,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Argentveloppes',
                style: TextStyle(
                  color: BlueTheme.textLight,
                  fontSize: 16, // Plus petit
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '© ${DateTime.now().year}',
                style: const TextStyle(
                  color: BlueTheme.textLight,
                  fontSize: 12, // Plus petit
                ),
              ),            ],
          ),
        ),
      ),
    );
  }
}
