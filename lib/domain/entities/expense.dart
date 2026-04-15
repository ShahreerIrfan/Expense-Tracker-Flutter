class ExpenseEntity {
  final int? id;
  final int userId;
  final int categoryId;
  final int accountId;
  final double amount;
  final String title;
  final String? description;
  final DateTime date;
  final bool isRecurring;
  final String? recurringType;
  final int? recurringInterval;
  final DateTime? nextRecurringDate;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String? receiptPath;
  final List<String>? tags;
  final List<SplitDetail>? splitWith;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Joined fields
  final String? categoryName;
  final String? categoryColor;
  final String? categoryIcon;
  final String? accountName;

  const ExpenseEntity({
    this.id,
    required this.userId,
    required this.categoryId,
    required this.accountId,
    required this.amount,
    required this.title,
    this.description,
    required this.date,
    this.isRecurring = false,
    this.recurringType,
    this.recurringInterval,
    this.nextRecurringDate,
    this.location,
    this.latitude,
    this.longitude,
    this.receiptPath,
    this.tags,
    this.splitWith,
    this.createdAt,
    this.updatedAt,
    this.categoryName,
    this.categoryColor,
    this.categoryIcon,
    this.accountName,
  });

  ExpenseEntity copyWith({
    int? id,
    int? userId,
    int? categoryId,
    int? accountId,
    double? amount,
    String? title,
    String? description,
    DateTime? date,
    bool? isRecurring,
    String? recurringType,
    int? recurringInterval,
    DateTime? nextRecurringDate,
    String? location,
    double? latitude,
    double? longitude,
    String? receiptPath,
    List<String>? tags,
    List<SplitDetail>? splitWith,
  }) {
    return ExpenseEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      amount: amount ?? this.amount,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringType: recurringType ?? this.recurringType,
      recurringInterval: recurringInterval ?? this.recurringInterval,
      nextRecurringDate: nextRecurringDate ?? this.nextRecurringDate,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      receiptPath: receiptPath ?? this.receiptPath,
      tags: tags ?? this.tags,
      splitWith: splitWith ?? this.splitWith,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      categoryName: categoryName,
      categoryColor: categoryColor,
      categoryIcon: categoryIcon,
      accountName: accountName,
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
        'date': date.toIso8601String(),
        'isRecurring': isRecurring,
        'recurringType': recurringType,
        'recurringInterval': recurringInterval,
        'nextRecurringDate': nextRecurringDate?.toIso8601String(),
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'receiptPath': receiptPath,
        'tags': tags,
        'splitWith': splitWith?.map((e) => e.toJson()).toList(),
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory ExpenseEntity.fromJson(Map<String, dynamic> json) => ExpenseEntity(
        id: json['id'] as int?,
        userId: json['userId'] as int,
        categoryId: json['categoryId'] as int,
        accountId: json['accountId'] as int,
        amount: (json['amount'] as num).toDouble(),
        title: json['title'] as String,
        description: json['description'] as String?,
        date: DateTime.parse(json['date'] as String),
        isRecurring: json['isRecurring'] as bool? ?? false,
        recurringType: json['recurringType'] as String?,
        recurringInterval: json['recurringInterval'] as int?,
        nextRecurringDate: json['nextRecurringDate'] != null
            ? DateTime.parse(json['nextRecurringDate'] as String)
            : null,
        location: json['location'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        receiptPath: json['receiptPath'] as String?,
        tags: (json['tags'] as List<dynamic>?)?.cast<String>(),
        splitWith: (json['splitWith'] as List<dynamic>?)
            ?.map((e) => SplitDetail.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class SplitDetail {
  final String name;
  final double amount;
  final bool isPaid;

  const SplitDetail({
    required this.name,
    required this.amount,
    this.isPaid = false,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'amount': amount,
        'isPaid': isPaid,
      };

  factory SplitDetail.fromJson(Map<String, dynamic> json) => SplitDetail(
        name: json['name'] as String,
        amount: (json['amount'] as num).toDouble(),
        isPaid: json['isPaid'] as bool? ?? false,
      );
}
