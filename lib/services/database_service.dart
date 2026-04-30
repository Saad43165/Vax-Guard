import '../models/vaccine_record.dart';
import 'sqlite_service.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static bool _initialized = false;
  int _totalVaccines = 0;
  int _completedVaccines = 0;
  int _pendingVaccines = 0;
  double _completionPercentage = 0;

  DatabaseService._();

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  Future<void> initialize() async {
    final db = SQLiteService.instance;
    await db.database;
    await _refreshStats();
    _initialized = true;
  }

  Future<void> _refreshStats() async {
    if (!_initialized) return;
    
    final db = SQLiteService.instance;
    
    try {
      final totalResult = await db.rawQuery('SELECT COUNT(*) as count FROM vaccine_records');
      _totalVaccines = totalResult.first['count'] as int;
      
      final completedResult = await db.rawQuery('SELECT COUNT(*) as count FROM vaccine_records WHERE is_completed = 1');
      _completedVaccines = completedResult.first['count'] as int;
      
      final pendingResult = await db.rawQuery('SELECT COUNT(*) as count FROM vaccine_records WHERE is_completed = 0');
      _pendingVaccines = pendingResult.first['count'] as int;
      
      if (_totalVaccines > 0) {
        _completionPercentage = (_completedVaccines / _totalVaccines) * 100;
      } else {
        _completionPercentage = 0;
      }
    } catch (e) {
      _totalVaccines = 0;
      _completedVaccines = 0;
      _pendingVaccines = 0;
      _completionPercentage = 0;
    }
  }

  int get totalVaccines => _totalVaccines;
  int get completedVaccines => _completedVaccines;
  int get pendingVaccines => _pendingVaccines;
  double get completionPercentage => _completionPercentage;

  Future<void> addVaccineRecord(VaccineRecord record) async {
    final db = SQLiteService.instance;
    await db.insert('vaccine_records', {
      'id': record.id,
      'vaccine_name': record.vaccineName,
      'vaccine_type': record.clinicName ?? '',
      'dose_number': record.doseNumber ?? '',
      'dose_count': 1,
      'vaccination_date': record.vaccinationDate.toIso8601String(),
      'next_dose_date': record.nextDoseDate?.toIso8601String(),
      'location': record.clinicName ?? '',
      'provider': record.administeredBy ?? '',
      'is_completed': record.isCompleted ? 1 : 0,
      'notes': record.notes ?? '',
      'side_effects': '',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
    await _refreshStats();
  }

  Future<List<VaccineRecord>> getAllVaccineRecords() async {
    final db = SQLiteService.instance;
    final results = await db.query('vaccine_records', orderBy: 'vaccination_date DESC');
    return results.map((map) => _vaccineRecordFromMap(map)).toList();
  }

  Future<VaccineRecord?> getVaccineRecord(String id) async {
    final db = SQLiteService.instance;
    final results = await db.query(
      'vaccine_records',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isEmpty) return null;
    return _vaccineRecordFromMap(results.first);
  }

  Future<List<VaccineRecord>> getCompletedVaccines() async {
    final db = SQLiteService.instance;
    final results = await db.query(
      'vaccine_records',
      where: 'is_completed = ?',
      whereArgs: [1],
      orderBy: 'vaccination_date DESC',
    );
    return results.map((map) => _vaccineRecordFromMap(map)).toList();
  }

  Future<List<VaccineRecord>> getUpcomingVaccines() async {
    final db = SQLiteService.instance;
    final now = DateTime.now().toIso8601String();
    final results = await db.query(
      'vaccine_records',
      where: 'next_dose_date > ? AND is_completed = ?',
      whereArgs: [now, 0],
      orderBy: 'next_dose_date ASC',
    );
    return results.map((map) => _vaccineRecordFromMap(map)).toList();
  }

  Future<void> updateVaccineRecord(VaccineRecord record) async {
    final db = SQLiteService.instance;
    await db.update(
      'vaccine_records',
      {
        'vaccine_name': record.vaccineName,
        'vaccine_type': record.clinicName ?? '',
        'dose_number': record.doseNumber ?? '',
        'dose_count': 1,
        'vaccination_date': record.vaccinationDate.toIso8601String(),
        'next_dose_date': record.nextDoseDate?.toIso8601String(),
        'location': record.clinicName ?? '',
        'provider': record.administeredBy ?? '',
        'is_completed': record.isCompleted ? 1 : 0,
        'notes': record.notes ?? '',
        'side_effects': '',
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [record.id],
    );
    await _refreshStats();
  }

  Future<void> markVaccineComplete(String id) async {
    final db = SQLiteService.instance;
    await db.update(
      'vaccine_records',
      {
        'is_completed': 1,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    await _refreshStats();
  }

  Future<void> deleteVaccineRecord(String id) async {
    final db = SQLiteService.instance;
    await db.delete(
      'vaccine_records',
      where: 'id = ?',
      whereArgs: [id],
    );
    await _refreshStats();
  }

  Future<void> deleteAllRecords() async {
    final db = SQLiteService.instance;
    await db.delete('vaccine_records');
    await _refreshStats();
  }

  VaccineRecord _vaccineRecordFromMap(Map<String, dynamic> map) {
    return VaccineRecord(
      id: map['id'] as String,
      vaccineName: map['vaccine_name'] as String,
      vaccinationDate: DateTime.parse(map['vaccination_date'] as String),
      lotNumber: map['lot_number'] as String? ?? map['location'] as String? ?? '',
      administeredBy: map['provider'] as String?,
      notes: map['notes'] as String?,
      isCompleted: (map['is_completed'] as int) == 1,
      nextDoseDate: map['next_dose_date'] != null ? DateTime.parse(map['next_dose_date'] as String) : null,
      doseNumber: map['dose_number'] as String?,
      clinicName: map['location'] as String? ?? map['vaccine_type'] as String?,
    );
  }

  Future<Map<String, int>> getVaccinesByMonth() async {
    final db = SQLiteService.instance;
    final results = await db.rawQuery('''
      SELECT strftime('%Y-%m', vaccination_date) as month, COUNT(*) as count 
      FROM vaccine_records 
      GROUP BY month 
      ORDER BY month DESC
    ''');
    final Map<String, int> monthlyData = {};
    for (final row in results) {
      monthlyData[row['month'] as String] = row['count'] as int;
    }
    return monthlyData;
  }
}