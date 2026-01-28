class AppConstants {
  // App info
  static const String appName = 'PackMate';
  static const String appVersion = '1.0.0';
  
  // Onboarding
  static const bool showOnboarding = true;
  static const String onboardingCompletedKey = 'onboarding_completed';
  
  // Trip types
  static const List<String> tripTypes = [
    'hike',
    'beach',
    'city',
    'business',
    'other',
  ];
  
  // Accommodation types
  static const List<String> accommodationTypes = [
    'tent',
    'hotel',
    'hostel',
    'apartment',
    'other',
  ];
  
  // Categories
  static const List<String> defaultCategories = [
    'clothing',
    'tech',
    'documents',
    'hygiene',
    'medicine',
    'gear',
  ];
  
  // Category display names (Russian)
  static const Map<String, String> categoryNames = {
    'clothing': 'Одежда',
    'tech': 'Техника',
    'documents': 'Документы',
    'hygiene': 'Гигиена',
    'medicine': 'Аптечка',
    'gear': 'Снаряжение',
  };
  
  // Category icons
  static const Map<String, String> categoryIcons = {
    'clothing': '👕',
    'tech': '📱',
    'documents': '📄',
    'hygiene': '🧴',
    'medicine': '💊',
    'gear': '🎒',
  };
  
  // Trip type display names (Russian)
  static const Map<String, String> tripTypeNames = {
    'hike': 'Поход',
    'beach': 'Пляж',
    'city': 'Город',
    'business': 'Командировка',
    'other': 'Другое',
  };
  
  // Trip type icons
  static const Map<String, String> tripTypeIcons = {
    'hike': '🏔️',
    'beach': '🏖️',
    'city': '🏙️',
    'business': '💼',
    'other': '✈️',
  };
  
  // Accommodation display names (Russian)
  static const Map<String, String> accommodationNames = {
    'tent': 'Палатка',
    'hotel': 'Отель',
    'hostel': 'Хостел',
    'apartment': 'Апартаменты',
    'other': 'Другое',
  };
  
  // Animation durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  
  // Padding and spacing
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  
  // Border radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
}
