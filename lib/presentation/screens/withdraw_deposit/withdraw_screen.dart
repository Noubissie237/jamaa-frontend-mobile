import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:jamaa_frontend_mobile/core/providers/auth_provider.dart';
import 'package:jamaa_frontend_mobile/core/providers/card_provider.dart';
import 'package:jamaa_frontend_mobile/core/providers/recharge_retrait_provider.dart';
import 'package:jamaa_frontend_mobile/utils/utils.dart';
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
  final _formKey = GlobalKey<FormState>();
  
  // Controllers pour dépôt virement
  final _virementAmountController = TextEditingController();
  final _virementNotesController = TextEditingController();
  
  String? _selectedBankId; // ID de la banque sélectionnée
  String? _selectedBankName; // Nom de la banque pour l'affichage
  double _selectedBankBalance = 0;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    
    // Charger les comptes bancaires de l'utilisateur au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserBankAccounts();
    });
  }

  @override
  void dispose() {
    _virementAmountController.dispose();
    _virementNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Effectuer un retrait'),
        centerTitle: true,
        // Bouton de rafraîchissement dans l'AppBar
        actions: [
          Consumer2<CardProvider, AuthProvider>(
            builder: (context, cardProvider, authProvider, child) {
              if (authProvider.currentUser == null) {
                return const SizedBox.shrink();
              }

              return IconButton(
                onPressed: cardProvider.isLoading ? null : _loadUserBankAccounts,
                icon: cardProvider.isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.refresh),
                tooltip: 'Actualiser les comptes',
              );
            },
          ),
        ],
      ),
      body: Consumer2<CardProvider, AuthProvider>(
        builder: (context, cardProvider, authProvider, child) {
          // Vérifier si l'utilisateur est connecté
          if (authProvider.currentUser == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Vous devez être connecté pour effectuer un retrait',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Form(
            key: _formKey,
            child: _buildBankTransferTab(cardProvider),
          );
        },
      ),
    );
  }

  Widget _buildBankTransferTab(CardProvider cardProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Solde actuel
          _buildBalanceCard(),
          
          const SizedBox(height: 32),
          
          // Instructions
          _buildInstructionsCard(
            'Retrait par virement',
            'Effectuez un retrait depuis votre banque vers votre compte JAMAA.',
            Icons.account_balance_outlined,
            Colors.green,
          ),
          
          const SizedBox(height: 24),
          
          // Sélection de la banque source
          Text(
            'Compte à débiter',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Affichage conditionnel selon l'état du provider
          if (cardProvider.isLoading)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 16),
                    Text('Chargement...'),
                  ],
                ),
              ),
            )
          else if (cardProvider.error != null)
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.error, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Erreur lors du chargement de vos comptes',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cardProvider.error!,
                      style: TextStyle(color: Colors.red.shade600),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _loadUserBankAccounts,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade100,
                        foregroundColor: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (cardProvider.userBankAccounts.isEmpty)
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.account_balance_wallet_outlined, 
                         size: 48, 
                         color: Colors.orange.shade700),
                    const SizedBox(height: 16),
                    Text(
                      'Aucun compte bancaire trouvé',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vous devez d\'abord lier un compte bancaire pour effectuer une recharge.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.orange.shade600),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        executeActionWithVerification(context, ()=> context.go('/main/banks/add'));
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Lier un compte bancaire'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade100,
                        foregroundColor: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            DropdownButtonFormField<String>(
              value: _selectedBankId,
              decoration: const InputDecoration(
                labelText: 'Compte à débiter',
                prefixIcon: Icon(Icons.account_balance),
                helperText: 'Sélectionnez le compte bancaire à utiliser',
              ),
              items: cardProvider.userBankAccounts.map((bankAccount) {
                return DropdownMenuItem(
                  value: bankAccount.id,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        bankAccount.bankName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${bankAccount.balance.toString()} XAF',
                        style: const TextStyle(
                          fontWeight: FontWeight.w100,
                          fontSize: 12,
                          color: Color.fromARGB(255, 68, 126, 2),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBankId = value;
                  // Trouver le nom de la banque correspondant à l'ID
                  final selectedAccount = cardProvider.userBankAccounts
                      .firstWhere((account) => account.id == value);
                  _selectedBankName = selectedAccount.bankName;
                  _selectedBankBalance = selectedAccount.balance;
                });
                debugPrint('[DEPOSIT] Compte sélectionné: $_selectedBankName (ID: $_selectedBankId)');
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez sélectionner un compte bancaire';
                }
                return null;
              },
            ),
          
          const SizedBox(height: 24),
          
          // Montant du virement (seulement si un compte est disponible)
          if (cardProvider.userBankAccounts.isNotEmpty) ...[
            Text(
              'Montant du retrait',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            CustomTextField(
              controller: _virementAmountController,
              label: 'Montant (XAF)',
              hint: 'Montant que vous allez virer',
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
                if (_selectedBankBalance < amount) {
                  return 'Solde insuffisant : solde actuel $_selectedBankBalance XAF';
                }
                
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Montants rapides
            _buildQuickAmounts(_virementAmountController),
            
            const SizedBox(height: 32),
            
            // Bouton confirmer
            SizedBox(
              width: double.infinity,
              child: LoadingButton(
                onPressed: _selectedBankId != null ? () => _makeWithdraw() : null,
                isLoading: _isProcessing,
                child: const Text('Effectuer le retrait'),
              ),
            ),
          ],
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
                'Solde actuel',
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
                color: color.withValues(alpha: 0.1),
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
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
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

Future<void> _makeWithdraw() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  setState(() {
    _isProcessing = true;
  });

  final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
  final rechargeProvider = Provider.of<RechargeRetraitProvider>(context, listen: false);
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  int userId = authProvider.currentUser!.id;

  try {
    final amount = double.parse(_virementAmountController.text);
    
    debugPrint('[DEPOSIT] Début de la recharge: '
        'Banque: $_selectedBankName (ID: $_selectedBankId), '
        'Montant: $amount XAF, '
        'Compte: ${dashboardProvider.formattedAccountId}');

    final success = await rechargeProvider.retrait(
      accountId: dashboardProvider.formattedAccountId,
      cardId: _selectedBankId!,
      amount: amount,
    );

    if (mounted) {
      if (success) {
        debugPrint('[DEPOSIT] Recharge notifiée avec succès');
        
        // Message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Retrait de $amount XAF vers $_selectedBankName effectuée avec succès'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Réinitialiser le formulaire
        _virementAmountController.clear();
        setState(() {
          _selectedBankId = null;
          _selectedBankName = null;
        });
        
        // Recharger les données du dashboard pour mettre à jour les soldes
        await dashboardProvider.loadDashboardData(userId: userId.toString());
        
        // Navigation seulement en cas de succès
        if (context.mounted) {
          context.go('/main');
        }
        
      } else {
        debugPrint('[DEPOSIT] Échec de la recharge');
        
        // Récupérer le message d'erreur du provider
        String errorMessage = 'Échec de la recharge';
        if (rechargeProvider.error != null) {
          errorMessage = 'Solde insuffisant pour effectuer cette recharge';
          
          // Personnaliser le message selon le type d'erreur
          switch (rechargeProvider.error!.type) {
            case 'INSUFFICIENT_BALANCE_ERROR':
              errorMessage = 'Solde insuffisant pour effectuer cette recharge';
              break;
            case 'RECHARGE_FAILED':
              errorMessage = 'La recharge a échoué. Veuillez réessayer.';
              break;
            case 'GRAPHQL_ERROR':
              errorMessage = 'Erreur de traitement. Veuillez réessayer.';
              break;
            case 'HTTP_ERROR':
              errorMessage = 'Problème de connexion. Vérifiez votre réseau.';
              break;
            case 'CONNECTION_ERROR':
              errorMessage = 'Impossible de se connecter au serveur.';
              break;
            default:
              errorMessage = 'Solde insuffisant pour effectuer cette recharge';
          }
        }
        
        // Message d'erreur spécifique
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Erreur de recharge',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(errorMessage),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Réessayer',
              textColor: Colors.white,
              onPressed: () {
                _makeWithdraw(); // Relancer la recharge
              },
            ),
          ),
        );
      }
    }

  } catch (e) {
    debugPrint('[DEPOSIT] Exception lors de la recharge: $e');
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Erreur technique',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text('Une erreur inattendue s\'est produite: ${e.toString()}'),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
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

  // Méthode pour charger les comptes bancaires de l'utilisateur
  Future<void> _loadUserBankAccounts() async {
    final cardProvider = Provider.of<CardProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Vérifier que l'utilisateur est connecté
    if (authProvider.currentUser == null) {

      return;
    }
    
    // Récupérer l'ID réel de l'utilisateur connecté
    final String userId = authProvider.currentUser!.id.toString();
    
    debugPrint('[DEPOSIT] Chargement des comptes bancaires pour l\'utilisateur: $userId');
    
    await cardProvider.fetchUserBankAccounts(userId);
    
    if (cardProvider.error != null) {
      debugPrint('[DEPOSIT] Erreur lors du chargement: ${cardProvider.error}');
    } else {
      debugPrint('[DEPOSIT] ${cardProvider.userBankAccounts.length} comptes bancaires chargés');
      
      // Réinitialiser la sélection si nécessaire
      if (_selectedBankId != null && 
          !cardProvider.userBankAccounts.any((account) => account.id == _selectedBankId)) {
        setState(() {
          _selectedBankId = null;
          _selectedBankName = null;
        });
      }
    }
  }
}