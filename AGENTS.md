# Repository Guidelines

This repository primarily contains the PackMate Flutter app in `packmate/`. The root also includes design docs and prebuilt APKs; day-to-day development happens inside `packmate/`.

## Project Structure & Module Organization
- `packmate/lib/`: application code. `core/` holds shared infrastructure, `features/` contains feature modules with presentation/domain/data layers, `shared/widgets/` hosts reusable UI, and `main.dart` is the entry point.
- `packmate/test/`: Flutter unit/widget tests.
- `packmate/assets/`: images and bundled assets.
- `packmate/android/`, `packmate/ios/`, `packmate/web/`: platform targets and config.

## Build, Test, and Development Commands
Run these from `packmate/`:
- `flutter pub get`: install dependencies.
- `flutter pub run build_runner build --delete-conflicting-outputs`: generate code (Riverpod/Isar).
- `flutter run`: run on a connected device or emulator.
- `flutter run --dart-define=WEATHER_API_KEY=YOUR_KEY`: run with weather API key.
- `flutter analyze`: static analysis with project lints.
- `flutter test`: run the test suite.
- `flutter build apk --debug` / `flutter build apk --release`: build Android APKs.

## Coding Style & Naming Conventions
- Dart style: 2-space indentation, `lowerCamelCase` for variables/functions, `UpperCamelCase` for types, `snake_case` for file names.
- Lints (see `packmate/analysis_options.yaml`): `prefer_const_constructors`, `prefer_const_declarations`, `prefer_final_locals`, `avoid_print`, `prefer_single_quotes`.
- Use `dart format` (or `flutter format`) before commits to keep formatting consistent.

## Testing Guidelines
- Framework: `flutter_test`.
- Name tests `*_test.dart` and keep them under `packmate/test/` mirroring `lib/` structure when possible.
- No explicit coverage target is defined; add tests for new features and bug fixes.

## Commit & Pull Request Guidelines
- No `.git` history is present in this workspace, so there is no documented commit-message convention. Use short, imperative subjects (e.g., "Add trip type validation") and keep commits focused.
- For PRs, include: a clear description, test command(s) run, and screenshots or screen recordings for UI changes. Link any relevant issues or tasks.

## Configuration & Secrets
- Weather API key is injected via `--dart-define=WEATHER_API_KEY=...` and should not be committed.
- Firebase config lives in `google-services.json` (Android). Ensure environment-specific values are correct before release builds.
