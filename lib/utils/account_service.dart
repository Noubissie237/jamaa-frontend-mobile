import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:jamaa_frontend_mobile/core/constants/api_constants.dart';
import 'dart:convert';

// Classe pour les erreurs de service
class AccountServiceError {
  final String message;
  final String? details;
  final String type;
  
  AccountServiceError({
    required this.message,
    this.details,
    required this.type,
  });
}

// Classe pour encapsuler les résultats
class ServiceResult<T> {
  final T? data;
  final AccountServiceError? error;
  final bool isSuccess;
  
  ServiceResult.success(this.data) : error = null, isSuccess = true;
  ServiceResult.failure(this.error) : data = null, isSuccess = false;
}

class AccountService {
  
  /// Récupère l'ID du compte à partir d'un numéro de téléphone
  /// 
  /// [phoneNumber] : Le numéro de téléphone du client
  /// 
  /// Retourne l'ID du compte ou null en cas d'erreur
  static Future<String?> getAccountIdByPhone(String phoneNumber) async {
    try {
      debugPrint('[ACCOUNT_SERVICE] Recherche du compte pour le numéro: $phoneNumber');
      
      // Étape 1 : Récupérer l'ID du client par numéro de téléphone
      final customerResult = await _getCustomerIdByPhone(phoneNumber);
      if (!customerResult.isSuccess || customerResult.data == null) {
        debugPrint('[ACCOUNT_SERVICE] Erreur lors de la récupération du client: ${customerResult.error?.message}');
        return null;
      }
      
      final customerId = customerResult.data!;
      debugPrint('[ACCOUNT_SERVICE] ID client trouvé: $customerId');
      
      // Étape 2 : Récupérer l'ID du compte par ID client
      final accountResult = await _getAccountIdByUserId(customerId);
      if (!accountResult.isSuccess || accountResult.data == null) {
        debugPrint('[ACCOUNT_SERVICE] Erreur lors de la récupération du compte: ${accountResult.error?.message}');
        return null;
      }
      
      final accountId = accountResult.data!;
      debugPrint('[ACCOUNT_SERVICE] ID compte trouvé: $accountId');
      
      return accountId;
      
    } catch (e) {
      debugPrint('[ACCOUNT_SERVICE] Erreur inattendue: $e');
      return null;
    }
  }
  
  /// Version avec gestion d'erreur détaillée
  /// 
  /// Retourne un ServiceResult avec les détails de l'erreur
  static Future<ServiceResult<String>> getAccountIdByPhoneWithError(String phoneNumber) async {
    try {
      debugPrint('[ACCOUNT_SERVICE] Recherche du compte pour le numéro: $phoneNumber');
      
      // Validation du numéro de téléphone
      if (phoneNumber.trim().isEmpty) {
        return ServiceResult.failure(AccountServiceError(
          message: 'Numéro de téléphone invalide',
          details: 'Le numéro de téléphone ne peut pas être vide',
          type: 'VALIDATION_ERROR',
        ));
      }
      
      // Étape 1 : Récupérer l'ID du client par numéro de téléphone
      final customerResult = await _getCustomerIdByPhone(phoneNumber);
      if (!customerResult.isSuccess) {
        return ServiceResult.failure(customerResult.error!);
      }
      
      if (customerResult.data == null) {
        return ServiceResult.failure(AccountServiceError(
          message: 'Client non trouvé',
          details: 'Aucun client trouvé avec ce numéro de téléphone',
          type: 'CUSTOMER_NOT_FOUND',
        ));
      }
      
      final customerId = customerResult.data!;
      debugPrint('[ACCOUNT_SERVICE] ID client trouvé: $customerId');
      
      // Étape 2 : Récupérer l'ID du compte par ID client
      final accountResult = await _getAccountIdByUserId(customerId);
      if (!accountResult.isSuccess) {
        return ServiceResult.failure(accountResult.error!);
      }
      
      if (accountResult.data == null) {
        return ServiceResult.failure(AccountServiceError(
          message: 'Compte non trouvé',
          details: 'Aucun compte trouvé pour ce client',
          type: 'ACCOUNT_NOT_FOUND',
        ));
      }
      
      final accountId = accountResult.data!;
      debugPrint('[ACCOUNT_SERVICE] ID compte trouvé: $accountId');
      
      return ServiceResult.success(accountId);
      
    } catch (e) {
      debugPrint('[ACCOUNT_SERVICE] Erreur inattendue: $e');
      return ServiceResult.failure(AccountServiceError(
        message: 'Erreur inattendue',
        details: e.toString(),
        type: 'UNEXPECTED_ERROR',
      ));
    }
  }

  // Méthode privée pour récupérer l'ID du client par téléphone
  static Future<ServiceResult<String>> _getCustomerIdByPhone(String phoneNumber) async {
    try {
      const String endpoint = ApiConstants.register;
      final String query = '''
        query {
          getCustomerByPhone(phone: "$phoneNumber") {
            id
          }
        }
      ''';

      final response = await _makeGraphQLRequest(endpoint, query);
      
      if (!response.isSuccess) {
        return ServiceResult.failure(response.error!);
      }

      final customerData = response.data?['data']?['getCustomerByPhone'];
      if (customerData == null) {
        return ServiceResult.failure(AccountServiceError(
          message: 'Client non trouvé',
          details: 'Aucun client avec le numéro $phoneNumber',
          type: 'CUSTOMER_NOT_FOUND',
        ));
      }

      final customerId = customerData['id']?.toString();
      if (customerId == null || customerId.isEmpty) {
        return ServiceResult.failure(AccountServiceError(
          message: 'ID client invalide',
          details: 'L\'ID du client est null ou vide',
          type: 'INVALID_CUSTOMER_ID',
        ));
      }

      return ServiceResult.success(customerId);

    } catch (e) {
      debugPrint('[ACCOUNT_SERVICE] Erreur lors de la récupération du client: $e');
      return ServiceResult.failure(AccountServiceError(
        message: 'Erreur lors de la récupération du client',
        details: e.toString(),
        type: 'CUSTOMER_FETCH_ERROR',
      ));
    }
  }

  // Méthode privée pour récupérer l'ID du compte par ID utilisateur
  static Future<ServiceResult<String>> _getAccountIdByUserId(String userId) async {
    try {
      const String endpoint = ApiConstants.accountServiceUrl;
      final String query = '''
        query {
          getAccountByUserId(userId: $userId) {
            id
          }
        }
      ''';

      final response = await _makeGraphQLRequest(endpoint, query);
      
      if (!response.isSuccess) {
        return ServiceResult.failure(response.error!);
      }

      final accountData = response.data?['data']?['getAccountByUserId'];
      if (accountData == null) {
        return ServiceResult.failure(AccountServiceError(
          message: 'Compte non trouvé',
          details: 'Aucun compte pour l\'utilisateur $userId',
          type: 'ACCOUNT_NOT_FOUND',
        ));
      }

      final accountId = accountData['id']?.toString();
      if (accountId == null || accountId.isEmpty) {
        return ServiceResult.failure(AccountServiceError(
          message: 'ID compte invalide',
          details: 'L\'ID du compte est null ou vide',
          type: 'INVALID_ACCOUNT_ID',
        ));
      }

      return ServiceResult.success(accountId);

    } catch (e) {
      debugPrint('[ACCOUNT_SERVICE] Erreur lors de la récupération du compte: $e');
      return ServiceResult.failure(AccountServiceError(
        message: 'Erreur lors de la récupération du compte',
        details: e.toString(),
        type: 'ACCOUNT_FETCH_ERROR',
      ));
    }
  }

  // Méthode générique pour les requêtes GraphQL
  static Future<ServiceResult<Map<String, dynamic>>> _makeGraphQLRequest(
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

      debugPrint('[ACCOUNT_SERVICE] ${endpoint} - Statut: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Vérifier les erreurs GraphQL
        if (data['errors'] != null) {
          return ServiceResult.failure(AccountServiceError(
            message: 'Erreur GraphQL',
            details: data['errors'].toString(),
            type: 'GRAPHQL_ERROR',
          ));
        }
        
        return ServiceResult.success(data);
      } else {
        return ServiceResult.failure(AccountServiceError(
          message: 'Erreur serveur (${response.statusCode})',
          details: response.body,
          type: 'HTTP_ERROR',
        ));
      }
    } catch (e) {
      return ServiceResult.failure(AccountServiceError(
        message: 'Erreur de connexion',
        details: e.toString(),
        type: 'CONNECTION_ERROR',
      ));
    }
  }
}