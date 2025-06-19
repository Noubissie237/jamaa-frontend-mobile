import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/transaction_provider.dart';
import '../../widgets/loading_button.dart';

class TransferConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> transferData;

  const TransferConfirmationScreen({
    super.key,
    required this.transferData,
  });

  @override
  State<TransferConfirmationScreen> createState() => _TransferConfirmationScreenState();
}

class _TransferConfirmationScreenState extends State<TransferConfirmationScreen> {
  final _pinController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmation'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Récapitulatif du transfert
            _buildTransferSummary(theme),
            
            const SizedBox(height: 24),
            
            // Détails de la transaction
            _buildTransferDetails(theme),
            
            const SizedBox(height: 24),
            
            // Frais de transfert
            _buildFeesSection(theme),
            
            const SizedBox(height: 24),
            
            // Code PIN
            _buildPinSection(theme),
            
            const SizedBox(height: 32),
            
            // Boutons d'action
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferSummary(ThemeData theme) {
    final transferType = widget.transferData['type'] as String;
    final amount = widget.transferData['amount'] as double;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Icône du type de transfert
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                _getTransferIcon(transferType),
                size: 40,
                color: theme.primaryColor,
              ),
            )
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut)
                .then(delay: 200.ms)
                .shimmer(duration: 1000.ms),
            
            const SizedBox(height: 16),
            
            // Montant
            Text(
              '${amount.toStringAsFixed(0)} XAF',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0),
            
            const SizedBox(height: 8),
            
            // Description
            Text(
              _getTransferDescription(transferType),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0),
            
            const SizedBox(height: 16),
            
            // Badge de confirmation
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'En attente de confirmation',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.orange,
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

  Widget _buildTransferDetails(ThemeData theme) {
    final transferType = widget.transferData['type'] as String;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Détails du transfert',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ..._buildTransferDetailRows(transferType, theme),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 600.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  List<Widget> _buildTransferDetailRows(String transferType, ThemeData theme) {
    final details = <Widget>[];
    
    switch (transferType) {
      case 'user':
        details.addAll([
          _buildDetailRow('Bénéficiaire', widget.transferData['recipient'], theme),
          _buildDetailRow('Type', 'Transfert utilisateur', theme),
        ]);
        break;
      case 'bank':
        details.addAll([
          _buildDetailRow('Banque', widget.transferData['bank'], theme),
          _buildDetailRow('Compte', widget.transferData['accountNumber'], theme),
          _buildDetailRow('Type', 'Transfert bancaire', theme),
        ]);
        break;
    }
    
    details.addAll([
      _buildDetailRow('Montant', '${widget.transferData['amount'].toStringAsFixed(0)} XAF', theme),
      _buildDetailRow('Date', _getCurrentDateTime(), theme),
    ]);
    
    return details;
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
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
                color: theme.colorScheme.onSurface.withOpacity(0.7),
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

  Widget _buildFeesSection(ThemeData theme) {
    final amount = widget.transferData['amount'] as double;
    final fees = _calculateFees(amount);
    final total = amount + fees;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Frais de transfert',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildDetailRow('Montant', '${amount.toStringAsFixed(0)} XAF', theme),
            _buildDetailRow('Frais', '${fees.toStringAsFixed(0)} XAF', theme),
            
            const Divider(),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total à débiter',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${total.toStringAsFixed(0)} XAF',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 700.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildPinSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Authentification',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: const InputDecoration(
                labelText: 'Code PIN',
                hintText: 'Saisissez votre code PIN',
                prefixIcon: Icon(Icons.lock_outline),
                counterText: '',
              ),
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Icon(
                  Icons.security,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Votre code PIN est requis pour confirmer cette transaction',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 800.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Consumer<TransactionProvider>(
            builder: (context, transactionProvider, child) {
              return LoadingButton(
                onPressed: _isProcessing ? null : _processTransfer,
                isLoading: _isProcessing,
                child: const Text('Confirmer le transfert'),
              );
            },
          ),
        ),
        
        const SizedBox(height: 12),
        
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _isProcessing ? null : () => Navigator.pop(context),
            child: const Text('Modifier'),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 900.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  IconData _getTransferIcon(String transferType) {
    switch (transferType) {
      case 'user':
        return Icons.person_outline;
      case 'bank':
        return Icons.account_balance;
      case 'mobile':
        return Icons.phone_android;
      default:
        return Icons.send;
    }
  }

  String _getTransferDescription(String transferType) {
    switch (transferType) {
      case 'user':
        return 'Transfert vers utilisateur JAMAA';
      case 'bank':
        return 'Transfert vers compte bancaire';
      case 'mobile':
        return 'Transfert Mobile Money';
      default:
        return 'Transfert';
    }
  }

  double _calculateFees(double amount) {
    // Simulation du calcul des frais
    if (amount <= 1000) return 50;
    if (amount <= 5000) return 100;
    if (amount <= 25000) return 250;
    if (amount <= 100000) return 500;
    return amount * 0.01; // 1% pour les gros montants
  }

  String _getCurrentDateTime() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} à ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _processTransfer() async {

  }

}