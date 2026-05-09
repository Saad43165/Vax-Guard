import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class L10n {
  /// Transforms a key into a readable string or returns the string if it's already formatted.
  static String s(BuildContext context, String text) {
    if (text.isEmpty) return "";
    
    // 1. Try AppLocalizations first
    final appLoc = AppLocalizations.of(context);
    if (appLoc != null) {
      final translated = appLoc.translate(text);
      // If the translated string is different from the key, it was found
      if (translated != text) {
        return translated;
      }
    }

    // 2. Check manual overrides
    final Map<String, String> overrides = {
      'vaxguard': 'VaxGuard',
      'ai_powered_engine': 'AI Diagnostic Engine',
      'good_morning': 'Good Morning',
      'good_afternoon': 'Good Afternoon',
      'good_evening': 'Good Evening',
      'health_explorer': 'Health Explorer',
    };

    if (overrides.containsKey(text.toLowerCase())) {
      return overrides[text.toLowerCase()]!;
    }

    // 3. Fallback: Convert snake_case to Space Separated Title Case
    // Only if it looks like a key (no spaces, contains underscores)
    if (!text.contains(' ') && text.contains('_')) {
      return text.split('_').map((word) {
        if (word.isEmpty) return "";
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      }).join(' ');
    }

    return text;
  }

  static String get(BuildContext context, String key) => s(context, key);
}
