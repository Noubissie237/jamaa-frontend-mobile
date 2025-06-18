import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:jamaa_frontend_mobile/core/constants/api_constants.dart';
import 'dart:convert';
import '../models/transaction.dart';

// Classe pour les erreurs spécifiques
class TransactionError {
  final String message;
  final String? details;
  final String type;
  
  TransactionError({
    required this.message,
    this.details,
    required this.type,
  });
}

// Classe pour encapsuler les résultats d'API
class ApiResult<T> {
  final T? data;
  final TransactionError? error;
  final bool isSuccess;
  
  ApiResult.success(this.data) : error = null, isSuccess = true;
  ApiResult.failure(this.error) : data = null, isSuccess = false;
}

class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  TransactionError? _error;

  TransactionProvider();

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  TransactionError? get error => _error;

  List<Transaction> get recentTransactions {
    return _transactions.take(5).toList();
  }

  bool get hasData => _transactions.isNotEmpty;
  bool get hasError => _error != null;

  // Méthode principale pour charger les transactions
Future<void> loadTransactions(int userId) async {
  _setLoading(true);
  _clearError();

  try {
    final result = await _fetchTransactionsByUserId(userId);

    if (result.isSuccess && result.data != null) {
      _transactions = result.data!
          .map((transactionData) => Transaction.fromGraphQL(transactionData))
          .where((transaction) {
            final isSender = transaction.idAccountSender == userId;
            final isSuccess = transaction.status == TransactionStatus.success;

            // Si ce n'est pas l'expéditeur (donc reçu) et que ce n'est pas réussi, on exclut
            if (!isSender && !isSuccess) return false;

            // On garde tout le reste
            return true;
          })
          .map((transaction) => _enrichTransactionForDisplay(transaction, userId))
          .toList();

      _transactions.sort((a, b) => b.dateEvent.compareTo(a.dateEvent));
      debugPrint('[TRANSACTIONS] ${_transactions.length} transactions chargées');
    } else {
      _setError(result.error ?? TransactionError(
        message: 'Erreur inconnue lors du chargement',
        type: 'UNKNOWN_ERROR',
      ));
    }

  } catch (e) {
    debugPrint('[TRANSACTIONS] Erreur inattendue: $e');
    _setError(TransactionError(
      message: 'Erreur inattendue',
      details: e.toString(),
      type: 'UNEXPECTED_ERROR',
    ));
  } finally {
    _setLoading(false);
  }
}

  // Récupération des transactions via GraphQL
  Future<ApiResult<List<Map<String, dynamic>>>> _fetchTransactionsByUserId(int userId) async {
    try {
      const String endpoint = ApiConstants.transactionServiceUrl;
      final String query = '''
        query {
          getTransactionsByUserId(userId: $userId) {
            transactionId,
            amount,
            idAccountSender,
            idAccountReceiver,
            transactionType,
            dateEvent,
            status
          }
        }
      ''';

      final response = await _makeGraphQLRequest(endpoint, query);
      
      if (!response.isSuccess) {
        return ApiResult.failure(response.error);
      }

      final transactionsData = response.data?['data']?['getTransactionsByUserId'];
      if (transactionsData == null) {
        return ApiResult.success([]); // Retourner une liste vide si pas de données
      }

      return ApiResult.success(List<Map<String, dynamic>>.from(transactionsData));

    } catch (e) {
      debugPrint('[TRANSACTIONS] Erreur lors de la récupération: $e');
      return ApiResult.failure(TransactionError(
        message: 'Erreur lors de la récupération des transactions',
        details: e.toString(),
        type: 'FETCH_ERROR',
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

      debugPrint('[TRANSACTIONS] ${endpoint} - Statut: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Vérifier les erreurs GraphQL
        if (data['errors'] != null) {
          return ApiResult.failure(TransactionError(
            message: 'Erreur GraphQL',
            details: data['errors'].toString(),
            type: 'GRAPHQL_ERROR',
          ));
        }
        
        return ApiResult.success(data);
      } else {
        return ApiResult.failure(TransactionError(
          message: 'Erreur serveur (${response.statusCode})',
          details: response.body,
          type: 'HTTP_ERROR',
        ));
      }
    } catch (e) {
      return ApiResult.failure(TransactionError(
        message: 'Erreur de connexion',
        details: e.toString(),
        type: 'CONNECTION_ERROR',
      ));
    }
  }
  
  // Enrichir la transaction avec des données d'affichage
  Transaction _enrichTransactionForDisplay(Transaction transaction, int currentUserId) {
    String title;
    String description;
    double displayAmount = transaction.amount;

    bool isSender = transaction.idAccountSender == currentUserId;
    
    switch (transaction.transactionType) {
      case TransactionType.transfert:
        if (isSender) {
          title = 'Transfert envoyé';
          description = 'Vers compte ${transaction.idAccountReceiver}';
          displayAmount = -transaction.amount;
        } else {
          title = 'Transfert reçu';
          description = 'De compte ${transaction.idAccountSender}';
          displayAmount = transaction.amount;
        }
        break;
      case TransactionType.depot:
        title = 'Dépôt';
        description = 'Dépôt d\'espèces sur votre compte';
        displayAmount = transaction.amount;
        break;
      case TransactionType.retrait:
        title = 'Retrait';
        description = 'Retrait d\'espèces de votre compte';
        displayAmount = -transaction.amount;
        break;
      case TransactionType.recharge:
        title = 'Recharge';
        description = 'Recharge de votre compte';
        displayAmount = transaction.amount;
        break;
      case TransactionType.virement:
        if (isSender) {
          title = 'Virement envoyé';
          description = 'Vers compte ${transaction.idAccountReceiver}';
          displayAmount = -transaction.amount;
        } else {
          title = 'Virement reçu';
          description = 'De compte ${transaction.idAccountSender}';
          displayAmount = transaction.amount;
        }
        break;
    }

    return transaction.copyWith(
      title: title,
      description: description,
      amount: displayAmount,
      reference: 'TXN-${transaction.transactionId.substring(0, 8).toUpperCase()}',
    );
  }

  // Méthodes de gestion d'état
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(TransactionError error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Méthode publique pour rafraîchir
  Future<void> refreshTransactions({required int userId}) async {
    await loadTransactions(userId);
  }

  // Méthode pour vider le cache
  void clearData() {
    _transactions = [];
    _error = null;
    notifyListeners();
  }

  // Méthode pour effacer les erreurs
  void clearError() {
    _clearError();
    notifyListeners();
  }

  String generateTransactionKey(Transaction tx) {
    return '${tx.dateEvent.millisecondsSinceEpoch}_${tx.amount}_${tx.transactionType.name}_${tx.idAccountSender}_${tx.idAccountReceiver}';
  }

}