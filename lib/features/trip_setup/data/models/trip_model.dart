import 'package:isar/isar.dart';

part 'trip_model.g.dart';

@collection
class TripModel {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String tripId;
  
  @Enumerated(EnumType.name)
  late TripType type;
  
  late String destination;
  late DateTime startDate;
  late DateTime endDate;
  late int durationDays;
  
  @Enumerated(EnumType.name)
  late AccommodationType accommodation;
  
  late List<String> activities;
  String? weatherConditions;
  String? weatherTemp;
  
  late DateTime createdAt;
  DateTime? updatedAt;
  
  @Enumerated(EnumType.name)
  late TripStatus status;
}

enum TripType {
  hike,
  beach,
  city,
  business,
  other,
}

enum AccommodationType {
  tent,
  hotel,
  hostel,
  apartment,
  other,
}

enum TripStatus {
  draft,
  planning,
  packing,
  completed,
}
