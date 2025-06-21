import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:jamaa_frontend_mobile/core/constants/api_constants.dart';
import 'dart:convert';

// Modèle pour RechargeRetrait
class RechargeRetrait {
  final String id;
  final String accountId;
  final String cardId;
  final double amount;
  final String operationType; // RECHARGE ou RETRAIT
  final String status; // SUCCESS, FAILED, PENDING
  final DateTime createdAt;
  final DateTime? updatedAt;

  RechargeRetrait({
    required this.id,
    required this.accountId,
    required this.cardId,
    required this.amount,
    required this.operationType,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory RechargeRetrait.fromJson(Map<String, dynamic> json) {
    return RechargeRetrait(
      id: json['id']?.toString() ?? '',
      accountId: json['accountId']?.toString() ?? '',
      cardId: json['cardId']?.toString() ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      operationType: json['operationType'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'cardId': cardId,
      'amount': amount,
      'operationType': operationType,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

// Classes d'erreur
class RechargeRetraitError {
  final String message;
  final String? details;
  final String type;
  
  RechargeRetraitError({
    required this.message,
    this.details,
    required this.type,
  });
}

class ApiResult<T> {
  final T? data;
  final RechargeRetraitError? error;
  final bool isSuccess;
  
  ApiResult.success(this.data) : error = null, isSuccess = true;
  ApiResult.failure(this.error) : data = null, isSuccess = false;
}

class RechargeRetraitProvider extends ChangeNotifier {
  List<RechargeRetrait> _operations = [];
  bool _isLoading = false;
  bool _isProcessing = false;
  RechargeRetraitError? _error;
  RechargeRetrait? _lastOperation;

  // Getters
  List<RechargeRetrait> get operations => _operations;
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  RechargeRetraitError? get error => _error;
  RechargeRetrait? get lastOperation => _lastOperation;
  bool get hasError => _error != null;
  bool get hasData => _operations.isNotEmpty;

  Future<bool> recharge({
    required String accountId,
    required String cardId,
    required double amount,
  }) async {
    _setProcessing(true);
    _clearError();

    try {
      const String endpoint = ApiConstants.rechargeRetraitServiceUrl; 
      final String mutation = '''
        mutation {
          recharge(accountId: "$accountId", cardId: "$cardId", amount: $amount) {
            id
            accountId
            cardId
            amount
            operationType
            status
            createdAt
            updatedAt
          }
        }
      ''';

      final response = await _makeGraphQLRequest(endpoint, mutation);
      
      if (!response.isSuccess) {
        _setError(response.error!);
        return false;
      }

      final operationData = response.data?['data']?['recharge'];
      if (operationData == null) {
        _setError(RechargeRetraitError(
          message: 'Échec de la recharge',
          details: 'Aucune donnée de recharge retournée',
          type: 'RECHARGE_FAILED',
        ));
        return false;
      }

      // Créer l'objet RechargeRetrait et l'ajouter à la liste
      final operation = RechargeRetrait.fromJson(operationData);
      _lastOperation = operation;
      _operations.insert(0, operation); // Ajouter en début de liste
      
      debugPrint('[RECHARGE] Recharge réussie: ${operation.id} - ${operation.amount} XAF');
      return true;

    } catch (e) {
      debugPrint('[RECHARGE] Erreur lors de la recharge: $e');
      _setError(RechargeRetraitError(
        message: 'Erreur lors de la recharge',
        details: e.toString(),
        type: 'RECHARGE_ERROR',
      ));
      return false;
    } finally {
      _setProcessing(false);
    }
  }

  // Méthode pour effectuer un retrait (carte vers compte)
  Future<bool> retrait({
    required String cardId,
    required String accountId,
    required double amount,
  }) async {
    _setProcessing(true);
    _clearError();

    try {
      const String endpoint = ApiConstants.rechargeRetraitServiceUrl; 
      final String mutation = '''
        mutation {
          retrait(cardId: "$cardId", accountId: "$accountId", amount: $amount) {
            id
            accountId
            cardId
            amount
            operationType
            status
            createdAt
            updatedAt
          }
        }
      ''';

      final response = await _makeGraphQLRequest(endpoint, mutation);
      
      if (!response.isSuccess) {
        _setError(response.error!);
        return false;
      }

      final operationData = response.data?['data']?['retrait'];
      if (operationData == null) {
        _setError(RechargeRetraitError(
          message: 'Échec du retrait',
          details: 'Aucune donnée de retrait retournée',
          type: 'RETRAIT_FAILED',
        ));
        return false;
      }

      // Créer l'objet RechargeRetrait et l'ajouter à la liste
      final operation = RechargeRetrait.fromJson(operationData);
      _lastOperation = operation;
      _operations.insert(0, operation); // Ajouter en début de liste
      
      debugPrint('[RETRAIT] Retrait réussi: ${operation.id} - ${operation.amount} XAF');
      return true;

    } catch (e) {
      debugPrint('[RETRAIT] Erreur lors du retrait: $e');
      _setError(RechargeRetraitError(
        message: 'Erreur lors du retrait',
        details: e.toString(),
        type: 'RETRAIT_ERROR',
      ));
      return false;
    } finally {
      _setProcessing(false);
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

      debugPrint('[RECHARGE_RETRAIT] ${endpoint} - Statut: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Vérifier les erreurs GraphQL
        if (data['errors'] != null) {
          return ApiResult.failure(RechargeRetraitError(
            message: 'Erreur GraphQL',
            details: data['errors'].toString(),
            type: 'GRAPHQL_ERROR',
          ));
        }
        
        return ApiResult.success(data);
      } else {
        return ApiResult.failure(RechargeRetraitError(
          message: 'Erreur serveur (${response.statusCode})',
          details: response.body,
          type: 'HTTP_ERROR',
        ));
      }
    } catch (e) {
      return ApiResult.failure(RechargeRetraitError(
        message: 'Erreur de connexion',
        details: e.toString(),
        type: 'CONNECTION_ERROR',
      ));
    }
  }

  void _setProcessing(bool processing) {
    _isProcessing = processing;
    notifyListeners();
  }

  void _setError(RechargeRetraitError error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Méthodes utilitaires publiques
  void clearData() {
    _operations = [];
    _lastOperation = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  String getOperationTypeText(String operationType) {
    switch (operationType) {
      case 'RECHARGE':
        return 'Recharge';
      case 'RETRAIT':
        return 'Retrait';
      default:
        return operationType;
    }
  }

  String getStatusText(String status) {
    switch (status) {
      case 'SUCCESS':
        return 'Réussie';
      case 'FAILED':
        return 'Échouée';
      case 'PENDING':
        return 'En attente';
      default:
        return status;
    }
  }
}