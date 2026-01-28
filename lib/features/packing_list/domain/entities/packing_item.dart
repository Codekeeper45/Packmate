class PackingItem {
  final String id;
  final String tripId;
  final String categoryId;
  final String name;
  final int quantity;
  final bool isPacked;
  final bool isEssential;
  final String? note;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime? packedAt;

  PackingItem({
    required this.id,
    required this.tripId,
    required this.categoryId,
    required this.name,
    required this.quantity,
    required this.isPacked,
    required this.isEssential,
    this.note,
    required this.sortOrder,
    required this.createdAt,
    this.packedAt,
  });

  PackingItem copyWith({
    String? id,
    String? tripId,
    String? categoryId,
    String? name,
    int? quantity,
    bool? isPacked,
    bool? isEssential,
    String? note,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? packedAt,
  }) {
    return PackingItem(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      isPacked: isPacked ?? this.isPacked,
      isEssential: isEssential ?? this.isEssential,
      note: note ?? this.note,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      packedAt: packedAt ?? this.packedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'categoryId': categoryId,
      'name': name,
      'quantity': quantity,
      'isPacked': isPacked,
      'isEssential': isEssential,
      'note': note,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toIso8601String(),
      'packedAt': packedAt?.toIso8601String(),
    };
  }

  factory PackingItem.fromJson(Map<String, dynamic> json) {
    return PackingItem(
      id: json['id'] as String,
      tripId: json['tripId'] as String,
      categoryId: json['categoryId'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      isPacked: json['isPacked'] as bool,
      isEssential: json['isEssential'] as bool,
      note: json['note'] as String?,
      sortOrder: json['sortOrder'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      packedAt: json['packedAt'] != null 
          ? DateTime.parse(json['packedAt'] as String) 
          : null,
    );
  }
}
