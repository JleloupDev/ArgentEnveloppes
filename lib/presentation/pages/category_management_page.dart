import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_utils.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/envelope.dart';
import '../providers/category_provider.dart';
import '../providers/envelope_provider.dart';
import '../layouts/page_layout.dart';

class CategoryManagementPage extends ConsumerStatefulWidget {
  const CategoryManagementPage({super.key});

  @override
  ConsumerState<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends ConsumerState<CategoryManagementPage> {  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryProvider);
    final envelopes = ref.watch(envelopeProvider);
    
    // Bouton d'action flottant
    final fab = FloatingActionButton(
      onPressed: () => _showAddCategoryDialog(context),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textLight,
      child: const Icon(Icons.add),
    );
    
    return PageLayout(
      title: 'Gestion des catégories',
      currentNavIndex: 1, // Index pour l'onglet Catégories
      showBackButton: false,
      floatingActionButton: fab,
      body: categories.isEmpty 
          ? _buildEmptyState()
          : ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final categoryEnvelopes = envelopes
                    .where((e) => e.categoryId == category.id)
                    .toList();
                
                return _buildCategoryCard(category, categoryEnvelopes);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.folder_outlined,
            size: 64,
            color: AppColors.grey,
          ),
          const SizedBox(height: AppSizes.m),
          const Text(
            'Aucune catégorie',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.s),
          const Text(
            'Créez une catégorie pour organiser vos enveloppes',
            style: TextStyle(color: AppColors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.m),
          ElevatedButton(
            onPressed: () => _showAddCategoryDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textLight,
            ),
            child: const Text('Créer une catégorie'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Category category, List<Envelope> envelopes) {
    final totalBudget = envelopes.fold<double>(0, (sum, e) => sum + e.budget);
    final totalSpent = envelopes.fold<double>(0, (sum, e) => sum + e.spent);
    final remainingBudget = totalBudget - totalSpent;
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.m),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nom de la catégorie et actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _showEditCategoryDialog(context, category),
                      tooltip: 'Modifier',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(AppSizes.s),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () => _showDeleteConfirmation(context, category),
                      tooltip: 'Supprimer',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(AppSizes.s),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: AppSizes.s),
            
            // Nombre d'enveloppes
            Text(
              '${envelopes.length} enveloppe${envelopes.length > 1 ? 's' : ''}',
              style: const TextStyle(
                color: AppColors.grey,
              ),
            ),
            
            const SizedBox(height: AppSizes.m),
            
            // Statistiques de la catégorie
            if (envelopes.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoColumn('Budget total', AppUtils.formatCurrency(totalBudget)),
                  _buildInfoColumn('Dépensé', AppUtils.formatCurrency(totalSpent)),
                  _buildInfoColumn(
                    'Reste',
                    AppUtils.formatCurrency(remainingBudget),
                    remainingBudget < 0 ? AppColors.error : AppColors.success,
                  ),
                ],
              ),
              
              const SizedBox(height: AppSizes.m),
              
              // Barre de progression
              LinearProgressIndicator(
                value: totalBudget > 0
                    ? (totalSpent / totalBudget).clamp(0.0, 1.0)
                    : 0.0,
                backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  totalSpent >= totalBudget ? AppColors.error : AppColors.primary,
                ),
                minHeight: 6,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, [Color? valueColor]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.grey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle catégorie'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nom de la catégorie',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                // Créer une nouvelle catégorie
                final newCategory = Category(
                  id: '', // L'id sera généré dans le repository
                  name: name,
                );
                
                // TODO: Appeler le usecase pour créer la catégorie
                
                Navigator.pop(context);
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, Category category) {
    final nameController = TextEditingController(text: category.name);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier la catégorie'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nom de la catégorie',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                // Mettre à jour la catégorie
                final updatedCategory = Category(
                  id: category.id,
                  name: name,
                );
                
                // TODO: Mettre à jour la catégorie dans le state
                
                Navigator.pop(context);
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la catégorie'),
        content: Text(
          'Voulez-vous vraiment supprimer la catégorie "${category.name}" ? '
          'Les enveloppes associées seront déplacées vers la catégorie par défaut.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Supprimer la catégorie
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
