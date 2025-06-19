import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void proceedToConfirmation(String transferType, BuildContext context, GlobalKey<FormState> _formKey, TextEditingController _recipientController, TextEditingController _amountController, TextEditingController _reasonController, TextEditingController _bankAccountController, TextEditingController _bankAmountController, TextEditingController _bankReasonController, String? _selectedBank) {
    if (!_formKey.currentState!.validate()) return;

    Map<String, dynamic> transferData;

    switch (transferType) {
      case 'user':
        transferData = {
          'type': 'user',
          'recipient': _recipientController.text,
          'amount': double.parse(_amountController.text),
          'reason': _reasonController.text,
        };
        break;
      case 'bank':
        if (_selectedBank == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Veuillez sélectionner une banque')),
          );
          return;
        }
        transferData = {
          'type': 'bank',
          'bank': _selectedBank,
          'accountNumber': _bankAccountController.text,
          'amount': double.parse(_bankAmountController.text),
          'reason': _bankReasonController.text,
        };
        break;
      default:
        return;
    }

    context.go('/main/transfer/confirmation', extra: transferData);
  }