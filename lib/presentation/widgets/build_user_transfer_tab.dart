import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/beneficiary_type_selector.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/build_balance_card.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/build_quick_amount.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/custom_text_field.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/proceed_to_confirmation.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/qr_scanner_screen.dart';

// Enum pour les types de bénéficiaire
enum BeneficiaryType {
  phone('Téléphone', Icons.phone, 'ex: 690232120'),
  account('Numéro de compte', Icons.credit_card, 'ex: 2025-DOF606'),
  scan('Scanner QR Code', Icons.qr_code_scanner, 'Scanner un code QR');

  const BeneficiaryType(this.label, this.icon, this.hint);
  final String label;
  final IconData icon;
  final String hint;
}

// État global pour maintenir le type sélectionné
class _BeneficiaryState {
  static BeneficiaryType selectedType = BeneficiaryType.phone;
}

Widget buildUserTransferTab(
  BuildContext context, 
  TextEditingController _recipientController, 
  TextEditingController _amountController, 
  TextEditingController _reasonController, 
  TextEditingController _bankAccountController, 
  TextEditingController _bankAmountController, 
  TextEditingController _bankReasonController, 
  String? _selectedBank, 
  GlobalKey<FormState> _formKey
) {
  return _UserTransferContent(
    recipientController: _recipientController,
    amountController: _amountController,
    reasonController: _reasonController,
    bankAccountController: _bankAccountController,
    bankAmountController: _bankAmountController,
    bankReasonController: _bankReasonController,
    selectedBank: _selectedBank,
    formKey: _formKey,
  );
}

class _UserTransferContent extends StatefulWidget {
  final TextEditingController recipientController;
  final TextEditingController amountController;
  final TextEditingController reasonController;
  final TextEditingController bankAccountController;
  final TextEditingController bankAmountController;
  final TextEditingController bankReasonController;
  final String? selectedBank;
  final GlobalKey<FormState> formKey;

  const _UserTransferContent({
    required this.recipientController,
    required this.amountController,
    required this.reasonController,
    required this.bankAccountController,
    required this.bankAmountController,
    required this.bankReasonController,
    required this.selectedBank,
    required this.formKey,
  });

  @override
  State<_UserTransferContent> createState() => _UserTransferContentState();
}

class _UserTransferContentState extends State<_UserTransferContent> {
  BeneficiaryType get _selectedBeneficiaryType => _BeneficiaryState.selectedType;
  
  set _selectedBeneficiaryType(BeneficiaryType type) {
    _BeneficiaryState.selectedType = type;
  }

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
        // Changer automatiquement vers "Numéro de compte" et préremplir le champ
        setState(() {
          _selectedBeneficiaryType = BeneficiaryType.account;
          widget.recipientController.text = result;
        });

        // Afficher une confirmation
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('QR Code scanné : $result'),
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

  // Validation selon le type sélectionné
  String? _validateBeneficiary(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez saisir ${_selectedBeneficiaryType.label.toLowerCase()}';
    }

    switch (_selectedBeneficiaryType) {
      case BeneficiaryType.phone:
        // Validation pour numéro de téléphone camerounais
        final phoneRegex = RegExp(r'^[6][0-9]{8}$');
        if (!phoneRegex.hasMatch(value)) {
          return 'Format de téléphone invalide (ex: 690232120)';
        }
        break;
      
      case BeneficiaryType.account:
        // Validation pour numéro de compte
        if (value.length < 8) {
          return 'Numéro de compte trop court (minimum 8 caractères)';
        }
        break;
      
      case BeneficiaryType.scan:
        // Le scan ne devrait pas arriver ici car il change automatiquement vers account
        break;
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
          // Solde disponible
          buildBalanceCard(),
          
          const SizedBox(height: 24),
          
          // Bénéficiaire
          Text(
            'Bénéficiaire',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 600.ms),
          
          const SizedBox(height: 12),

          // Sélecteur de type de bénéficiaire
          BeneficiaryTypeSelector(
            selectedType: _selectedBeneficiaryType,
            onTypeChanged: (type) {
              setState(() {
                _selectedBeneficiaryType = type;
                // Effacer le champ quand on change de type
                widget.recipientController.clear();
              });
              
              // Si l'utilisateur choisit de scanner, lancer le scan immédiatement
              if (type == BeneficiaryType.scan) {
                _scanQRCode();
              }
            },
          )
              .animate()
              .fadeIn(delay: 250.ms, duration: 600.ms),

          const SizedBox(height: 16),

          // Champ de saisie adaptatif
          if (_selectedBeneficiaryType != BeneficiaryType.scan)
            CustomTextField(
              controller: widget.recipientController,
              label: _selectedBeneficiaryType.label,
              hint: _selectedBeneficiaryType.hint,
              prefixIcon: _selectedBeneficiaryType.icon,
              keyboardType: _selectedBeneficiaryType == BeneficiaryType.phone 
                  ? TextInputType.number 
                  : TextInputType.text,
              inputFormatters: _selectedBeneficiaryType == BeneficiaryType.phone
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : null,
              validator: _validateBeneficiary,
              suffixIcon: _selectedBeneficiaryType == BeneficiaryType.account
                  ? IconButton(
                      icon: const Icon(Icons.qr_code_scanner),
                      onPressed: _scanQRCode,
                      tooltip: 'Scanner QR Code',
                    )
                  : null,
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 600.ms)
                .slideX(begin: -0.2, end: 0),

          // Message pour le scan
          if (_selectedBeneficiaryType == BeneficiaryType.scan)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    size: 48,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Appuyez pour scanner un QR Code',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _scanQRCode,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Scanner maintenant'),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 600.ms),
          
          const SizedBox(height: 24),
          
          // Montant
          Text(
            'Montant',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 600.ms),
          
          const SizedBox(height: 12),
          
          CustomTextField(
            controller: widget.amountController,
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
              if (amount < 100) {
                return 'Montant minimum : 100 XAF';
              }
              return null;
            },
          )
              .animate()
              .fadeIn(delay: 500.ms, duration: 600.ms)
              .slideX(begin: 0.2, end: 0),
          
          const SizedBox(height: 16),
          
          // Montants rapides
          buildQuickAmounts(context, widget.amountController),
          
          const SizedBox(height: 24),
          
          // Bouton continuer
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => proceedToConfirmation(
                'user', 
                context, 
                widget.formKey, 
                widget.recipientController, 
                widget.amountController, 
                widget.reasonController, 
                widget.bankAccountController, 
                widget.bankAmountController, 
                widget.bankReasonController, 
                widget.selectedBank
              ),
              child: const Text('Continuer'),
            ),
          )
              .animate()
              .fadeIn(delay: 800.ms, duration: 600.ms)
              .slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }
}