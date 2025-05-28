import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_button.dart';

class AddBankScreen extends StatefulWidget {
  const AddBankScreen({super.key});

  @override
  State<AddBankScreen> createState() => _AddBankScreenState();
}

class _AddBankScreenState extends State<AddBankScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountNumberController = TextEditingController();
  final _accountHolderController = TextEditingController();
  final _pinController = TextEditingController();
  
  String? _selectedBank;
  String? _selectedAccountType;
  bool _isProcessing = false;
  int _currentStep = 0;

  final List<String> _banks = [
    'Afriland First Bank',
    'BICEC',
    'UBA Cameroun',
    'Ecobank',
    'SGBC',
    'CCA Bank',
    'Commercial Bank',
  ];

  final List<String> _accountTypes = [
    'Compte Courant',
    'Compte Épargne',
    'Compte à terme',
    'Compte Professionnel',
  ];

  @override
  void dispose() {
    _accountNumberController.dispose();
    _accountHolderController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une banque'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepTapped: (step) {
            if (step <= _currentStep) {
              setState(() {
                _currentStep = step;
              });
            }
          },
          controlsBuilder: (context, details) {
            return Row(
              children: [
                if (details.stepIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Précédent'),
                    ),
                  ),
                if (details.stepIndex > 0) const SizedBox(width: 12),
                Expanded(
                  child: details.stepIndex == 2
                      ? LoadingButton(
                          onPressed: _linkBankAccount,
                          isLoading: _isProcessing,
                          child: const Text('Lier le compte'),
                        )
                      : ElevatedButton(
                          onPressed: details.onStepContinue,
                          child: const Text('Suivant'),
                        ),
                ),
              ],
            );
          },
          onStepContinue: () {
            if (_currentStep < 2) {
              if (_validateCurrentStep()) {
                setState(() {
                  _currentStep++;
                });
              }
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep--;
              });
            }
          },
          steps: [
            Step(
              title: const Text('Sélection de la banque'),
              content: _buildBankSelectionStep(),
              isActive: _currentStep >= 0,
            ),
            Step(
              title: const Text('Informations du compte'),
              content: _buildAccountInfoStep(),
              isActive: _currentStep >= 1,
            ),
            Step(
              title: const Text('Vérification'),
              content: _buildVerificationStep(),
              isActive: _currentStep >= 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankSelectionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choisissez votre banque',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms),
        
        const SizedBox(height: 16),
        
        Text(
          'Sélectionnez la banque où vous avez un compte actif',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 600.ms),
        
        const SizedBox(height: 24),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2,
          ),
          itemCount: _banks.length,
          itemBuilder: (context, index) {
            final bank = _banks[index];
            final isSelected = _selectedBank == bank;
            
            return Card(
              elevation: isSelected ? 8 : 2,
              color: isSelected 
                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                  : null,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedBank = bank;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(
                            color: Theme.of(context).primaryColor,
                            width: 2,
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            bank.substring(0, 1),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          bank,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(delay: (300 + index * 100).ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0);
          },
        ),
      ],
    );
  }

  Widget _buildAccountInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations du compte',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms),
        
        const SizedBox(height: 16),
        
        Text(
          'Saisissez les informations de votre compte $_selectedBank',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 600.ms),
        
        const SizedBox(height: 24),
        
        // Type de compte
        DropdownButtonFormField<String>(
          value: _selectedAccountType,
          decoration: const InputDecoration(
            labelText: 'Type de compte',
            prefixIcon: Icon(Icons.account_balance_wallet),
          ),
          items: _accountTypes.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedAccountType = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Veuillez sélectionner un type de compte';
            }
            return null;
          },
        )
            .animate()
            .fadeIn(delay: 300.ms, duration: 600.ms)
            .slideX(begin: -0.2, end: 0),
        
        const SizedBox(height: 16),
        
        // Numéro de compte
        CustomTextField(
          controller: _accountNumberController,
          label: 'Numéro de compte',
          hint: 'Saisissez votre numéro de compte',
          prefixIcon: Icons.credit_card,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(20),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez saisir votre numéro de compte';
            }
            if (value.length < 10) {
              return 'Numéro de compte trop court';
            }
            return null;
          },
        )
            .animate()
            .fadeIn(delay: 400.ms, duration: 600.ms)
            .slideX(begin: 0.2, end: 0),
        
        const SizedBox(height: 16),
        
        // Nom du titulaire
        CustomTextField(
          controller: _accountHolderController,
          label: 'Nom du titulaire du compte',
          hint: 'Nom complet comme sur le compte',
          prefixIcon: Icons.person,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez saisir le nom du titulaire';
            }
            if (value.length < 3) {
              return 'Nom trop court';
            }
            return null;
          },
        )
            .animate()
            .fadeIn(delay: 500.ms, duration: 600.ms)
            .slideX(begin: -0.2, end: 0),
        
        const SizedBox(height: 24),
        
        // Note informative
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ces informations sont sécurisées et ne seront utilisées que pour vérifier votre compte.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: 600.ms, duration: 600.ms),
      ],
    );
  }

  Widget _buildVerificationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vérification',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms),
        
        const SizedBox(height: 16),
        
        Text(
          'Vérifiez les informations avant de lier votre compte',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 600.ms),
        
        const SizedBox(height: 24),
        
        // Récapitulatif
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSummaryRow('Banque', _selectedBank ?? ''),
                _buildSummaryRow('Type de compte', _selectedAccountType ?? ''),
                _buildSummaryRow('Numéro de compte', _formatAccountNumber(_accountNumberController.text)),
                _buildSummaryRow('Titulaire', _accountHolderController.text),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(delay: 300.ms, duration: 600.ms)
            .slideY(begin: 0.3, end: 0),
        
        const SizedBox(height: 24),
        
        // Code PIN de confirmation
        Text(
          'Code PIN de confirmation',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        )
            .animate()
            .fadeIn(delay: 400.ms, duration: 600.ms),
        
        const SizedBox(height: 12),
        
        CustomTextField(
          controller: _pinController,
          label: 'Code PIN',
          hint: 'Saisissez votre code PIN JAMAA',
          prefixIcon: Icons.lock_outline,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez saisir votre code PIN';
            }
            if (value.length != 4) {
              return 'Le code PIN doit contenir 4 chiffres';
            }
            return null;
          },
        )
            .animate()
            .fadeIn(delay: 500.ms, duration: 600.ms)
            .slideX(begin: 0.2, end: 0),
        
        const SizedBox(height: 24),
        
        // Avertissement
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning_outlined,
                color: Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'En liant ce compte, vous acceptez que JAMAA accède aux informations de solde de ce compte.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: 600.ms, duration: 600.ms),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAccountNumber(String accountNumber) {
    if (accountNumber.length <= 4) return accountNumber;
    return '**** **** ${accountNumber.substring(accountNumber.length - 4)}';
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (_selectedBank == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Veuillez sélectionner une banque')),
          );
          return false;
        }
        return true;
      case 1:
        return _formKey.currentState?.validate() ?? false;
      default:
        return true;
    }
  }

  Future<void> _linkBankAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulation de liaison du compte
      await Future.delayed(const Duration(seconds: 3));
      
      if (mounted) {
        // Afficher le dialogue de succès
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => _buildSuccessDialog(),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la liaison: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Widget _buildSuccessDialog() {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.check_circle,
              size: 50,
              color: Colors.green,
            ),
          )
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut),
          
          const SizedBox(height: 24),
          
          Text(
            'Compte lié avec succès !',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Votre compte $_selectedBank a été lié à votre portefeuille JAMAA.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer le dialog
                context.go('/main/banks'); // Retourner à la liste des banques
              },
              child: const Text('Voir mes comptes'),
            ),
          ),
        ],
      ),
    );
  }
}