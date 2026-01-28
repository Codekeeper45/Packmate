import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';

import '../../features/packing_list/domain/entities/category.dart';
import '../../features/packing_list/domain/entities/packing_item.dart';
import '../constants/app_constants.dart';

class AIService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent';
  
  final Dio _dio = Dio();
  final _uuid = const Uuid();

  Future<List<Category>> generatePackingList({
    required String tripId,
    required String tripType,
    required String destination,
    required int durationDays,
    required String accommodation,
    required List<String> activities,
    String? weatherConditions,
    String? weatherTemp,
  }) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      return _generateRuleBased(
        tripId: tripId,
        tripType: tripType,
        durationDays: durationDays,
        accommodation: accommodation,
        activities: activities,
        weatherTemp: weatherTemp,
      );
    }

    // Try Gemini API first
    try {
      final categories = await _generateWithGemini(
        apiKey: apiKey,
        tripId: tripId,
        tripType: tripType,
        destination: destination,
        durationDays: durationDays,
        accommodation: accommodation,
        activities: activities,
        weatherConditions: weatherConditions,
        weatherTemp: weatherTemp,
      );
      if (categories.isNotEmpty) {
        return categories;
      }
    } catch (e) {
      print('Gemini API error: $e');
      // Fall back to rule-based generation
    }
    
    // Fallback: rule-based generation
    return _generateRuleBased(
      tripId: tripId,
      tripType: tripType,
      durationDays: durationDays,
      accommodation: accommodation,
      activities: activities,
      weatherTemp: weatherTemp,
    );
  }

  Future<List<Category>> _generateWithGemini({
    required String apiKey,
    required String tripId,
    required String tripType,
    required String destination,
    required int durationDays,
    required String accommodation,
    required List<String> activities,
    String? weatherConditions,
    String? weatherTemp,
  }) async {
    final prompt = buildPrompt(
      tripType: tripType,
      destination: destination,
      durationDays: durationDays,
      accommodation: accommodation,
      activities: activities,
      weatherConditions: weatherConditions,
    );

    final response = await _dio.post(
      '$_baseUrl?key=$apiKey',
      options: Options(
        headers: {'Content-Type': 'application/json'},
      ),
      data: {
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 4096,
        }
      },
    );

    if (response.statusCode == 200) {
      final data = response.data;
      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
      
      if (text != null) {
        return _parseGeminiResponse(tripId, text);
      }
    }
    
    return [];
  }

  List<Category> _parseGeminiResponse(String tripId, String responseText) {
    try {
      // Extract JSON from response (may have markdown code blocks)
      String jsonStr = responseText;
      
      // Remove markdown code blocks if present
      final jsonMatch = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```').firstMatch(responseText);
      if (jsonMatch != null) {
        jsonStr = jsonMatch.group(1) ?? responseText;
      }
      
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      final categoriesJson = json['categories'] as List<dynamic>?;
      
      if (categoriesJson == null) return [];
      
      final categories = <Category>[];
      int sortOrder = 0;
      
      for (final catJson in categoriesJson) {
        final categoryId = _uuid.v4();
        final items = <PackingItem>[];
        
        final itemsJson = catJson['items'] as List<dynamic>? ?? [];
        for (final itemJson in itemsJson) {
          items.add(PackingItem(
            id: _uuid.v4(),
            tripId: tripId,
            categoryId: categoryId,
            name: itemJson['name'] as String? ?? '',
            quantity: itemJson['quantity'] as int? ?? 1,
            isPacked: false,
            isEssential: itemJson['essential'] as bool? ?? false,
            note: itemJson['note'] as String?,
            sortOrder: 0,
            createdAt: DateTime.now(),
          ));
        }
        
        final iconKey = catJson['icon'] as String? ?? 'other';
        final colorMap = {
          'clothing': '#EC4899',
          'tech': '#3B82F6',
          'documents': '#F59E0B',
          'hygiene': '#14B8A6',
          'medicine': '#EF4444',
          'gear': '#8B5CF6',
          'other': '#6B7280',
        };
        
        categories.add(Category(
          id: categoryId,
          tripId: tripId,
          name: catJson['name'] as String? ?? 'Другое',
          icon: AppConstants.categoryIcons[iconKey] ?? 'inventory_2',
          sortOrder: sortOrder++,
          colorHex: colorMap[iconKey] ?? '#6B7280',
          items: items,
          totalItems: items.length,
          packedItems: 0,
        ));
      }
      
      return categories;
    } catch (e) {
      print('Error parsing Gemini response: $e');
      return [];
    }
  }

  List<Category> _generateRuleBased({
    required String tripId,
    required String tripType,
    required int durationDays,
    required String accommodation,
    required List<String> activities,
    String? weatherTemp,
  }) {
    final categories = <Category>[];
    
    // 1. Clothing category
    categories.add(_generateClothingCategory(
      tripId: tripId,
      tripType: tripType,
      durationDays: durationDays,
      weatherTemp: weatherTemp,
      accommodation: accommodation,
    ));
    
    // 2. Tech category
    categories.add(_generateTechCategory(
      tripId: tripId,
      tripType: tripType,
      durationDays: durationDays,
    ));
    
    // 3. Documents category
    categories.add(_generateDocumentsCategory(
      tripId: tripId,
    ));
    
    // 4. Hygiene category
    categories.add(_generateHygieneCategory(
      tripId: tripId,
      durationDays: durationDays,
      accommodation: accommodation,
    ));
    
    // 5. Medicine category
    categories.add(_generateMedicineCategory(
      tripId: tripId,
      tripType: tripType,
    ));
    
    // 6. Special gear category (based on trip type)
    if (tripType == 'hike' || tripType == 'beach' || activities.isNotEmpty) {
      categories.add(_generateGearCategory(
        tripId: tripId,
        tripType: tripType,
        accommodation: accommodation,
        activities: activities,
      ));
    }
    
    return categories;
  }

  Category _generateClothingCategory({
    required String tripId,
    required String tripType,
    required int durationDays,
    String? weatherTemp,
    required String accommodation,
  }) {
    final items = <PackingItem>[];
    final categoryId = _uuid.v4();
    
    // Base clothing items
    items.add(_createItem(tripId, categoryId, 'Футболки', durationDays, true));
    items.add(_createItem(tripId, categoryId, 'Нижнее белье', durationDays, true));
    items.add(_createItem(tripId, categoryId, 'Носки', durationDays, true));
    
    // Pants based on duration
    final pantsCount = (durationDays / 3).ceil().clamp(1, 4);
    items.add(_createItem(tripId, categoryId, 'Штаны/джинсы', pantsCount, true));
    
    // Weather-based items
    if (weatherTemp != null) {
      final temp = int.tryParse(weatherTemp.replaceAll(RegExp(r'[^0-9-]'), '')) ?? 20;
      if (temp < 15) {
        items.add(_createItem(tripId, categoryId, 'Теплая куртка', 1, true));
        items.add(_createItem(tripId, categoryId, 'Свитер/толстовка', 2, false));
      }
      if (temp < 5) {
        items.add(_createItem(tripId, categoryId, 'Термобелье', 1, true));
        items.add(_createItem(tripId, categoryId, 'Шапка', 1, true));
        items.add(_createItem(tripId, categoryId, 'Перчатки', 1, false));
      }
      if (temp > 25) {
        items.add(_createItem(tripId, categoryId, 'Шорты', 2, false));
        items.add(_createItem(tripId, categoryId, 'Головной убор', 1, true, note: 'Защита от солнца'));
      }
    }
    
    // Trip type specific
    if (tripType == 'beach') {
      items.add(_createItem(tripId, categoryId, 'Купальник/плавки', 2, true));
      items.add(_createItem(tripId, categoryId, 'Пляжная одежда', 2, false));
      items.add(_createItem(tripId, categoryId, 'Сланцы', 1, true));
    } else if (tripType == 'hike') {
      items.add(_createItem(tripId, categoryId, 'Треккинговые штаны', 2, true));
      items.add(_createItem(tripId, categoryId, 'Флисовая кофта', 1, true));
      items.add(_createItem(tripId, categoryId, 'Дождевик', 1, true));
    } else if (tripType == 'business') {
      items.add(_createItem(tripId, categoryId, 'Рубашки', (durationDays / 2).ceil(), true));
      items.add(_createItem(tripId, categoryId, 'Костюм/пиджак', 1, true));
      items.add(_createItem(tripId, categoryId, 'Туфли', 1, true));
    }
    
    // Universal items
    items.add(_createItem(tripId, categoryId, 'Пижама', 1, false));
    items.add(_createItem(tripId, categoryId, 'Удобная обувь', 1, true));
    
    return Category(
      id: categoryId,
      tripId: tripId,
      name: AppConstants.categoryNames['clothing']!,
      icon: AppConstants.categoryIcons['clothing']!,
      sortOrder: 0,
      colorHex: '#EC4899',
      items: items,
      totalItems: items.length,
      packedItems: 0,
    );
  }

  Category _generateTechCategory({
    required String tripId,
    required String tripType,
    required int durationDays,
  }) {
    final items = <PackingItem>[];
    final categoryId = _uuid.v4();
    
    // Essential tech
    items.add(_createItem(tripId, categoryId, 'Телефон', 1, true));
    items.add(_createItem(tripId, categoryId, 'Зарядка для телефона', 1, true));
    items.add(_createItem(tripId, categoryId, 'Powerbank', 1, true));
    
    // Based on trip type
    if (tripType == 'business') {
      items.add(_createItem(tripId, categoryId, 'Ноутбук', 1, true));
      items.add(_createItem(tripId, categoryId, 'Зарядка для ноутбука', 1, true));
      items.add(_createItem(tripId, categoryId, 'Мышка', 1, false));
    }
    
    if (tripType == 'hike') {
      items.add(_createItem(tripId, categoryId, 'Фонарик/налобный фонарь', 1, true));
      items.add(_createItem(tripId, categoryId, 'Запасные батарейки', 2, true));
    }
    
    // Universal
    items.add(_createItem(tripId, categoryId, 'Наушники', 1, false));
    items.add(_createItem(tripId, categoryId, 'Адаптер для розетки', 1, false, note: 'Проверь тип розеток в стране'));
    
    if (durationDays > 5) {
      items.add(_createItem(tripId, categoryId, 'Удлинитель', 1, false));
    }
    
    return Category(
      id: categoryId,
      tripId: tripId,
      name: AppConstants.categoryNames['tech']!,
      icon: AppConstants.categoryIcons['tech']!,
      sortOrder: 1,
      colorHex: '#3B82F6',
      items: items,
      totalItems: items.length,
      packedItems: 0,
    );
  }

  Category _generateDocumentsCategory({
    required String tripId,
  }) {
    final items = <PackingItem>[];
    final categoryId = _uuid.v4();
    
    items.add(_createItem(tripId, categoryId, 'Паспорт', 1, true));
    items.add(_createItem(tripId, categoryId, 'Копия паспорта', 1, true, note: 'Отдельно от оригинала'));
    items.add(_createItem(tripId, categoryId, 'Билеты', 1, true, note: 'Или в приложении'));
    items.add(_createItem(tripId, categoryId, 'Бронь отеля', 1, true, note: 'Или в приложении'));
    items.add(_createItem(tripId, categoryId, 'Банковские карты', 2, true));
    items.add(_createItem(tripId, categoryId, 'Наличные', 1, true, note: 'Местная валюта'));
    items.add(_createItem(tripId, categoryId, 'Страховка', 1, true));
    items.add(_createItem(tripId, categoryId, 'Водительские права', 1, false, note: 'Если планируешь аренду авто'));
    
    return Category(
      id: categoryId,
      tripId: tripId,
      name: AppConstants.categoryNames['documents']!,
      icon: AppConstants.categoryIcons['documents']!,
      sortOrder: 2,
      colorHex: '#F59E0B',
      items: items,
      totalItems: items.length,
      packedItems: 0,
    );
  }

  Category _generateHygieneCategory({
    required String tripId,
    required int durationDays,
    required String accommodation,
  }) {
    final items = <PackingItem>[];
    final categoryId = _uuid.v4();
    
    items.add(_createItem(tripId, categoryId, 'Зубная щетка', 1, true));
    items.add(_createItem(tripId, categoryId, 'Зубная паста', 1, true));
    items.add(_createItem(tripId, categoryId, 'Дезодорант', 1, true));
    
    // If tent/camping - need more items
    if (accommodation == 'tent') {
      items.add(_createItem(tripId, categoryId, 'Шампунь', 1, true));
      items.add(_createItem(tripId, categoryId, 'Мыло/гель для душа', 1, true));
      items.add(_createItem(tripId, categoryId, 'Полотенце', 2, true));
      items.add(_createItem(tripId, categoryId, 'Туалетная бумага', 2, true));
      items.add(_createItem(tripId, categoryId, 'Влажные салфетки', 2, true));
    } else {
      items.add(_createItem(tripId, categoryId, 'Шампунь (мини)', 1, false, note: 'В отеле обычно есть'));
      items.add(_createItem(tripId, categoryId, 'Полотенце', 1, false, note: 'В отеле обычно есть'));
    }
    
    items.add(_createItem(tripId, categoryId, 'Расческа', 1, true));
    items.add(_createItem(tripId, categoryId, 'Бритва', 1, false));
    items.add(_createItem(tripId, categoryId, 'Солнцезащитный крем', 1, true));
    
    return Category(
      id: categoryId,
      tripId: tripId,
      name: AppConstants.categoryNames['hygiene']!,
      icon: AppConstants.categoryIcons['hygiene']!,
      sortOrder: 3,
      colorHex: '#14B8A6',
      items: items,
      totalItems: items.length,
      packedItems: 0,
    );
  }

  Category _generateMedicineCategory({
    required String tripId,
    required String tripType,
  }) {
    final items = <PackingItem>[];
    final categoryId = _uuid.v4();
    
    // Basic medicine kit
    items.add(_createItem(tripId, categoryId, 'Обезболивающее', 1, true, note: 'Ибупрофен/парацетамол'));
    items.add(_createItem(tripId, categoryId, 'Пластыри', 1, true));
    items.add(_createItem(tripId, categoryId, 'Антисептик', 1, true));
    items.add(_createItem(tripId, categoryId, 'Средство от аллергии', 1, false));
    items.add(_createItem(tripId, categoryId, 'Средство от расстройства желудка', 1, true));
    
    if (tripType == 'hike') {
      items.add(_createItem(tripId, categoryId, 'Эластичный бинт', 1, true));
      items.add(_createItem(tripId, categoryId, 'Средство от насекомых', 1, true));
      items.add(_createItem(tripId, categoryId, 'Мазь от ушибов', 1, false));
    }
    
    if (tripType == 'beach') {
      items.add(_createItem(tripId, categoryId, 'Средство после загара', 1, true));
      items.add(_createItem(tripId, categoryId, 'Средство от укусов', 1, false));
    }
    
    items.add(_createItem(tripId, categoryId, 'Личные лекарства', 1, true, note: 'Если принимаешь постоянно'));
    
    return Category(
      id: categoryId,
      tripId: tripId,
      name: AppConstants.categoryNames['medicine']!,
      icon: AppConstants.categoryIcons['medicine']!,
      sortOrder: 4,
      colorHex: '#EF4444',
      items: items,
      totalItems: items.length,
      packedItems: 0,
    );
  }

  Category _generateGearCategory({
    required String tripId,
    required String tripType,
    required String accommodation,
    required List<String> activities,
  }) {
    final items = <PackingItem>[];
    final categoryId = _uuid.v4();
    
    if (tripType == 'hike') {
      items.add(_createItem(tripId, categoryId, 'Рюкзак', 1, true));
      items.add(_createItem(tripId, categoryId, 'Треккинговые ботинки', 1, true));
      items.add(_createItem(tripId, categoryId, 'Треккинговые палки', 1, false));
      items.add(_createItem(tripId, categoryId, 'Карта/навигатор', 1, true));
      items.add(_createItem(tripId, categoryId, 'Компас', 1, false));
      items.add(_createItem(tripId, categoryId, 'Бутылка для воды', 1, true));
      items.add(_createItem(tripId, categoryId, 'Перекус', 1, true, note: 'Орехи, батончики'));
      
      if (accommodation == 'tent') {
        items.add(_createItem(tripId, categoryId, 'Палатка', 1, true));
        items.add(_createItem(tripId, categoryId, 'Спальник', 1, true));
        items.add(_createItem(tripId, categoryId, 'Коврик', 1, true));
        items.add(_createItem(tripId, categoryId, 'Горелка', 1, true));
        items.add(_createItem(tripId, categoryId, 'Посуда', 1, true));
      }
    }
    
    if (tripType == 'beach') {
      items.add(_createItem(tripId, categoryId, 'Пляжное полотенце', 1, true));
      items.add(_createItem(tripId, categoryId, 'Пляжная сумка', 1, false));
      items.add(_createItem(tripId, categoryId, 'Солнцезащитные очки', 1, true));
      items.add(_createItem(tripId, categoryId, 'Маска для плавания', 1, false));
      items.add(_createItem(tripId, categoryId, 'Книга/журнал', 1, false));
    }
    
    // Activity-based items
    if (activities.contains('swimming')) {
      items.add(_createItem(tripId, categoryId, 'Очки для плавания', 1, false));
    }
    if (activities.contains('photography')) {
      items.add(_createItem(tripId, categoryId, 'Камера', 1, false));
      items.add(_createItem(tripId, categoryId, 'Карта памяти', 2, false));
    }
    
    return Category(
      id: categoryId,
      tripId: tripId,
      name: AppConstants.categoryNames['gear']!,
      icon: AppConstants.categoryIcons['gear']!,
      sortOrder: 5,
      colorHex: '#8B5CF6',
      items: items,
      totalItems: items.length,
      packedItems: 0,
    );
  }

  PackingItem _createItem(
    String tripId,
    String categoryId,
    String name,
    int quantity,
    bool isEssential, {
    String? note,
  }) {
    return PackingItem(
      id: _uuid.v4(),
      tripId: tripId,
      categoryId: categoryId,
      name: name,
      quantity: quantity,
      isPacked: false,
      isEssential: isEssential,
      note: note,
      sortOrder: 0,
      createdAt: DateTime.now(),
    );
  }

  // Prompt for Gemini API
  String buildPrompt({
    required String tripType,
    required String destination,
    required int durationDays,
    required String accommodation,
    required List<String> activities,
    String? weatherConditions,
  }) {
    return '''
Ты — профессиональный консультант по сборам в поездку. Создай детальный список вещей.

ПАРАМЕТРЫ ПОЕЗДКИ:
- Тип: ${AppConstants.tripTypeNames[tripType] ?? tripType}
- Место: $destination
- Длительность: $durationDays дней
- Проживание: ${AppConstants.accommodationNames[accommodation] ?? accommodation}
- Активности: ${activities.isEmpty ? 'не указаны' : activities.join(', ')}
${weatherConditions != null ? '- Погода: $weatherConditions' : ''}

ФОРМАТ ОТВЕТА (только JSON, без markdown):
{
  "categories": [
    {
      "name": "Одежда",
      "icon": "clothing",
      "items": [
        {"name": "Футболка", "quantity": 3, "essential": true, "note": "Быстросохнущие"}
      ]
    }
  ]
}

ДОСТУПНЫЕ ИКОНКИ: clothing, tech, documents, hygiene, medicine, gear, other

КАТЕГОРИИ:
1. Одежда (clothing) - учитывай климат и активности
2. Техника и аксессуары (tech)
3. Документы и деньги (documents)
4. Гигиена и косметика (hygiene)
5. Аптечка (medicine)
6. Специальное снаряжение (gear) - по типу поездки

ТРЕБОВАНИЯ:
- Указывай количество для каждой вещи
- Отмечай обязательные вещи (essential: true)
- Добавляй заметки для контекстных вещей
- Учитывай ограничения авиакомпаний для ручной клади
- Будь практичным и реалистичным
- Верни ТОЛЬКО JSON без дополнительного текста
''';
  }
}

// Provider for AI Service
final aiServiceProvider = Provider<AIService>((ref) => AIService());
