import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jamaa_frontend_mobile/core/constants/api_constants.dart';
import 'dart:convert';
import '../models/bank.dart';

class BankProvider extends ChangeNotifier {
  List<Bank> _banks = [];
  bool _isLoading = false;
  bool _isSubscribing = false;
  String? _error;

  List<Bank> get banks => _banks;
  bool get isLoading => _isLoading;
  bool get isSubscribing => _isSubscribing;
  String? get error => _error;

  // Méthode pour récupérer toutes les banques
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

  // Méthode pour souscrire à une banque
  Future<Map<String, dynamic>> subscribeToBank({
    required int userId,
    required String bankId,
  }) async {
    _isSubscribing = true;
    _error = null;
    notifyListeners();

    try {
      final url = Uri.parse(ApiConstants.bankServiceUrl);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'query': '''
            mutation SubscribeToBank {
              subscribeToBank(subscription: {
                userId: "$userId"
                bankId: "$bankId"
              }) {
                id
                userId
                bankId
                status
                createdAt
              }
            }
          '''
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Vérifier les erreurs GraphQL
        if (data['errors'] != null) {
          final errorMessage = data['errors'][0]['message'] ?? 'Erreur lors de la souscription';
          _error = errorMessage;
          return {
            'success': false,
            'error': errorMessage,
          };
        } else {
          final subscriptionData = data['data']['subscribeToBank'];
          
          return {
            'success': true,
            'data': subscriptionData,
            'message': 'Souscription réussie!',
          };
        }
      } else {
        final errorMessage = 'Erreur réseau : ${response.statusCode}';
        _error = errorMessage;
        return {
          'success': false,
          'error': errorMessage,
        };
      }
    } catch (e) {
      final errorMessage = 'Erreur lors de la souscription: $e';
      _error = errorMessage;
      return {
        'success': false,
        'error': errorMessage,
      };
    } finally {
      _isSubscribing = false;
      notifyListeners();
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

  // Méthode pour obtenir le nombre total de banques
  int get totalBanksCount => _banks.length;

  // Méthode pour vider le cache des banques
  void clearBankData() {
    _banks = [];
    _error = null;
    notifyListeners();
  }

  // Méthode pour rafraîchir les banques
  Future<void> refreshBanks() async {
    await fetchBanks();
  }
}