class Transfert {
  final String id;
  final String senderAccountId;
  final String receiverAccountId;
  final double amount;
  final DateTime createdAt;

  Transfert({
    required this.id,
    required this.senderAccountId,
    required this.receiverAccountId,
    required this.amount,
    required this.createdAt,
  });

  factory Transfert.fromJson(Map<String, dynamic> json) {
    return Transfert(
      id: json['id']?.toString() ?? '',
      senderAccountId: json['senderAccountId']?.toString() ?? '',
      receiverAccountId: json['receiverAccountId']?.toString() ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      createdAt: _parseDate(json['createAt']),
    );
  }

  static DateTime _parseDate(dynamic date) {
    try {
      return date != null ? DateTime.parse(date.toString()) : DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }
}