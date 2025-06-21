import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/dashboard_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_button.dart';

class BillPaymentScreen extends StatefulWidget {
  const BillPaymentScreen({super.key});

  @override
  State<BillPaymentScreen> createState() => _BillPaymentScreenState();
}

class _BillPaymentScreenState extends State<BillPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _referenceController = TextEditingController();
  final _amountController = TextEditingController();
  
  String? _selectedService;
  bool _isLoading = false;
  bool _billVerified = false;
  Map<String, dynamic>? _billDetails;

  final List<BillService> _services = [
    BillService(
      id: 'eneo',
      name: 'ENEO',
      description: 'Électricité du Cameroun',
      icon: Icons.electrical_services,
      color: Colors.yellow,
      referenceLabel: 'Numéro de compteur',
      referenceHint: 'Ex: 123456789',
    ),
    BillService(
      id: 'camwater',
      name: 'CAMWATER',
      description: 'Camerounaise des Eaux',
      icon: Icons.water_drop,
      color: Colors.blue,
      referenceLabel: 'Numéro d\'abonné',
      referenceHint: 'Ex: 987654321',
    ),
    BillService(
      id: 'canal',
      name: 'Canal+',
      description: 'Télévision par satellite',
      icon: Icons.tv,
      color: Colors.purple,
      referenceLabel: 'Numéro d\'abonné',
      referenceHint: 'Ex: 41234567890',
    ),
    BillService(
      id: 'dstv',
      name: 'DStv',
      description: 'Télévision numérique',
      icon: Icons.tv,
      color: Colors.orange,
      referenceLabel: 'Smartcard/IUC',
      referenceHint: 'Ex: 1234567890',
    ),
  ];

  @override
  void dispose() {
    _referenceController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement de factures'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Solde disponible
              _buildBalanceCard(),
              
              const SizedBox(height: 24),
              
              // Sélection du service
              _buildServiceSelection(),
              
              const SizedBox(height: 24),
              
              // Formulaire de paiement
              if (_selectedService != null) ...[
                _buildPaymentForm(),
                
                const SizedBox(height: 24),
                
                // Détails de la facture (si vérifiée)
                if (_billVerified && _billDetails != null)
                  _buildBillDetails(),
                
                const SizedBox(height: 32),
                
                // Bouton de paiement
                _buildPaymentButton(),
              ],
            ],
          ),
        ),
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
                Theme.of(context).primaryColor.withValues(alpha: 0.8),
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
                  color: Colors.white.withValues(alpha: 0.9),
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

  Widget _buildServiceSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choisir un service',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 600.ms),
        
        const SizedBox(height: 16),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: _services.length,
          itemBuilder: (context, index) {
            final service = _services[index];
            final isSelected = _selectedService == service.id;
            
            return Card(
              elevation: isSelected ? 8 : 2,
              color: isSelected 
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                  : null,
              child: InkWell(
                onTap: () => _selectService(service),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: service.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(25),
                          border: isSelected
                              ? Border.all(
                                  color: Theme.of(context).primaryColor,
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Icon(
                          service.icon,
                          color: service.color,
                          size: 25,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        service.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : null,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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

  Widget _buildPaymentForm() {
    final service = _services.firstWhere((s) => s.id == _selectedService);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations de paiement',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        )
            .animate()
            .fadeIn(delay: 500.ms, duration: 600.ms),
        
        const SizedBox(height: 16),
        
        // Référence/Numéro
        CustomTextField(
          controller: _referenceController,
          label: service.referenceLabel,
          hint: service.referenceHint,
          prefixIcon: Icons.tag,
          keyboardType: TextInputType.text,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez saisir le ${service.referenceLabel.toLowerCase()}';
            }
            if (value.length < 5) {
              return 'Référence trop courte';
            }
            return null;
          },
          onChanged: (value) {
            if (_billVerified) {
              setState(() {
                _billVerified = false;
                _billDetails = null;
              });
            }
          },
        )
            .animate()
            .fadeIn(delay: 600.ms, duration: 600.ms)
            .slideX(begin: -0.2, end: 0),
        
        const SizedBox(height: 16),
        
        // Bouton de vérification
        if (!_billVerified)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _verifyBill,
              icon: const Icon(Icons.search),
              label: const Text('Vérifier la facture'),
            ),
          )
              .animate()
              .fadeIn(delay: 700.ms, duration: 600.ms),
        
        // Montant (si facture vérifiée ou saisie manuelle)
        if (_billVerified || service.id == 'canal' || service.id == 'dstv') ...[
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: _amountController,
            label: 'Montant (XAF)',
            hint: 'Saisissez le montant à payer',
            prefixIcon: Icons.money,
            keyboardType: TextInputType.number,
            enabled: !_billVerified,
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
              .fadeIn(delay: 800.ms, duration: 600.ms)
              .slideX(begin: 0.2, end: 0),
        ],
      ],
    );
  }

  Widget _buildBillDetails() {
    if (_billDetails == null) return const SizedBox.shrink();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Facture vérifiée',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            _buildDetailRow('Nom du client', _billDetails!['customerName']),
            _buildDetailRow('Référence', _billDetails!['reference']),
            _buildDetailRow('Montant dû', '${_billDetails!['amount']} XAF'),
            _buildDetailRow('Date d\'échéance', _billDetails!['dueDate']),
            
            if (_billDetails!['penalty'] != null && _billDetails!['penalty'] > 0)
              _buildDetailRow(
                'Pénalité',
                '${_billDetails!['penalty']} XAF',
                color: Colors.red,
              ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton() {
    return SizedBox(
      width: double.infinity,
      child: LoadingButton(
        onPressed: _canProceedPayment() ? _processPayment : null,
        isLoading: _isLoading,
        child: Text(
          _billVerified 
              ? 'Payer ${_billDetails?['amount'] ?? ''} XAF'
              : 'Payer la facture',
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 900.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  void _selectService(BillService service) {
    setState(() {
      _selectedService = service.id;
      _referenceController.clear();
      _amountController.clear();
      _billVerified = false;
      _billDetails = null;
    });
  }

  Future<void> _verifyBill() async {
    if (_referenceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir la référence'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulation de vérification
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock bill details
      final mockDetails = {
        'customerName': 'JOHN DOE',
        'reference': _referenceController.text,
        'amount': 15750,
        'dueDate': '15/12/2024',
        'penalty': 0,
      };

      setState(() {
        _billVerified = true;
        _billDetails = mockDetails;
        _amountController.text = mockDetails['amount'].toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Facture trouvée et vérifiée'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la vérification: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _canProceedPayment() {
    if (_selectedService == null) return false;
    if (_referenceController.text.isEmpty) return false;
    if (_amountController.text.isEmpty) return false;
    
    final service = _services.firstWhere((s) => s.id == _selectedService);
    
    // Pour ENEO et CAMWATER, la facture doit être vérifiée
    if ((service.id == 'eneo' || service.id == 'camwater') && !_billVerified) {
      return false;
    }
    
    return true;
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulation du traitement de paiement
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
            content: Text('Erreur lors du paiement: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildSuccessDialog() {
    final service = _services.firstWhere((s) => s.id == _selectedService);
    final amount = _amountController.text;
    
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
              color: Colors.green.withValues(alpha: 0.1),
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
            'Paiement réussi !',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Votre paiement ${service.name} de $amount XAF a été effectué avec succès.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Fermer le dialog
                    _resetForm();
                  },
                  child: const Text('Nouveau paiement'),
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

  void _resetForm() {
    setState(() {
      _selectedService = null;
      _referenceController.clear();
      _amountController.clear();
      _billVerified = false;
      _billDetails = null;
    });
  }
}

class BillService {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String referenceLabel;
  final String referenceHint;

  BillService({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.referenceLabel,
    required this.referenceHint,
  });
}