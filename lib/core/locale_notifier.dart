import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleKey = 'app_locale';

class LocaleNotifier extends ChangeNotifier {
  Locale _locale = const Locale('en');

  LocaleNotifier._();

  static LocaleNotifier? _instance;
  static LocaleNotifier get instance {
    _instance ??= LocaleNotifier._();
    return _instance!;
  }

  Locale get locale => _locale;

  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English', 'flag': '🇬🇧', 'native': 'English'},
    {'code': 'es', 'name': 'Spanish', 'flag': '🇪🇸', 'native': 'Español'},
    {'code': 'fr', 'name': 'French', 'flag': '🇫🇷', 'native': 'Français'},
    {'code': 'ur', 'name': 'Urdu', 'flag': '🇵🇰', 'native': 'اردو'},
    {'code': 'hi', 'name': 'Hindi', 'flag': '🇮🇳', 'native': 'हिंदी'},
  ];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_kLocaleKey) ?? 'en';
    _locale = Locale(code);
    notifyListeners();
  }

  Future<void> setLocale(String languageCode) async {
    _locale = Locale(languageCode);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleKey, languageCode);
  }

  String get currentLanguageName {
    return supportedLanguages.firstWhere(
      (l) => l['code'] == _locale.languageCode,
      orElse: () => {'name': 'English'},
    )['name']!;
  }

  String get currentLanguageFlag {
    return supportedLanguages.firstWhere(
      (l) => l['code'] == _locale.languageCode,
      orElse: () => {'flag': '🇬🇧'},
    )['flag']!;
  }
}
