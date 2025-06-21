import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/transaction_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/transaction.dart';
import '../../widgets/transaction_item.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TransactionType? _selectedFilter;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.id;
      if (userId != null) {
        context.read<TransactionProvider>().loadTransactions(userId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showFilterOptions,
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            onPressed: _exportTransactions,
            icon: const Icon(Icons.download),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black,
          tabs: const [
            Tab(text: 'Toutes'),
            Tab(text: 'Entrées'),
            Tab(text: 'Sorties'),
          ],
        ),
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, transactionProvider, child) {
          if (transactionProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (transactionProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur de chargement',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Service indisponible, veuillez reessayer plus tard',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      final userId = context.read<AuthProvider>().currentUser?.id;
                      if (userId != null) {
                        transactionProvider.loadTransactions(userId);
                      }
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          // Vérifier si toutes les transactions sont vides
          final hasAnyTransactions = transactionProvider.transactions.isNotEmpty;
          final hasIncomeTransactions = transactionProvider.transactions.any((t) => t.amount > 0);
          final hasExpenseTransactions = transactionProvider.transactions.any((t) => t.amount < 0);

          return TabBarView(
            controller: _tabController,
            children: [
              _buildTransactionsList(
                transactionProvider.transactions,
                hasAnyTransactions,
                'Commencez à effectuer des transactions pour les voir apparaître ici.',
              ),
              _buildTransactionsList(
                transactionProvider.transactions.where((t) => t.amount > 0).toList(),
                hasIncomeTransactions,
                'Vos revenus et dépôts apparaîtront dans cet onglet.',
              ),
              _buildTransactionsList(
                transactionProvider.transactions.where((t) => t.amount < 0).toList(),
                hasExpenseTransactions,
                'Vos dépenses et retraits apparaîtront dans cet onglet.',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTransactionsList(List<Transaction> transactions, bool hasTransactions, String emptyMessage) {
    final filteredTransactions = _applyFilters(transactions);

    if (filteredTransactions.isEmpty) {
      // Différencier entre "pas de transactions du tout" et "pas de résultats après filtrage"
      final isFilteredEmpty = transactions.isNotEmpty && filteredTransactions.isEmpty;
      
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                ),
                child: Icon(
                  isFilteredEmpty ? Icons.search_off : Icons.receipt_long_outlined,
                  size: 64,
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isFilteredEmpty ? 'Aucun résultat' : 'Aucune transaction',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isFilteredEmpty 
                    ? 'Aucune transaction ne correspond à vos critères de recherche. Essayez de modifier vos filtres.'
                    : emptyMessage,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (isFilteredEmpty)
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedFilter = null;
                      _selectedDateRange = null;
                    });
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Effacer les filtres'),
                )
              else
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigation vers l'écran de création de transaction ou d'accueil
                    context.go('/main/home');
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Commencer'),
                ),
            ],
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 600.ms)
          .slideY(begin: 0.3, end: 0);
    }

    return RefreshIndicator(
      onRefresh: () async {
        final userId = context.read<AuthProvider>().currentUser?.id;
        if (userId != null) {
          await context.read<TransactionProvider>().loadTransactions(userId);
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredTransactions.length,
        itemBuilder: (context, index) {
          final transaction = filteredTransactions[index];
          return TransactionItem(
            transaction: transaction,
            onTap: () => context.go('/main/transactions/detail/${transaction.transactionId}'),
          )
              .animate()
              .fadeIn(delay: (index * 100).ms, duration: 600.ms)
              .slideX(begin: 0.3, end: 0);
        },
      ),
    );
  }

  List<Transaction> _applyFilters(List<Transaction> transactions) {
    var filtered = transactions;

    // Filtre par type
    if (_selectedFilter != null) {
      filtered = filtered.where((t) => t.type == _selectedFilter).toList();
    }

    // Filtre par date
    if (_selectedDateRange != null) {
      filtered = filtered.where((t) {
        return t.createdAtOrDateEvent.isAfter(_selectedDateRange!.start) &&
               t.createdAtOrDateEvent.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    return filtered;
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildFilterBottomSheet(),
    );
  }

  Widget _buildFilterBottomSheet() {
    return StatefulBuilder(
      builder: (context, setStateModal) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filtres',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedFilter = null;
                        _selectedDateRange = null;
                      });
                      setStateModal(() {});
                    },
                    child: const Text('Réinitialiser'),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Filtre par type
              Text(
                'Type de transaction',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              
              Wrap(
                spacing: 8,
                children: TransactionType.values.map((type) {
                  final isSelected = _selectedFilter == type;
                  return FilterChip(
                    label: Text(_getTypeLabel(type)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setStateModal(() {
                        _selectedFilter = selected ? type : null;
                      });
                      setState(() {
                        _selectedFilter = selected ? type : null;
                      });
                    },
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 24),
              
              // Filtre par date
              Text(
                'Période',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              
              InkWell(
                onTap: () async {
                  final dateRange = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now(),
                    initialDateRange: _selectedDateRange,
                  );
                  
                  if (dateRange != null) {
                    setState(() {
                      _selectedDateRange = dateRange;
                    });
                    setStateModal(() {
                      _selectedDateRange = dateRange;
                    });
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.date_range,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedDateRange != null
                              ? '${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}'
                              : 'Sélectionner une période',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Bouton Appliquer
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Appliquer les filtres'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getTypeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.transfert:
        return 'Transfert';
      case TransactionType.depot:
        return 'Dépôt';
      case TransactionType.retrait:
        return 'Retrait';
      case TransactionType.recharge:
        return 'Recharge';
      case TransactionType.virement:
        return 'Virement';
    }
  }

  void _exportTransactions() {
    // TODO: Implémenter l'export des transactions
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export des transactions à venir'),
      ),
    );
  }
}