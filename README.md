# PackMate

РњРѕР±РёР»СЊРЅРѕРµ РїСЂРёР»РѕР¶РµРЅРёРµ РґР»СЏ РіРµРЅРµСЂР°С†РёРё СЃРїРёСЃРєРѕРІ РІРµС‰РµР№ РїРµСЂРµРґ РїРѕРµР·РґРєРѕР№.

## Р’РѕР·РјРѕР¶РЅРѕСЃС‚Рё

- рџЋЇ Р’С‹Р±РѕСЂ С‚РёРїР° РїРѕРµР·РґРєРё (РїРѕС…РѕРґ, РїР»СЏР¶, РіРѕСЂРѕРґ, РєРѕРјР°РЅРґРёСЂРѕРІРєР°)
- рџ“Ќ РЈС‡С‘С‚ РјРµСЃС‚Р° РЅР°Р·РЅР°С‡РµРЅРёСЏ Рё РїРѕРіРѕРґС‹
- рџ¤– РЈРјРЅР°СЏ РіРµРЅРµСЂР°С†РёСЏ СЃРїРёСЃРєР° РїРѕ РєР°С‚РµРіРѕСЂРёСЏРј
- вњЏпёЏ Р РµРґР°РєС‚РёСЂРѕРІР°РЅРёРµ СЃРїРёСЃРєР°
- вњ… Р РµР¶РёРј СЃР±РѕСЂРѕРІ СЃ РѕС‚СЃР»РµР¶РёРІР°РЅРёРµРј РїСЂРѕРіСЂРµСЃСЃР°
- рџ“Ѓ РЎРѕС…СЂР°РЅРµРЅРёРµ С€Р°Р±Р»РѕРЅРѕРІ РґР»СЏ Р±СѓРґСѓС‰РёС… РїРѕРµР·РґРѕРє

## РЈСЃС‚Р°РЅРѕРІРєР° Рё Р·Р°РїСѓСЃРє

### РўСЂРµР±РѕРІР°РЅРёСЏ

- Flutter SDK 3.2.0 РёР»Рё РІС‹С€Рµ
- Dart 3.2.0 РёР»Рё РІС‹С€Рµ
- Android Studio / Xcode

### РЁР°РіРё

1. **РЈСЃС‚Р°РЅРѕРІРёС‚Рµ Flutter SDK**
   ```bash
   # Windows (С‡РµСЂРµР· chocolatey)
   choco install flutter
   
   # macOS
   brew install flutter
   
   # РР»Рё СЃРєР°С‡Р°Р№С‚Рµ СЃ https://flutter.dev/docs/get-started/install
   ```

2. **РљР»РѕРЅРёСЂСѓР№С‚Рµ РїСЂРѕРµРєС‚ Рё РїРµСЂРµР№РґРёС‚Рµ РІ РїР°РїРєСѓ**
   ```bash
   cd Packmate
   ```

3. **РЈСЃС‚Р°РЅРѕРІРёС‚Рµ Р·Р°РІРёСЃРёРјРѕСЃС‚Рё**
   ```bash
   flutter pub get
   ```

4. **РЎРіРµРЅРµСЂРёСЂСѓР№С‚Рµ РєРѕРґ (Isar, Riverpod)**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. **Р—Р°РїСѓСЃС‚РёС‚Рµ РїСЂРёР»РѕР¶РµРЅРёРµ**
   ```bash
   # Android
   flutter run
   
   # iOS
   flutter run -d ios
   ```

### РЎР±РѕСЂРєР° APK

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release
```

APK Р±СѓРґРµС‚ РІ `build/app/outputs/flutter-apk/app-release.apk`

## РЎС‚СЂСѓРєС‚СѓСЂР° РїСЂРѕРµРєС‚Р°

```
lib/
в”њв”Ђв”Ђ core/                    # РћР±С‰РёРµ СѓС‚РёР»РёС‚С‹
в”‚   в”њв”Ђв”Ђ constants/           # РљРѕРЅСЃС‚Р°РЅС‚С‹
в”‚   в”њв”Ђв”Ђ theme/               # РўРµРјР° РїСЂРёР»РѕР¶РµРЅРёСЏ
в”‚   в”њв”Ђв”Ђ router/              # РќР°РІРёРіР°С†РёСЏ (go_router)
в”‚   в””в”Ђв”Ђ services/            # AI Рё Weather СЃРµСЂРІРёСЃС‹
в”‚
в”њв”Ђв”Ђ features/                # Р¤РёС‡Рё РїСЂРёР»РѕР¶РµРЅРёСЏ
в”‚   в”њв”Ђв”Ђ onboarding/          # РћРЅР±РѕСЂРґРёРЅРі
в”‚   в”њв”Ђв”Ђ trip_setup/          # РќР°СЃС‚СЂРѕР№РєР° РїРѕРµР·РґРєРё
в”‚   в”њв”Ђв”Ђ packing_list/        # РЎРїРёСЃРѕРє РІРµС‰РµР№
в”‚   в”њв”Ђв”Ђ packing_mode/        # Р РµР¶РёРј СЃР±РѕСЂРѕРІ
в”‚   в””в”Ђв”Ђ templates/           # РЁР°Р±Р»РѕРЅС‹
в”‚
в”њв”Ђв”Ђ shared/                  # РћР±С‰РёРµ РІРёРґР¶РµС‚С‹
в”‚   в””в”Ђв”Ђ widgets/
в”‚
в””в”Ђв”Ђ main.dart
```

## РўРµС…РЅРѕР»РѕРіРёРё

- **Flutter** - UI С„СЂРµР№РјРІРѕСЂРє
- **Riverpod** - State management
- **Isar** - Р›РѕРєР°Р»СЊРЅР°СЏ Р±Р°Р·Р° РґР°РЅРЅС‹С…
- **go_router** - РќР°РІРёРіР°С†РёСЏ
- **Dio** - HTTP РєР»РёРµРЅС‚

## РљРѕРЅС„РёРіСѓСЂР°С†РёСЏ API

Р”Р»СЏ СЂР°Р±РѕС‚С‹ РїРѕРіРѕРґС‹ РґРѕР±Р°РІСЊС‚Рµ API РєР»СЋС‡:

```bash
flutter run --dart-define=WEATHER_API_KEY=РІР°С€_РєР»СЋС‡
```

РџРѕР»СѓС‡РёС‚СЊ Р±РµСЃРїР»Р°С‚РЅС‹Р№ РєР»СЋС‡: https://www.weatherapi.com/

## Р›РёС†РµРЅР·РёСЏ

MIT

## Environment

Create a `.env` file in the project root (see `.env.example`):

```
GEMINI_API_KEY=your_key_here
WEATHER_API_KEY=your_key_here
```

## Install APK

After building a release APK, install it via adb:

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```
