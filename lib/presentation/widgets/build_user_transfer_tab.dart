import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/build_balance_card.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/build_quick_amount.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/custom_text_field.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/proceed_to_confirmation.dart';

Widget buildUserTransferTab(BuildContext context, TextEditingController _recipientController, TextEditingController _amountController, TextEditingController _reasonController, TextEditingController _bankAccountController, TextEditingController _bankAmountController, TextEditingController _bankReasonController, String? _selectedBank, GlobalKey<FormState> _formKey) {
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
          
          CustomTextField(
            controller: _recipientController,
            label: 'Téléphone',
            hint: 'ex: 690232120',
            prefixIcon: Icons.person_outline,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez saisir le téléphone du bénéficiaire';
              }
              return null;
            },
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 600.ms)
              .slideX(begin: -0.2, end: 0),
          
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
            controller: _amountController,
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
          buildQuickAmounts(context, _amountController),
          
          const SizedBox(height: 24),
          
          // Bouton continuer
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => proceedToConfirmation('user', context, _formKey, _recipientController, _amountController, _reasonController, _bankAccountController, _bankAmountController, _bankReasonController, _selectedBank),
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