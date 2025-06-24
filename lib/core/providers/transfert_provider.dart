import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:jamaa_frontend_mobile/core/constants/api_constants.dart';
import 'dart:convert';
import 'package:jamaa_frontend_mobile/core/models/transfert.dart';


class TransfertError {
  final String message;
  final String? details;
  final String type;
  
  TransfertError({
    required this.message,
    this.details,
    required this.type,
  });
}

class ApiResult<T> {
  final T? data;
  final TransfertError? error;
  final bool isSuccess;
  
  ApiResult.success(this.data) : error = null, isSuccess = true;
  ApiResult.failure(this.error) : data = null, isSuccess = false;
}

class TransfertProvider extends ChangeNotifier {
  List<Transfert> _transferts = [];
  bool _isLoading = false;
  bool _isTransferring = false;
  TransfertError? _error;
  Transfert? _lastTransfert;
  String _userId = '';
  String? _lastBankTransfertId; // Pour stocker l'ID du dernier transfert bancaire

  // Getters
  List<Transfert> get transferts => _transferts;
  String get tmpUserId => _userId;
  bool get isLoading => _isLoading;
  bool get isTransferring => _isTransferring;
  TransfertError? get error => _error;
  Transfert? get lastTransfert => _lastTransfert;
  String? get lastBankTransfertId => _lastBankTransfertId;
  bool get hasError => _error != null;
  bool get hasData => _transferts.isNotEmpty;

Future<String?> getUserIdByAccountNumber(String accountNumber) async {
  _clearError();

  try {
    const String endpoint = ApiConstants.accountServiceUrl;
    final String query = '''
      query {
        getAccountByAccountNumber(accountNumber: "$accountNumber") {
          userId
        }
      }
    ''';

    final response = await _makeGraphQLRequest(endpoint, query);
    
    if (!response.isSuccess) {
      _setError(response.error!);
      return null;
    }

    final accountData = response.data?['data']?['getAccountByAccountNumber'];
    if (accountData == null) {
      _setError(TransfertError(
        message: 'Données de compte non trouvées',
        details: 'Aucune donnée de compte retournée',
        type: 'DATA_NOT_FOUND',
      ));
      return null;
    }

    _userId = accountData['userId'];
    return _userId; // Retourner l'userId
  } catch (e) {
    _setError(TransfertError(
      message: 'Erreur lors de la récupération de l\'userId',
      details: e.toString(),
      type: 'ACCOUNT_FETCH_ERROR',
    ));
    return null;
  }
}

  // Méthode pour effectuer un transfert d'application
  Future<bool> makeAppTransfert({
    required String senderAccountId,
    required String receiverAccountId,
    required double amount,
  }) async {
    _setTransferring(true);
    _clearError();

    try {
      const String endpoint = ApiConstants.transfertServiceUrl;
      final String mutation = '''
        mutation {
          makeAppTransfert(
            idSenderAccount: $senderAccountId,
            idReceiverAccount: $receiverAccountId,
            amount: $amount
          ) {
            id,
            senderAccountId,
            receiverAccountId,
            amount,
            createAt
          }
        }
      ''';

      final response = await _makeGraphQLRequest(endpoint, mutation);
      
      if (!response.isSuccess) {
        _setError(response.error!);
        return false;
      }

      final transfertData = response.data?['data']?['makeAppTransfert'];
      if (transfertData == null) {
        _setError(TransfertError(
          message: 'Échec du transfert',
          details: 'Aucune donnée de transfert retournée',
          type: 'TRANSFER_FAILED',
        ));
        return false;
      }

      // Créer l'objet Transfert et l'ajouter à la liste
      final transfert = Transfert.fromJson(transfertData);
      _lastTransfert = transfert;
      _transferts.insert(0, transfert); // Ajouter en début de liste
      
      debugPrint('[TRANSFERT] Transfert réussi: ${transfert.id} - ${transfert.amount} XAF');
      return true;

    } catch (e) {
      debugPrint('[TRANSFERT] Erreur lors du transfert: $e');
      _setError(TransfertError(
        message: 'Erreur lors du transfert',
        details: e.toString(),
        type: 'TRANSFER_ERROR',
      ));
      return false;
    } finally {
      _setTransferring(false);
    }
  }

  // Méthode pour effectuer un transfert bancaire
  Future<bool> makeBankTransfert({
    required int senderBankId,
    required int receiverBankId,
    required double amount,
  }) async {
    _setTransferring(true);
    _clearError();

    try {
      const String endpoint = ApiConstants.transfertServiceUrl;
      final String mutation = '''
        mutation {
          makeBankTransfert(
            idSenderBank: $senderBankId,
            idReceiverBank: $receiverBankId,
            amount: $amount
          ) {
            id
          }
        }
      ''';

      final response = await _makeGraphQLRequest(endpoint, mutation);
      
      if (!response.isSuccess) {
        _setError(response.error!);
        return false;
      }

      final transfertData = response.data?['data']?['makeBankTransfert'];
      if (transfertData == null) {
        _setError(TransfertError(
          message: 'Échec du transfert bancaire',
          details: 'Aucune donnée de transfert bancaire retournée',
          type: 'BANK_TRANSFER_FAILED',
        ));
        return false;
      }

      // Stocker l'ID du transfert bancaire
      _lastBankTransfertId = transfertData['id']?.toString();
      
      debugPrint('[TRANSFERT] Transfert bancaire réussi: ID ${_lastBankTransfertId} - ${amount} XAF');
      return true;

    } catch (e) {
      debugPrint('[TRANSFERT] Erreur lors du transfert bancaire: $e');
      _setError(TransfertError(
        message: 'Erreur lors du transfert bancaire',
        details: e.toString(),
        type: 'BANK_TRANSFER_ERROR',
      ));
      return false;
    } finally {
      _setTransferring(false);
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
        },
        body: jsonEncode({'query': query}),
      );

      debugPrint('[TRANSFERT] ${endpoint} - Statut: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Vérifier les erreurs GraphQL
        if (data['errors'] != null) {
          return ApiResult.failure(TransfertError(
            message: 'Erreur GraphQL',
            details: data['errors'].toString(),
            type: 'GRAPHQL_ERROR',
          ));
        }
        
        return ApiResult.success(data);
      } else {
        return ApiResult.failure(TransfertError(
          message: 'Erreur serveur (${response.statusCode})',
          details: response.body,
          type: 'HTTP_ERROR',
        ));
      }
    } catch (e) {
      return ApiResult.failure(TransfertError(
        message: 'Erreur de connexion',
        details: e.toString(),
        type: 'CONNECTION_ERROR',
      ));
    }
  }

  void _setTransferring(bool transferring) {
    _isTransferring = transferring;
    notifyListeners();
  }

  void _setError(TransfertError error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Méthodes utilitaires publiques
  void clearData() {
    _transferts = [];
    _lastTransfert = null;
    _lastBankTransfertId = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  // Méthodes utilitaires pour le formatage
  String formatAmount(double amount) {
    return '${amount.toStringAsFixed(2)} XAF';
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Méthodes pour filtrer les transferts
  List<Transfert> getTransfertsBySender(String senderAccountId) {
    return _transferts.where((t) => t.senderAccountId == senderAccountId).toList();
  }

  List<Transfert> getTransfertsByReceiver(String receiverAccountId) {
    return _transferts.where((t) => t.receiverAccountId == receiverAccountId).toList();
  }

  List<Transfert> getTransfertsForAccount(String accountId) {
    return _transferts.where((t) => 
      t.senderAccountId == accountId || t.receiverAccountId == accountId
    ).toList();
  }
}