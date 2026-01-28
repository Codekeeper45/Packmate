import 'packing_item.dart';

class Category {
  final String id;
  final String tripId;
  final String name;
  final String icon;
  final int sortOrder;
  final String colorHex;
  final List<PackingItem> items;
  final int totalItems;
  final int packedItems;

  Category({
    required this.id,
    required this.tripId,
    required this.name,
    required this.icon,
    required this.sortOrder,
    required this.colorHex,
    required this.items,
    required this.totalItems,
    required this.packedItems,
  });

  double get progressPercent {
    if (totalItems == 0) return 0.0;
    return (packedItems / totalItems) * 100;
  }

  bool get isComplete => totalItems > 0 && packedItems == totalItems;

  Category copyWith({
    String? id,
    String? tripId,
    String? name,
    String? icon,
    int? sortOrder,
    String? colorHex,
    List<PackingItem>? items,
    int? totalItems,
    int? packedItems,
  }) {
    return Category(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
      colorHex: colorHex ?? this.colorHex,
      items: items ?? this.items,
      totalItems: totalItems ?? this.totalItems,
      packedItems: packedItems ?? this.packedItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'name': name,
      'icon': icon,
      'sortOrder': sortOrder,
      'colorHex': colorHex,
      'items': items.map((e) => e.toJson()).toList(),
      'totalItems': totalItems,
      'packedItems': packedItems,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List? ?? [];
    return Category(
      id: json['id'] as String,
      tripId: json['tripId'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      sortOrder: json['sortOrder'] as int,
      colorHex: json['colorHex'] as String,
      items: itemsList.map((e) => PackingItem.fromJson(e as Map<String, dynamic>)).toList(),
      totalItems: json['totalItems'] as int,
      packedItems: json['packedItems'] as int,
    );
  }
}
