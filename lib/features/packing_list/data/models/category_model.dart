import 'package:isar/isar.dart';

part 'category_model.g.dart';

@collection
class CategoryModel {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String categoryId;
  
  @Index()
  late String tripId;
  
  late String name;
  late String icon;
  late int sortOrder;
  late String colorHex;
  
  late int totalItems;
  late int packedItems;
}
