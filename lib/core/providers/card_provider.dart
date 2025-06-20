import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jamaa_frontend_mobile/core/constants/api_constants.dart';
import 'dart:convert';
import '../models/bank_account.dart';
import '../models/bank.dart';

// Classe pour les informations de base de la carte
class CardBasicInfo {
  final String id;
  final String holderName;
  final String bankName;

  CardBasicInfo({
    required this.id,
    required this.holderName,
    required this.bankName,
  });

  factory CardBasicInfo.fromJson(Map<String, dynamic> json) {
    return CardBasicInfo(
      id: json['id']?.toString() ?? '',
      holderName: json['holderName']?.toString() ?? '',
      bankName: json['bankName']?.toString() ?? '',
    );
  }
}

class CardProvider extends ChangeNotifier {
  List<BankAccount> _userBankAccounts = [];
  bool _isLoading = false;
  String? _error;
  CardBasicInfo? _cardBasicInfo; // Nouvelle variable pour stocker les infos de base

  List<BankAccount> get userBankAccounts => _userBankAccounts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  CardBasicInfo? get cardBasicInfo => _cardBasicInfo; // Nouveau getter

  // Nouvelle méthode pour récupérer les informations de base d'une carte
  Future<CardBasicInfo?> getCardBasicInfo(String cardNumber) async {
    _isLoading = true;
    _error = null;
    _cardBasicInfo = null;
    notifyListeners();

    try {
      final url = Uri.parse(ApiConstants.cardServiceUrl);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'query': '''
            query {
              cardByNumber(cardNumber: "$cardNumber") {
                id,
              }
            }
          '''
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['errors'] != null) {
          print('Erreur GraphQL pour les informations de carte: ${data['errors']}');
          _error = 'Erreur GraphQL: ${data['errors']}';
          return null;
        } else {
          final cardData = data['data']['cardByNumber'];
          if (cardData != null) {
            _cardBasicInfo = CardBasicInfo.fromJson(cardData);
            print('Informations de carte récupérées: ${_cardBasicInfo?.holderName} - ${_cardBasicInfo?.bankName}');
            return _cardBasicInfo;
          } else {
            _error = 'Aucune carte trouvée avec ce numéro';
            return null;
          }
        }
      } else {
        final errorMessage = 'Erreur réseau: ${response.statusCode}';
        print(errorMessage);
        _error = errorMessage;
        return null;
      }
    } catch (e) {
      final errorMessage = 'Erreur lors de la récupération des informations de carte: $e';
      print(errorMessage);
      _error = errorMessage;
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Méthode pour récupérer les comptes bancaires de l'utilisateur
  Future<void> fetchUserBankAccounts(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

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
          _error = 'Erreur GraphQL: ${data['errors']}';
        } else {
          final List accountsJson = data['data']['cardsByCustomer'] ?? [];
          _userBankAccounts = accountsJson.map((account) {
            return BankAccount(
              id: account['id']?.toString() ?? '',
              bankName: account['bankName']?.toString() ?? 'Banque inconnue',
              accountNumber: account['cardNumber']?.toString() ?? '',
              accountType: 'Compte Courant',
              balance: _parseBalance(account['currentBalance']),
              linkedAt: _parseDate(account['createdAt']),
              bankId: account['bankId']?.toString() ?? '',
            );
          }).toList();
        }
      } else {
        final errorMessage = 'Erreur réseau: ${response.statusCode}';
        print(errorMessage);
        _userBankAccounts = [];
        _error = errorMessage;
      }
    } catch (e) {
      final errorMessage = 'Erreur lors de la récupération des comptes bancaires: $e';
      print(errorMessage);
      _userBankAccounts = [];
      _error = errorMessage;
    }
    
    _isLoading = false;
    notifyListeners();
  }

  // Méthode pour récupérer un compte bancaire par numéro de carte
  Future<void> fetchBankAccountsByCardNumber(String cardNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = Uri.parse(ApiConstants.cardServiceUrl);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'query': '''
            query GetCardByNumber {
              cardByNumber(cardNumber: "$cardNumber") {
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
          _error = 'Erreur GraphQL: ${data['errors']}';
        } else {
          final cardData = data['data']['cardByNumber'];
          if (cardData != null) {
            final account = BankAccount(
              id: cardData['id']?.toString() ?? '',
              bankName: cardData['bankName']?.toString() ?? 'Banque inconnue',
              accountNumber: cardData['cardNumber']?.toString() ?? '',
              accountType: 'Compte Courant',
              balance: _parseBalance(cardData['currentBalance']),
              linkedAt: _parseDate(cardData['createdAt']),
              bankId: cardData['bankId']?.toString() ?? '',
            );
            _userBankAccounts = [account];
          } else {
            _userBankAccounts = [];
          }
        }
      } else {
        final errorMessage = 'Erreur réseau: ${response.statusCode}';
        print(errorMessage);
        _userBankAccounts = [];
        _error = errorMessage;
      }
    } catch (e) {
      final errorMessage = 'Erreur lors de la récupération du compte bancaire: $e';
      print(errorMessage);
      _userBankAccounts = [];
      _error = errorMessage;
    }
    
    _isLoading = false;
    notifyListeners();
  }

  // Méthode pour obtenir les banques disponibles (non utilisées par l'utilisateur)
  List<Bank> getAvailableBanks(List<Bank> allBanks) {
    if (allBanks.isEmpty) return [];
    
    // Récupérer les IDs des banques auxquelles l'utilisateur est déjà inscrit
    final userBankIds = _userBankAccounts
        .map((account) => account.bankId)
        .where((id) => id.isNotEmpty)
        .toSet();

    // Filtrer les banques pour exclure celles déjà utilisées
    return allBanks.where((bank) => !userBankIds.contains(bank.id)).toList();
  }

  // Méthode pour vérifier si une banque est disponible
  bool isBankAvailable(String bankId) {
    final userBankIds = _userBankAccounts
        .map((account) => account.bankId)
        .where((id) => id.isNotEmpty)
        .toSet();
    
    return !userBankIds.contains(bankId);
  }

  // Méthode pour vérifier si l'utilisateur a des comptes bancaires
  bool get hasUserBankAccounts => _userBankAccounts.isNotEmpty;

  // Méthode pour obtenir le solde total de tous les comptes
  double get totalBalance => _userBankAccounts.fold<double>(
    0.0, 
    (sum, account) => sum + account.balance
  );

  // Méthode pour obtenir le nombre de comptes bancaires
  int get userBankAccountsCount => _userBankAccounts.length;

  // Méthode pour obtenir les statistiques des comptes
  Map<String, dynamic> get accountStats => {
    'userBankAccounts': _userBankAccounts.length,
    'totalBalance': totalBalance,
  };

  // Méthode pour rafraîchir les comptes bancaires
  Future<void> refreshUserBankAccounts(String userId) async {
    await fetchUserBankAccounts(userId);
  }

  // Méthode pour vider le cache des comptes
  void clearAccountData() {
    _userBankAccounts = [];
    _cardBasicInfo = null; // Effacer aussi les infos de carte
    _error = null;
    notifyListeners();
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
}