class CategoryEntity {
  final int? id;
  final int userId;
  final String name;
  final String icon;
  final String color;
  final String type; // expense, income, both
  final int? parentId;
  final int sortOrder;
  final bool isDefault;
  final bool isActive;
  final DateTime? createdAt;

  // Computed
  final List<CategoryEntity>? children;

  const CategoryEntity({
    this.id,
    required this.userId,
    required this.name,
    this.icon = 'category',
    this.color = '#4CAF50',
    required this.type,
    this.parentId,
    this.sortOrder = 0,
    this.isDefault = false,
    this.isActive = true,
    this.createdAt,
    this.children,
  });

  CategoryEntity copyWith({
    int? id,
    int? userId,
    String? name,
    String? icon,
    String? color,
    String? type,
    int? parentId,
    int? sortOrder,
    bool? isDefault,
    bool? isActive,
    List<CategoryEntity>? children,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      parentId: parentId ?? this.parentId,
      sortOrder: sortOrder ?? this.sortOrder,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      children: children ?? this.children,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'name': name,
        'icon': icon,
        'color': color,
        'type': type,
        'parentId': parentId,
        'sortOrder': sortOrder,
        'isDefault': isDefault,
        'isActive': isActive,
        'createdAt': createdAt?.toIso8601String(),
      };

  factory CategoryEntity.fromJson(Map<String, dynamic> json) => CategoryEntity(
        id: json['id'] as int?,
        userId: json['userId'] as int,
        name: json['name'] as String,
        icon: json['icon'] as String? ?? 'category',
        color: json['color'] as String? ?? '#4CAF50',
        type: json['type'] as String,
        parentId: json['parentId'] as int?,
        sortOrder: json['sortOrder'] as int? ?? 0,
        isDefault: json['isDefault'] as bool? ?? false,
        isActive: json['isActive'] as bool? ?? true,
      );
}
