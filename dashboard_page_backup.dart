import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_utils.dart';
import '../layouts/page_layout.dart';
import '../providers/envelope_provider.dart';
import '../providers/category_provider.dart';
import '../../domain/entities/category.dart';
import '../widgets/envelope_card.dart';
import '../router/app_router.dart';
import 'envelope_detail_page.dart';
import 'add_transaction_page.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final envelopes = ref.watch(envelopeProvider);
    final categories = ref.watch(categoryProvider);

    // Calculs des totaux
    final totalBudget = ref.read(envelopeProvider.notifier).totalBudget;
    final totalSpent = ref.read(envelopeProvider.notifier).totalSpent;
    final totalRemaining = ref.read(envelopeProvider.notifier).totalRemaining;
    
    return PageLayout(
      title: "Tableau de bord",
      currentNavIndex: 0,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEnvelopeDialog(context, ref),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
      body: envelopes.isEmpty
          ? _buildEmptyState(context, ref)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Résumé du budget
                Card(
                  margin: const EdgeInsets.only(bottom: AppSizes.m),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.m),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Résumé du budget",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSizes.m),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryItem(
                                "Budget total",
                                AppUtils.formatCurrency(totalBudget),
                                AppColors.primary,
                              ),
                            ),
                            Expanded(
                              child: _buildSummaryItem(
                                "Dépensé",
                                AppUtils.formatCurrency(totalSpent),
                                AppColors.warning,
                              ),
                            ),
                            Expanded(
                              child: _buildSummaryItem(
                                "Restant",
                                AppUtils.formatCurrency(totalRemaining),
                                totalRemaining < 0 ? AppColors.error : AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                // En-tête de la liste des enveloppes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Mes enveloppes",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRouter.categories);
                      },
                      icon: const Icon(Icons.category, size: 18),
                      label: const Text("Gérer les catégories"),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.s),
                
                // Liste des enveloppes
                ...envelopes.map((envelope) {
                  // Trouver la catégorie associée à l'enveloppe
                  final categoryName = envelope.categoryId != null 
                      ? categories
                          .firstWhere(
                            (c) => c.id == envelope.categoryId,
                            orElse: () => const Category(id: '', name: ''),
                          )
                          .name 
                      : null;

                  return EnvelopeCard(
                    envelope: envelope,
                    categoryName: categoryName,
                    onTap: () => _navigateToEnvelopeDetail(context, envelope.id),
                    onAddTransaction: () => _navigateToAddTransaction(context, envelope.id),
                  );
                }).toList(),
              ],
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: AppColors.grey,
          ),
          const SizedBox(height: AppSizes.m),
          const Text(
            "Aucune enveloppe budgétaire",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.s),
          const Text(
            "Commencez par créer votre première enveloppe budgétaire",
            style: TextStyle(color: AppColors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.l),
          ElevatedButton(
            onPressed: () => _showAddEnvelopeDialog(context, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textLight,
            ),
            child: const Text("Créer une enveloppe"),
          ),
          const SizedBox(height: AppSizes.m),
          TextButton.icon(
            icon: const Icon(Icons.category),
            label: const Text("Gérer les catégories"),
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.categories);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.grey,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSizes.xs),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _navigateToEnvelopeDetail(BuildContext context, String envelopeId) {
    // Utiliser la navigation adaptée selon la plateforme
    if (kIsWeb) {
      Navigator.pushNamed(
        context,
        "${AppRouter.envelopeDetail}?id=$envelopeId",
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EnvelopeDetailPage(envelopeId: envelopeId),
        ),
      );
    }
  }

  void _navigateToAddTransaction(BuildContext context, String envelopeId) {
    // Utiliser la navigation adaptée selon la plateforme
    if (kIsWeb) {
      Navigator.pushNamed(
        context,
        "${AppRouter.addTransaction}?envelopeId=$envelopeId",
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddTransactionPage(envelopeId: envelopeId),
        ),
      );
    }
  }

  void _showAddEnvelopeDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final budgetController = TextEditingController();
    String? selectedCategoryId;
    final categories = ref.read(categoryProvider);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nouvelle enveloppe'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom de l\'enveloppe',
                    hintText: 'Ex: Courses, Loisirs, Transport...',
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: AppSizes.m),
                TextField(
                  controller: budgetController,
                  decoration: const InputDecoration(
                    labelText: 'Budget alloué',
                    hintText: 'Ex: 100',
                    prefixText: '€ ',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppSizes.m),
                DropdownButtonFormField<String>(
                  value: selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Catégorie (optionnel)',
                  ),
                  hint: const Text('Sélectionnez une catégorie'),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Aucune catégorie'),
                    ),
                    ...categories.map((category) => DropdownMenuItem<String>(
                      value: category.id,
                      child: Text(category.name),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedCategoryId = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty || 
                    budgetController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez remplir tous les champs obligatoires'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                try {
                  final budget = double.parse(budgetController.text.trim());
                  
                  final newEnvelope = Envelope(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text.trim(),
                    budget: budget,
                    spent: 0,
                    categoryId: selectedCategoryId,
                  );
                  
                  ref.read(envelopeProvider.notifier).addEnvelope(newEnvelope);
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Enveloppe créée avec succès'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Le budget doit être un nombre valide'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Créer'),
            ),
          ],
        ),
      ),
    );
  }
}
