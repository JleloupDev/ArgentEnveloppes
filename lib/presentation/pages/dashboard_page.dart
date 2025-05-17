import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../layouts/page_layout.dart';
import '../router/app_router.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PageLayout(
      title: "Tableau de bord",
      currentNavIndex: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.category),
          tooltip: "Gérer les catégories",
          onPressed: () {
            Navigator.pushNamed(context, AppRouter.categories);
          },
        ),
      ],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_balance_wallet,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: 20),
            const Text(
              "Bienvenue sur Argentveloppes",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Application de gestion de budget personnel",
              style: TextStyle(
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRouter.categories);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text("Gérer mes catégories"),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("La méthode des enveloppes consiste à allouer un budget spécifique à chaque catégorie de dépenses"),
                    duration: Duration(seconds: 5),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              child: const Text("En savoir plus sur la méthode des enveloppes"),
            ),
          ],
        ),
      ),
    );
  }
}
