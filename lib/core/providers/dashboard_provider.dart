import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:jamaa_frontend_mobile/core/constants/api_constants.dart';
import 'dart:convert';
import '../models/bank_account.dart';

// Classe pour les erreurs spécifiques
class DashboardError {
  final String message;
  final String? details;
  final String type;
  
  DashboardError({
    required this.message,
    this.details,
    required this.type,
  });
}

// Classe pour encapsuler les résultats d'API
class ApiResult<T> {
  final T? data;
  final DashboardError? error;
  final bool isSuccess;
  
  ApiResult.success(this.data) : error = null, isSuccess = true;
  ApiResult.failure(this.error) : data = null, isSuccess = false;
}

class DashboardProvider extends ChangeNotifier {
  double _totalBalance = 0.0;
  String _accountNumber = '';
  List<BankAccount> _bankAccounts = [];
  bool _isLoading = false;
  DashboardError? _error;

  // Getters
  double get totalBalance => _totalBalance;
  List<BankAccount> get bankAccounts => _bankAccounts;
  bool get isLoading => _isLoading;
  DashboardError? get error => _error;

  String get formattedTotalBalance {
    return '${_totalBalance.toStringAsFixed(2)} XAF';
  }

  String get formattedAllTotalBalance {
    double total = _bankAccounts.fold<double>(0.0, (sum, account) => sum + account.balance);
    total += _totalBalance;
    return '${total.toStringAsFixed(2)} XAF';
  }

  String get formattedAccountNumber {
    return _accountNumber.isNotEmpty 
        ? _accountNumber
        : '';
  }

  bool get hasData => _totalBalance > 0 || _bankAccounts.isNotEmpty;
  bool get hasError => _error != null;

  // Méthode principale améliorée
  Future<void> loadDashboardData({required String userId}) async {
    _setLoading(true);
    _clearError();

    try {
      // Charger les données en parallèle pour optimiser les performances
      final results = await Future.wait([
        _fetchAccountData(userId),
        _fetchBankAccounts(userId),
      ]);

      final accountResult = results[0] as ApiResult<Map<String, dynamic>>;
      final bankAccountsResult = results[1] as ApiResult<List<BankAccount>>;

      // Traiter les résultats
      _handleAccountResult(accountResult);
      _handleBankAccountsResult(bankAccountsResult);

      // Vérifier si au moins une opération a réussi
      if (!accountResult.isSuccess && !bankAccountsResult.isSuccess) {
        _setError(DashboardError(
          message: 'Impossible de charger les données',
          details: 'Toutes les requêtes ont échoué',
          type: 'NETWORK_ERROR',
        ));
      }

    } catch (e) {
      debugPrint('[DASHBOARD] Erreur inattendue: $e');
      _setError(DashboardError(
        message: 'Erreur inattendue',
        details: e.toString(),
        type: 'UNEXPECTED_ERROR',
      ));
    } finally {
      _setLoading(false);
    }
  }

  // Récupération des données de compte
  Future<ApiResult<Map<String, dynamic>>> _fetchAccountData(String userId) async {
    try {
      const String endpoint = ApiConstants.accountServiceUrl;
      final String query = '''
        query {
          getAccountByUserId(userId: $userId) {
            balance,
            accountNumber
          }
        }
      ''';

      final response = await _makeGraphQLRequest(endpoint, query);
      
      if (!response.isSuccess) {
        return ApiResult.failure(response.error);
      }

      final accountData = response.data?['data']?['getAccountByUserId'];
      if (accountData == null) {
        return ApiResult.failure(DashboardError(
          message: 'Données de compte non trouvées',
          type: 'DATA_NOT_FOUND',
        ));
      }

      return ApiResult.success(accountData);

    } catch (e) {
      debugPrint('[DASHBOARD] Erreur lors de la récupération du compte: $e');
      return ApiResult.failure(DashboardError(
        message: 'Erreur lors de la récupération du solde',
        details: e.toString(),
        type: 'ACCOUNT_FETCH_ERROR',
      ));
    }
  }

  // Récupération des comptes bancaires
  Future<ApiResult<List<BankAccount>>> _fetchBankAccounts(String userId) async {
    try {
      const String endpoint = ApiConstants.cardServiceUrl;
      final String query = '''
        query {
          cardsByCustomer(customerId: $userId) {
            id,
            bankName,
            cardNumber,
            bankId,
            currentBalance,
            createdAt
          }
        }
      ''';

      final response = await _makeGraphQLRequest(endpoint, query);
      
      if (!response.isSuccess) {
        return ApiResult.failure(response.error);
      }

      final bankAccountsData = response.data?['data']?['cardsByCustomer'];
      if (bankAccountsData == null || bankAccountsData.isEmpty) {
        return ApiResult.success([]); // Pas d'erreur si aucun compte bancaire
      }

      final bankAccounts = (bankAccountsData as List).map((account) {
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

      return ApiResult.success(bankAccounts);

    } catch (e) {
      debugPrint('[DASHBOARD] Erreur lors de la récupération des comptes bancaires: $e');
      return ApiResult.failure(DashboardError(
        message: 'Erreur lors de la récupération des comptes bancaires',
        details: e.toString(),
        type: 'BANK_ACCOUNTS_FETCH_ERROR',
      ));
    }
  }

  // Méthode générique pour les requêtes GraphQL
  Future<ApiResult<Map<String, dynamic>>> _makeGraphQLRequest(
    String endpoint, 
    String query,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          // Ajouter d'autres headers si nécessaire (auth, etc.)
        },
        body: jsonEncode({'query': query}),
      );

      debugPrint('[DASHBOARD] ${endpoint} - Statut: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Vérifier les erreurs GraphQL
        if (data['errors'] != null) {
          return ApiResult.failure(DashboardError(
            message: 'Erreur GraphQL',
            details: data['errors'].toString(),
            type: 'GRAPHQL_ERROR',
          ));
        }
        
        return ApiResult.success(data);
      } else {
        return ApiResult.failure(DashboardError(
          message: 'Erreur serveur (${response.statusCode})',
          details: response.body,
          type: 'HTTP_ERROR',
        ));
      }
    } catch (e) {
      return ApiResult.failure(DashboardError(
        message: 'Erreur de connexion',
        details: e.toString(),
        type: 'CONNECTION_ERROR',
      ));
    }
  }

  // Traitement des résultats
  void _handleAccountResult(ApiResult<Map<String, dynamic>> result) {
    if (result.isSuccess && result.data != null) {
      final data = result.data!;
      _totalBalance = _parseBalance(data['balance']);
      _accountNumber = data['accountNumber']?.toString() ?? '';
      debugPrint('[DASHBOARD] Solde chargé: $_totalBalance XAF');
    } else {
      debugPrint('[DASHBOARD] Échec du chargement du solde: ${result.error?.message}');
    }
  }

  void _handleBankAccountsResult(ApiResult<List<BankAccount>> result) {
    if (result.isSuccess && result.data != null) {
      _bankAccounts = result.data!;
      debugPrint('[DASHBOARD] ${_bankAccounts.length} comptes bancaires chargés');
    } else {
      _bankAccounts = [];
      debugPrint('[DASHBOARD] Échec du chargement des comptes bancaires: ${result.error?.message}');
    }
  }

  // Méthodes utilitaires
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
        return 'assets/images/afriland_logo.png';
      case 'uba':
        return 'assets/images/uba_logo.png';
      case 'bicec':
        return 'assets/images/bicec_logo.png';
      case 'sgbc':
        return 'assets/images/sgbc_logo.png';
      default:
        return 'assets/images/default_logo.png';
    }
  }

  // Méthodes de gestion d'état
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(DashboardError error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Méthode publique pour rafraîchir
  Future<void> refreshBalance({required String userId}) async {
    await loadDashboardData(userId: userId);
  }

  // Méthode pour vider le cache
  void clearData() {
    _totalBalance = 0.0;
    _accountNumber = '';
    _bankAccounts = [];
    _error = null;
    notifyListeners();
  }
}