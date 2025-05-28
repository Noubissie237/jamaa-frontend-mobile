enum TransactionType {
  transfer,
  deposit,
  withdraw,
  payment,
  billPayment,
}

enum TransactionStatus {
  pending,
  completed,
  failed,
  cancelled,
}

class Transaction {
  final String id;
  final String title;
  final String description;
  final double amount;
  final String currency;
  final TransactionType type;
  final TransactionStatus status;
  final DateTime createdAt;
  final String? recipientName;
  final String? recipientPhone;
  final String? bankName;
  final String? reference;
  final Map<String, dynamic>? metadata;

  Transaction({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    this.currency = 'XAF',
    required this.type,
    required this.status,
    required this.createdAt,
    this.recipientName,
    this.recipientPhone,
    this.bankName,
    this.reference,
    this.metadata,
  });

  String get formattedAmount {
    return '${amount.toStringAsFixed(0)} $currency';
  }

  String get typeLabel {
    switch (type) {
      case TransactionType.transfer:
        return 'Transfert';
      case TransactionType.deposit:
        return 'Dépôt';
      case TransactionType.withdraw:
        return 'Retrait';
      case TransactionType.payment:
        return 'Paiement';
      case TransactionType.billPayment:
        return 'Facture';
    }
  }

  String get statusLabel {
    switch (status) {
      case TransactionStatus.pending:
        return 'En attente';
      case TransactionStatus.completed:
        return 'Terminé';
      case TransactionStatus.failed:
        return 'Échoué';
      case TransactionStatus.cancelled:
        return 'Annulé';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'currency': currency,
      'type': type.index,
      'status': status.index,
      'createdAt': createdAt.toIso8601String(),
      'recipientName': recipientName,
      'recipientPhone': recipientPhone,
      'bankName': bankName,
      'reference': reference,
      'metadata': metadata,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      amount: json['amount'].toDouble(),
      currency: json['currency'] ?? 'XAF',
      type: TransactionType.values[json['type']],
      status: TransactionStatus.values[json['status']],
      createdAt: DateTime.parse(json['createdAt']),
      recipientName: json['recipientName'],
      recipientPhone: json['recipientPhone'],
      bankName: json['bankName'],
      reference: json['reference'],
      metadata: json['metadata'],
    );
  }
}
