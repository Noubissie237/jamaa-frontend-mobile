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
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Section principale avec icône et montant
          Row(
            children: [
              // Icône de transaction
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _getTransactionColor(transaction.type).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: _getTransactionColor(transaction.type).withValues(alpha: 0.2),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  _getTransactionIcon(transaction.type),
                  size: 50,
                  color: _getTransactionColor(transaction.type),
                ),
              )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut)
                  .then(delay: 200.ms)
                  .shimmer(duration: 1000.ms),
              
              const SizedBox(width: 32),
              
              // Montant et titre
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Montant
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${isCredit ? '+' : ''}${transaction.formattedAmount}',
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isCredit ? Colors.green : Colors.red,
                          fontSize: 42,
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 600.ms)
                        .slideX(begin: 0.3, end: 0),
                    
                    const SizedBox(height: 12),
                    
                    // Titre
                    Text(
                      transaction.title ?? 'Transaction ${transaction.typeLabel}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 600.ms)
                        .slideX(begin: 0.3, end: 0),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Ligne de séparation
          Container(
            height: 1,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  theme.dividerColor.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Section statut étendue
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Indicateur de statut animé
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 2000.ms),
                
                const SizedBox(width: 16),
                
                // Texte du statut
                Expanded(
                  child: Text(
                    transaction.statusLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 500.ms, duration: 600.ms)
              .slideY(begin: 0.3, end: 0)
              .then(delay: 1000.ms)
              .shimmer(duration: 1500.ms, color: statusColor.withValues(alpha: 0.1)),
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
              transaction.senderAccountNumber ?? transaction.idAccountSender,
              theme,
            ),

            _buildInfoRow(
              'Compte destinataire',
              transaction.receiverAccountNumber ?? transaction.idAccountReceiver,
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
       
        // Télécharger le reçu
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _downloadReceipt(context, transaction),
            icon: const Icon(Icons.download),
            label: const Text('Télécharger le reçu'),
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

  void _downloadReceipt(BuildContext context, Transaction transaction) {
    // TODO: Implémenter le téléchargement de reçu
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Téléchargement du reçu à venir'),
      ),
    );
  }

}