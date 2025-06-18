import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jamaa_frontend_mobile/core/constants/api_constants.dart';
import 'dart:convert';
import '../models/bank.dart';
import '../models/bank_account.dart';

class BankProvider extends ChangeNotifier {
  List<Bank> _banks = [];
  List<BankAccount> _userBankAccounts = [];
  bool _isLoading = false;
  bool _isLoadingAvailable = false;
  String? _error;

  List<Bank> get banks => _banks;
  List<BankAccount> get userBankAccounts => _userBankAccounts;
  bool get isLoading => _isLoading;
  bool get isLoadingAvailable => _isLoadingAvailable;
  String? get error => _error;

  // Getter pour les banques disponibles (non utilisées par l'utilisateur)
  List<Bank> get availableBanks {
    if (_banks.isEmpty) return [];
    
    // Récupérer les IDs des banques auxquelles l'utilisateur est déjà inscrit
    final userBankIds = _userBankAccounts
        .map((account) => account.bankId)
        .where((id) => id.isNotEmpty)
        .toSet();

    // Filtrer les banques pour exclure celles déjà utilisées
    return _banks.where((bank) => !userBankIds.contains(bank.id)).toList();
  }

  // Getter pour vérifier si une banque est disponible
  bool isBankAvailable(String bankId) {
    final userBankIds = _userBankAccounts
        .map((account) => account.bankId)
        .where((id) => id.isNotEmpty)
        .toSet();
    
    return !userBankIds.contains(bankId);
  }

  // Méthode existante pour récupérer toutes les banques
  Future<void> fetchBanks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = Uri.parse(ApiConstants.bankServiceUrl);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'query': '''
            query GetAllBanks {
              banks {
                id
                name
                slogan
                logoUrl
                minimumBalance
                withdrawFees
                internalTransferFees
                externalTransferFees
                createdAt
                updatedAt
              }
            }
          '''
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Vérifier les erreurs GraphQL
        if (data['errors'] != null) {
          _error = 'Erreur GraphQL: ${data['errors']}';
        } else {
          final List banksJson = data['data']['banks'] ?? [];
          _banks = banksJson.map((json) => Bank.fromJson(json)).toList();
        }
      } else {
        _error = 'Erreur réseau : ${response.statusCode}';
      }
    } catch (e) {
      _error = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }

  // Nouvelle méthode pour récupérer les comptes bancaires de l'utilisateur
  Future<void> fetchUserBankAccounts(String userId) async {
    try {
      final url = Uri.parse(ApiConstants.cardServiceUrl);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'query': '''
            query GetUserBankAccounts {
              cardsByCustomer(customerId: $userId) {
                id
                bankName
                cardNumber
                bankId
                currentBalance
                createdAt
              }
            }
          '''
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['errors'] != null) {
          print('Erreur GraphQL pour les comptes bancaires: ${data['errors']}');
          _userBankAccounts = [];
        } else {
          final List accountsJson = data['data']['cardsByCustomer'] ?? [];
          _userBankAccounts = accountsJson.map((account) {
            return BankAccount(
              id: account['id']?.toString() ?? '',
              bankName: account['bankName']?.toString() ?? 'Banque inconnue',
              accountNumber: account['cardNumber']?.toString() ?? '',
              accountType: 'Compte Courant',
              balance: _parseBalance(account['currentBalance']),
              bankLogo: _getBankLogo(account['bankName']?.toString()),
              linkedAt: _parseDate(account['createdAt']),
              bankId: account['bankId']?.toString() ?? '',
            );
          }).toList();
        }
      } else {
        print('Erreur réseau pour les comptes bancaires: ${response.statusCode}');
        _userBankAccounts = [];
      }
    } catch (e) {
      print('Erreur lors de la récupération des comptes bancaires: $e');
      _userBankAccounts = [];
    }
    
    notifyListeners();
  }

  // Méthode combinée pour charger les banques et les comptes de l'utilisateur
  Future<void> loadAvailableBanks(String userId) async {
    _isLoadingAvailable = true;
    _error = null;
    notifyListeners();

    try {
      // Charger les données en parallèle pour optimiser les performances
      await Future.wait([
        fetchBanks(),
        fetchUserBankAccounts(userId),
      ]);
    } catch (e) {
      _error = 'Erreur lors du chargement des banques disponibles: $e';
    }

    _isLoadingAvailable = false;
    notifyListeners();
  }

  // Méthode pour rafraîchir les données
  Future<void> refreshAvailableBanks(String userId) async {
    await loadAvailableBanks(userId);
  }

  // Méthodes utilitaires privées
  double _parseBalance(dynamic balance) {
    if (balance == null) return 0.0;
    return double.tryParse(balance.toString()) ?? 0.0;
  }

  DateTime _parseDate(dynamic date) {
    try {
      return date != null ? DateTime.parse(date.toString()) : DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  String _getBankLogo(String? bankName) {
    if (bankName == null) return 'assets/images/default_logo.png';
    
    switch (bankName.toLowerCase()) {
      case 'afriland':
      case 'afriland first bank':
        return 'assets/images/afriland_logo.png';
      case 'uba':
      case 'uba cameroun':
        return 'assets/images/uba_logo.png';
      case 'bicec':
        return 'assets/images/bicec_logo.png';
      case 'sgbc':
        return 'assets/images/sgbc_logo.png';
      case 'ecobank':
        return 'assets/images/ecobank_logo.png';
      case 'cca':
      case 'cca bank':
        return 'assets/images/cca_logo.png';
      default:
        return 'assets/images/default_logo.png';
    }
  }

  // Méthode pour obtenir une banque par son ID
  Bank? getBankById(String bankId) {
    try {
      return _banks.firstWhere((bank) => bank.id == bankId);
    } catch (e) {
      return null;
    }
  }

  // Méthode pour obtenir le nombre de banques disponibles
  int get availableBanksCount => availableBanks.length;

  // Méthode pour vérifier si l'utilisateur a des comptes bancaires
  bool get hasUserBankAccounts => _userBankAccounts.isNotEmpty;

  // Méthode pour obtenir les statistiques
  Map<String, dynamic> get bankStats => {
    'totalBanks': _banks.length,
    'availableBanks': availableBanks.length,
    'userBankAccounts': _userBankAccounts.length,
    'totalBalance': _userBankAccounts.fold<double>(
      0.0, 
      (sum, account) => sum + account.balance
    ),
  };

  // Méthode pour vider le cache
  void clearData() {
    _banks = [];
    _userBankAccounts = [];
    _error = null;
    notifyListeners();
  }
}