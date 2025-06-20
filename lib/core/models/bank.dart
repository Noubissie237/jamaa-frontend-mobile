class Bank {
  final String id;
  final String name;
  final String slogan;
  final double minimumBalance;
  final double withdrawFees;
  final double internalTransferFees;
  final double externalTransferFees;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Bank({
    required this.id,
    required this.name,
    required this.slogan,
    required this.minimumBalance,
    required this.withdrawFees,
    required this.internalTransferFees,
    required this.externalTransferFees,
    required this.createdAt,
    this.updatedAt,
  });

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      id: json['id'],
      name: json['name'],
      slogan: json['slogan'],
      minimumBalance: (json['minimumBalance'] as num).toDouble(),
      withdrawFees: (json['withdrawFees'] as num).toDouble(),
      internalTransferFees: (json['internalTransferFees'] as num).toDouble(),
      externalTransferFees: (json['externalTransferFees'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }
}
