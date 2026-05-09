import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/history_entry.dart';
import '../models/vaccine_record.dart';
import 'sqlite_service.dart';

class DatabaseService extends ChangeNotifier {
  static DatabaseService? _instance;
  static bool _initialized = false;
  int _totalVaccines = 0;
  int _completedVaccines = 0;
  int _pendingVaccines = 0;
  int _totalAssessments = 0;
  double _completionPercentage = 0;

  DatabaseService._();

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  Future<void> initialize() async {
    final db = SQLiteService.instance;
    await db.database;
    _initialized = true;
    await _refreshStats();
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

      final assessmentsResult = await db.rawQuery('SELECT COUNT(*) as count FROM assessment_history');
      _totalAssessments = assessmentsResult.first['count'] as int;
      
      _completionPercentage = _totalVaccines > 0 ? (_completedVaccines / _totalVaccines) * 100 : 0;
    } catch (e) {
      _resetStats();
    }
    notifyListeners();
  }

  void _resetStats() {
    _totalVaccines = 0;
    _completedVaccines = 0;
    _pendingVaccines = 0;
    _totalAssessments = 0;
    _completionPercentage = 0;
  }

  int get totalVaccines => _totalVaccines;
  int get completedVaccines => _completedVaccines;
  int get pendingVaccines => _pendingVaccines;
  int get totalAssessments => _totalAssessments;
  double get completionPercentage => _completionPercentage;
  int get totalHistoryCount => _totalVaccines + _totalAssessments;

  Future<List<VaccineRecord>> getPendingVaccines() async {
    final db = SQLiteService.instance;
    final results = await db.query('vaccine_records', where: 'is_completed = ?', whereArgs: [0], orderBy: 'vaccination_date ASC');
    return results.map((map) => _vaccineRecordFromMap(map)).toList();
  }

  Future<List<VaccineRecord>> getUpcomingVaccines() async {
    final db = SQLiteService.instance;
    final now = DateTime.now().toIso8601String();
    final results = await db.query('vaccine_records', where: 'next_dose_date > ? AND is_completed = ?', whereArgs: [now, 0], orderBy: 'next_dose_date ASC');
    return results.map((map) => _vaccineRecordFromMap(map)).toList();
  }

  Future<List<VaccineRecord>> getAllVaccineRecords() async {
    final db = SQLiteService.instance;
    final results = await db.query('vaccine_records', orderBy: 'vaccination_date DESC');
    return results.map((map) => _vaccineRecordFromMap(map)).toList();
  }

  Future<void> addVaccineRecord(VaccineRecord record) async {
    final db = SQLiteService.instance;
    await db.insert('vaccine_records', _vaccineRecordToMap(record));
    await _refreshStats();
  }

  Future<void> deleteVaccineRecord(String id) async {
    final db = SQLiteService.instance;
    await db.delete('vaccine_records', where: 'id = ?', whereArgs: [id]);
    await _refreshStats();
  }

  Future<void> markVaccineComplete(String id) async {
    final db = SQLiteService.instance;
    await db.update('vaccine_records', {'is_completed': 1}, where: 'id = ?', whereArgs: [id]);
    await _refreshStats();
  }

  Future<void> deleteAllRecords() async {
    final db = SQLiteService.instance;
    await db.delete('vaccine_records');
    await db.delete('assessment_history');
    await _refreshStats();
  }

  Future<void> saveHealthAssessment({
    required String title,
    required String description,
    required String recommendation,
    required int score,
    required List<String> actions,
    String? details,
    String type = 'triage',
  }) async {
    final db = SQLiteService.instance;
    final now = DateTime.now().toIso8601String();
    await db.insert('assessment_history', {
      'id': const Uuid().v4(),
      'assessment_type': type,
      'title': title,
      'summary': recommendation,
      'status': score >= 70 ? 'High' : (score >= 40 ? 'Medium' : 'Low'),
      'risk_level': title.toUpperCase(),
      'risk_score': score,
      'details': details ?? description,
      'metadata_json': jsonEncode({'actions': actions}),
      'created_at': now,
    });
    await _refreshStats();
  }

  Future<void> saveAnimalBiteAssessment({
    required Map<String, String> answers,
    required String result,
    String? details,
  }) async {
    await saveHealthAssessment(
      title: 'Animal Bite Assessment',
      description: details ?? result,
      recommendation: result,
      score: result.contains('Critical') ? 90 : (result.contains('High') ? 70 : 30),
      actions: ['Immediate Wound Care', 'Clinical Consultation', 'Rabies PEP Evaluation'],
      details: details,
      type: 'animal_bite',
    );
  }

  Future<void> saveSymptomCheckerAssessment({
    required Set<String> selectedSymptoms,
    required String severity,
    required int score,
    required String summary,
    required List<String> recommendations,
    String? details,
  }) async {
    await saveHealthAssessment(
      title: 'Symptom Analysis',
      description: summary,
      recommendation: severity,
      score: score,
      actions: recommendations,
      details: details,
      type: 'symptom_checker',
    );
  }

  Future<void> saveDiseaseAssessment({
    required String assessmentId,
    required String assessmentName,
    required String subtitle,
    required dynamic result,
    required Map<String, int> answers,
    required List<dynamic> questions,
    required List<String> urgentFlags,
    String? details,
  }) async {
    await saveHealthAssessment(
      title: assessmentName,
      description: result.summary,
      recommendation: result.headline,
      score: result.score,
      actions: result.actions,
      details: details,
      type: 'disease_assessment',
    );
  }

  Future<List<HistoryEntry>> getHistoryEntries() async {
    final vaccineRecords = await getAllVaccineRecords();
    final db = SQLiteService.instance;
    final assessments = await db.query('assessment_history', orderBy: 'created_at DESC');
    final history = [
      ...vaccineRecords.map(HistoryEntry.fromVaccineRecord),
      ...assessments.map(HistoryEntry.fromAssessmentMap),
    ];
    history.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return history;
  }

  VaccineRecord _vaccineRecordFromMap(Map<String, dynamic> map) {
    return VaccineRecord(
      id: map['id'] as String,
      vaccineName: map['vaccine_name'] as String,
      vaccinationDate: DateTime.parse(map['vaccination_date'] as String),
      lotNumber: map['lot_number'] as String? ?? '',
      administeredBy: map['provider'] as String?,
      notes: map['notes'] as String?,
      isCompleted: (map['is_completed'] as int) == 1,
      nextDoseDate: map['next_dose_date'] != null ? DateTime.parse(map['next_dose_date'] as String) : null,
      doseNumber: map['dose_number'] as String?,
      clinicName: map['location'] as String? ?? '',
    );
  }

  Map<String, dynamic> _vaccineRecordToMap(VaccineRecord record) {
    return {
      'id': record.id,
      'vaccine_name': record.vaccineName,
      'vaccination_date': record.vaccinationDate.toIso8601String(),
      'lot_number': record.lotNumber,
      'provider': record.administeredBy,
      'notes': record.notes,
      'is_completed': record.isCompleted ? 1 : 0,
      'next_dose_date': record.nextDoseDate?.toIso8601String(),
      'dose_number': record.doseNumber,
      'location': record.clinicName,
    };
  }
}
