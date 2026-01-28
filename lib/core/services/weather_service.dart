import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/api_constants.dart';

class WeatherService {
  final Dio _dio;

  WeatherService() : _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.weatherBaseUrl,
      connectTimeout: ApiConstants.connectionTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
    ),
  );

  Future<WeatherData?> getWeatherForecast(String location, {int days = 3}) async {
    try {
      final response = await _dio.get(
        ApiConstants.weatherForecastEndpoint,
        queryParameters: {
          'key': ApiConstants.weatherApiKey,
          'q': location,
          'days': days,
          'lang': 'ru',
        },
      );

      if (response.statusCode == 200) {
        return WeatherData.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Weather API error: $e');
      return null;
    }
  }
}

class WeatherData {
  final String locationName;
  final String country;
  final double currentTempC;
  final String condition;
  final String conditionIcon;
  final List<ForecastDay> forecast;

  WeatherData({
    required this.locationName,
    required this.country,
    required this.currentTempC,
    required this.condition,
    required this.conditionIcon,
    required this.forecast,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>;
    final current = json['current'] as Map<String, dynamic>;
    final forecastData = json['forecast'] as Map<String, dynamic>;
    final forecastDays = forecastData['forecastday'] as List;

    return WeatherData(
      locationName: location['name'] as String,
      country: location['country'] as String,
      currentTempC: (current['temp_c'] as num).toDouble(),
      condition: (current['condition'] as Map<String, dynamic>)['text'] as String,
      conditionIcon: (current['condition'] as Map<String, dynamic>)['icon'] as String,
      forecast: forecastDays
          .map((day) => ForecastDay.fromJson(day as Map<String, dynamic>))
          .toList(),
    );
  }

  String get summary {
    if (forecast.isEmpty) return condition;
    
    final avgTemp = forecast.fold<double>(0, (sum, day) => sum + day.avgTempC) / forecast.length;
    final hasRain = forecast.any((day) => day.chanceOfRain > 30);
    
    String summary = '${avgTemp.round()}°C, $condition';
    if (hasRain) summary += ', возможен дождь';
    
    return summary;
  }

  String get tempRange {
    if (forecast.isEmpty) return '${currentTempC.round()}°C';
    
    final minTemp = forecast.map((d) => d.minTempC).reduce((a, b) => a < b ? a : b);
    final maxTemp = forecast.map((d) => d.maxTempC).reduce((a, b) => a > b ? a : b);
    
    return '${minTemp.round()}°C - ${maxTemp.round()}°C';
  }
}

class ForecastDay {
  final DateTime date;
  final double maxTempC;
  final double minTempC;
  final double avgTempC;
  final String condition;
  final String conditionIcon;
  final int chanceOfRain;

  ForecastDay({
    required this.date,
    required this.maxTempC,
    required this.minTempC,
    required this.avgTempC,
    required this.condition,
    required this.conditionIcon,
    required this.chanceOfRain,
  });

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    final day = json['day'] as Map<String, dynamic>;
    
    return ForecastDay(
      date: DateTime.parse(json['date'] as String),
      maxTempC: (day['maxtemp_c'] as num).toDouble(),
      minTempC: (day['mintemp_c'] as num).toDouble(),
      avgTempC: (day['avgtemp_c'] as num).toDouble(),
      condition: (day['condition'] as Map<String, dynamic>)['text'] as String,
      conditionIcon: (day['condition'] as Map<String, dynamic>)['icon'] as String,
      chanceOfRain: (day['daily_chance_of_rain'] as num?)?.toInt() ?? 0,
    );
  }
}

// Provider for Weather Service
final weatherServiceProvider = Provider<WeatherService>((ref) => WeatherService());

// Weather data provider for a specific location
final weatherDataProvider = FutureProvider.family<WeatherData?, String>((ref, location) async {
  if (location.isEmpty) return null;
  final service = ref.read(weatherServiceProvider);
  return service.getWeatherForecast(location, days: 7);
});
