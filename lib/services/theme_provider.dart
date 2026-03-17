import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppColorTheme { standard, blue, purple, green, orange }

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  AppColorTheme _colorTheme = AppColorTheme.blue;

  ThemeMode get themeMode => _themeMode;
  AppColorTheme get colorTheme => _colorTheme;

  // Vibrant colors for all themes
  Color get primaryColor {
    if (_themeMode == ThemeMode.light) {
      switch (_colorTheme) {
        case AppColorTheme.standard:
          return Colors.grey.shade700;
        case AppColorTheme.blue:
          return const Color(0xFF007BFF);
        case AppColorTheme.purple:
          return const Color(0xFF7C4DFF);
        case AppColorTheme.green:
          return const Color(0xFF00C853);
        case AppColorTheme.orange:
          return const Color(0xFFFF6D00);
      }
    } else {
      switch (_colorTheme) {
        case AppColorTheme.standard:
          return Colors.white70;
        case AppColorTheme.blue:
          return const Color(0xFF007BFF);
        case AppColorTheme.purple:
          return const Color(0xFF7C4DFF);
        case AppColorTheme.green:
          return const Color(0xFF00C853);
        case AppColorTheme.orange:
          return const Color(0xFFFF6D00);
      }
    }
  }

  ThemeProvider() {
    _loadFromPrefs();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _saveToPrefs();
    notifyListeners();
  }

  void setColorTheme(AppColorTheme theme) {
    _colorTheme = theme;
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDark') ?? false;
    final themeName = prefs.getString('colorThemeName') ?? 'blue';

    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _colorTheme = AppColorTheme.values.firstWhere(
      (e) => e.name == themeName, 
      orElse: () => AppColorTheme.blue
    );
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', _themeMode == ThemeMode.dark);
    await prefs.setString('colorThemeName', _colorTheme.name);
  }
}
