import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/envelope.dart';
import '../providers/categories_provider.dart';
import '../providers/envelopes_provider.dart';
import 'create_envelope_page.dart';

class CategoryDetailPage extends ConsumerWidget {
  final String categoryId;

  const CategoryDetailPage({
    super.key,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final envelopes = ref.watch(envelopesProvider);
    
    final category = categories.firstWhere((c) => c.id == categoryId);
    final categoryEnvelopes = envelopes.where((e) => e.categoryId == categoryId).toList();
    
    // Calculs pour la catégorie
    final totalBudget = categoryEnvelopes.fold<double>(0, (sum, env) => sum + env.budget);
    final totalSpent = categoryEnvelopes.fold<double>(0, (sum, env) => sum + env.spent);
    final totalRemaining = totalBudget - totalSpent;

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editCategory(context, ref, category),
          ),
        ],
      ),
      body: Column(
        children: [
          // Résumé de la catégorie
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Column(
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Enveloppes', categoryEnvelopes.length.toString(), Icons.account_balance_wallet),
                    _buildStatItem('Budget total', '${totalBudget.toStringAsFixed(2)} €', Icons.euro),
                    _buildStatItem('Dépensé', '${totalSpent.toStringAsFixed(2)} €', Icons.trending_down),
                    _buildStatItem('Reste', '${totalRemaining.toStringAsFixed(2)} €', Icons.savings),
                  ],
                ),
              ],
            ),
          ),
          
          // Liste des enveloppes
          Expanded(
            child: categoryEnvelopes.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: categoryEnvelopes.length,
                    itemBuilder: (context, index) {
                      final envelope = categoryEnvelopes[index];
                      return _buildEnvelopeCard(context, envelope);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CreateEnvelopePage(
                // Pré-sélectionner la catégorie
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle enveloppe'),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.grey),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_balance_wallet, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Aucune enveloppe dans cette catégorie',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Créez votre première enveloppe pour cette catégorie',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CreateEnvelopePage(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Créer une enveloppe'),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvelopeCard(BuildContext context, Envelope envelope) {
    final percentage = envelope.consumptionPercentage;
    final remaining = envelope.remaining;
    
    Color statusColor;
    switch (envelope.status) {
      case EnvelopeStatus.good:
        statusColor = Colors.green;
        break;
      case EnvelopeStatus.warning:
        statusColor = Colors.orange;
        break;
      case EnvelopeStatus.exceeded:
        statusColor = Colors.red;
        break;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.2),
          child: Icon(
            Icons.account_balance_wallet,
            color: statusColor,
          ),
        ),
        title: Text(envelope.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${envelope.spent.toStringAsFixed(2)} € / ${envelope.budget.toStringAsFixed(2)} €'),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${remaining.toStringAsFixed(2)} €',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: remaining >= 0 ? Colors.green : Colors.red,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                color: statusColor,
              ),
            ),
          ],
        ),
        onTap: () {
          // Navigation vers le détail de l'enveloppe
          Navigator.of(context).pushNamed('/envelope/${envelope.id}');
        },
      ),
    );
  }

  void _editCategory(BuildContext context, WidgetRef ref, Category category) {
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              ref.read(categoriesProvider.notifier).deleteCategory(category.id);
              Navigator.of(context).pop(); // Fermer dialog
              Navigator.of(context).pop(); // Retourner au dashboard
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final updatedCategory = category.copyWith(name: nameController.text);
                ref.read(categoriesProvider.notifier).updateCategory(updatedCategory);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }
}
