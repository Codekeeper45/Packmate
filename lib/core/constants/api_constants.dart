import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // Weather API
  static String get weatherApiKey =>
      dotenv.env['WEATHER_API_KEY'] ?? 'demo_key';
  static const String weatherBaseUrl = 'http://api.weatherapi.com/v1';
  static const String weatherForecastEndpoint = '/forecast.json';
  
  // Gemini AI (via Firebase)
  static const String geminiModel = 'gemini-1.5-flash';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
  
  // Cache durations
  static const Duration weatherCacheDuration = Duration(minutes: 30);
  static const Duration aiCacheDuration = Duration(hours: 24);
}
