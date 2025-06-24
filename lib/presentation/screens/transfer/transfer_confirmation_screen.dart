import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jamaa_frontend_mobile/utils/account_service.dart';
import 'package:jamaa_frontend_mobile/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/providers/transaction_provider.dart';
import '../../../core/providers/transfert_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/card_provider.dart';
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Confirmation du transfert'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Récapitulatif du transfert
            _buildTransferSummary(theme),
            
            const SizedBox(height: 20),
            
            // Détails de la transaction
            _buildTransferDetails(theme),
            
            const SizedBox(height: 20),
            
            // Frais de transfert
            _buildFeesSection(theme),
            
            const SizedBox(height: 20),
            
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
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.primaryColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Icône du type de transfert
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
              ),
              child: Icon(
                _getTransferIcon(transferType),
                size: 40,
                color: Colors.white,
              ),
            )
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut)
                .then(delay: 200.ms)
                .shimmer(duration: 1000.ms, color: Colors.white.withValues(alpha: 0.5)),
            
            const SizedBox(height: 20),
            
            // Montant
            Text(
              '${amount.toStringAsFixed(0)} XAF',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
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
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.9),
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
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'En attente de confirmation',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: theme.primaryColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Détails du transfert',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            ..._buildTransferDetailRows(transferType, theme),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 600.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Future<String?> getUserNameByAccountNumber(String accountNumber) async {
    try {
      final transfertProvider = Provider.of<TransfertProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final userId = await transfertProvider.getUserIdByAccountNumber(accountNumber);
      if (userId == null) return null;
      
      final user = await authProvider.getUserById(userId);
      if (user != null) {
        return '${user.firstName} ${user.lastName}'.toUpperCase();
      }
      
      return null;
    } catch (e) {
      debugPrint('Erreur getUserNameByAccountNumber: $e');
      return null;
    }
  }


List<Widget> _buildTransferDetailRows(String transferType, ThemeData theme) {
  final details = <Widget>[];
  final cardProvider = Provider.of<CardProvider>(context, listen: false);

  debugPrint("==============================");
  cardProvider.getCardBasicInfo(unformatAccountNumber(widget.transferData['receiverAccountNumber']));

  switch (transferType) {
    case 'user':
      details.addAll([
        _buildDetailRow('Bénéficiaire', widget.transferData['recipient'], theme, Icons.person),
        // Utiliser FutureBuilder pour gérer l'appel asynchrone
        FutureBuilder<String?>(
          future: getUserNameByAccountNumber(widget.transferData['recipient']),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildDetailRow(
                'Nom', 
                'Chargement...', 
                theme, 
                Icons.note,
                trailing: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            } else if (snapshot.hasError) {
              return _buildDetailRow('Nom', 'Erreur de chargement', theme, Icons.note);
            } else {
              return _buildDetailRow(
                'Nom', 
                snapshot.data ?? 'Nom indisponible', 
                theme, 
                Icons.note
              );
            }
          },
        ),
        _buildDetailRow('Type', 'Transfert utilisateur', theme, Icons.swap_horiz),
      ]);
      break;
    case 'bank':
      details.addAll([
        _buildDetailRow('Banque expéditrice', widget.transferData['senderBankName'], theme, Icons.account_balance),
        _buildDetailRow('Compte destinataire', widget.transferData['receiverAccountNumber'], theme, Icons.credit_card),
        _buildDetailRow('Type', 'Transfert bancaire', theme, Icons.swap_horiz),
      ]);
      break;
  }
  
  details.addAll([
    _buildDetailRow('Montant', '${widget.transferData['amount'].toStringAsFixed(0)} XAF', theme, Icons.money),
    _buildDetailRow('Date', _getCurrentDateTime(), theme, Icons.schedule),
  ]);
  
  return details;
}


Widget _buildDetailRow(String label, String value, ThemeData theme, IconData icon, {Widget? trailing}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.primaryColor.withValues(alpha: 0.7)),
        const SizedBox(width: 12),
        SizedBox(
          width: 120,
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
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        // Ajouter le widget trailing s'il est fourni
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing,
        ],
      ],
    ),
  );
}

  Widget _buildFeesSection(ThemeData theme) {
    final amount = widget.transferData['amount'] as double;
    final fees = _calculateFees(amount);
    final total = amount + fees;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calculate, color: theme.primaryColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Récapitulatif financier',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            _buildFinancialRow('Montant du transfert', amount, theme),
            _buildFinancialRow('Frais de service', fees, theme),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(thickness: 1),
            ),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.primaryColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total à débiter',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  Text(
                    '${total.toStringAsFixed(0)} XAF',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                      fontSize: 20,
                    ),
                  ),
                ],
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

  Widget _buildFinancialRow(String label, double amount, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '${amount.toStringAsFixed(0)} XAF',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinSection(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: theme.primaryColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Authentification sécurisée',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: InputDecoration(
                labelText: 'Code PIN',
                hintText: 'Saisissez votre code PIN à 4 chiffres',
                prefixIcon: Icon(Icons.lock_outline, color: theme.primaryColor),
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.primaryColor.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.primaryColor, width: 2),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Colors.blue[700],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Votre code PIN est requis pour sécuriser cette transaction',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
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
          child: Consumer3<TransactionProvider, TransfertProvider, CardProvider>(
            builder: (context, transactionProvider, transfertProvider, cardProvider, child) {
              final isLoading = _isProcessing || transfertProvider.isTransferring || cardProvider.isLoading;
              
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isLoading 
                        ? [Colors.grey, Colors.grey] 
                        : [Colors.green, Colors.green.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: (isLoading ? Colors.grey : Colors.green).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: LoadingButton(
                  onPressed: isLoading ? null : _processTransfer,
                  isLoading: isLoading,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Confirmer le transfert',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 16),
        
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _isProcessing ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(
                color: _isProcessing ? Colors.grey : Theme.of(context).primaryColor,
                width: 1.5,
              ),
            ),
            child: Text(
              'Modifier les détails',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _isProcessing ? Colors.grey : Theme.of(context).primaryColor,
              ),
            ),
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
        return Icons.account_balance_outlined;
      default:
        return Icons.send_outlined;
    }
  }

  String _getTransferDescription(String transferType) {
    switch (transferType) {
      case 'user':
        return 'Transfert vers utilisateur JAMAA';
      case 'bank':
        return 'Transfert vers compte bancaire';
      default:
        return 'Transfert';
    }
  }

  double _calculateFees(double amount) {
    final transferType = widget.transferData['type'] as String;
    
    // Frais différentiés par type de transfert
    if (transferType == 'user') {
      // Frais pour transfert utilisateur
      return amount * 0;
    } else {
      // Frais pour transfert bancaire (plus élevés)
      if (amount <= 1000) return 100;
      if (amount <= 5000) return 200;
      if (amount <= 25000) return 500;
      if (amount <= 100000) return 1000;
      return amount * 0.015; // 1.5% pour les gros montants
    }
  }

  String _getCurrentDateTime() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  Future<void> _processTransfer() async {
    if (_isProcessing) return;

    // Validation du PIN
    if (_pinController.text.trim().length != 4) {
      _showErrorDialog('Veuillez saisir un code PIN à 4 chiffres');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final transferType = widget.transferData['type'] as String;
      
      if (transferType == 'user') {
        await _processUserTransfer();
      } else if (transferType == 'bank') {
        await _processBankTransfer();
      } else {
        _showErrorDialog('Type de transfert non supporté');
      }

    } catch (e) {
      debugPrint('[TRANSFER] Erreur inattendue: $e');
      _showErrorDialog('Une erreur inattendue s\'est produite');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _processUserTransfer() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final transfertProvider = Provider.of<TransfertProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final pin = prefs.getString('user_pin');
    
    // Vérifier que l'utilisateur est connecté
    if (authProvider.currentUser == null) {
      _showErrorDialog('Vous devez être connecté pour effectuer un transfert');
      return;
    }

    if (pin != _pinController.text.trim()) {
      _showErrorDialog('Code PIN incorrect');
      return;
    }

    // Récupérer les informations du transfert
    final recipientPhone = widget.transferData['recipient'] as String;
    final amount = widget.transferData['amount'] as double;
    final senderPhone = authProvider.currentUser!.phone;

    debugPrint('[TRANSFER] Début du transfert utilisateur');
    debugPrint('[TRANSFER] Expéditeur: $senderPhone');
    debugPrint('[TRANSFER] Bénéficiaire: $recipientPhone');
    debugPrint('[TRANSFER] Montant: $amount XAF');

    // Vérifier qu'on ne transfère pas vers soi-même
    if (senderPhone == recipientPhone) {
      _showErrorDialog('Vous ne pouvez pas effectuer un transfert vers votre propre compte');
      return;
    }

    try {
      // Étape 1: Récupérer l'ID du compte expéditeur
      debugPrint('[TRANSFER] Récupération de l\'ID du compte expéditeur...');
      final senderAccountId = await AccountService.getAccountIdByPhone(senderPhone);
      
      if (senderAccountId == null) {
        _showErrorDialog('Impossible de récupérer votre compte. Veuillez réessayer.');
        return;
      }
      
      debugPrint('[TRANSFER] ID compte expéditeur: $senderAccountId');

      // Étape 2: Récupérer l'ID du compte bénéficiaire
      debugPrint('[TRANSFER] Récupération de l\'ID du compte bénéficiaire...');
      final receiverAccountId = await  AccountService.getAccountIdByPhone(recipientPhone);
      
      if (receiverAccountId == null) {
        _showErrorDialog('Le bénéficiaire n\'a pas été trouvé. Vérifiez le numéro bénéficiaire.');
        return;
      }
      
      debugPrint('[TRANSFER] ID compte bénéficiaire: $receiverAccountId');

      // Étape 3: Effectuer le transfert
      debugPrint('[TRANSFER] Exécution du transfert...');
      final success = await transfertProvider.makeAppTransfert(
        senderAccountId: senderAccountId,
        receiverAccountId: receiverAccountId,
        amount: amount,
      );

      if (success) {
        debugPrint('[TRANSFER] Transfert réussi!');
        _showSuccessDialog();
      } else {
        debugPrint('[TRANSFER] Échec du transfert: ${transfertProvider.error?.message}');
        _showErrorDialog(
          transfertProvider.error?.message ?? 'Le transfert a échoué. Veuillez réessayer.'
        );
      }

    } catch (e) {
      debugPrint('[TRANSFER] Erreur lors du transfert: $e');
      _showErrorDialog('Erreur lors du transfert: ${e.toString()}');
    }
  }

  Future<void> _processBankTransfer() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final transfertProvider = Provider.of<TransfertProvider>(context, listen: false);
    final cardProvider = Provider.of<CardProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final pin = prefs.getString('user_pin');
    
    // Vérifier que l'utilisateur est connecté
    if (authProvider.currentUser == null) {
      _showErrorDialog('Vous devez être connecté pour effectuer un transfert');
      return;
    }

    if (pin != _pinController.text.trim()) {
      _showErrorDialog('Code PIN incorrect');
      return;
    }

    // Récupérer les informations du transfert bancaire
    final senderBankId = widget.transferData['senderBankId'] as String;
    final receiverAccountNumber = widget.transferData['receiverAccountNumber'] as String;
    final receiverAccountNumberUnformatted = unformatAccountNumber(receiverAccountNumber);
    final amount = widget.transferData['amount'] as double;

    debugPrint('[BANK_TRANSFER] Début du transfert bancaire');
    debugPrint('[BANK_TRANSFER] Banque expéditrice ID: $senderBankId');
    debugPrint('[BANK_TRANSFER] Compte destinataire: $receiverAccountNumberUnformatted');
    debugPrint('[BANK_TRANSFER] Montant: $amount XAF');

    try {
      // Étape 1: Récupérer les informations de la carte destinataire
      debugPrint('[BANK_TRANSFER] Récupération des informations de la carte destinataire...');
      final cardInfo = await cardProvider.getCardBasicInfo(receiverAccountNumberUnformatted);
      
      if (cardInfo == null) {
        _showErrorDialog('Carte destinataire introuvable. Vérifiez le numéro de compte.');
        return;
      }
      
      debugPrint('[BANK_TRANSFER] Carte trouvée: ${cardInfo.holderName} - ${cardInfo.bankName}');

      // Étape 2: Récupérer l'ID de la banque destinataire
      // On utilise fetchBankAccountsByCardNumber pour obtenir plus d'informations

      await cardProvider.fetchBankAccountsByCardNumber(receiverAccountNumberUnformatted);
      
      if (cardProvider.userBankAccounts.isEmpty) {
        _showErrorDialog('Impossible de récupérer les informations de la banque destinataire.');
        return;
      }

      final receiverBankAccount = cardProvider.userBankAccounts.first;
      final receiverBankId = receiverBankAccount.id;
      
      debugPrint('[BANK_TRANSFER] ID banque destinataire: $receiverBankId');

      // Étape 3: Effectuer le transfert bancaire
      debugPrint('[BANK_TRANSFER] Exécution du transfert bancaire...');
      final success = await transfertProvider.makeBankTransfert(
        senderBankId: int.parse(senderBankId),
        receiverBankId: int.parse(receiverBankId),
        amount: amount,
      );

      if (success) {
        debugPrint('[BANK_TRANSFER] Transfert bancaire réussi! ID: ${transfertProvider.lastBankTransfertId}');
        _showSuccessDialog();
      } else {
        debugPrint('[BANK_TRANSFER] Échec du transfert bancaire: ${transfertProvider.error?.message}');
        _showErrorDialog(
          transfertProvider.error?.message ?? 'Le transfert bancaire a échoué. Veuillez réessayer.'
        );
      }

    } catch (e) {
      debugPrint('[BANK_TRANSFER] Erreur lors du transfert bancaire: $e');
      _showErrorDialog('Erreur lors du transfert bancaire: ${e.toString()}');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.error_outline, color: Colors.red[600], size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Erreur de transfert', 
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.red[800],
              height: 1.4,
            ),
          ),
        ),
        actions: [
          Container(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Fermer',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    final transferType = widget.transferData['type'] as String;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.green[200]!, width: 2),
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green[600],
                size: 40,
              ),
            )
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut)
                .then(delay: 200.ms)
                .shimmer(duration: 1000.ms, color: Colors.green.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              'Transfert réussi !',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Votre ${transferType == 'user' ? 'transfert utilisateur' : 'transfert bancaire'} a été effectué avec succès !',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green[800],
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  children: [
                    _buildSuccessDetailRow(
                      'Montant',
                      '${widget.transferData['amount'].toStringAsFixed(0)} XAF',
                      Icons.money,
                      Colors.green[700]!,
                    ),
                    const SizedBox(height: 12),
                    if (transferType == 'user')
                      _buildSuccessDetailRow(
                        'Bénéficiaire',
                        widget.transferData['recipient'],
                        Icons.person,
                        Colors.blue[700]!,
                      )
                    else 
                      _buildSuccessDetailRow(
                        'Compte destinataire',
                        widget.transferData['receiverAccountNumber'],
                        Icons.credit_card,
                        Colors.blue[700]!,
                      ),
                    const SizedBox(height: 12),
                    _buildSuccessDetailRow(
                      'Date et heure',
                      _getCurrentDateTime(),
                      Icons.schedule,
                      Colors.grey[700]!,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          Container(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                // Fermer le dialog et retourner aux écrans précédents
                Navigator.pop(context); // Fermer le dialog
                Navigator.pop(context); // Retourner à l'écran de transfert
                Navigator.pop(context); // Retourner au dashboard
              },
              child: const Text(
                'Retour au tableau de bord',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessDetailRow(String label, String value, IconData icon, Color iconColor) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}