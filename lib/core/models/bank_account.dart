class BankAccount {
  final String id;
  final String bankName;
  final String accountNumber;
  final String accountType;
  final double balance;
  final String currency;
  final String bankLogo;
  final bool isActive;
  final DateTime linkedAt;
  final String bankId;

  BankAccount({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    required this.accountType,
    required this.balance,
    this.currency = 'XAF',
    required this.bankLogo,
    this.isActive = true,
    required this.linkedAt,
    required this.bankId,
  });

  String get maskedAccountNumber {
    if (accountNumber.length <= 4) return accountNumber;
    return '**** **** ${accountNumber.substring(accountNumber.length - 4)}';
  }

    String get formattedBalance {
    return '${balance.toStringAsFixed(2)} $currency';
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountType': accountType,
      'balance': balance,
      'currency': currency,
      'bankLogo': bankLogo,
      'isActive': isActive,
      'linkedAt': linkedAt.toIso8601String(),
      'bankId': bankId,
    };
  }

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id'],
      bankName: json['bankName'],
      accountNumber: json['accountNumber'],
      accountType: json['accountType'],
      balance: json['balance'].toDouble(),
      currency: json['currency'] ?? 'XAF',
      bankLogo: json['bankLogo'],
      isActive: json['isActive'] ?? true,
      linkedAt: DateTime.parse(json['linkedAt']),
      bankId: json['bankId'],
    );
  }
}