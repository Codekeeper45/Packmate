# PackMate - План разработки и Техническое задание

## 1. Общая информация

**Название приложения:** PackMate

**Краткое описание:** Мобильное приложение, которое за 2 минуты генерирует персонализированный список вещей для поездки и помогает отслеживать процесс сборов.

**Платформы:** Android, iOS (Flutter)

**Срок разработки:** 3-4 недели

---

## 2. Описание идеи (MVP)

### Проблема
Путешественники часто забывают важные вещи при сборах, что приводит к стрессу и дополнительным расходам. Ручное составление списков занимает время и не учитывает контекст поездки (погода, тип отдыха, длительность).

### Пользователь
Туристы, походники, командировочные — люди, которые регулярно путешествуют и хотят минимизировать риск забыть важное.

### Ключевое действие
Создать список вещей на основе параметров поездки (тип, даты, место, условия проживания).

### Результат
Готовый чек-лист с прогрессом сборов 0-100%, возможность сохранить как шаблон для будущих поездок.

---

## 3. User Personas

### Persona 1: Походник Алексей
- **Возраст:** 28-35 лет
- **Род занятий:** IT-специалист
- **Цель:** Не забыть критическое снаряжение для похода в горы
- **Основная боль:** Забыл аптечку/налобный фонарь в прошлом походе
- **Контекст:** Использует за 1-3 дня до выхода, финальная проверка утром в день выхода

### Persona 2: Турист Мария
- **Возраст:** 25-40 лет
- **Род занятий:** Менеджер
- **Цель:** Быстро собраться в отпуск без лишнего стресса
- **Основная боль:** Всегда забывает зарядки/адаптеры/документы
- **Контекст:** Использует за 2-7 дней до поездки, проверка в аэропорту

### Persona 3: Командировочный Дмитрий
- **Возраст:** 30-45 лет
- **Род занятий:** Руководитель проекта
- **Цель:** Минимальный багаж с максимальной функциональностью
- **Основная боль:** Частые поездки, нет времени думать о сборах
- **Контекст:** Использует шаблоны, быстрый чек за 30 минут до выезда

---

## 4. User Flow (9 шагов)

```
[1. Старт] → [2. Выбор типа] → [3. Параметры] → [4. Уточнение]
                                                      ↓
[9. Завершение] ← [8. Режим сборов] ← [7. Сохранение] ← [6. Редактирование] ← [5. Генерация]
```

1. **Старт/Открытие приложения** — Онбординг с ценностным предложением
2. **Выбор типа поездки** — Поход / Пляж / Город / Бизнес / Другое
3. **Ввод параметров** — Даты, место, длительность
4. **Уточнение условий** — Палатка/отель, море/горы, активности
5. **Генерация списка** — AI создает список по категориям
6. **Редактирование** — Добавить/удалить/изменить количество
7. **Сохранение** — Сохранить список (опционально как шаблон)
8. **Режим сборов** — Чек-лист с отметками "взял/не взял"
9. **Завершение** — 100% прогресс, предложение сохранить шаблон

---

## 5. Экранная структура MVP

| # | Экран | Назначение | Ключевые элементы |
|---|-------|------------|-------------------|
| 1 | Онбординг | Объяснить ценность приложения | 2-3 слайда, кнопка "Начать" |
| 2 | Выбор типа поездки | Определить контекст | 5 карточек типов поездки |
| 3 | Параметры поездки | Собрать базовые данные | Поля: место, даты, длительность |
| 4 | Уточнение условий | Детализировать контекст | Чипы: жилье, активности, климат |
| 5 | Сгенерированный список | Показать результат AI | Категории с вещами, кнопка "Редактировать" |
| 6 | Редактирование | Настроить список | +/- вещи, изменение количества |
| 7 | Сохранение | Подтвердить список | Название, опция "Сохранить как шаблон" |
| 8 | Режим сборов | Отмечать собранное | Чек-боксы, прогресс-бар |
| 9 | Завершение | Поздравить и предложить шаблон | Статистика, кнопки действий |

---

## 6. Техническая архитектура

### 6.1 Технологический стек

| Компонент | Технология | Обоснование |
|-----------|------------|-------------|
| **Framework** | Flutter 3.x | Кроссплатформенность, быстрая разработка |
| **State Management** | Riverpod 2.x | Compile-time safety, минимальный boilerplate |
| **Local Storage** | Isar 4.x | Быстрая NoSQL БД, offline-first |
| **Navigation** | go_router | Официальная рекомендация Flutter |
| **AI Generation** | Google Gemini API (Firebase AI Logic) | Бесплатный tier, качественная генерация |
| **Weather API** | WeatherAPI.com | 1M запросов/месяц бесплатно |

### 6.2 Структура проекта (Feature-First Clean Architecture)

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── api_constants.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── app_colors.dart
│   ├── router/
│   │   └── app_router.dart
│   ├── services/
│   │   ├── ai_service.dart
│   │   └── weather_service.dart
│   └── utils/
│       └── extensions.dart
│
├── features/
│   ├── onboarding/
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── onboarding_page.dart
│   │       └── widgets/
│   │           └── onboarding_slide.dart
│   │
│   ├── trip_setup/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── trip_model.dart
│   │   │   └── repositories/
│   │   │       └── trip_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── trip.dart
│   │   │   └── repositories/
│   │   │       └── trip_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── trip_provider.dart
│   │       ├── pages/
│   │       │   ├── trip_type_page.dart
│   │       │   ├── trip_params_page.dart
│   │       │   └── trip_conditions_page.dart
│   │       └── widgets/
│   │           ├── trip_type_card.dart
│   │           └── condition_chip.dart
│   │
│   ├── packing_list/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── packing_item_model.dart
│   │   │   │   └── category_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── packing_local_datasource.dart
│   │   │   └── repositories/
│   │   │       └── packing_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── packing_item.dart
│   │   │   │   └── category.dart
│   │   │   ├── repositories/
│   │   │   │   └── packing_repository.dart
│   │   │   └── usecases/
│   │   │       ├── generate_packing_list.dart
│   │   │       └── update_item_status.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── packing_list_provider.dart
│   │       ├── pages/
│   │       │   ├── generated_list_page.dart
│   │       │   ├── edit_list_page.dart
│   │       │   └── save_list_page.dart
│   │       └── widgets/
│   │           ├── category_section.dart
│   │           └── packing_item_tile.dart
│   │
│   ├── packing_mode/
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── packing_progress_provider.dart
│   │       ├── pages/
│   │       │   ├── packing_mode_page.dart
│   │       │   └── completion_page.dart
│   │       └── widgets/
│   │           ├── progress_bar.dart
│   │           └── checkable_item.dart
│   │
│   └── templates/
│       ├── data/
│       │   ├── models/
│       │   │   └── template_model.dart
│       │   └── repositories/
│       │       └── template_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── template.dart
│       │   └── repositories/
│       │       └── template_repository.dart
│       └── presentation/
│           ├── providers/
│           │   └── template_provider.dart
│           └── pages/
│               └── templates_page.dart
│
├── shared/
│   └── widgets/
│       ├── app_button.dart
│       ├── app_card.dart
│       └── loading_indicator.dart
│
└── main.dart
```

### 6.3 Модели данных

```dart
// Trip (Поездка)
class Trip {
  final String id;
  final TripType type;           // hike, beach, city, business, other
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final int durationDays;
  final AccommodationType accommodation;  // tent, hotel, hostel, apartment
  final List<String> activities;
  final String? weatherConditions;
  final DateTime createdAt;
}

// PackingItem (Вещь в списке)
class PackingItem {
  final String id;
  final String name;
  final String categoryId;
  final int quantity;
  final bool isPacked;
  final bool isEssential;
  final String? note;
}

// Category (Категория)
class Category {
  final String id;
  final String name;
  final String icon;
  final int sortOrder;
  final List<PackingItem> items;
}

// Template (Шаблон)
class Template {
  final String id;
  final String name;
  final TripType tripType;
  final List<Category> categories;
  final DateTime createdAt;
  final int usageCount;
}

// PackingSession (Сессия сборов)
class PackingSession {
  final String id;
  final String tripId;
  final List<Category> categories;
  final int totalItems;
  final int packedItems;
  final double progressPercent;
  final PackingStatus status;  // in_progress, completed
  final DateTime startedAt;
  final DateTime? completedAt;
}
```

---

## 7. Интеграции

### 7.1 AI-генерация списка (Google Gemini)

**Промпт для генерации:**
```
Ты — профессиональный консультант по сборам в поездку. Создай детальный список вещей.

ПАРАМЕТРЫ ПОЕЗДКИ:
- Тип: {tripType}
- Место: {destination}
- Длительность: {durationDays} дней
- Даты: {startDate} - {endDate}
- Проживание: {accommodation}
- Активности: {activities}
- Погода: {weatherConditions}

ФОРМАТ ОТВЕТА (JSON):
{
  "categories": [
    {
      "name": "Одежда",
      "icon": "clothing",
      "items": [
        {"name": "Футболка", "quantity": 3, "essential": true, "note": "Быстросохнущие"},
        ...
      ]
    },
    ...
  ]
}

КАТЕГОРИИ:
1. Одежда (учитывай климат и активности)
2. Техника и аксессуары
3. Документы и деньги
4. Гигиена и косметика
5. Аптечка
6. Специальное снаряжение (по типу поездки)

ТРЕБОВАНИЯ:
- Указывай количество для каждой вещи
- Отмечай обязательные вещи (essential: true)
- Добавляй заметки для контекстных вещей
- Учитывай ограничения авиакомпаний для ручной клади
- Будь практичным и реалистичным
```

### 7.2 Weather API

**Endpoint:** `http://api.weatherapi.com/v1/forecast.json`

**Параметры:**
- `key`: API ключ
- `q`: город или координаты
- `days`: количество дней (до 14)

**Использование:** Получаем прогноз для места поездки и передаем в AI для контекста.

---

## 8. План разработки (по дням)

### Неделя 1: Фундамент (5 дней)

| День | Задача | Результат |
|------|--------|-----------|
| 1 | Настройка проекта, зависимости, структура папок | Работающий пустой проект |
| 2 | Модели данных (Isar), базовые entities | Схема БД готова |
| 3 | Riverpod providers, репозитории | State management настроен |
| 4 | Навигация go_router, все маршруты | Переходы между экранами |
| 5 | Базовая тема, shared widgets | UI kit готов |

### Неделя 2: Экраны настройки поездки (5 дней)

| День | Задача | Результат |
|------|--------|-----------|
| 6 | Онбординг (3 слайда) | Первый экран работает |
| 7 | Выбор типа поездки | Карточки типов |
| 8 | Параметры поездки (форма) | Валидация, DatePicker |
| 9 | Уточнение условий (чипы) | Динамические опции |
| 10 | Интеграция Weather API | Погода подгружается |

### Неделя 3: AI и списки (5 дней)

| День | Задача | Результат |
|------|--------|-----------|
| 11 | Интеграция Gemini API | Генерация работает |
| 12 | Экран сгенерированного списка | Отображение по категориям |
| 13 | Редактирование списка | CRUD для вещей |
| 14 | Сохранение списка/шаблона | Персистентность |
| 15 | Управление шаблонами | Список шаблонов |

### Неделя 4: Режим сборов и финализация (5 дней)

| День | Задача | Результат |
|------|--------|-----------|
| 16 | Режим сборов (чек-лист) | Отметки, прогресс |
| 17 | Экран завершения | Статистика, действия |
| 18 | Тестирование, баг-фиксы | Стабильное приложение |
| 19 | UI полировка, анимации | Приятный UX |
| 20 | Сборка APK, документация | Готовый билд |

---

## 9. Работа с ИИ (промпты)

### Промпт №1: Первичная генерация списка

```
Ты — эксперт по сборам в поездку. Создай персонализированный список вещей.

Поездка: {tripType} в {destination} на {durationDays} дней.
Проживание: {accommodation}.
Погода: {weatherConditions}.

Выдай JSON со списком вещей по категориям: Одежда, Техника, Документы, Гигиена, Аптечка, Снаряжение.
Для каждой вещи укажи: название, количество, обязательность (essential), заметку.
```

### Промпт №2: Уточнение списка

```
Скорректируй список вещей с учетом:
- Тип проживания: {accommodation} (палатка требует больше снаряжения)
- Активности: {activities}
- Температура: {temperature}°C
- Осадки: {precipitation}

Добавь недостающее, удали лишнее, скорректируй количество.
```

---

## 10. Метрики успеха

| Метрика | Целевое значение |
|---------|------------------|
| Время до первого списка | < 2 минут |
| Процент завершенных сборов | > 70% |
| Сохранение шаблонов | > 30% пользователей |
| Повторное использование | > 50% пользователей |
| Crash-free rate | > 99% |

---

## 11. Самооценка

### Сильные стороны
- Решает реальную боль (забытые вещи = стресс + расходы)
- Персонализация через AI (контекст погоды, типа поездки)
- Простой и понятный flow (< 2 минут до результата)
- Повторное использование через шаблоны

### Сомнения
- Качество AI-рекомендаций без реальных данных о пользователе
- Зависимость от интернета для генерации (можно решить fallback-списками)
- Конкуренция с простыми заметками

### Улучшения при большем времени
- Интеграция с календарем (автоматическое создание списка при бронировании)
- Социальные функции (поделиться списком, рекомендации друзей)
- Умные напоминания (за N дней до поездки)
- Интеграция с e-commerce (купить недостающее)
- Персонализация на основе истории (запоминание предпочтений)

---

## 12. Зависимости (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  
  # Navigation
  go_router: ^14.6.2
  
  # Local Storage
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1
  path_provider: ^2.1.4
  
  # Networking
  dio: ^5.7.0
  
  # AI Integration
  firebase_core: ^3.8.1
  firebase_vertexai: ^1.0.0
  
  # UI
  flutter_animate: ^4.5.0
  shimmer: ^3.0.0
  
  # Utils
  intl: ^0.19.0
  uuid: ^4.5.1

dev_dependencies:
  build_runner: ^2.4.13
  riverpod_generator: ^2.6.2
  isar_generator: ^3.1.0+1
  flutter_test:
    sdk: flutter
```

---

## 13. API ключи и конфигурация

### Необходимые ключи:
1. **WeatherAPI.com** — бесплатный tier (1M запросов/месяц)
2. **Firebase** — для Gemini API (Firebase AI Logic)

### Конфигурация:
```dart
// lib/core/constants/api_constants.dart
class ApiConstants {
  static const weatherApiKey = String.fromEnvironment('WEATHER_API_KEY');
  static const weatherBaseUrl = 'http://api.weatherapi.com/v1';
}
```

---

## 14. Чек-лист готовности к сдаче

- [ ] Одно ключевое действие пользователя (генерация списка)
- [ ] Минимум одна персона (3 персоны описаны)
- [ ] User Flow не менее 7 шагов (9 шагов)
- [ ] Логически связанные экраны (9 экранов)
- [ ] Четкие промпты к ИИ (2 промпта)
- [ ] Работающий APK для тестирования
- [ ] Офлайн-режим для сохраненных списков

---

## 15. Контакты и ресурсы

- **Репозиторий:** [будет создан]
- **Figma прототип:** [будет создан]
- **APK для тестирования:** [будет собран]

---

*Документ подготовлен: Январь 2026*
*Версия: 1.0*
