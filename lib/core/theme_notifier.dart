import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kDarkModeKey = 'dark_mode';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeNotifier._();

  static ThemeNotifier? _instance;
  static ThemeNotifier get instance {
    _instance ??= ThemeNotifier._();
    return _instance!;
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_kDarkModeKey) ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> setDark(bool value) async {
    _themeMode = value ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDarkModeKey, value);
  }

  Future<void> toggle() => setDark(!isDark);
}
