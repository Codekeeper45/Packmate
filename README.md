# PackMate

Мобильное приложение для генерации списков вещей перед поездкой.

## Возможности

- 🎯 Выбор типа поездки (поход, пляж, город, командировка)
- 📍 Учёт места назначения и погоды
- 🤖 Умная генерация списка по категориям (Gemini + fallback)
- ✏️ Редактирование списка
- ✅ Режим сборов с отслеживанием прогресса
- 📁 Сохранение шаблонов для будущих поездок

## Установка и запуск

### Требования

- Flutter SDK 3.2.0 или выше
- Dart 3.2.0 или выше
- Android Studio / Xcode

### Шаги

1. Установите Flutter SDK
2. Клонируйте проект и перейдите в папку
   ```bash
   cd Packmate
   ```
3. Установите зависимости
   ```bash
   flutter pub get
   ```
4. Сгенерируйте код (Isar, Riverpod)
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
5. Запустите приложение
   ```bash
   # Android
   flutter run

   # iOS
   flutter run -d ios
   ```

## Сборка APK

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release
```

APK будет в `build/app/outputs/flutter-apk/app-release.apk`

## Environment

Создайте `.env` в корне проекта (пример в `.env.example`):

```
GEMINI_API_KEY=your_key_here
WEATHER_API_KEY=your_key_here
```

## Установка APK

После сборки release APK установите его через adb:

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

## Структура проекта

```
lib/
├── core/                    # Общие утилиты
│   ├── constants/           # Константы
│   ├── theme/               # Тема приложения
│   ├── router/              # Навигация (go_router)
│   └── services/            # AI и Weather сервисы
│
├── features/                # Фичи приложения
│   ├── onboarding/          # Онбординг
│   ├── trip_setup/          # Настройка поездки
│   ├── packing_list/        # Список вещей
│   ├── packing_mode/        # Режим сборов
│   └── templates/           # Шаблоны
│
├── shared/                  # Общие виджеты
│   └── widgets/
│
└── main.dart
```

## Технологии

- Flutter
- Riverpod
- Isar
- go_router
- Dio

## Конфигурация API

Для работы погоды укажите ключ `WEATHER_API_KEY` в `.env`.
Для работы Gemini укажите ключ `GEMINI_API_KEY` в `.env`.
Если ключ Gemini не указан, используется rule-based генерация.

## Лицензия

MIT
