import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/bank_card.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/card_carousel.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/dashboard_provider.dart';
import '../../../core/providers/transaction_provider.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/bank_account_card.dart';
import '../../widgets/transaction_item.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _balanceVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboardData(userId: context.read<AuthProvider>().currentUser!.id.toString());
      context.read<TransactionProvider>().loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header avec salutation
                _buildHeader(),

                const SizedBox(height: 24),

                // Carte de solde
                _buildBalanceSection(),

                const SizedBox(height: 24),

                // Actions rapides
                _buildQuickActions(),

                const SizedBox(height: 24),

                // Comptes bancaires
                _buildBankAccountsSection(),

                const SizedBox(height: 24),

                // Transactions récentes
                _buildRecentTransactionsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    String fullName = 'Utilisateur';
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        fullName = '${user?.firstName.toUpperCase()} ${user?.lastName.toUpperCase()}';
        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bonjour,',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fullName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => context.go('/main/notifications'),
              icon: Stack(
                children: [
                  const Icon(Icons.notifications_outlined, size: 28),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0);
      },
    );
  }

Widget _buildBalanceSection() {
  return Consumer<DashboardProvider>(
    builder: (context, dashboardProvider, child) {
      if (dashboardProvider.isLoading) {
        return Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      // Créer la liste des cartes
      List<Widget> cards = [];
      
      // Ajouter la carte principale
      cards.add(
        BalanceCard(
          balance: dashboardProvider.formattedTotalBalance,
          cardNumber: dashboardProvider.formattedAccountNumber,
          isVisible: _balanceVisible,
          onToggleVisibility: () {
            setState(() {
              _balanceVisible = !_balanceVisible;
            });
          },
          onRecharge: () {
            // TODO: Action de recharge
          },
        ),
      );
      
      // Ajouter les cartes bancaires
      for (final account in dashboardProvider.bankAccounts) {
        cards.add(
          BankCard(
            bankAccount: account,
            isVisible: _balanceVisible,
            onToggleVisibility: () {
              setState(() {
                _balanceVisible = !_balanceVisible;
              });
            },
            onRecharge: () {
              // TODO: Action de recharge pour ce compte
            },
            onTap: () {
              // TODO: Naviguer vers les détails du compte
            },
          ),
        );
      }

      return CardCarousel(
        cards: cards,
        height: 220,
        viewportFraction: 0.95,
      )
      .animate()
      .fadeIn(delay: 200.ms, duration: 600.ms)
      .slideY(begin: 0.3, end: 0);
    },
  );
}

  Widget _buildQuickActions() {
    final actions = [
      QuickAction(
        icon: Icons.send,
        label: 'Transférer',
        color: Colors.blue,
        onTap: () => context.go('/main/transfer'),
      ),
      QuickAction(
        icon: Icons.add_circle,
        label: 'Déposer',
        color: Colors.green,
        onTap: () => context.go('/main/deposit'),
      ),
      QuickAction(
        icon: Icons.remove_circle,
        label: 'Retirer',
        color: Colors.orange,
        onTap: () => context.go('/main/withdraw'),
      ),
      QuickAction(
        icon: Icons.payment,
        label: 'Payer',
        color: Colors.purple,
        onTap: () => context.go('/main/payments'),
      ),
    ];

    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions rapides',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:
                  actions
                      .map((action) => _buildQuickActionItem(action))
                      .toList(),
            ),
          ],
        )
        .animate()
        .fadeIn(delay: 400.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildQuickActionItem(QuickAction action) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: action.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: action.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(action.icon, color: action.color, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    action.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBankAccountsSection() {
    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, child) {
        return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mes comptes bancaires',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/main/banks'),
                      child: const Text('Voir tout'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (dashboardProvider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (dashboardProvider.bankAccounts.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.account_balance_outlined,
                          size: 48,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Aucun compte bancaire lié',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ajoutez vos comptes bancaires pour commencer',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => context.go('/main/banks/add'),
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter un compte'),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    children:
                        dashboardProvider.bankAccounts
                            .take(2) // Afficher seulement les 2 premiers
                            .map(
                              (account) => BankAccountCard(
                                bankAccount: account,
                                onTap: () {
                                  // TODO: Naviguer vers les détails du compte
                                },
                              ),
                            )
                            .toList(),
                  ),
              ],
            )
            .animate()
            .fadeIn(delay: 600.ms, duration: 600.ms)
            .slideY(begin: 0.3, end: 0);
      },
    );
  }

  Widget _buildRecentTransactionsSection() {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transactions récentes',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/main/transactions'),
                      child: const Text('Voir tout'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (transactionProvider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (transactionProvider.recentTransactions.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.history_outlined,
                          size: 48,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Aucune transaction récente',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Vos transactions apparaîtront ici',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    children:
                        transactionProvider.recentTransactions
                            .map(
                              (transaction) => TransactionItem(
                                transaction: transaction,
                                onTap:
                                    () => context.go(
                                      '/main/transactions/detail/${transaction.id}',
                                    ),
                              ),
                            )
                            .toList(),
                  ),
              ],
            )
            .animate()
            .fadeIn(delay: 800.ms, duration: 600.ms)
            .slideY(begin: 0.3, end: 0);
      },
    );
  }

  Future<void> _refreshData() async {
    await Future.wait([
      context.read<DashboardProvider>().refreshBalance(userId: context.read<AuthProvider>().currentUser!.id.toString()),
      context.read<TransactionProvider>().loadTransactions(),
    ]);
  }
}

class QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
