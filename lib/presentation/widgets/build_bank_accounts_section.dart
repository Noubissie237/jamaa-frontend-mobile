import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:jamaa_frontend_mobile/core/providers/dashboard_provider.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/bank_account_card.dart';
import 'package:go_router/go_router.dart';

Widget buildBankAccountsSection(BuildContext context) {
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
