import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/demo_data.dart';  // Import pour les données de démonstration
import '../../domain/entities/category.dart';
import '../../domain/entities/envelope.dart';
import '../layouts/page_layout.dart';
import '../providers/category_provider.dart';
import '../providers/envelope_provider.dart';
import '../providers/usecase_provider.dart';
import '../router/app_router.dart';
import '../widgets/category_card.dart';
import '../widgets/dashboard_stats.dart';
import '../widgets/envelope_card_with_quick_add.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // Charger les données au premier chargement de la page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }
  Future<void> _loadData() async {
    try {
      // Récupérer les catégories depuis le use case
      final getCategories = ref.read(getCategoriesUseCaseProvider);
      final categories = await getCategories();
      
      // Si aucune catégorie n'est trouvée, charger les données de démonstration
      if (categories.isEmpty) {
        // Utiliser les données de démonstration
        final demoCategories = DemoData.getCategories();
        final demoEnvelopes = DemoData.getEnvelopes();
        
        // Sauvegarder les catégories de démonstration
        for (final category in demoCategories) {
          final createCategory = ref.read(createCategoryUseCaseProvider);
          await createCategory(category);
        }
        
        // Sauvegarder les enveloppes de démonstration
        for (final envelope in demoEnvelopes) {
          final createEnvelope = ref.read(createEnvelopeUseCaseProvider);
          await createEnvelope(envelope);
        }
        
        // Mettre à jour l'état des catégories
        if (mounted) {
          ref.read(categoryProvider.notifier).setCategories(demoCategories);
          ref.read(envelopeProvider.notifier).setEnvelopes(demoEnvelopes);
        }
      } else {
        // Mettre à jour l'état des catégories
        if (mounted) {
          ref.read(categoryProvider.notifier).setCategories(categories);
        }
        
        // Récupérer les enveloppes
        final repository = ref.read(budgetRepositoryProvider);
        final envelopes = await repository.getAllEnvelopes();
        
        // Mettre à jour l'état des enveloppes
        if (mounted) {
          ref.read(envelopeProvider.notifier).setEnvelopes(envelopes);
        }
      }
    } catch (e) {
      // Gérer les erreurs de chargement
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors du chargement des données')),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryProvider);
    final envelopes = ref.watch(envelopeProvider);
    
    // Obtenir les noms des catégories pour chaque enveloppe
    Map<String, String> categoryNames = {};
    for (final envelope in envelopes) {
      if (envelope.categoryId != null) {
        final category = categories.firstWhere(
          (c) => c.id == envelope.categoryId,
          orElse: () => const Category(id: '', name: ''),
        );
        if (category.id.isNotEmpty) {
          categoryNames[envelope.id] = category.name;
        }
      }
    }
      return PageLayout(
      title: 'Tableau de bord',
      currentNavIndex: 0, // Index pour l'onglet Tableau de bord
      showBackButton: false,      actions: [
        // Bouton pour rafraîchir les données
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Rafraîchir les données',
          onPressed: _loadData,
        ),
        // Bouton pour réinitialiser les données (uniquement en mode debug)
        IconButton(
          icon: const Icon(Icons.restore),
          tooltip: 'Réinitialiser avec données de démo',
          onPressed: _resetWithDemoData,
        ),
      ],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistiques globales
            const DashboardStats(),
            
            const SizedBox(height: AppSizes.l),
            
            // Section Résumé par catégories
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.m),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Résumé par catégories',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: AppSizes.s),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${categories.length}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddCategoryDialog(context, ref),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Nouvelle catégorie'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textLight,
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.m),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSizes.m),
            
            // Liste des catégories
            if (categories.isEmpty)
              _buildEmptyCategoriesState(context, ref)
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.m),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: categories.length,                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return CategoryCard(
                      category: category,
                      onEdit: () => _showEditCategoryDialog(context, ref, category),
                      onDelete: () => _showDeleteConfirmation(context, ref, category),
                      showGlobalStats: true, // Afficher les montants généraux
                    );
                  },
                ),
              ),
              
            const SizedBox(height: AppSizes.xl),
            
            // Section Enveloppes récentes
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.m),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Enveloppes récentes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddEnvelopeDialog(context, ref),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Nouvelle enveloppe'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textLight,
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.m),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSizes.m),
            
            // Liste des enveloppes récentes
            if (envelopes.isEmpty)
              _buildEmptyEnvelopesState(context, ref)
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.m),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: envelopes.length > 4 ? 4 : envelopes.length, // Limiter à 4 enveloppes récentes
                  itemBuilder: (context, index) {
                    final envelope = envelopes[index];
                    return EnvelopeCardWithQuickAdd(
                      envelope: envelope,
                      categoryName: categoryNames[envelope.id],
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRouter.envelopeDetail,
                        arguments: envelope.id,
                      ),
                    );
                  },
                ),
              ),
              
            const SizedBox(height: AppSizes.xl),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyCategoriesState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          children: [
            const Icon(
              Icons.category_outlined,
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
              'Les catégories vous permettent d\'organiser vos enveloppes budgétaires par thème',
              style: TextStyle(color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.m),
            ElevatedButton.icon(
              onPressed: () => _showAddCategoryDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Créer une catégorie'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyEnvelopesState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          children: [
            const Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: AppColors.grey,
            ),
            const SizedBox(height: AppSizes.m),
            const Text(
              'Aucune enveloppe',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.s),
            const Text(
              'Les enveloppes vous permettent de répartir votre budget sur différents postes de dépenses',
              style: TextStyle(color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.m),
            ElevatedButton.icon(
              onPressed: () => _showAddEnvelopeDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Créer une enveloppe'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialogues pour l'ajout, la modification et la suppression des éléments
  
  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle catégorie'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nom',
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
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                // Créer une nouvelle catégorie
                final newCategory = Category(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                );
                
                try {
                  // Utiliser le use case pour créer la catégorie
                  final createCategory = ref.read(createCategoryUseCaseProvider);
                  await createCategory(newCategory);
                  
                  // Mettre à jour l'état local
                  ref.read(categoryProvider.notifier).addCategory(newCategory);
                  
                  // Fermer le dialogue
                  Navigator.pop(context);
                } catch (e) {
                  // Afficher une erreur
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Erreur lors de la création de la catégorie')),
                    );
                  }
                }
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }
  
  void _showEditCategoryDialog(BuildContext context, WidgetRef ref, Category category) {
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
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                // Mettre à jour la catégorie
                final updatedCategory = Category(
                  id: category.id,
                  name: name,
                );
                
                try {
                  // Utiliser le use case pour mettre à jour la catégorie
                  final updateCategory = ref.read(updateCategoryUseCaseProvider);
                  await updateCategory(updatedCategory);
                  
                  // Mettre à jour l'état local
                  ref.read(categoryProvider.notifier).updateCategory(updatedCategory);
                  
                  // Fermer le dialogue
                  Navigator.pop(context);
                } catch (e) {
                  // Afficher une erreur
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Erreur lors de la mise à jour de la catégorie')),
                    );
                  }
                }
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Category category) {
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
            onPressed: () async {
              try {
                // Utiliser le use case pour supprimer la catégorie
                final deleteCategory = ref.read(deleteCategoryUseCaseProvider);
                await deleteCategory(category.id);
                
                // Mettre à jour l'état local
                ref.read(categoryProvider.notifier).removeCategory(category.id);
                
                // Fermer le dialogue
                Navigator.pop(context);
              } catch (e) {
                // Afficher une erreur
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erreur lors de la suppression de la catégorie')),
                  );
                }
              }
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
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom de l\'enveloppe',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: AppSizes.m),
                TextField(
                  controller: budgetController,
                  decoration: const InputDecoration(
                    labelText: 'Budget',
                    border: OutlineInputBorder(),
                    prefixText: '€ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: AppSizes.m),
                DropdownButtonFormField<String?>(
                  decoration: const InputDecoration(
                    labelText: 'Catégorie',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedCategoryId,
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Sans catégorie'),
                    ),
                    ...categories.map((category) => DropdownMenuItem<String?>(
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
            TextButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final budgetText = budgetController.text.replaceAll(',', '.').trim();
                
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez entrer un nom pour l\'enveloppe')),
                  );
                  return;
                }
                
                double? budget = double.tryParse(budgetText);
                if (budget == null || budget <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez entrer un montant valide')),
                  );
                  return;
                }
                
                // Créer une nouvelle enveloppe
                final newEnvelope = Envelope(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                  budget: budget,
                  spent: 0,
                  categoryId: selectedCategoryId,
                );
                
                try {
                  // Utiliser le use case pour créer l'enveloppe
                  final createEnvelope = ref.read(createEnvelopeUseCaseProvider);
                  await createEnvelope(newEnvelope);
                  
                  // Mettre à jour l'état local
                  ref.read(envelopeProvider.notifier).addEnvelope(newEnvelope);
                  
                  // Fermer le dialogue
                  Navigator.pop(context);
                } catch (e) {
                  // Afficher une erreur
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Erreur lors de la création de l\'enveloppe')),
                    );
                  }
                }
              },
              child: const Text('Créer'),
            ),
          ],
        ),
      ),
    );
  }
  // Méthode pour réinitialiser les données avec des données de démonstration
  Future<void> _resetWithDemoData() async {
    try {
      print('Début de la réinitialisation des données de démonstration');
      
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
        print('Obtention du repository');
      // Obtenir le repository
      final repository = ref.read(budgetRepositoryProvider);
      
      print('Suppression des données existantes');
      // Supprimer toutes les données existantes
      await repository.clearAllData();
        print('Chargement des données de démo');
      // Obtenir les données de démonstration
      final demoCategories = DemoData.getCategories();
      print('Catégories de démo: ${demoCategories.length}');
      final demoEnvelopes = DemoData.getEnvelopes();
      print('Enveloppes de démo: ${demoEnvelopes.length}');
      
      // Sauvegarder les catégories de démonstration
      for (final category in demoCategories) {
        final createCategory = ref.read(createCategoryUseCaseProvider);
        await createCategory(category);
      }
      
      // Sauvegarder les enveloppes de démonstration
      for (final envelope in demoEnvelopes) {
        final createEnvelope = ref.read(createEnvelopeUseCaseProvider);
        await createEnvelope(envelope);
      }
      
      // Mettre à jour l'état des catégories et enveloppes
      ref.read(categoryProvider.notifier).setCategories(demoCategories);
      ref.read(envelopeProvider.notifier).setEnvelopes(demoEnvelopes);
      
      // Fermer le dialogue de chargement et afficher une confirmation
      if (mounted) {
        Navigator.pop(context); // Fermer le dialogue de chargement
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Données de démonstration chargées')),
        );
      }
    } catch (e) {
      // Fermer le dialogue de chargement en cas d'erreur
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la réinitialisation des données')),
        );
      }
    }
  }
}