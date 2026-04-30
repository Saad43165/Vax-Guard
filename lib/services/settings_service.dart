import '../services/sqlite_service.dart';

class SettingsService {
  static SettingsService? _instance;

  SettingsService._();

  static SettingsService get instance {
    _instance ??= SettingsService._();
    return _instance!;
  }

  Future<void> setSetting(String key, String value, {String type = 'string'}) async {
    final db = SQLiteService.instance;
    await db.insert('settings', {
      'key': key,
      'value': value,
      'type': type,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<String?> getSetting(String key) async {
    final db = SQLiteService.instance;
    final results = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (results.isEmpty) return null;
    return results.first['value'] as String?;
  }

  Future<bool> getBoolSetting(String key, {bool defaultValue = false}) async {
    final value = await getSetting(key);
    if (value == null) return defaultValue;
    return value == 'true';
  }

  Future<int> getIntSetting(String key, {int defaultValue = 0}) async {
    final value = await getSetting(key);
    if (value == null) return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }

  Future<void> setBoolSetting(String key, bool value) async {
    await setSetting(key, value.toString(), type: 'bool');
  }

  Future<void> setIntSetting(String key, int value) async {
    await setSetting(key, value.toString(), type: 'int');
  }

  Future<void> deleteSetting(String key) async {
    final db = SQLiteService.instance;
    await db.delete(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  Future<void> clearAllSettings() async {
    final db = SQLiteService.instance;
    await db.delete('settings');
  }
}