class TransactionEntity {
  final int? id;
  final int userId;
  final String type; // expense, income, transfer
  final int referenceId;
  final int? fromAccountId;
  final int? toAccountId;
  final double amount;
  final String? note;
  final DateTime date;
  final DateTime? createdAt;

  const TransactionEntity({
    this.id,
    required this.userId,
    required this.type,
    required this.referenceId,
    this.fromAccountId,
    this.toAccountId,
    required this.amount,
    this.note,
    required this.date,
    this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'type': type,
        'referenceId': referenceId,
        'fromAccountId': fromAccountId,
        'toAccountId': toAccountId,
        'amount': amount,
        'note': note,
        'date': date.toIso8601String(),
        'createdAt': createdAt?.toIso8601String(),
      };

  factory TransactionEntity.fromJson(Map<String, dynamic> json) =>
      TransactionEntity(
        id: json['id'] as int?,
        userId: json['userId'] as int,
        type: json['type'] as String,
        referenceId: json['referenceId'] as int,
        fromAccountId: json['fromAccountId'] as int?,
        toAccountId: json['toAccountId'] as int?,
        amount: (json['amount'] as num).toDouble(),
        note: json['note'] as String?,
        date: DateTime.parse(json['date'] as String),
      );
}
