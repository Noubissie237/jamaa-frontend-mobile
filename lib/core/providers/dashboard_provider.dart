import 'package:flutter/foundation.dart';
import '../models/bank_account.dart';

class DashboardProvider extends ChangeNotifier {
  double _totalBalance = 0.0;
  List<BankAccount> _bankAccounts = [];
  bool _isLoading = false;
  String? _error;

  double get totalBalance => _totalBalance;
  List<BankAccount> get bankAccounts => _bankAccounts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get formattedTotalBalance {
    return '${_totalBalance.toStringAsFixed(0)} XAF';
  }

  Future<void> loadDashboardData() async {
    _setLoading(true);
    _error = null;

    try {
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock bank accounts
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

      _totalBalance = _bankAccounts.fold(0.0, (sum, account) => sum + account.balance);
      notifyListeners();
    } catch (e) {
      _error = 'Erreur de chargement des données';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshBalance() async {
    await loadDashboardData();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}