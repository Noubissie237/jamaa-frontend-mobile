import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:jamaa_frontend_mobile/core/models/bank.dart';
import 'package:jamaa_frontend_mobile/core/providers/auth_provider.dart';
import 'package:jamaa_frontend_mobile/core/providers/bank_provider.dart';
import 'package:jamaa_frontend_mobile/core/providers/card_provider.dart'; // Ajouté
import 'package:jamaa_frontend_mobile/presentation/widgets/build_verification_step.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/loading_button.dart';
import 'package:provider/provider.dart';

class AddBankScreen extends StatefulWidget {
  const AddBankScreen({super.key});

  @override
  State<AddBankScreen> createState() => _AddBankScreenState();
}

class _AddBankScreenState extends State<AddBankScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountHolderController = TextEditingController();
  final _pinController = TextEditingController();
  
  String? _selectedBankId;
  bool _isProcessing = false;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _loadAvailableBanks();
  }

  void _loadAvailableBanks() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final bankProvider = Provider.of<BankProvider>(context, listen: false);
      final cardProvider = Provider.of<CardProvider>(context, listen: false);
      
      final userId = authProvider.currentUser?.id;
      if (userId != null) {
        // Charger d'abord toutes les banques
        bankProvider.fetchBanks().then((_) {
          // Puis charger les comptes de l'utilisateur
          cardProvider.fetchUserBankAccounts(userId.toString());
        });
      }
    });
  }

  @override
  void dispose() {
    _accountHolderController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Souscrire à une banque'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshBanks,
          ),
        ],
      ),
      body: Consumer2<BankProvider, CardProvider>(
        builder: (context, bankProvider, cardProvider, child) {
          // Afficher un loader si les données sont en cours de chargement
          if (bankProvider.isLoading || cardProvider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Chargement des banques disponibles...'),
                ],
              ),
            );
          }

          // Afficher une erreur si il y en a une
          if (bankProvider.error != null || cardProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur lors du chargement',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bankProvider.error ?? cardProvider.error ?? 'Erreur inconnue',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _refreshBanks,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          // Calculer les banques disponibles
          final availableBanks = cardProvider.getAvailableBanks(bankProvider.banks);

          // Afficher un message si aucune banque n'est disponible
          if (availableBanks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune banque disponible',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vous êtes déjà inscrit à toutes les banques disponibles ou aucune banque n\'est configurée.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _refreshBanks,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Actualiser'),
                  ),
                ],
              ),
            );
          }

          // Afficher le formulaire avec les banques disponibles
          return Form(
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
                      child: details.stepIndex == 1
                          ? LoadingButton(
                              onPressed: _linkBankAccount,
                              isLoading: _isProcessing,
                              child: const Text('Confirmer'),
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
                if (_currentStep < 1) {
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
                  content: _buildBankSelectionStep(availableBanks),
                  isActive: _currentStep >= 0,
                ),
                Step(
                  title: const Text('Confirmation'),
                  content: buildVerificationStep(bankProvider, _selectedBankId),
                  isActive: _currentStep >= 1,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBankSelectionStep(List<Bank> availableBanks) {
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
          'Sélectionnez la banque où vous souhaitez ouvrir un compte (${availableBanks.length} banque${availableBanks.length > 1 ? 's' : ''} disponible${availableBanks.length > 1 ? 's' : ''})',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 600.ms),
        
        const SizedBox(height: 24),
        
        // Version ListView pour éviter les overflows
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: availableBanks.length,
          itemBuilder: (context, index) {
            final bank = availableBanks[index];
            final isSelected = _selectedBankId == bank.id;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                elevation: isSelected ? 8 : 2,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedBankId = bank.id;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
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
                        // Logo de la banque ou initiale
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                                  child: Text(
                                    bank.name.substring(0, 1).toUpperCase(),
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Informations de la banque
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bank.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : null,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (bank.slogan.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  bank.slogan,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                'Solde minimum: ${bank.minimumBalance.toStringAsFixed(0)} FCFA',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Icône de sélection
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected 
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                              width: 2,
                            ),
                            color: isSelected 
                                ? Theme.of(context).primaryColor
                                : Colors.transparent,
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: (300 + index * 100).ms, duration: 600.ms)
                  .slideX(begin: 0.3, end: 0),
            );
          },
        ),
      ],
    );
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (_selectedBankId == null) {
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

  void _refreshBanks() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bankProvider = Provider.of<BankProvider>(context, listen: false);
    final cardProvider = Provider.of<CardProvider>(context, listen: false);
    
    final userId = authProvider.currentUser?.id;
    if (userId != null) {
      // Rafraîchir les banques puis les comptes utilisateur
      bankProvider.fetchBanks().then((_) {
        cardProvider.fetchUserBankAccounts(userId.toString());
      });
    }
  }

  Future<void> _linkBankAccount() async {
    // Validation préalable
    if (_selectedBankId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune banque sélectionnée'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final bankProvider = Provider.of<BankProvider>(context, listen: false);
      final cardProvider = Provider.of<CardProvider>(context, listen: false);
      
      // Vérifier que l'utilisateur est connecté
      final currentUser = authProvider.currentUser;
      if (currentUser?.id == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Récupérer les détails de la banque sélectionnée
      final selectedBank = bankProvider.getBankById(_selectedBankId!);
      if (selectedBank == null) {
        throw Exception('Banque sélectionnée non trouvée');
      }

      // Vérifier que la banque est toujours disponible
      if (!cardProvider.isBankAvailable(_selectedBankId!)) {
        throw Exception('Cette banque n\'est plus disponible. Vous y êtes peut-être déjà inscrit.');
      }

      // Effectuer la souscription via l'API
      final result = await bankProvider.subscribeToBank(
        userId: currentUser!.id,
        bankId: _selectedBankId!,
      );

      if (mounted) {
        if (result['success'] == true) {
          // Succès de la souscription
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result['message'] ?? 'Souscription à ${selectedBank.name} réussie!',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // Petit délai pour permettre à l'utilisateur de voir le message de succès
          await Future.delayed(const Duration(milliseconds: 500));
          
          // Rafraîchir les données pour mettre à jour la liste des banques disponibles
          await cardProvider.fetchUserBankAccounts(currentUser.id.toString());
          
          // Retourner à l'écran précédent
          if (mounted) {
            context.pop();
          }
        } else {
          // Erreur lors de la souscription
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result['error'] ?? 'Erreur lors de la souscription',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Réessayer',
                textColor: Colors.white,
                onPressed: _linkBankAccount,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // Gestion des erreurs génériques
        String errorMessage = 'Erreur inattendue lors de la souscription';
        
        // Personnaliser le message selon le type d'erreur
        if (e.toString().contains('network') || e.toString().contains('réseau')) {
          errorMessage = 'Problème de connexion réseau. Vérifiez votre connexion internet.';
        } else if (e.toString().contains('timeout')) {
          errorMessage = 'La requête a pris trop de temps. Veuillez réessayer.';
        } else if (e.toString().contains('Utilisateur non connecté')) {
          errorMessage = 'Session expirée. Veuillez vous reconnecter.';
        } else {
          errorMessage = e.toString().replaceFirst('Exception: ', '');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Réessayer',
              textColor: Colors.white,
              onPressed: _linkBankAccount,
            ),
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
}