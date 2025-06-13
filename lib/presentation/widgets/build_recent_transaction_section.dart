import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jamaa_frontend_mobile/core/providers/transaction_provider.dart';
import 'package:provider/provider.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/transaction_item.dart';
import 'package:go_router/go_router.dart';

Widget buildRecentTransactionSection(BuildContext context) {
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
                      style: BorderStyle.solid,
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
