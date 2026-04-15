class BudgetEntity {
  final int? id;
  final int userId;
  final int? categoryId;
  final double amount;
  final double spent;
  final String period; // weekly, monthly, yearly
  final DateTime startDate;
  final DateTime endDate;
  final bool rollover;
  final double rolloverAmount;
  final bool alertAt50;
  final bool alertAt80;
  final bool alertAt100;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Computed
  final String? categoryName;
  final String? categoryColor;

  const BudgetEntity({
    this.id,
    required this.userId,
    this.categoryId,
    required this.amount,
    this.spent = 0.0,
    required this.period,
    required this.startDate,
    required this.endDate,
    this.rollover = false,
    this.rolloverAmount = 0.0,
    this.alertAt50 = true,
    this.alertAt80 = true,
    this.alertAt100 = true,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.categoryName,
    this.categoryColor,
  });

  double get remaining => amount + rolloverAmount - spent;
  double get utilizationPercent =>
      amount > 0 ? (spent / (amount + rolloverAmount)) * 100 : 0;
  bool get isOverBudget => spent > (amount + rolloverAmount);

  BudgetEntity copyWith({
    int? id,
    int? userId,
    int? categoryId,
    double? amount,
    double? spent,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
    bool? rollover,
    double? rolloverAmount,
    bool? alertAt50,
    bool? alertAt80,
    bool? alertAt100,
    bool? isActive,
  }) {
    return BudgetEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      spent: spent ?? this.spent,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      rollover: rollover ?? this.rollover,
      rolloverAmount: rolloverAmount ?? this.rolloverAmount,
      alertAt50: alertAt50 ?? this.alertAt50,
      alertAt80: alertAt80 ?? this.alertAt80,
      alertAt100: alertAt100 ?? this.alertAt100,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'categoryId': categoryId,
        'amount': amount,
        'spent': spent,
        'period': period,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'rollover': rollover,
        'rolloverAmount': rolloverAmount,
        'alertAt50': alertAt50,
        'alertAt80': alertAt80,
        'alertAt100': alertAt100,
        'isActive': isActive,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory BudgetEntity.fromJson(Map<String, dynamic> json) => BudgetEntity(
        id: json['id'] as int?,
        userId: json['userId'] as int,
        categoryId: json['categoryId'] as int?,
        amount: (json['amount'] as num).toDouble(),
        spent: (json['spent'] as num?)?.toDouble() ?? 0.0,
        period: json['period'] as String,
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: DateTime.parse(json['endDate'] as String),
        rollover: json['rollover'] as bool? ?? false,
        rolloverAmount: (json['rolloverAmount'] as num?)?.toDouble() ?? 0.0,
        alertAt50: json['alertAt50'] as bool? ?? true,
        alertAt80: json['alertAt80'] as bool? ?? true,
        alertAt100: json['alertAt100'] as bool? ?? true,
        isActive: json['isActive'] as bool? ?? true,
      );
}
