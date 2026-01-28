import 'package:isar/isar.dart';

part 'packing_item_model.g.dart';

@collection
class PackingItemModel {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String itemId;
  
  @Index()
  late String tripId;
  
  @Index()
  late String categoryId;
  
  late String name;
  late int quantity;
  late bool isPacked;
  late bool isEssential;
  String? note;
  
  late int sortOrder;
  late DateTime createdAt;
  DateTime? packedAt;
}
