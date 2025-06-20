import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/build_quick_amount.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/custom_text_field.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/proceed_to_confirmation.dart';
import 'package:jamaa_frontend_mobile/core/models/bank_account.dart';

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
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const SizedBox(height: 30),
        
        // Numéro de compte
        CustomTextField(
          controller: bankAccountController,
          label: 'Numéro de compte destinataire',
          prefixIcon: Icons.credit_card,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez saisir le numéro de compte';
            }
            if (value.length < 12) {
              return 'Numéro de compte invalide';
            }
            return null;
          },
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
        if (isLoading)
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
        else if (userBankAccounts.isEmpty)
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
            value: selectedBankId,
            decoration: const InputDecoration(
              labelText: 'Sélectionner une banque',
              prefixIcon: Icon(Icons.account_balance),
            ),
            items: userBankAccounts.map((account) {
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
            onChanged: userBankAccounts.isEmpty 
                ? null 
                : (String? bankId) {
                    if (bankId != null) {
                      final selectedAccount = userBankAccounts.firstWhere(
                        (account) => account.id == bankId,
                      );
                      onBankChanged(bankId, selectedAccount.bankName);
                    }
                  },
            validator: (value) {
              if (userBankAccounts.isNotEmpty && (value == null || value.isEmpty)) {
                return 'Veuillez sélectionner une banque';
              }
              return null;
            },
          ),
        
        // Affichage de la banque sélectionnée
        if (selectedBankName != null && selectedBankId != null)
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
                      'Banque sélectionnée: $selectedBankName',
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
          controller: bankAmountController,
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
            if (selectedBankId != null) {
              final selectedAccount = userBankAccounts.firstWhere(
                (account) => account.id == selectedBankId,
                orElse: () => userBankAccounts.first,
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
        buildQuickAmounts(context, bankAmountController),
        
        const SizedBox(height: 24),
        
        // Bouton continuer
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (userBankAccounts.isEmpty || isLoading)
                ? null
                : () => proceedToConfirmation(
                    'bank', 
                    context, 
                    formKey, 
                    recipientController, 
                    amountController, 
                    reasonController, 
                    bankAccountController, 
                    bankAmountController, 
                    bankReasonController, 
                    selectedBankName, // Passer le nom de la banque
                    selectedBankId: selectedBankId, // Passer également l'ID
                  ),
            child: Text(
              isLoading 
                  ? 'Chargement...' 
                  : userBankAccounts.isEmpty 
                      ? 'Aucune banque disponible' 
                      : 'Continuer'
            ),
          ),
        ),
        
        // Message d'aide si pas de comptes
        if (userBankAccounts.isEmpty && !isLoading)
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