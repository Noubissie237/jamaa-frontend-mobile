import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/transaction_provider.dart';
import '../../../core/models/transaction.dart';

class TransactionDetailScreen extends StatelessWidget {
  final String transactionId;

  const TransactionDetailScreen({
    super.key,
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail de la transaction'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _shareTransaction(context),
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, transactionProvider, child) {
          final transaction = transactionProvider.transactions
              .where((t) => t.transactionId == transactionId)
              .firstOrNull;

          if (transaction == null) {
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
                    'Transaction introuvable',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Retour'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Statut et montant
                _buildStatusCard(transaction, theme),
                
                const SizedBox(height: 24),
                
                // Informations principales
                _buildInfoSection(transaction, theme),
                
                const SizedBox(height: 24),
                
                // Détails supplémentaires
                _buildDetailsSection(transaction, theme),
                
                const SizedBox(height: 32),
                
                // Actions
                _buildActionsSection(context, transaction, theme),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(Transaction transaction, ThemeData theme) {
    final isCredit = transaction.amount > 0;
    final statusColor = _getStatusColor(transaction.status);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Icône de transaction
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _getTransactionColor(transaction.type).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                _getTransactionIcon(transaction.type),
                size: 40,
                color: _getTransactionColor(transaction.type),
              ),
            )
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut)
                .then(delay: 200.ms)
                .shimmer(duration: 1000.ms),
            
            const SizedBox(height: 16),
            
            // Montant
            Text(
              '${isCredit ? '+' : ''}${transaction.formattedAmount}',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isCredit ? Colors.green : Colors.red,
              ),
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0),
            
            const SizedBox(height: 8),
            
            // Titre
            Text(
              transaction.title ?? 'Transaction ${transaction.typeLabel}',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0),
            
            const SizedBox(height: 16),
            
            // Statut
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    transaction.statusLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 500.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(Transaction transaction, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildInfoRow(
              'Type',
              transaction.typeLabel,
              theme,
            ),
            
            _buildInfoRow(
              'Date',
              DateFormat('dd MMMM yyyy à HH:mm', 'fr_FR').format(transaction.createdAtOrDateEvent),
              theme,
            ),
            
            _buildInfoRow(
              'Référence',
              transaction.reference ?? 'TXN-${transaction.transactionId.substring(0, 8).toUpperCase()}',
              theme,
            ),
            
            if (transaction.recipientName != null)
              _buildInfoRow(
                'Bénéficiaire',
                transaction.recipientName!,
                theme,
              ),
            
            if (transaction.recipientPhone != null)
              _buildInfoRow(
                'Téléphone',
                transaction.recipientPhone!,
                theme,
              ),
            
            if (transaction.bankName != null)
              _buildInfoRow(
                'Banque',
                transaction.bankName!,
                theme,
              ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 600.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildDetailsSection(Transaction transaction, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Détails',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildInfoRow(
              'Description',
              transaction.description ?? 'Transaction ${transaction.typeLabel.toLowerCase()}',
              theme,
            ),
            
            _buildInfoRow(
              'Devise',
              transaction.currency,
              theme,
            ),
            
            _buildInfoRow(
              'Montant',
              '${transaction.amount.abs().toStringAsFixed(0)} ${transaction.currency}',
              theme,
            ),
            
            _buildInfoRow(
              'ID Transaction',
              transaction.transactionId,
              theme,
            ),
            
            _buildInfoRow(
              'Compte expéditeur',
              transaction.idAccountSender.toString(),
              theme,
            ),
            
            _buildInfoRow(
              'Compte destinataire',
              transaction.idAccountReceiver.toString(),
              theme,
            ),
            
            if (transaction.metadata != null && transaction.metadata!.isNotEmpty)
              ...transaction.metadata!.entries.map(
                (entry) => _buildInfoRow(
                  entry.key,
                  entry.value.toString(),
                  theme,
                ),
              ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 700.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildActionsSection(BuildContext context, Transaction transaction, ThemeData theme) {
    return Column(
      children: [
        // Répéter la transaction
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _repeatTransaction(context, transaction),
            icon: const Icon(Icons.repeat),
            label: const Text('Répéter cette transaction'),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Télécharger le reçu
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _downloadReceipt(context, transaction),
            icon: const Icon(Icons.download),
            label: const Text('Télécharger le reçu'),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Signaler un problème
        if (transaction.status == TransactionStatus.failed)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _reportProblem(context, transaction),
              icon: const Icon(Icons.report_problem),
              label: const Text('Signaler un problème'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
              ),
            ),
          ),
      ],
    )
        .animate()
        .fadeIn(delay: 800.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.transfert:
        return Icons.send;
      case TransactionType.depot:
        return Icons.add_circle;
      case TransactionType.retrait:
        return Icons.remove_circle;
      case TransactionType.recharge:
        return Icons.payment;
      case TransactionType.virement:
        return Icons.receipt;
    }
  }

  Color _getTransactionColor(TransactionType type) {
    switch (type) {
      case TransactionType.transfert:
        return Colors.blue;
      case TransactionType.depot:
        return Colors.green;
      case TransactionType.retrait:
        return Colors.orange;
      case TransactionType.recharge:
        return Colors.purple;
      case TransactionType.virement:
        return Colors.red;
    }
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.success:
        return Colors.green;
      case TransactionStatus.failed:
        return Colors.red;
    }
  }

  void _shareTransaction(BuildContext context) {
    // TODO: Implémenter le partage de transaction
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Partage de transaction à venir'),
      ),
    );
  }

  void _repeatTransaction(BuildContext context, Transaction transaction) {
    // TODO: Implémenter la répétition de transaction
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Répétition de transaction à venir'),
      ),
    );
  }

  void _downloadReceipt(BuildContext context, Transaction transaction) {
    // TODO: Implémenter le téléchargement de reçu
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Téléchargement du reçu à venir'),
      ),
    );
  }

  void _reportProblem(BuildContext context, Transaction transaction) {
    // TODO: Implémenter le signalement de problème
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Signalement de problème à venir'),
      ),
    );
  }
}