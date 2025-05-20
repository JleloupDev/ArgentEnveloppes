import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_utils.dart';
import '../../domain/entities/envelope.dart';
import '../../domain/entities/transaction.dart';
import '../providers/envelope_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_list_item.dart';
import '../layouts/page_layout.dart';
import 'add_transaction_page.dart';

class EnvelopeDetailPage extends ConsumerStatefulWidget {
  final String envelopeId;

  const EnvelopeDetailPage({
    super.key,
    required this.envelopeId,
  });

  @override
  ConsumerState<EnvelopeDetailPage> createState() => _EnvelopeDetailPageState();
}

class _EnvelopeDetailPageState extends ConsumerState<EnvelopeDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Si vous avez besoin de charger des données spécifiques à cette enveloppe
      // ref.read(transactionProvider.notifier).loadTransactionsForEnvelope(widget.envelopeId);
    });  
  }  
  @override
Widget build(BuildContext context) {
  // Récupérer les données de l'enveloppe et des transactions
  final envelopes = ref.watch(envelopeProvider);
  final transactions = ref.watch(transactionProvider);
  
  // Trouver l'enveloppe actuelle
  final envelope = envelopes.firstWhere(
    (e) => e.id == widget.envelopeId,
    orElse: () => Envelope(id: '', name: 'Enveloppe inconnue', budget: 0, spent: 0),
  );
  
  // Calculer le montant restant
  final remaining = envelope.budget - envelope.spent;
  
  // Filtrer les transactions pour cette enveloppe
  final envelopeTransactions = transactions
      .where((t) => t.envelopeId == widget.envelopeId)
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date)); // Tri par date décroissante
  
  // Définir les actions pour la barre d'applications
  final appBarActions = [
    IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () => _showEditEnvelopeDialog(context, envelope),
    ),
    IconButton(
      icon: const Icon(Icons.delete),
      onPressed: () => _showDeleteConfirmation(context, envelope),
    ),
  ];
  
  // Créer le bouton d'action flottant
  final fab = FloatingActionButton(
    onPressed: () => _navigateToAddTransaction(),
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.textLight,
    child: const Icon(Icons.add),
  );
  
  return PageLayout(
    title: envelope.name,
    currentNavIndex: 2, // Enveloppes nav index
    showBackButton: true,
    actions: appBarActions,
    floatingActionButton: fab,
    useScrollView: false, // Utiliser le mode sans défilement
    body: SafeArea(
      child: Column(
        children: [
          // Carte d'information de l'enveloppe
          Padding(
            padding: const EdgeInsets.all(AppSizes.m),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Budget et dépenses
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoColumn('Budget', AppUtils.formatCurrency(envelope.budget)),
                        ),
                        Expanded(
                          child: _buildInfoColumn('Dépensé', AppUtils.formatCurrency(envelope.spent)),
                        ),
                        Expanded(
                          child: _buildInfoColumn(
                            'Restant',
                            AppUtils.formatCurrency(remaining),
                            remaining < 0 ? AppColors.error : null,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppSizes.m),
                    
                    // Barre de progression
                    const Text(
                      'Progression du budget',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.grey,
                      ),
                    ),
                    const SizedBox(height: AppSizes.s),
                    LinearProgressIndicator(
                      value: envelope.budget > 0
                          ? (envelope.spent / envelope.budget).clamp(0.0, 1.0)
                          : 0.0,
                      backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        envelope.spent >= envelope.budget
                            ? AppColors.error
                            : AppColors.primary,
                      ),
                      minHeight: 8,
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      envelope.budget > 0
                          ? '${AppUtils.formatPercentage(envelope.spent / envelope.budget)} utilisé'
                          : '0% utilisé',
                      style: TextStyle(
                        fontSize: 12,
                        color: envelope.spent >= envelope.budget
                            ? AppColors.error
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Titre de la liste des transactions
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.m,
              vertical: AppSizes.s,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Transactions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _navigateToAddTransaction(),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Ajouter'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          
          // Liste des transactions
          Expanded(
            child: envelopeTransactions.isEmpty
                ? _buildEmptyTransactions()
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSizes.m),
                    itemCount: envelopeTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = envelopeTransactions[index];
                      return TransactionListItem(
                        transaction: transaction,
                        onDelete: () => _showDeleteTransactionConfirmation(context, transaction),
                      );
                    },
                  ),
          ),
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
            fontSize: 14,
            color: AppColors.grey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyTransactions() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: AppColors.grey,
          ),
          const SizedBox(height: AppSizes.m),
          const Text(
            'Aucune transaction',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.s),
          const Text(
            'Ajoutez une transaction pour suivre vos dépenses',
            style: TextStyle(color: AppColors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.m),
          ElevatedButton(
            onPressed: () => _navigateToAddTransaction(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textLight,
            ),
            child: const Text('Ajouter une transaction'),
          ),
        ],
      ),
    );
  }

  void _navigateToAddTransaction() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionPage(envelopeId: widget.envelopeId),
      ),
    );
  }

  void _showEditEnvelopeDialog(BuildContext context, Envelope envelope) {
    // TODO: Implémenter la modification d'enveloppe
    final nameController = TextEditingController(text: envelope.name);
    final budgetController = TextEditingController(text: envelope.budget.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier l\'enveloppe'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nom',
              ),
            ),
            const SizedBox(height: AppSizes.m),
            TextField(
              controller: budgetController,
              decoration: const InputDecoration(
                labelText: 'Budget',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              // Vérifier et convertir les valeurs
              final name = nameController.text.trim();
              double? budget = double.tryParse(budgetController.text.trim());
              
              if (name.isNotEmpty && budget != null) {
                // Créer l'enveloppe mise à jour
                final updatedEnvelope = Envelope(
                  id: envelope.id,
                  name: name,
                  budget: budget,
                  spent: envelope.spent,
                  categoryId: envelope.categoryId,
                );
                
                // Mettre à jour l'enveloppe
                ref.read(envelopeProvider.notifier).updateEnvelope(updatedEnvelope);
                Navigator.pop(context);
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Envelope envelope) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'enveloppe'),
        content: Text(
          'Voulez-vous vraiment supprimer l\'enveloppe "${envelope.name}" ? '
          'Cette action supprimera également toutes les transactions associées.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              // Supprimer l'enveloppe
              ref.read(envelopeProvider.notifier).removeEnvelope(envelope.id);
              
              // Supprimer les transactions associées
              final envelopeTransactions = ref.read(transactionProvider)
                  .where((t) => t.envelopeId == envelope.id)
                  .toList();
              
              for (var transaction in envelopeTransactions) {
                ref.read(transactionProvider.notifier)
                  .removeTransaction(transaction.id);
              }
              
              Navigator.pop(context);
              Navigator.pop(context); // Retour à la page précédente
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showDeleteTransactionConfirmation(BuildContext context, Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(        title: const Text('Supprimer la transaction'),
        content: Text(
          'Voulez-vous vraiment supprimer cette transaction${transaction.comment != null ? " : \"${transaction.comment}\"" : ""} ?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
  TextButton(
            onPressed: () {
              // Supprimer la transaction
              ref.read(transactionProvider.notifier).removeTransaction(transaction.id);
              
              // Mettre à jour le montant dépensé dans l'enveloppe
              final envelopes = ref.read(envelopeProvider);
              final envelope = envelopes.firstWhere((e) => e.id == transaction.envelopeId);
              
              // Ajuster le montant dépensé en fonction du type de transaction
              double newSpent = envelope.spent;
              if (transaction.type == TransactionType.expense) {
                newSpent -= transaction.amount;
              } else {
                newSpent += transaction.amount;
              }
              
              // Mettre à jour l'enveloppe
              final updatedEnvelope = Envelope(
                id: envelope.id,
                name: envelope.name,
                budget: envelope.budget,
                spent: newSpent,
                categoryId: envelope.categoryId,
              );
              ref.read(envelopeProvider.notifier).updateEnvelope(updatedEnvelope);
              
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
