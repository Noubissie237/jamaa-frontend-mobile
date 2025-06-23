import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/build_bank_transfer_tab.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/build_user_transfer_tab.dart';
import 'package:jamaa_frontend_mobile/core/providers/card_provider.dart';
import 'package:jamaa_frontend_mobile/core/providers/auth_provider.dart'; // Ajoutez cet import

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
  
  String? _selectedBankId; // Changé pour stocker l'ID de la banque
  String? _selectedBankName; // Pour afficher le nom de la banque

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Charger les comptes bancaires de l'utilisateur au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserBankAccounts();
    });
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
    super.dispose();
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
    final String userId = authProvider.currentUser!.id.toString(); // ou .id selon votre modèle User
    
    debugPrint('[TRANSFER] Chargement des comptes bancaires pour l\'utilisateur: $userId');
    
    await cardProvider.fetchUserBankAccounts(userId);
    
    if (cardProvider.error != null) {
      // Afficher un message d'erreur si le chargement échoue
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des banques: ${cardProvider.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      debugPrint('[TRANSFER] ${cardProvider.userBankAccounts.length} comptes bancaires chargés');
    }
  }

  // Méthode pour gérer la sélection d'une banque
  void _onBankSelected(String? bankId, String? bankName) {
    setState(() {
      _selectedBankId = bankId;
      _selectedBankName = bankName;
    });
    debugPrint('[TRANSFER] Banque sélectionnée: $bankName (ID: $bankId)');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transférer'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black,
          tabs: const [
            Tab(
              icon: Icon(Icons.person),
              text: 'JAMAA',
            ),
            Tab(
              icon: Icon(Icons.account_balance),
              text: 'Banque',
            )
          ],
        ),
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
                    'Vous devez être connecté pour effectuer un transfert',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Form(
            key: _formKey,
            child: TabBarView(
              controller: _tabController,
              children: [
                buildUserTransferTab(
                  context, 
                  _recipientController, 
                  _amountController, 
                  _reasonController, 
                  _bankAccountController, 
                  _bankAmountController, 
                  _bankReasonController, 
                  _selectedBankName, // Passer le nom de la banque pour l'affichage
                  _formKey
                ),
                buildBankTransferTab(
                  context, 
                  _bankAccountController, 
                  _bankAmountController, 
                  _bankReasonController, 
                  _selectedBankName, // Passer le nom pour l'affichage
                  _formKey, 
                  cardProvider.userBankAccounts, // Passer la liste des comptes bancaires
                  _onBankSelected, // Callback pour la sélection
                  _recipientController, 
                  _amountController, 
                  _reasonController,
                  selectedBankId: _selectedBankId, // Passer l'ID sélectionné
                  isLoading: cardProvider.isLoading, // État de chargement
                ),
              ],
            ),
          );
        },
      ),
      // Bouton de rafraîchissement optionnel
      floatingActionButton: Consumer2<CardProvider, AuthProvider>(
        builder: (context, cardProvider, authProvider, child) {
          // Ne pas afficher le bouton si l'utilisateur n'est pas connecté
          if (authProvider.currentUser == null) {
            return const SizedBox.shrink();
          }

          if (cardProvider.isLoading) {
            return FloatingActionButton(
              onPressed: null,
              backgroundColor: Colors.grey,
              child: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            );
          }
          
          return FloatingActionButton(
            onPressed: _loadUserBankAccounts,
            tooltip: 'Actualiser les banques',
            child: const Icon(Icons.refresh),
          );
        },
      ),
    );
  }
}