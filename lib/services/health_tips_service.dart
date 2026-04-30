import '../services/sqlite_service.dart';

class HealthTipsService {
  static HealthTipsService? _instance;

  HealthTipsService._();

  static HealthTipsService get instance {
    _instance ??= HealthTipsService._();
    return _instance!;
  }

  Future<List<Map<String, dynamic>>> getAllHealthTips() async {
    final db = SQLiteService.instance;
    return await db.query('health_tips', orderBy: 'created_at DESC');
  }

  Future<List<Map<String, dynamic>>> getHealthTipsByCategory(String category) async {
    final db = SQLiteService.instance;
    return await db.query(
      'health_tips',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'created_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getFavoriteHealthTips() async {
    final db = SQLiteService.instance;
    return await db.query(
      'health_tips',
      where: 'is_favorite = ?',
      whereArgs: [1],
      orderBy: 'created_at DESC',
    );
  }

  Future<void> toggleFavorite(int id, bool isFavorite) async {
    final db = SQLiteService.instance;
    await db.update(
      'health_tips',
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = SQLiteService.instance;
    final results = await db.rawQuery('SELECT DISTINCT category FROM health_tips');
    return results;
  }
}