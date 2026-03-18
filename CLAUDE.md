# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PackMate is a Flutter mobile app that generates personalized packing lists for trips. Users select trip type, destination, dates, and conditions, then get an AI-generated packing list organized by categories. The app uses Firebase for auth and cloud sync, and Gemini API for AI-powered list generation with a rule-based fallback.

## Build & Run Commands

All commands run from the **project root** (not a subdirectory).

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run with Weather API key (Gemini key goes in .env, not here)
flutter run --dart-define=WEATHER_API_KEY=your_key

# Build APKs
flutter build apk --debug
flutter build apk --release

# Install release APK via adb
adb install -r build/app/outputs/flutter-apk/app-release.apk

# Analyze code
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart
```

## Environment Configuration

Create a `.env` file in the project root:
```
GEMINI_API_KEY=your_key_here
```

Weather API key is passed via `--dart-define=WEATHER_API_KEY=your_key`. If `GEMINI_API_KEY` is absent, `AIService` falls back to rule-based generation automatically.

## Architecture

Feature-First Clean Architecture with Riverpod for state management.

```
lib/
├── core/
│   ├── constants/      # AppConstants (trip types, category keys, spacing/radius)
│   ├── router/         # AppRoutes + appRouterProvider (go_router)
│   ├── services/       # AIService, AuthService, FirestoreService, SyncService, WeatherService
│   └── theme/          # AppTheme (light/dark), AppColors, themeModeProvider
├── features/
│   ├── auth/           # presentation only (pages + providers); uses core/services/auth_service.dart
│   ├── home/
│   ├── onboarding/
│   ├── packing_list/   # Full clean arch: data/domain/presentation layers
│   ├── packing_mode/
│   ├── settings/
│   ├── templates/      # Full clean arch: data/domain/presentation layers
│   └── trip_setup/     # Full clean arch: data/domain/presentation layers
├── shared/widgets/     # Reusable UI: AppButton, AppCard, LoadingIndicator, MainShell
└── main.dart
```

Only `packing_list`, `templates`, and `trip_setup` have full data/domain/presentation layers. Other features have presentation-only structure.

### Navigation

`app_router.dart` uses a `ShellRoute` for screens with bottom navigation (home, templates, settings). All other flows (trip setup, packing list, packing mode, auth) are full-screen routes outside the shell. Route names are constants on `AppRoutes`.

Auth redirect logic in the router: onboarding → login → home, based on `onboardingCompletedProvider` and `authStateProvider`.

### State Management

Key providers (defined in `lib/features/trip_setup/presentation/providers/trip_provider.dart`):
- `currentTripProvider` (`StateNotifierProvider<TripNotifier, Trip?>`) — current trip being set up
- `packingListProvider` (`StateNotifierProvider<PackingListNotifier, List<Category>>`) — packing list state
- `selectedTripTypeProvider` — trip type selection
- `packingProgressProvider` / `isPackingCompleteProvider` — derived progress state

Both `TripNotifier` and `PackingListNotifier` have a `fromRemote` flag to prevent sync loops when setting data loaded from Firestore.

### Firebase / Sync Architecture

Two Firestore services exist with different schemas:
- **`FirestoreService`** (hierarchical): `users/{uid}/trips/{tripId}/categories/{catId}/items/{itemId}` — used for session sync
- **`SyncService`** (flat): `users/{uid}/trips`, `users/{uid}/categories`, `users/{uid}/items` — legacy flat structure

Auto-sync is handled by `autoSyncProvider` (watched in `main.dart`), which triggers on any state change. `SessionSyncController` handles login/logout transitions: loads latest trip from cloud on login, pushes local data to cloud if cloud is empty.

### AI List Generation

`AIService.generatePackingList()` calls Gemini API (`gemini-3-flash-preview`) with a Russian-language prompt. On failure or missing key, falls back to `_generateRuleBased()`, which produces categories based on trip type, accommodation, activities, and weather temperature.

## Tech Stack

- Flutter 3.2+ / Dart 3.2+
- `flutter_riverpod` — state management
- `go_router` — navigation
- `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_analytics` — Firebase
- `google_sign_in` — Google auth
- `dio` — HTTP (Gemini/Weather API calls)
- `shared_preferences`, `path_provider` — local storage fallback
- `flutter_animate`, `smooth_page_indicator` — UI animations
- `flutter_dotenv` — `.env` loading
- `intl` — date formatting (ru_RU locale initialized at startup)

## Linting

`flutter_lints` + additional rules: `prefer_const_constructors`, `prefer_const_declarations`, `prefer_final_locals`, `avoid_print`, `prefer_single_quotes`.
