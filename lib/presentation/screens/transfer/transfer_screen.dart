import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/dashboard_provider.dart';
import '../../widgets/custom_text_field.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  
  // Controllers pour transfert vers utilisateur
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();
  
  // Controllers pour transfert vers banque
  final _bankAccountController = TextEditingController();
  final _bankAmountController = TextEditingController();
  final _bankReasonController = TextEditingController();
  
  // Controllers pour Mobile Money
  final _mobileNumberController = TextEditingController();
  final _mobileAmountController = TextEditingController();
  final _mobileReasonController = TextEditingController();
  
  String? _selectedBank;
  String? _selectedMobileOperator;

  final List<String> _banks = [
    'Afriland First Bank',
    'BICEC',
    'UBA Cameroun',
    'Ecobank',
    'SGBC',
  ];

  final List<String> _mobileOperators = [
    'MTN Mobile Money',
    'Orange Money',
    'Express Union Mobile',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _recipientController.dispose();
    _amountController.dispose();
    _reasonController.dispose();
    _bankAccountController.dispose();
    _bankAmountController.dispose();
    _bankReasonController.dispose();
    _mobileNumberController.dispose();
    _mobileAmountController.dispose();
    _mobileReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transférer'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.person),
              text: 'Utilisateur',
            ),
            Tab(
              icon: Icon(Icons.account_balance),
              text: 'Banque',
            ),
            Tab(
              icon: Icon(Icons.phone_android),
              text: 'Mobile Money',
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildUserTransferTab(),
            _buildBankTransferTab(),
            _buildMobileMoneyTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTransferTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Solde disponible
          _buildBalanceCard(),
          
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
            label: 'Email ou téléphone',
            hint: 'exemple@email.com ou +237123456789',
            prefixIcon: Icons.person_outline,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez saisir l\'email ou le téléphone du bénéficiaire';
              }
              return null;
            },
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 600.ms)
              .slideX(begin: -0.2, end: 0),
          
          const SizedBox(height: 16),
          
          // Contacts récents
          _buildRecentContacts(),
          
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
          _buildQuickAmounts(_amountController),
          
          const SizedBox(height: 24),
          
          // Motif
          Text(
            'Motif (optionnel)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          )
              .animate()
              .fadeIn(delay: 600.ms, duration: 600.ms),
          
          const SizedBox(height: 12),
          
          CustomTextField(
            controller: _reasonController,
            label: 'Motif du transfert',
            hint: 'Ex: Remboursement, cadeau...',
            prefixIcon: Icons.note_outlined,
            maxLines: 2,
          )
              .animate()
              .fadeIn(delay: 700.ms, duration: 600.ms)
              .slideX(begin: -0.2, end: 0),
          
          const SizedBox(height: 32),
          
          // Bouton continuer
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _proceedToConfirmation('user'),
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

  Widget _buildBankTransferTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Solde disponible
          _buildBalanceCard(),
          
          const SizedBox(height: 24),
          
          // Banque de destination
          Text(
            'Banque de destination',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 12),
          
          DropdownButtonFormField<String>(
            value: _selectedBank,
            decoration: const InputDecoration(
              labelText: 'Sélectionner une banque',
              prefixIcon: Icon(Icons.account_balance),
            ),
            items: _banks.map((bank) {
              return DropdownMenuItem(
                value: bank,
                child: Text(bank),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedBank = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Veuillez sélectionner une banque';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Numéro de compte
          CustomTextField(
            controller: _bankAccountController,
            label: 'Numéro de compte',
            prefixIcon: Icons.credit_card,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez saisir le numéro de compte';
              }
              if (value.length < 10) {
                return 'Numéro de compte invalide';
              }
              return null;
            },
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
            controller: _bankAmountController,
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
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Montants rapides
          _buildQuickAmounts(_bankAmountController),
          
          const SizedBox(height: 24),
          
          // Motif
          CustomTextField(
            controller: _bankReasonController,
            label: 'Motif (optionnel)',
            hint: 'Ex: Virement personnel...',
            prefixIcon: Icons.note_outlined,
            maxLines: 2,
          ),
          
          const SizedBox(height: 32),
          
          // Bouton continuer
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _proceedToConfirmation('bank'),
              child: const Text('Continuer'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileMoneyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Solde disponible
          _buildBalanceCard(),
          
          const SizedBox(height: 24),
          
          // Opérateur
          Text(
            'Opérateur Mobile Money',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 12),
          
          DropdownButtonFormField<String>(
            value: _selectedMobileOperator,
            decoration: const InputDecoration(
              labelText: 'Sélectionner un opérateur',
              prefixIcon: Icon(Icons.phone_android),
            ),
            items: _mobileOperators.map((operator) {
              return DropdownMenuItem(
                value: operator,
                child: Text(operator),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedMobileOperator = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Veuillez sélectionner un opérateur';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Numéro de téléphone
          CustomTextField(
            controller: _mobileNumberController,
            label: 'Numéro de téléphone',
            hint: '+237123456789',
            prefixIcon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez saisir le numéro de téléphone';
              }
              if (!RegExp(r'^\+?[0-9]{8,15}$').hasMatch(value.replaceAll(' ', ''))) {
                return 'Numéro de téléphone invalide';
              }
              return null;
            },
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
            controller: _mobileAmountController,
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
          ),
          
          const SizedBox(height: 16),
          
          // Montants rapides
          _buildQuickAmounts(_mobileAmountController),
          
          const SizedBox(height: 24),
          
          // Motif
          CustomTextField(
            controller: _mobileReasonController,
            label: 'Motif (optionnel)',
            hint: 'Ex: Cadeau, remboursement...',
            prefixIcon: Icons.note_outlined,
            maxLines: 2,
          ),
          
          const SizedBox(height: 32),
          
          // Bouton continuer
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _proceedToConfirmation('mobile'),
              child: const Text('Continuer'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Solde disponible',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                dashboardProvider.formattedTotalBalance,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    )
        .animate()
        .fadeIn(delay: 100.ms, duration: 600.ms)
        .slideY(begin: -0.2, end: 0);
  }

  Widget _buildRecentContacts() {
    final recentContacts = [
      {'name': 'Marie Nguyen', 'phone': '+237698765432'},
      {'name': 'Paul Kamga', 'phone': '+237677654321'},
      {'name': 'Sarah Mballa', 'phone': '+237655432109'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contacts récents',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recentContacts.length,
            itemBuilder: (context, index) {
              final contact = recentContacts[index];
              return Container(
                width: 70,
                margin: const EdgeInsets.only(right: 12),
                child: InkWell(
                  onTap: () {
                    _recipientController.text = contact['phone']!;
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Center(
                          child: Text(
                            contact['name']!.substring(0, 1),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        contact['name']!.split(' ')[0],
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAmounts(TextEditingController controller) {
    final quickAmounts = [1000, 5000, 10000, 25000, 50000, 100000];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Montants rapides',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: quickAmounts.map((amount) {
            return InkWell(
              onTap: () {
                controller.text = amount.toString();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${amount.toString()} XAF',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _proceedToConfirmation(String transferType) {
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
      case 'mobile':
        if (_selectedMobileOperator == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Veuillez sélectionner un opérateur')),
          );
          return;
        }
        transferData = {
          'type': 'mobile',
          'operator': _selectedMobileOperator,
          'phoneNumber': _mobileNumberController.text,
          'amount': double.parse(_mobileAmountController.text),
          'reason': _mobileReasonController.text,
        };
        break;
      default:
        return;
    }

    context.go('/main/transfer/confirmation', extra: transferData);
  }
}