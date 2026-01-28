import 'package:isar/isar.dart';

part 'template_model.g.dart';

@collection
class TemplateModel {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String templateId;
  
  late String name;
  late String tripType;
  late String categoriesJson; // JSON string of categories with items
  
  late DateTime createdAt;
  DateTime? updatedAt;
  late int usageCount;
}
