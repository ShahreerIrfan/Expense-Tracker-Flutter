class UserEntity {
  final int? id;
  final String name;
  final String? email;
  final String avatarColor;
  final String? pin;
  final bool biometricEnabled;
  final String currency;
  final String language;
  final bool isDarkMode;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserEntity({
    this.id,
    required this.name,
    this.email,
    this.avatarColor = '#4CAF50',
    this.pin,
    this.biometricEnabled = false,
    this.currency = 'BDT',
    this.language = 'en',
    this.isDarkMode = false,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  UserEntity copyWith({
    int? id,
    String? name,
    String? email,
    String? avatarColor,
    String? pin,
    bool? biometricEnabled,
    String? currency,
    String? language,
    bool? isDarkMode,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarColor: avatarColor ?? this.avatarColor,
      pin: pin ?? this.pin,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'avatarColor': avatarColor,
        'biometricEnabled': biometricEnabled,
        'currency': currency,
        'language': language,
        'isDarkMode': isDarkMode,
        'isActive': isActive,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory UserEntity.fromJson(Map<String, dynamic> json) => UserEntity(
        id: json['id'] as int?,
        name: json['name'] as String,
        email: json['email'] as String?,
        avatarColor: json['avatarColor'] as String? ?? '#4CAF50',
        biometricEnabled: json['biometricEnabled'] as bool? ?? false,
        currency: json['currency'] as String? ?? 'BDT',
        language: json['language'] as String? ?? 'en',
        isDarkMode: json['isDarkMode'] as bool? ?? false,
        isActive: json['isActive'] as bool? ?? true,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
      );
}
