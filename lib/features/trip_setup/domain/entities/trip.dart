class Trip {
  final String id;
  final String type;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final int durationDays;
  final String accommodation;
  final List<String> activities;
  final String? weatherConditions;
  final String? weatherTemp;
  final DateTime createdAt;
  final String status;

  Trip({
    required this.id,
    required this.type,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.durationDays,
    required this.accommodation,
    required this.activities,
    this.weatherConditions,
    this.weatherTemp,
    required this.createdAt,
    required this.status,
  });

  Trip copyWith({
    String? id,
    String? type,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    int? durationDays,
    String? accommodation,
    List<String>? activities,
    String? weatherConditions,
    String? weatherTemp,
    DateTime? createdAt,
    String? status,
  }) {
    return Trip(
      id: id ?? this.id,
      type: type ?? this.type,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      durationDays: durationDays ?? this.durationDays,
      accommodation: accommodation ?? this.accommodation,
      activities: activities ?? this.activities,
      weatherConditions: weatherConditions ?? this.weatherConditions,
      weatherTemp: weatherTemp ?? this.weatherTemp,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'destination': destination,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'durationDays': durationDays,
      'accommodation': accommodation,
      'activities': activities,
      'weatherConditions': weatherConditions,
      'weatherTemp': weatherTemp,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String,
      type: json['type'] as String,
      destination: json['destination'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      durationDays: json['durationDays'] as int,
      accommodation: json['accommodation'] as String,
      activities: List<String>.from(json['activities'] as List),
      weatherConditions: json['weatherConditions'] as String?,
      weatherTemp: json['weatherTemp'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: json['status'] as String,
    );
  }
}
