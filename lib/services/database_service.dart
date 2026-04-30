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

    notifyListeners();
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
      'lot_number': record.lotNumber,
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
        'lot_number': record.lotNumber,
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
    await db.delete('assessment_history');
    await db.delete('triage_results');
    await _refreshStats();
  }

  Future<void> saveHealthAssessment({
    required String title,
    required String description,
    required String recommendation,
    required int score,
    required List<String> actions,
  }) async {
    final db = SQLiteService.instance;
    final now = DateTime.now().toIso8601String();
    final riskLevel = title.toUpperCase();

    await db.insert('assessment_history', {
      'id': const Uuid().v4(),
      'assessment_type': 'triage',
      'title': title,
      'summary': recommendation,
      'status': _riskStatusFromScore(score),
      'risk_level': riskLevel,
      'risk_score': score,
      'details': description,
      'metadata_json': jsonEncode({
        'actions': actions,
      }),
      'created_at': now,
    });

    await db.insert('triage_results', {
      'symptoms': 'Health assessment',
      'risk_level': riskLevel,
      'risk_score': score,
      'recommendations': [
        description,
        recommendation,
        ...actions,
      ].join('\n'),
      'created_at': now,
    });

    notifyListeners();
  }

  Future<void> saveAnimalBiteAssessment({
    required Map<String, String> answers,
    required String result,
    String? imagePath,
    Map<String, dynamic>? extraMetadata,
  }) async {
    final db = SQLiteService.instance;
    final now = DateTime.now().toIso8601String();
    final riskLevel = _animalBiteRiskLabel(result);
    final animal = answers['animal']?.trim();
    final location = answers['location']?.trim();

    await db.insert('assessment_history', {
      'id': const Uuid().v4(),
      'assessment_type': 'animal_bite',
      'title': animal == null || animal.isEmpty
          ? 'Animal Bite Assessment'
          : '${_capitalize(animal)} Bite Assessment',
      'summary': [
        if (location != null && location.isNotEmpty) location,
        answers['time'] ?? 'Recent incident',
      ].join(' • '),
      'status': riskLevel,
      'risk_level': riskLevel,
      'risk_score': _animalBiteRiskScore(result),
      'details': result,
      'metadata_json': jsonEncode({
        'answers': answers,
        'image_path': imagePath,
        ...?extraMetadata,
      }),
      'created_at': now,
    });

    notifyListeners();
  }

  Future<void> saveSymptomCheckerAssessment({
    required Set<String> selectedSymptoms,
    required String severity,
    required int score,
    required String summary,
    required List<String> recommendations,
  }) async {
    final db = SQLiteService.instance;
    final now = DateTime.now().toIso8601String();
    final symptomList = selectedSymptoms.toList()..sort();

    await db.insert('assessment_history', {
      'id': const Uuid().v4(),
      'assessment_type': 'symptom_checker',
      'title': 'Symptom Checker',
      'summary': summary,
      'status': _riskStatusFromScore(score),
      'risk_level': severity,
      'risk_score': score,
      'details': 'Severity: $severity',
      'metadata_json': jsonEncode({
        'selected_symptoms': symptomList,
        'selected_count': symptomList.length,
        'severity': severity,
        'actions': recommendations,
      }),
      'created_at': now,
    });

    notifyListeners();
  }

  Future<void> saveDiseaseAssessment({
    required String assessmentId,
    required String assessmentName,
    required String subtitle,
    required dynamic result,
    required Map<String, int> answers,
    required List<dynamic> questions,
    required List<String> urgentFlags,
  }) async {
    final db = SQLiteService.instance;
    final now = DateTime.now().toIso8601String();
    final resolvedAnswers = <String, String>{};

    for (final question in questions) {
      final questionId = question.id as String;
      final optionIndex = answers[questionId];
      if (optionIndex == null ||
          optionIndex < 0 ||
          optionIndex >= (question.options as List).length) {
        continue;
      }
      resolvedAnswers[questionId] = question.options[optionIndex].label as String;
    }

    await db.insert('assessment_history', {
      'id': const Uuid().v4(),
      'assessment_type': 'disease_assessment',
      'title': assessmentName,
      'summary': subtitle,
      'status': result.level as String,
      'risk_level': result.level as String,
      'risk_score': result.score as int,
      'details': result.summary as String,
      'metadata_json': jsonEncode({
        'assessment_id': assessmentId,
        'assessment_name': assessmentName,
        'next_step': result.nextStep,
        'matched_concerns': result.matchedConcerns,
        'actions': result.actions,
        'answers': resolvedAnswers,
        'urgent_flags': urgentFlags,
      }),
      'created_at': now,
    });

    notifyListeners();
  }

  Future<List<HistoryEntry>> getHistoryEntries() async {
    final vaccineRecords = await getAllVaccineRecords();
    final db = SQLiteService.instance;
    final assessments = await db.query(
      'assessment_history',
      orderBy: 'created_at DESC',
    );

    final history = <HistoryEntry>[
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

  Future<Map<String, int>> getAssessmentTypeCounts() async {
    final db = SQLiteService.instance;
    final results = await db.rawQuery('''
      SELECT assessment_type, COUNT(*) as count
      FROM assessment_history
      GROUP BY assessment_type
    ''');

    final counts = <String, int>{};
    for (final row in results) {
      final key = (row['assessment_type'] as String?) ?? 'unknown';
      counts[key] = (row['count'] as int?) ?? 0;
    }
    return counts;
  }

  String _riskStatusFromScore(int score) {
    if (score >= 70) return 'High';
    if (score >= 40) return 'Medium';
    return 'Low';
  }

  String _animalBiteRiskLabel(String result) {
    if (result.contains('HIGH RISK')) return 'High Risk';
    if (result.contains('URGENT')) return 'Urgent';
    if (result.contains('MODERATE')) return 'Moderate';
    return 'Low Risk';
  }

  int _animalBiteRiskScore(String result) {
    if (result.contains('HIGH RISK')) return 90;
    if (result.contains('URGENT')) return 70;
    if (result.contains('MODERATE')) return 40;
    return 20;
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}
