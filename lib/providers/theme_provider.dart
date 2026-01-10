import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suayed/services/logger_service.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.system;
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isSystemMode => _themeMode == ThemeMode.system;
  bool get isInitialized => _isInitialized;

  ThemeProvider() {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      AppLogger.d('🎨 Loading theme mode from preferences');
      final prefs = await SharedPreferences.getInstance();
      final savedThemeMode = prefs.getString(_themeModeKey);

      if (savedThemeMode != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == savedThemeMode,
          orElse: () => ThemeMode.system,
        );
        AppLogger.i('🎨 Loaded theme mode: $_themeMode');
      } else {
        AppLogger.d('🎨 No saved theme mode, using system default');
      }
    } catch (e) {
      AppLogger.e('❌ Error loading theme mode', e);
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    try {
      AppLogger.d('🎨 Saving theme mode: $mode');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, mode.toString());
      AppLogger.i('✅ Theme mode saved successfully');
    } catch (e) {
      AppLogger.e('❌ Error saving theme mode', e);
    }
  }

  void toggleTheme() {
    final newMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setThemeMode(newMode);
  }

  void setLightMode() => setThemeMode(ThemeMode.light);
  void setDarkMode() => setThemeMode(ThemeMode.dark);
  void setSystemMode() => setThemeMode(ThemeMode.system);
}
