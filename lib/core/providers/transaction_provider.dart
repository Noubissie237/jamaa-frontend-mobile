import 'package:flutter/foundation.dart';
import '../models/transaction.dart';

class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Transaction> get recentTransactions {
    return _transactions.take(5).toList();
  }

  Future<void> loadTransactions() async {
    _setLoading(true);
    _error = null;

    try {
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock transactions
      _transactions = [
        Transaction(
          id: '1',
          title: 'Transfert vers Marie Nguyen',
          description: 'Envoi d\'argent',
          amount: -25000,
          type: TransactionType.transfer,
          status: TransactionStatus.completed,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          recipientName: 'Marie Nguyen',
          recipientPhone: '+237698765432',
          reference: 'TXN001',
        ),
        Transaction(
          id: '2',
          title: 'Dépôt via agent',
          description: 'Dépôt d\'espèces',
          amount: 50000,
          type: TransactionType.deposit,
          status: TransactionStatus.completed,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          reference: 'DEP002',
        ),
        Transaction(
          id: '3',
          title: 'Paiement ENEO',
          description: 'Facture électricité',
          amount: -15000,
          type: TransactionType.billPayment,
          status: TransactionStatus.completed,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          reference: 'BILL003',
        ),
        Transaction(
          id: '4',
          title: 'Retrait GAB',
          description: 'Retrait d\'espèces',
          amount: -30000,
          type: TransactionType.withdraw,
          status: TransactionStatus.completed,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          reference: 'WTH004',
        ),
      ];

      _transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
    } catch (e) {
      _error = 'Erreur de chargement des transactions';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createTransaction({
    required String title,
    required String description,
    required double amount,
    required TransactionType type,
    String? recipientName,
    String? recipientPhone,
    String? bankName,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      await Future.delayed(const Duration(seconds: 2));
      
      final newTransaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        amount: amount,
        type: type,
        status: TransactionStatus.pending,
        createdAt: DateTime.now(),
        recipientName: recipientName,
        recipientPhone: recipientPhone,
        bankName: bankName,
        reference: 'TXN${DateTime.now().millisecondsSinceEpoch}',
      );

      _transactions.insert(0, newTransaction);
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de la création de la transaction';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}