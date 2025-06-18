import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jamaa_frontend_mobile/core/providers/auth_provider.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/build_accounts_summary.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:jamaa_frontend_mobile/core/providers/bank_provider.dart';
import '../../../core/providers/dashboard_provider.dart';

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
      final userId = context.read<AuthProvider>().currentUser!.id.toString();
      context.read<DashboardProvider>().loadDashboardData(userId: userId);
      // Utiliser loadAvailableBanks au lieu de fetchBanks pour charger les banques et les comptes utilisateur
      context.read<BankProvider>().loadAvailableBanks(userId);
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
      body: Consumer2<DashboardProvider, BankProvider>(
        builder: (context, dashboardProvider, bankProvider, child) {
          // Vérifier l'état de chargement des deux providers
          if (dashboardProvider.isLoading || bankProvider.isLoadingAvailable) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Vérifier les erreurs des deux providers
          final error = dashboardProvider.error ?? bankProvider.error;
          if (error != null) {
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
                    dashboardProvider.error?.message ?? bankProvider.error ?? 'Erreur inconnue',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      final userId = context.read<AuthProvider>().currentUser!.id.toString();
                      dashboardProvider.loadDashboardData(userId: userId);
                      bankProvider.loadAvailableBanks(userId);
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final userId = context.read<AuthProvider>().currentUser!.id.toString();
              await Future.wait([
                dashboardProvider.refreshBalance(userId: userId),
                bankProvider.refreshAvailableBanks(userId),
              ]);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Résumé des comptes
                  buildAccountsSummary(context, dashboardProvider),
                  
                  const SizedBox(height: 32),
                  
                  // Liste des comptes bancaires (si vous voulez l'afficher)
                  if (bankProvider.hasUserBankAccounts) ...[
                    _buildUserBankAccounts(bankProvider),
                    const SizedBox(height: 32),
                  ],
                  
                  // Banques disponibles
                  _buildAvailableBanks(bankProvider),
                ],
              ),
            ),
          );
        },
      )
    );
  }

  Widget _buildUserBankAccounts(BankProvider bankProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mes comptes bancaires',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: bankProvider.userBankAccounts.length,
          itemBuilder: (context, index) {
            final account = bankProvider.userBankAccounts[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withValues(alpha: 0.15),
                  child: Text(
                    account.bankName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  account.bankName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '***${account.accountNumber.substring(account.accountNumber.length - 4)}',
                ),
                trailing: Text(
                  '${account.balance.toStringAsFixed(2)} FCFA',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAvailableBanks(BankProvider bankProvider) {
    // Utiliser availableBanks au lieu de banks
    final availableBanks = bankProvider.availableBanks;
    
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
          availableBanks.isEmpty 
            ? 'Vous êtes connecté à toutes les banques partenaires disponibles'
            : 'Connectez vos comptes de ces banques partenaires',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        )
            .animate()
            .fadeIn(delay: 650.ms, duration: 600.ms),
        
        const SizedBox(height: 16),
        
        // Afficher un message si aucune banque n'est disponible
        if (availableBanks.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Toutes les banques connectées !',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Vous avez connecté tous les comptes bancaires disponibles.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          // Grille des banques disponibles
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
                  onTap: () => context.go('/main/banks/details', extra: bank),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              bank.name.substring(0, 1),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            bank.name,
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
}