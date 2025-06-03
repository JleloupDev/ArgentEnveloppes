import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/envelope.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/transaction.dart';
import '../providers/envelopes_provider.dart';
import '../providers/categories_provider.dart';
import '../providers/transactions_provider.dart';
import 'create_envelope_page.dart';
import 'category_detail_page.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ArgentEnveloppes'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigation vers les paramètres
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vue d'ensemble du budget
            _buildBudgetOverview(),
            
            const SizedBox(height: 24),
            
            // Actions rapides
            const Text(
              'Actions rapides',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildQuickActions(),
            
            const SizedBox(height: 24),
            
            // Catégories
            const Text(
              'Catégories',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildCategoryList(),
            
            const SizedBox(height: 24),
            
            // Enveloppes récentes
            const Text(
              'Mes enveloppes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildEnvelopeList(context),
          ],
        ),
      ),      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigation vers la création d'enveloppe
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreateEnvelopePage(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle enveloppe'),
      ),
    );
  }
  Widget _buildBudgetOverview() {
    return Consumer(
      builder: (context, ref, child) {
        final budgetStats = ref.watch(budgetStatsProvider);
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vue d\'ensemble',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBudgetItem('Budget total', '${budgetStats.totalBudget.toStringAsFixed(2)} €', Colors.blue),
                    _buildBudgetItem('Dépensé', '${budgetStats.totalSpent.toStringAsFixed(2)} €', Colors.red),
                    _buildBudgetItem('Disponible', '${budgetStats.totalRemaining.toStringAsFixed(2)} €', Colors.green),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBudgetItem(String label, String amount, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
  Widget _buildQuickActions() {
    return Consumer(
      builder: (context, ref, child) {
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showQuickExpenseDialog(context, ref),
                icon: const Icon(Icons.remove),
                label: const Text('Dépense rapide'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[100],
                  foregroundColor: Colors.red[800],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showQuickIncomeDialog(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('Ajouter revenu'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[100],
                  foregroundColor: Colors.green[800],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  Widget _buildCategoryList() {
    return Consumer(
      builder: (context, ref, child) {
        final categories = ref.watch(categoriesProvider);
        final envelopes = ref.watch(envelopesProvider);
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ...categories.map((category) {
                  final categoryEnvelopes = envelopes.where((e) => e.categoryId == category.id).toList();
                  final totalBudget = categoryEnvelopes.fold<double>(0, (sum, env) => sum + env.budget);
                  final totalSpent = categoryEnvelopes.fold<double>(0, (sum, env) => sum + env.spent);
                  
                  return Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.category),
                        title: Text(category.name),
                        subtitle: Text('${categoryEnvelopes.length} enveloppes • ${totalSpent.toStringAsFixed(2)} € / ${totalBudget.toStringAsFixed(2)} €'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CategoryDetailPage(categoryId: category.id),
                            ),
                          );
                        },
                      ),
                      if (category.id != categories.last.id) const Divider(),
                    ],
                  );
                }).toList(),
                if (categories.isNotEmpty) const Divider(),
                ListTile(
                  leading: const Icon(Icons.add_circle_outline),
                  title: const Text('Créer une catégorie'),
                  onTap: () => _createNewCategory(context, ref),
                ),
              ],
            ),
          ),
        );
      },
    );
  }Widget _buildEnvelopeList(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final envelopes = ref.watch(envelopesProvider);
        
        return Column(
          children: envelopes.map((envelope) => 
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _buildEnvelopeCard(envelope, context),
            )
          ).toList(),
        );
      },
    );
  }
  Widget _buildEnvelopeCard(Envelope envelope, BuildContext context) {
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
        ),        onTap: () {
          // Navigation vers le détail de l'enveloppe
          Navigator.of(context).pushNamed('/envelope/${envelope.id}');
        },
      ),
    );
  }

  void _createNewCategory(BuildContext context, WidgetRef ref) {
    final categoryController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle catégorie'),
        content: TextField(
          controller: categoryController,
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
          ElevatedButton(
            onPressed: () {
              if (categoryController.text.isNotEmpty) {
                final newCategory = Category(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: categoryController.text,
                );
                
                ref.read(categoriesProvider.notifier).addCategory(newCategory);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  void _showQuickExpenseDialog(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    final commentController = TextEditingController();
    final envelopes = ref.read(envelopesProvider);
    String? selectedEnvelopeId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Dépense rapide'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedEnvelopeId,
                hint: const Text('Choisir une enveloppe'),
                decoration: const InputDecoration(
                  labelText: 'Enveloppe',
                  border: OutlineInputBorder(),
                ),
                items: envelopes.map((envelope) {
                  return DropdownMenuItem(
                    value: envelope.id,
                    child: Text(envelope.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedEnvelopeId = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Montant (€)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  labelText: 'Commentaire (optionnel)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text);
                if (amount != null && amount > 0 && selectedEnvelopeId != null) {
                  final transaction = Transaction(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    envelopeId: selectedEnvelopeId!,
                    amount: amount,
                    type: TransactionType.expense,
                    comment: commentController.text.isEmpty ? null : commentController.text,
                    date: DateTime.now(),
                  );
                  
                  ref.read(transactionsProvider.notifier).addTransaction(transaction);
                  ref.read(envelopesProvider.notifier).addTransaction(
                    selectedEnvelopeId!, 
                    amount, 
                    true, // expense
                  );
                  
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Dépense de ${amount.toStringAsFixed(2)}€ ajoutée')),
                  );
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickIncomeDialog(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    final commentController = TextEditingController();
    final envelopes = ref.read(envelopesProvider);
    String? selectedEnvelopeId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Ajouter un revenu'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedEnvelopeId,
                hint: const Text('Choisir une enveloppe'),
                decoration: const InputDecoration(
                  labelText: 'Enveloppe',
                  border: OutlineInputBorder(),
                ),
                items: envelopes.map((envelope) {
                  return DropdownMenuItem(
                    value: envelope.id,
                    child: Text(envelope.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedEnvelopeId = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Montant (€)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  labelText: 'Commentaire (optionnel)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text);
                if (amount != null && amount > 0 && selectedEnvelopeId != null) {
                  final transaction = Transaction(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    envelopeId: selectedEnvelopeId!,
                    amount: amount,
                    type: TransactionType.income,
                    comment: commentController.text.isEmpty ? null : commentController.text,
                    date: DateTime.now(),
                  );
                  
                  ref.read(transactionsProvider.notifier).addTransaction(transaction);
                  ref.read(envelopesProvider.notifier).addTransaction(
                    selectedEnvelopeId!, 
                    amount, 
                    false, // income
                  );
                  
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Revenu de ${amount.toStringAsFixed(2)}€ ajouté')),
                  );
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }
}