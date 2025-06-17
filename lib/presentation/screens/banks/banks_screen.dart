import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jamaa_frontend_mobile/core/providers/auth_provider.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/build_accounts_summary.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

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
                    dashboardProvider.error!.message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
                  buildAccountsSummary(context, dashboardProvider),
                  
                  const SizedBox(height: 32),
                  
                  // Liste des comptes bancaires
                  // buildBankAccountsList(context, dashboardProvider),
                  
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
}