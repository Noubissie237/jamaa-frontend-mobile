import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/dashboard_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_button.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  
  // Controllers pour retrait agent
  final _agentAmountController = TextEditingController();
  final _agentPhoneController = TextEditingController();
  
  // Controllers pour retrait GAB
  final _gabAmountController = TextEditingController();
  final _gabPinController = TextEditingController();
  
  String? _selectedBank;
  bool _isProcessing = false;

  final List<String> _banks = [
    'Afriland First Bank',
    'BICEC',
    'UBA Cameroun',
    'Ecobank',
    'SGBC',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _agentAmountController.dispose();
    _agentPhoneController.dispose();
    _gabAmountController.dispose();
    _gabPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Retirer de l\'argent'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.person),
              text: 'Via Agent',
            ),
            Tab(
              icon: Icon(Icons.atm),
              text: 'GAB',
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildAgentWithdrawTab(),
            _buildATMWithdrawTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentWithdrawTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Solde disponible
          _buildBalanceCard(),
          
          const SizedBox(height: 32),
          
          // Instructions
          _buildInstructionsCard(
            'Retrait via Agent',
            'Trouvez un agent JAMAA près de chez vous et présentez le code généré pour retirer votre argent.',
            Icons.person_pin_circle,
            Colors.blue,
          ),
          
          const SizedBox(height: 24),
          
          // Montant
          Text(
            'Montant à retirer',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 600.ms),
          
          const SizedBox(height: 12),
          
          CustomTextField(
            controller: _agentAmountController,
            label: 'Montant (XAF)',
            hint: 'Saisissez le montant',
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
              if (amount < 500) {
                return 'Montant minimum : 500 XAF';
              }
              if (amount > 500000) {
                return 'Montant maximum : 500 000 XAF';
              }
              return null;
            },
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 600.ms)
              .slideX(begin: -0.2, end: 0),
          
          const SizedBox(height: 16),
          
          // Montants rapides
          _buildQuickAmounts(_agentAmountController),
          
          const SizedBox(height: 24),
          
          // Numéro de téléphone (optionnel)
          Text(
            'Numéro de téléphone (optionnel)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          )
              .animate()
              .fadeIn(delay: 500.ms, duration: 600.ms),
          
          const SizedBox(height: 8),
          
          Text(
            'Pour recevoir le code de retrait par SMS',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          )
              .animate()
              .fadeIn(delay: 550.ms, duration: 600.ms),
          
          const SizedBox(height: 12),
          
          CustomTextField(
            controller: _agentPhoneController,
            label: 'Numéro de téléphone',
            hint: '+237123456789',
            prefixIcon: Icons.phone,
            keyboardType: TextInputType.phone,
          )
              .animate()
              .fadeIn(delay: 600.ms, duration: 600.ms)
              .slideX(begin: 0.2, end: 0),
          
          const SizedBox(height: 32),
          
          // Frais de retrait
          _buildFeesInfo(),
          
          const SizedBox(height: 32),
          
          // Bouton générer code
          SizedBox(
            width: double.infinity,
            child: LoadingButton(
              onPressed: () => _generateWithdrawCode('agent'),
              isLoading: _isProcessing,
              child: const Text('Générer le code de retrait'),
            ),
          )
              .animate()
              .fadeIn(delay: 800.ms, duration: 600.ms)
              .slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }

  Widget _buildATMWithdrawTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Solde disponible
          _buildBalanceCard(),
          
          const SizedBox(height: 32),
          
          // Instructions
          _buildInstructionsCard(
            'Retrait GAB',
            'Retirez votre argent directement aux distributeurs automatiques de billets des banques partenaires.',
            Icons.atm,
            Colors.green,
          ),
          
          const SizedBox(height: 24),
          
          // Sélection de la banque
          Text(
            'Banque partenaire',
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
          
          const SizedBox(height: 24),
          
          // Montant
          Text(
            'Montant à retirer',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 12),
          
          CustomTextField(
            controller: _gabAmountController,
            label: 'Montant (XAF)',
            hint: 'Saisissez le montant',
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
                return 'Montant minimum : 1 000 XAF';
              }
              if (amount > 300000) {
                return 'Montant maximum : 300 000 XAF';
              }
              if (amount % 5000 != 0) {
                return 'Le montant doit être un multiple de 5 000 XAF';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Montants rapides pour GAB
          _buildQuickAmountsGAB(_gabAmountController),
          
          const SizedBox(height: 24),
          
          // Code PIN de confirmation
          Text(
            'Code PIN de confirmation',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 12),
          
          CustomTextField(
            controller: _gabPinController,
            label: 'Code PIN',
            hint: 'Saisissez votre code PIN',
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
          ),
          
          const SizedBox(height: 32),
          
          // Frais de retrait
          _buildFeesInfo(),
          
          const SizedBox(height: 32),
          
          // Bouton générer code
          SizedBox(
            width: double.infinity,
            child: LoadingButton(
              onPressed: () => _generateWithdrawCode('atm'),
              isLoading: _isProcessing,
              child: const Text('Générer le code de retrait'),
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
        .fadeIn(duration: 600.ms)
        .slideY(begin: -0.2, end: 0);
  }

  Widget _buildInstructionsCard(String title, String description, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                icon,
                color: color,
                size: 25,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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
        .fadeIn(delay: 200.ms, duration: 600.ms)
        .slideX(begin: -0.3, end: 0);
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

  Widget _buildQuickAmountsGAB(TextEditingController controller) {
    final quickAmounts = [5000, 10000, 25000, 50000, 100000, 200000];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Montants rapides (multiples de 5 000)',
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

  Widget _buildFeesInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Frais de retrait',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• 0 - 25 000 XAF: 200 XAF\n'
            '• 25 001 - 100 000 XAF: 500 XAF\n'
            '• 100 001 - 500 000 XAF: 1 000 XAF',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.blue,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 700.ms, duration: 600.ms);
  }

  Future<void> _generateWithdrawCode(String type) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulation de génération de code
      await Future.delayed(const Duration(seconds: 2));
      
      final amount = type == 'agent' 
          ? _agentAmountController.text 
          : _gabAmountController.text;
      
      if (mounted) {
        // Afficher le dialogue avec le code
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => _buildWithdrawCodeDialog(type, amount),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la génération: ${e.toString()}'),
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

  Widget _buildWithdrawCodeDialog(String type, String amount) {
    final withdrawCode = 'WD${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    
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
            'Code de retrait généré',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Code en gros
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
              ),
            ),
            child: Text(
              withdrawCode,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
                letterSpacing: 2,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Montant: $amount XAF',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            type == 'agent'
                ? 'Présentez ce code à l\'agent JAMAA'
                : 'Utilisez ce code au GAB ${_selectedBank ?? ''}',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Valable pendant 24 heures',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Partager le code
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Partage du code à venir')),
                    );
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Partager'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Fermer le dialog
                    Navigator.of(context).pop(); // Retourner à l'écran précédent
                  },
                  child: const Text('Terminé'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}