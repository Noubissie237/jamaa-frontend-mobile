enum TransactionType {
  transfert,    // Correspond à TRANSFERT
  depot,        // Correspond à DEPOT
  retrait,      // Correspond à RETRAIT
  recharge,     // Correspond à RECHARGE
  virement,     // Correspond à VIREMENT
}

enum TransactionStatus {
  failed,       // Correspond à FAILED
  success,      // Correspond à SUCCESS
}

class Transaction {
  final String transactionId;
  final double amount;
  final String idAccountSender;
  final String idAccountReceiver;
  final TransactionType transactionType;
  final TransactionStatus status;
  final DateTime dateEvent;
  final DateTime? createdAt;
  
  // Champs optionnels pour l'affichage frontend
  final String? title;
  final String? description;
  final String currency;
  final String? recipientName;
  final String? recipientPhone;
  final String? bankName;
  final String? reference;
  final Map<String, dynamic>? metadata;
  final String? senderAccountNumber;
  final String? receiverAccountNumber;

  Transaction({
    required this.transactionId,
    required this.amount,
    required this.idAccountSender,
    required this.idAccountReceiver,
    required this.transactionType,
    required this.status,
    required this.dateEvent,
    this.createdAt,
    this.title,
    this.description,
    this.currency = 'XAF',
    this.recipientName,
    this.recipientPhone,
    this.bankName,
    this.reference,
    this.metadata,
    this.senderAccountNumber,
    this.receiverAccountNumber,
  });

  String get formattedAmount {
    return '${amount.toStringAsFixed(0)} $currency';
  }

  String get typeLabel {
    switch (transactionType) {
      case TransactionType.transfert:
        return 'Transfert';
      case TransactionType.depot:
        return 'Dépôt';
      case TransactionType.retrait:
        return 'Retrait';
      case TransactionType.recharge:
        return 'Recharge';
      case TransactionType.virement:
        return 'Virement';
    }
  }

  String get statusLabel {
    switch (status) {
      case TransactionStatus.success:
        return 'Réussi';
      case TransactionStatus.failed:
        return 'Échoué';
    }
  }

  // Méthode pour convertir les types backend vers frontend
  String get _transactionTypeToString {
    switch (transactionType) {
      case TransactionType.transfert:
        return 'TRANSFERT';
      case TransactionType.depot:
        return 'DEPOT';
      case TransactionType.retrait:
        return 'RETRAIT';
      case TransactionType.recharge:
        return 'RECHARGE';
      case TransactionType.virement:
        return 'VIREMENT';
    }
  }

  String get _statusToString {
    switch (status) {
      case TransactionStatus.success:
        return 'SUCCESS';
      case TransactionStatus.failed:
        return 'FAILED';
    }
  }

  // Méthode pour convertir depuis les strings backend
  static TransactionType _transactionTypeFromString(String type) {
    switch (type.toUpperCase()) {
      case 'TRANSFERT':
        return TransactionType.transfert;
      case 'DEPOT':
        return TransactionType.depot;
      case 'RETRAIT':
        return TransactionType.retrait;
      case 'RECHARGE':
        return TransactionType.recharge;
      case 'VIREMENT':
        return TransactionType.virement;
      default:
        throw ArgumentError('Type de transaction inconnu: $type');
    }
  }

  static TransactionStatus _statusFromString(String status) {
    switch (status.toUpperCase()) {
      case 'SUCCESS':
        return TransactionStatus.success;
      case 'FAILED':
        return TransactionStatus.failed;
      default:
        throw ArgumentError('Statut de transaction inconnu: $status');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'amount': amount,
      'idAccountSender': idAccountSender,
      'idAccountReceiver': idAccountReceiver,
      'transactionType': _transactionTypeToString,
      'status': _statusToString,
      'dateEvent': dateEvent.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'title': title,
      'description': description,
      'currency': currency,
      'recipientName': recipientName,
      'recipientPhone': recipientPhone,
      'bankName': bankName,
      'reference': reference,
      'metadata': metadata,
    };
  }

  // Factory pour créer depuis la réponse GraphQL
  factory Transaction.fromGraphQL(Map<String, dynamic> json) {
    return Transaction(
      transactionId: json['transactionId'],
      amount: double.parse(json['amount'].toString()),
      idAccountSender: json['idAccountSender'].toString(),
      idAccountReceiver: json['idAccountReceiver'].toString(),
      transactionType: _transactionTypeFromString(json['transactionType']),
      status: _statusFromString(json['status']),
      dateEvent: DateTime.parse(json['dateEvent']),
      createdAt: DateTime.parse(json['dateEvent']), // CORRECTION: Initialiser createdAt
      currency: 'XAF',
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      transactionId: json['transactionId'],
      amount: json['amount'].toDouble(),
      idAccountSender: json['idAccountSender'],
      idAccountReceiver: json['idAccountReceiver'],
      transactionType: _transactionTypeFromString(json['transactionType']),
      status: _statusFromString(json['status']),
      dateEvent: DateTime.parse(json['dateEvent']),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      title: json['title'],
      description: json['description'],
      currency: json['currency'] ?? 'XAF',
      recipientName: json['recipientName'],
      recipientPhone: json['recipientPhone'],
      bankName: json['bankName'],
      reference: json['reference'],
      metadata: json['metadata'],
    );
  }

  // Méthode pour enrichir une transaction avec des données d'affichage
  Transaction copyWith({
    String? transactionId,
    double? amount,
    String? idAccountSender,
    String? idAccountReceiver,
    TransactionType? transactionType,
    TransactionStatus? status,
    DateTime? dateEvent,
    DateTime? createdAt,
    String? title,
    String? description,
    String? currency,
    String? recipientName,
    String? recipientPhone,
    String? bankName,
    String? reference,
    Map<String, dynamic>? metadata,
    String? senderAccountNumber,
    String? receiverAccountNumber,
  }) {
    return Transaction(
      transactionId: transactionId ?? this.transactionId,
      amount: amount ?? this.amount,
      idAccountSender: idAccountSender ?? this.idAccountSender,
      idAccountReceiver: idAccountReceiver ?? this.idAccountReceiver,
      transactionType: transactionType ?? this.transactionType,
      status: status ?? this.status,
      dateEvent: dateEvent ?? this.dateEvent,
      createdAt: createdAt ?? this.createdAt,
      title: title ?? this.title,
      description: description ?? this.description,
      currency: currency ?? this.currency,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      bankName: bankName ?? this.bankName,
      reference: reference ?? this.reference,
      metadata: metadata ?? this.metadata,
      senderAccountNumber: senderAccountNumber ?? this.senderAccountNumber,
      receiverAccountNumber: receiverAccountNumber ?? this.receiverAccountNumber,
    );
  }

  // Méthodes de migration pour compatibilité avec l'ancien modèle
  TransactionType get type => transactionType; // Alias pour compatibilité
  DateTime get createdAtOrDateEvent => createdAt ?? dateEvent; // Fallback intelligent
  
  // Méthode pour créer depuis l'ancien format (rétrocompatibilité)
  factory Transaction.fromLegacyJson(Map<String, dynamic> json) {
    // Conversion des anciens types vers les nouveaux
    TransactionType convertLegacyType(String legacyType) {
      switch (legacyType.toLowerCase()) {
        case 'transfer':
          return TransactionType.transfert;
        case 'deposit':
          return TransactionType.depot;
        case 'withdraw':
          return TransactionType.retrait;
        case 'payment':
          return TransactionType.recharge;
        case 'billpayment':
          return TransactionType.virement;
        default:
          return TransactionType.transfert;
      }
    }

    TransactionStatus convertLegacyStatus(String legacyStatus) {
      switch (legacyStatus.toLowerCase()) {
        case 'completed':
        case 'pending': // On considère pending comme success temporairement
          return TransactionStatus.success;
        case 'failed':
        case 'cancelled':
          return TransactionStatus.failed;
        default:
          return TransactionStatus.success;
      }
    }

    return Transaction(
      transactionId: json['id'],
      amount: json['amount'].toDouble(),
      idAccountSender: json['idAccountSender'] ?? 0, // Valeur par défaut
      idAccountReceiver: json['idAccountReceiver'] ?? 0, // Valeur par défaut
      transactionType: json['type'] is int 
          ? TransactionType.values[json['type']]
          : convertLegacyType(json['type'].toString()),
      status: json['status'] is int 
          ? (json['status'] == 1 ? TransactionStatus.success : TransactionStatus.failed)
          : convertLegacyStatus(json['status'].toString()),
      dateEvent: DateTime.parse(json['createdAt'] ?? json['dateEvent'] ?? DateTime.now().toIso8601String()),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      title: json['title'],
      description: json['description'],
      currency: json['currency'] ?? 'XAF',
      recipientName: json['recipientName'],
      recipientPhone: json['recipientPhone'],
      bankName: json['bankName'],
      reference: json['reference'],
      metadata: json['metadata'],
    );
  }
}