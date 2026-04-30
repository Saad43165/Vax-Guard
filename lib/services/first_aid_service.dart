import '../services/sqlite_service.dart';

class FirstAidService {
  static FirstAidService? _instance;

  FirstAidService._();

  static FirstAidService get instance {
    _instance ??= FirstAidService._();
    return _instance!;
  }

  Future<List<Map<String, dynamic>>> getAllGuides() async {
    final db = SQLiteService.instance;
    return await db.query('first_aid_guides', orderBy: 'title ASC');
  }

  Future<List<Map<String, dynamic>>> getGuidesByCategory(String category) async {
    final db = SQLiteService.instance;
    return await db.query(
      'first_aid_guides',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'title ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getEmergencyGuides() async {
    final db = SQLiteService.instance;
    return await db.query(
      'first_aid_guides',
      where: 'emergency_level = ?',
      whereArgs: ['critical'],
      orderBy: 'title ASC',
    );
  }

  Future<Map<String, dynamic>?> getGuideByTitle(String title) async {
    final db = SQLiteService.instance;
    final results = await db.query(
      'first_aid_guides',
      where: 'title = ?',
      whereArgs: [title],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<List<Map<String, dynamic>>> searchGuides(String query) async {
    final db = SQLiteService.instance;
    return await db.query(
      'first_aid_guides',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'title ASC',
    );
  }
}