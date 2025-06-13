import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:jamaa_frontend_mobile/core/constants/api_constants.dart';
import 'dart:convert';

import '../models/bank_account.dart';

class DashboardProvider extends ChangeNotifier {
  double _totalBalance = 0.0;
  String _accountNumber = '';
  List<BankAccount> _bankAccounts = [];
  bool _isLoading = false;
  String? _error;

  double get totalBalance => _totalBalance;
  List<BankAccount> get bankAccounts => _bankAccounts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get formattedTotalBalance {
    return '${_totalBalance.toStringAsFixed(2)} XAF';
  }

  String get formattedAccountNumber {
    return _accountNumber;
  }

  Future<void> loadDashboardData({required String userId}) async {
    _setLoading(true);
    _error = null;

    try {
      // Requête GraphQL pour récupérer le solde
      const String endpoint = ApiConstants.accountServiceUrl;
      final String query = '''
        query {
          getAccountByUserId(userId: $userId) {
            balance,
            accountNumber
          }
        }
      ''';

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'query': query}),
      );

      debugPrint('[DASHBOARD] Statut : ${response.statusCode}');
      debugPrint('[DASHBOARD] Body : ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final balanceData = data['data']?['getAccountByUserId'];
        final accountNumber = balanceData['accountNumber'];
        if (balanceData != null && balanceData['balance'] != null) {
          final balanceRaw = balanceData['balance'];
          if (balanceRaw != null) {
            _totalBalance = double.tryParse(balanceRaw.toString()) ?? 0.0;
            _accountNumber = accountNumber;
          } else {
            _totalBalance = 0.0;
          }
        } else {
          _error = 'Solde non trouvé';
          _totalBalance = 0.0;
        }
      } else {
        _error = 'Erreur serveur';
        _totalBalance = 0.0;
      }

      // Mock bank accounts (temporaire)
      _bankAccounts = [
        BankAccount(
          id: '1',
          bankName: 'Afriland First Bank',
          accountNumber: '1234567890123456',
          accountType: 'Compte Courant',
          balance: 250000,
          bankLogo: 'assets/images/afriland_logo.png',
          linkedAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        BankAccount(
          id: '2',
          bankName: 'BICEC',
          accountNumber: '9876543210987654',
          accountType: 'Compte Épargne',
          balance: 180000,
          bankLogo: 'assets/images/bicec_logo.png',
          linkedAt: DateTime.now().subtract(const Duration(days: 15)),
        ),
        BankAccount(
          id: '3',
          bankName: 'UBA Cameroun',
          accountNumber: '5555444433332222',
          accountType: 'Compte Courant',
          balance: 95000,
          bankLogo: 'assets/images/uba_logo.png',
          linkedAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
      ];

      notifyListeners();
    } catch (e) {
      _error = 'Erreur de chargement des données';
      _totalBalance = 0.0;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshBalance({required String userId}) async {
    await loadDashboardData(userId: userId);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
