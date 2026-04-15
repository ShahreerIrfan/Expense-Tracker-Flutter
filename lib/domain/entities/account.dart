class AccountEntity {
  final int? id;
  final int userId;
  final String name;
  final String type; // cash, bank, mobile_wallet, credit_card
  final String icon;
  final String color;
  final double balance;
  final double initialBalance;
  final String currency;
  final String? accountNumber;
  final String? bankName;
  final bool includeInTotal;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AccountEntity({
    this.id,
    required this.userId,
    required this.name,
    required this.type,
    this.icon = 'account_balance_wallet',
    this.color = '#2196F3',
    this.balance = 0.0,
    this.initialBalance = 0.0,
    this.currency = 'BDT',
    this.accountNumber,
    this.bankName,
    this.includeInTotal = true,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  AccountEntity copyWith({
    int? id,
    int? userId,
    String? name,
    String? type,
    String? icon,
    String? color,
    double? balance,
    double? initialBalance,
    String? currency,
    String? accountNumber,
    String? bankName,
    bool? includeInTotal,
    bool? isActive,
  }) {
    return AccountEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      balance: balance ?? this.balance,
      initialBalance: initialBalance ?? this.initialBalance,
      currency: currency ?? this.currency,
      accountNumber: accountNumber ?? this.accountNumber,
      bankName: bankName ?? this.bankName,
      includeInTotal: includeInTotal ?? this.includeInTotal,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'name': name,
        'type': type,
        'icon': icon,
        'color': color,
        'balance': balance,
        'initialBalance': initialBalance,
        'currency': currency,
        'accountNumber': accountNumber,
        'bankName': bankName,
        'includeInTotal': includeInTotal,
        'isActive': isActive,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory AccountEntity.fromJson(Map<String, dynamic> json) => AccountEntity(
        id: json['id'] as int?,
        userId: json['userId'] as int,
        name: json['name'] as String,
        type: json['type'] as String,
        icon: json['icon'] as String? ?? 'account_balance_wallet',
        color: json['color'] as String? ?? '#2196F3',
        balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
        initialBalance: (json['initialBalance'] as num?)?.toDouble() ?? 0.0,
        currency: json['currency'] as String? ?? 'BDT',
        accountNumber: json['accountNumber'] as String?,
        bankName: json['bankName'] as String?,
        includeInTotal: json['includeInTotal'] as bool? ?? true,
        isActive: json['isActive'] as bool? ?? true,
      );
}
