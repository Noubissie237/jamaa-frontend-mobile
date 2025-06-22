import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/build_quick_amount.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/card_number_input_formatter.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/custom_text_field.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/proceed_to_confirmation.dart';
import 'package:jamaa_frontend_mobile/core/models/bank_account.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/qr_scanner_screen.dart';

Widget buildBankTransferTab(
  BuildContext context, 
  TextEditingController bankAccountController, 
  TextEditingController bankAmountController, 
  TextEditingController bankReasonController, 
  String? selectedBankName, // Nom de la banque sélectionnée pour l'affichage
  GlobalKey<FormState> formKey, 
  List<BankAccount> userBankAccounts, // Liste des comptes bancaires de l'utilisateur
  Function(String?, String?) onBankChanged, // Callback (bankId, bankName)
  TextEditingController recipientController,
  TextEditingController amountController,
  TextEditingController reasonController, {
  String? selectedBankId, // ID de la banque sélectionnée
  bool isLoading = false, // État de chargement
}) {
  return _BankTransferContent(
    bankAccountController: bankAccountController,
    bankAmountController: bankAmountController,
    bankReasonController: bankReasonController,
    selectedBankName: selectedBankName,
    formKey: formKey,
    userBankAccounts: userBankAccounts,
    onBankChanged: onBankChanged,
    recipientController: recipientController,
    amountController: amountController,
    reasonController: reasonController,
    selectedBankId: selectedBankId,
    isLoading: isLoading,
  );
}

class _BankTransferContent extends StatefulWidget {
  final TextEditingController bankAccountController;
  final TextEditingController bankAmountController;
  final TextEditingController bankReasonController;
  final String? selectedBankName;
  final GlobalKey<FormState> formKey;
  final List<BankAccount> userBankAccounts;
  final Function(String?, String?) onBankChanged;
  final TextEditingController recipientController;
  final TextEditingController amountController;
  final TextEditingController reasonController;
  final String? selectedBankId;
  final bool isLoading;

  const _BankTransferContent({
    required this.bankAccountController,
    required this.bankAmountController,
    required this.bankReasonController,
    required this.selectedBankName,
    required this.formKey,
    required this.userBankAccounts,
    required this.onBankChanged,
    required this.recipientController,
    required this.amountController,
    required this.reasonController,
    required this.selectedBankId,
    required this.isLoading,
  });

  @override
  State<_BankTransferContent> createState() => _BankTransferContentState();
}

class _BankTransferContentState extends State<_BankTransferContent> {
  // Fonction pour scanner le QR Code
  Future<void> _scanQRCode() async {
    try {
      final result = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (context) => const QRScannerScreen(),
        ),
      );

      if (result != null && result.isNotEmpty) {
        // Préremplir le champ numéro de compte
        setState(() {
          widget.bankAccountController.text = result;
        });

        // Afficher une confirmation
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Numéro de compte scanné : $result'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du scan : ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  // Validation du numéro de compte bancaire
  String? _validateBankAccount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez saisir le numéro de compte';
    }
    
    // Validation pour format carte bancaire (16 chiffres)
    final bankAccountRegex = RegExp(r'^[0-9]{16}$');
    if (!bankAccountRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Format de carte bancaire invalide (16 chiffres requis)';
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          
          // Numéro de compte avec option scanner
          Text(
            'Numéro de carte destinataire',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Boutons de sélection : Saisir manuellement ou Scanner
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Focus sur le champ de texte pour saisie manuelle
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text(
                    'Saisir',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _scanQRCode,
                  icon: const Icon(Icons.qr_code_scanner, size: 18),
                  label: const Text(
                    'Scanner QR',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: widget.bankAccountController,
            label: 'Numéro de carte (1234 5678 9012 3456)',
            hint: 'ex: 1234 5678 9012 3456',
            prefixIcon: Icons.credit_card,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              CardNumberInputFormatter(),
            ],
            validator: _validateBankAccount,
            suffixIcon: IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: _scanQRCode,
              tooltip: 'Scanner QR Code',
            ),
          ),

          const SizedBox(height: 24),
          
          // Banque choisie
          Text(
            'Sélectionner votre banque',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Gestion des états de chargement et liste vide
          if (widget.isLoading)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Chargement de vos banques...'),
                ],
              ),
            )
          else if (widget.userBankAccounts.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(8),
                color: Colors.orange[50],
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Aucun compte bancaire trouvé. Veuillez d\'abord ajouter un compte bancaire.',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            )
          else
            DropdownButtonFormField<String>(
              value: widget.selectedBankId,
              decoration: const InputDecoration(
                labelText: 'Sélectionner une banque',
                prefixIcon: Icon(Icons.account_balance),
              ),
              items: widget.userBankAccounts.map((account) {
                return DropdownMenuItem<String>(
                  value: account.id,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        account.bankName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        '${account.balance.toStringAsFixed(0)} XAF',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: widget.userBankAccounts.isEmpty 
                  ? null 
                  : (String? bankId) {
                      if (bankId != null) {
                        final selectedAccount = widget.userBankAccounts.firstWhere(
                          (account) => account.id == bankId,
                        );
                        widget.onBankChanged(bankId, selectedAccount.bankName);
                      }
                    },
              validator: (value) {
                if (widget.userBankAccounts.isNotEmpty && (value == null || value.isEmpty)) {
                  return 'Veuillez sélectionner une banque';
                }
                return null;
              },
            ),
          
          // Affichage de la banque sélectionnée
          if (widget.selectedBankName != null && widget.selectedBankId != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.blue[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Banque sélectionnée: ${widget.selectedBankName}',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 24),
          
          // Montant
          Text(
            'Montant',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 12),
          
          CustomTextField(
            controller: widget.bankAmountController,
            label: 'Montant (XAF)',
            prefixIcon: Icons.money,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez saisir un montant';
              }
              final amount = int.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'Montant invalide';
              }
              if (amount < 1000) {
                return 'Montant minimum : 1000 XAF';
              }
              
              // Vérification du solde disponible si une banque est sélectionnée
              if (widget.selectedBankId != null) {
                final selectedAccount = widget.userBankAccounts.firstWhere(
                  (account) => account.id == widget.selectedBankId,
                  orElse: () => widget.userBankAccounts.first,
                );
                if (amount > selectedAccount.balance) {
                  return 'Solde insuffisant (${selectedAccount.balance.toStringAsFixed(0)} XAF disponible)';
                }
              }
              
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Montants rapides
          buildQuickAmounts(context, widget.bankAmountController),
          
          const SizedBox(height: 24),
          
          // Bouton continuer
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (widget.userBankAccounts.isEmpty || widget.isLoading)
                  ? null
                  : () => proceedToConfirmation(
                      'bank', 
                      context, 
                      widget.formKey, 
                      widget.recipientController, 
                      widget.amountController, 
                      widget.reasonController, 
                      widget.bankAccountController, 
                      widget.bankAmountController, 
                      widget.bankReasonController, 
                      widget.selectedBankName, // Passer le nom de la banque
                      selectedBankId: widget.selectedBankId, // Passer également l'ID
                    ),
              child: Text(
                widget.isLoading 
                    ? 'Chargement...' 
                    : widget.userBankAccounts.isEmpty 
                        ? 'Aucune banque disponible' 
                        : 'Continuer'
              ),
            ),
          ),
          
          // Message d'aide si pas de comptes
          if (widget.userBankAccounts.isEmpty && !widget.isLoading)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Card(
                color: Colors.grey[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey[600], size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Pour effectuer un transfert bancaire, vous devez d\'abord ajouter un compte bancaire à votre profil.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Navigation vers la page d'ajout de compte bancaire
                          // Navigator.pushNamed(context, '/add-bank-account');
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Ajouter un compte'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
}
