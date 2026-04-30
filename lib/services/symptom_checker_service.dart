import '../services/sqlite_service.dart';

class SymptomCheckerService {
  static SymptomCheckerService? _instance;

  SymptomCheckerService._();

  static SymptomCheckerService get instance {
    _instance ??= SymptomCheckerService._();
    return _instance!;
  }

  Future<List<Map<String, dynamic>>> getAllSymptoms() async {
    final db = SQLiteService.instance;
    return await db.query('symptoms', orderBy: 'name ASC');
  }

  Future<List<Map<String, dynamic>>> getSymptomsByCategory(String category) async {
    final db = SQLiteService.instance;
    return await db.query(
      'symptoms',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'name ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getSymptomsBySeverity(String severity) async {
    final db = SQLiteService.instance;
    return await db.query(
      'symptoms',
      where: 'severity = ?',
      whereArgs: [severity],
      orderBy: 'name ASC',
    );
  }

  Future<Map<String, dynamic>?> getSymptomByName(String name) async {
    final db = SQLiteService.instance;
    final results = await db.query(
      'symptoms',
      where: 'name = ?',
      whereArgs: [name],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<List<Map<String, dynamic>>> searchSymptoms(String query) async {
    final db = SQLiteService.instance;
    return await db.query(
      'symptoms',
      where: 'name LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
  }

  Future<int> assessRisk(List<String> selectedSymptoms) async {
    int riskScore = 0;
    for (final symptom in selectedSymptoms) {
      final result = await getSymptomByName(symptom);
      if (result != null) {
        switch (result['severity']) {
          case 'critical':
            riskScore += 40;
            break;
          case 'high':
            riskScore += 25;
            break;
          case 'medium':
            riskScore += 15;
            break;
          case 'low':
            riskScore += 5;
            break;
        }
      }
    }
    return riskScore.clamp(0, 100);
  }

  Future<String> getRiskLevel(int riskScore) async {
    if (riskScore >= 75) return 'Critical';
    if (riskScore >= 50) return 'High';
    if (riskScore >= 25) return 'Medium';
    return 'Low';
  }
}