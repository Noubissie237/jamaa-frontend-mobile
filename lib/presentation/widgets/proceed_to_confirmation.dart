import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jamaa_frontend_mobile/utils/utils.dart';

void proceedToConfirmation(
  String transferType, 
  BuildContext context, 
  GlobalKey<FormState> formKey, 
  TextEditingController recipientController, 
  TextEditingController amountController, 
  TextEditingController reasonController, 
  TextEditingController bankAccountController, 
  TextEditingController bankAmountController, 
  TextEditingController bankReasonController, 
  String? selectedBankName, {
  String? selectedBankId, // Nouveau paramètre pour l'ID de la banque
}) {
  if (!formKey.currentState!.validate()) return;

  Map<String, dynamic> transferData;

  switch (transferType) {
    case 'user':
      transferData = {
        'type': 'user',
        'recipient': recipientController.text,
        'amount': double.parse(amountController.text),
        'reason': reasonController.text.isEmpty ? 'Transfert utilisateur' : reasonController.text,
      };
      break;
      
    case 'bank':
      if (selectedBankName == null || selectedBankId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner une banque'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      transferData = {
        'type': 'bank',
        'senderBankId': selectedBankId, // ID de la banque expéditrice
        'senderBankName': selectedBankName, // Nom pour affichage
        'receiverAccountNumber': bankAccountController.text, // Numéro de compte destinataire
        'amount': double.parse(bankAmountController.text),
        'reason': bankReasonController.text.isEmpty ? 'Transfert bancaire' : bankReasonController.text,
      };
      break;
      
    default:
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Type de transfert non supporté'),
          backgroundColor: Colors.red,
        ),
      );
      return;
  }

  // Navigation vers la page de confirmation
  executeActionWithVerification(context, () => context.go('/main/transfer/confirmation', extra: transferData));
}