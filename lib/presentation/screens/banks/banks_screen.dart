import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jamaa_frontend_mobile/core/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/dashboard_provider.dart';
import '../../widgets/bank_account_card.dart';

class BanksScreen extends StatefulWidget {
  const BanksScreen({super.key});

  @override
  State<BanksScreen> createState() => _BanksScreenState();
}

class _BanksScreenState extends State<BanksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboardData(userId: context.read<AuthProvider>().currentUser!.id.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes banques'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.go('/main/banks/add'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, dashboardProvider, child) {
          if (dashboardProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (dashboardProvider.error != null) {
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
                    dashboardProvider.error!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      dashboardProvider.loadDashboardData(userId: context.read<AuthProvider>().currentUser!.id.toString());
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => dashboardProvider.refreshBalance(userId: context.read<AuthProvider>().currentUser!.id.toString()),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Résumé des comptes
                  _buildAccountsSummary(dashboardProvider),
                  
                  const SizedBox(height: 32),
                  
                  // Liste des comptes bancaires
                  _buildBankAccountsList(dashboardProvider),
                  
                  const SizedBox(height: 32),
                  
                  // Banques disponibles
                  _buildAvailableBanks(),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/main/banks/add'),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter une banque'),
      )
          .animate()
          .slideY(begin: 1, end: 0, duration: 600.ms, curve: Curves.elasticOut),
    );
  }

  Widget _buildAccountsSummary(DashboardProvider dashboardProvider) {
    final totalAccounts = dashboardProvider.bankAccounts.length;
    final activeAccounts = dashboardProvider.bankAccounts.where((a) => a.isActive).length;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    Icons.account_balance,
                    size: 30,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Solde total',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dashboardProvider.formattedTotalBalance,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        totalAccounts.toString(),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Comptes liés',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Theme.of(context).dividerColor,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        activeAccounts.toString(),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Actifs',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: -0.2, end: 0);
  }

  Widget _buildBankAccountsList(DashboardProvider dashboardProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Comptes bancaires',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (dashboardProvider.bankAccounts.isNotEmpty)
              TextButton.icon(
                onPressed: _sortAccounts,
                icon: const Icon(Icons.sort, size: 16),
                label: const Text('Trier'),
              ),
          ],
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 600.ms),
        
        const SizedBox(height: 16),
        
        if (dashboardProvider.bankAccounts.isEmpty)
          _buildEmptyState()
        else
          Column(
            children: dashboardProvider.bankAccounts.asMap().entries.map((entry) {
              final index = entry.key;
              final account = entry.value;
              return BankAccountCard(
                bankAccount: account,
                onTap: () => _showAccountDetails(account),
              )
                  .animate()
                  .fadeIn(delay: (300 + index * 100).ms, duration: 600.ms)
                  .slideX(begin: 0.3, end: 0);
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun compte bancaire',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez vos comptes bancaires pour commencer à utiliser JAMAA',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/main/banks/add'),
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un compte'),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildAvailableBanks() {
    final availableBanks = [
      {'name': 'Afriland First Bank', 'logo': 'assets/images/afriland_logo.png', 'color': Colors.green},
      {'name': 'BICEC', 'logo': 'assets/images/bicec_logo.png', 'color': Colors.blue},
      {'name': 'UBA Cameroun', 'logo': 'assets/images/uba_logo.png', 'color': Colors.red},
      {'name': 'Ecobank', 'logo': 'assets/images/ecobank_logo.png', 'color': Colors.orange},
      {'name': 'SGBC', 'logo': 'assets/images/sgbc_logo.png', 'color': Colors.purple},
      {'name': 'CCA Bank', 'logo': 'assets/images/cca_logo.png', 'color': Colors.teal},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Banques disponibles',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        )
            .animate()
            .fadeIn(delay: 600.ms, duration: 600.ms),
        
        const SizedBox(height: 8),
        
        Text(
          'Connectez vos comptes de ces banques partenaires',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        )
            .animate()
            .fadeIn(delay: 650.ms, duration: 600.ms),
        
        const SizedBox(height: 16),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: availableBanks.length,
          itemBuilder: (context, index) {
            final bank = availableBanks[index];
            return Card(
              child: InkWell(
                onTap: () => context.go('/main/banks/add', extra: bank['name']),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: (bank['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            (bank['name'] as String).substring(0, 1),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: bank['color'] as Color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          bank['name'] as String,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(delay: (700 + index * 100).ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0);
          },
        ),
      ],
    );
  }

  void _sortAccounts() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trier par',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('Nom de la banque'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implémenter le tri par nom
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('Solde (croissant)'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implémenter le tri par solde croissant
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('Solde (décroissant)'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implémenter le tri par solde décroissant
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Date d\'ajout'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implémenter le tri par date
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAccountDetails(bankAccount) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          bankAccount.bankName.substring(0, 1),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bankAccount.bankName,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            bankAccount.accountType,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Solde
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor,
                                Theme.of(context).primaryColor.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Solde disponible',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${bankAccount.balance.toStringAsFixed(0)} ${bankAccount.currency}',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Informations du compte
                        _buildDetailSection('Informations du compte', [
                          _buildDetailItem('Numéro de compte', bankAccount.maskedAccountNumber),
                          _buildDetailItem('Type de compte', bankAccount.accountType),
                          _buildDetailItem('Devise', bankAccount.currency),
                          _buildDetailItem('Statut', 
                            bankAccount.isActive ? 'Actif' : 'Inactif',
                            color: bankAccount.isActive ? Colors.green : Colors.red,
                          ),
                          _buildDetailItem('Lié le', 
                            '${bankAccount.linkedAt.day}/${bankAccount.linkedAt.month}/${bankAccount.linkedAt.year}'
                          ),
                        ]),
                        
                        const SizedBox(height: 24),
                        
                        // Actions
                        Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  // TODO: Actualiser le solde
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Actualiser le solde'),
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: bankAccount.isActive 
                                    ? () => _toggleAccountStatus(bankAccount)
                                    : () => _toggleAccountStatus(bankAccount),
                                icon: Icon(bankAccount.isActive ? Icons.pause : Icons.play_arrow),
                                label: Text(bankAccount.isActive ? 'Désactiver' : 'Activer'),
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => _unlinkAccount(bankAccount),
                                icon: const Icon(Icons.link_off),
                                label: const Text('Délier le compte'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...items,
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleAccountStatus(bankAccount) {
    // TODO: Implémenter la désactivation/activation du compte
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          bankAccount.isActive 
              ? 'Compte désactivé' 
              : 'Compte activé'
        ),
      ),
    );
    Navigator.pop(context);
  }

  void _unlinkAccount(bankAccount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Délier le compte'),
        content: Text(
          'Êtes-vous sûr de vouloir délier le compte ${bankAccount.bankName} ? '
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implémenter la suppression du compte
              Navigator.pop(context); // Fermer le dialog
              Navigator.pop(context); // Fermer le bottom sheet
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Compte délié avec succès'),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Délier'),
          ),
        ],
      ),
    );
  }
}