import 'package:flutter/material.dart';

/// Available theme presets
enum AppThemePreset {
  indigo,    // Default - Indigo/Purple
  ocean,     // Blue/Cyan
  forest,    // Green/Teal
  sunset,    // Orange/Red
  lavender,  // Purple/Pink
  midnight,  // Dark Blue
  rose,      // Pink/Rose
  mint,      // Mint/Green
}

class ThemePresetData {
  final String name;
  final String nameRu;
  final Color primary;
  final Color secondary;
  final Color accent;
  final String emoji;

  const ThemePresetData({
    required this.name,
    required this.nameRu,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.emoji,
  });
}

class ThemePresets {
  static const Map<AppThemePreset, ThemePresetData> presets = {
    AppThemePreset.indigo: ThemePresetData(
      name: 'Indigo',
      nameRu: 'Индиго',
      primary: Color(0xFF6366F1),
      secondary: Color(0xFF10B981),
      accent: Color(0xFFF59E0B),
      emoji: '💜',
    ),
    AppThemePreset.ocean: ThemePresetData(
      name: 'Ocean',
      nameRu: 'Океан',
      primary: Color(0xFF0EA5E9),
      secondary: Color(0xFF06B6D4),
      accent: Color(0xFF14B8A6),
      emoji: '🌊',
    ),
    AppThemePreset.forest: ThemePresetData(
      name: 'Forest',
      nameRu: 'Лес',
      primary: Color(0xFF22C55E),
      secondary: Color(0xFF10B981),
      accent: Color(0xFF84CC16),
      emoji: '🌲',
    ),
    AppThemePreset.sunset: ThemePresetData(
      name: 'Sunset',
      nameRu: 'Закат',
      primary: Color(0xFFF97316),
      secondary: Color(0xFFEF4444),
      accent: Color(0xFFFBBF24),
      emoji: '🌅',
    ),
    AppThemePreset.lavender: ThemePresetData(
      name: 'Lavender',
      nameRu: 'Лаванда',
      primary: Color(0xFF8B5CF6),
      secondary: Color(0xFFA855F7),
      accent: Color(0xFFEC4899),
      emoji: '💐',
    ),
    AppThemePreset.midnight: ThemePresetData(
      name: 'Midnight',
      nameRu: 'Полночь',
      primary: Color(0xFF3B82F6),
      secondary: Color(0xFF6366F1),
      accent: Color(0xFF8B5CF6),
      emoji: '🌙',
    ),
    AppThemePreset.rose: ThemePresetData(
      name: 'Rose',
      nameRu: 'Роза',
      primary: Color(0xFFEC4899),
      secondary: Color(0xFFF472B6),
      accent: Color(0xFFFDA4AF),
      emoji: '🌸',
    ),
    AppThemePreset.mint: ThemePresetData(
      name: 'Mint',
      nameRu: 'Мята',
      primary: Color(0xFF14B8A6),
      secondary: Color(0xFF2DD4BF),
      accent: Color(0xFF5EEAD4),
      emoji: '🍃',
    ),
  };

  static ThemePresetData getPreset(AppThemePreset preset) {
    return presets[preset] ?? presets[AppThemePreset.indigo]!;
  }
}
