import '../../../packing_list/domain/entities/category.dart';

class Template {
  final String id;
  final String name;
  final String tripType;
  final List<Category> categories;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int usageCount;

  Template({
    required this.id,
    required this.name,
    required this.tripType,
    required this.categories,
    required this.createdAt,
    this.updatedAt,
    required this.usageCount,
  });

  int get totalItems {
    return categories.fold(0, (sum, cat) => sum + cat.items.length);
  }

  Template copyWith({
    String? id,
    String? name,
    String? tripType,
    List<Category>? categories,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? usageCount,
  }) {
    return Template(
      id: id ?? this.id,
      name: name ?? this.name,
      tripType: tripType ?? this.tripType,
      categories: categories ?? this.categories,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      usageCount: usageCount ?? this.usageCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tripType': tripType,
      'categories': categories.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'usageCount': usageCount,
    };
  }

  factory Template.fromJson(Map<String, dynamic> json) {
    final categoriesList = json['categories'] as List? ?? [];
    return Template(
      id: json['id'] as String,
      name: json['name'] as String,
      tripType: json['tripType'] as String,
      categories: categoriesList
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      usageCount: json['usageCount'] as int,
    );
  }
}
