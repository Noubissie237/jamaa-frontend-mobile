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

  // Getters
  List<Transfert> get transferts => _transferts;
  bool get isLoading => _isLoading;
  bool get isTransferring => _isTransferring;
  TransfertError? get error => _error;
  Transfert? get lastTransfert => _lastTransfert;
  bool get hasError => _error != null;
  bool get hasData => _transferts.isNotEmpty;

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