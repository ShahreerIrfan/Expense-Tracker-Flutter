class IncomeEntity {
  final int? id;
  final int userId;
  final int categoryId;
  final int accountId;
  final double amount;
  final String title;
  final String? description;
  final String? source;
  final DateTime date;
  final bool isRecurring;
  final String? recurringType;
  final int? recurringInterval;
  final DateTime? nextRecurringDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Joined fields
  final String? categoryName;
  final String? accountName;

  const IncomeEntity({
    this.id,
    required this.userId,
    required this.categoryId,
    required this.accountId,
    required this.amount,
    required this.title,
    this.description,
    this.source,
    required this.date,
    this.isRecurring = false,
    this.recurringType,
    this.recurringInterval,
    this.nextRecurringDate,
    this.createdAt,
    this.updatedAt,
    this.categoryName,
    this.accountName,
  });

  IncomeEntity copyWith({
    int? id,
    int? userId,
    int? categoryId,
    int? accountId,
    double? amount,
    String? title,
    String? description,
    String? source,
    DateTime? date,
    bool? isRecurring,
    String? recurringType,
    int? recurringInterval,
    DateTime? nextRecurringDate,
  }) {
    return IncomeEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      amount: amount ?? this.amount,
      title: title ?? this.title,
      description: description ?? this.description,
      source: source ?? this.source,
      date: date ?? this.date,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringType: recurringType ?? this.recurringType,
      recurringInterval: recurringInterval ?? this.recurringInterval,
      nextRecurringDate: nextRecurringDate ?? this.nextRecurringDate,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'categoryId': categoryId,
        'accountId': accountId,
        'amount': amount,
        'title': title,
        'description': description,
        'source': source,
        'date': date.toIso8601String(),
        'isRecurring': isRecurring,
        'recurringType': recurringType,
        'recurringInterval': recurringInterval,
        'nextRecurringDate': nextRecurringDate?.toIso8601String(),
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory IncomeEntity.fromJson(Map<String, dynamic> json) => IncomeEntity(
        id: json['id'] as int?,
        userId: json['userId'] as int,
        categoryId: json['categoryId'] as int,
        accountId: json['accountId'] as int,
        amount: (json['amount'] as num).toDouble(),
        title: json['title'] as String,
        description: json['description'] as String?,
        source: json['source'] as String?,
        date: DateTime.parse(json['date'] as String),
        isRecurring: json['isRecurring'] as bool? ?? false,
        recurringType: json['recurringType'] as String?,
        recurringInterval: json['recurringInterval'] as int?,
        nextRecurringDate: json['nextRecurringDate'] != null
            ? DateTime.parse(json['nextRecurringDate'] as String)
            : null,
      );
}
