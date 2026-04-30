import 'dart:convert';

import 'vaccine_record.dart';

enum HistoryEntryType {
  vaccine,
  triage,
  animalBite,
  symptomChecker,
  diseaseAssessment,
}

class HistoryEntry {
  final String id;
  final HistoryEntryType type;
  final String title;
  final String summary;
  final String statusLabel;
  final DateTime createdAt;
  final int? riskScore;
  final String? details;
  final Map<String, dynamic> metadata;

  const HistoryEntry({
    required this.id,
    required this.type,
    required this.title,
    required this.summary,
    required this.statusLabel,
    required this.createdAt,
    this.riskScore,
    this.details,
    this.metadata = const {},
  });

  factory HistoryEntry.fromVaccineRecord(VaccineRecord record) {
    final summaryParts = <String>[
      if (record.doseNumber != null && record.doseNumber!.trim().isNotEmpty)
        record.doseNumber!,
      if (record.clinicName != null && record.clinicName!.trim().isNotEmpty)
        record.clinicName!,
      if (record.lotNumber.trim().isNotEmpty) 'Lot ${record.lotNumber}',
    ];

    return HistoryEntry(
      id: record.id,
      type: HistoryEntryType.vaccine,
      title: record.vaccineName,
      summary: summaryParts.isEmpty
          ? 'Vaccination record'
          : summaryParts.join(' • '),
      statusLabel: record.isCompleted ? 'Completed' : 'Pending',
      createdAt: record.vaccinationDate,
      details: record.notes,
      metadata: {
        'dose_number': record.doseNumber,
        'clinic_name': record.clinicName,
        'lot_number': record.lotNumber,
        'administered_by': record.administeredBy,
        'notes': record.notes,
        'next_dose_date': record.nextDoseDate?.toIso8601String(),
      },
    );
  }

  factory HistoryEntry.fromAssessmentMap(Map<String, dynamic> map) {
    final rawType = (map['assessment_type'] as String? ?? '').trim();
    final metadataJson = map['metadata_json'] as String?;

    return HistoryEntry(
      id: map['id'] as String,
      type: _typeFromStorage(rawType),
      title: map['title'] as String? ?? 'Assessment',
      summary: map['summary'] as String? ?? '',
      statusLabel: map['status'] as String? ?? 'Saved',
      createdAt: DateTime.parse(map['created_at'] as String),
      riskScore: map['risk_score'] as int?,
      details: map['details'] as String?,
      metadata: _parseMetadata(metadataJson),
    );
  }

  static HistoryEntryType _typeFromStorage(String value) {
    switch (value) {
      case 'triage':
        return HistoryEntryType.triage;
      case 'animal_bite':
        return HistoryEntryType.animalBite;
      case 'symptom_checker':
        return HistoryEntryType.symptomChecker;
      case 'disease_assessment':
        return HistoryEntryType.diseaseAssessment;
      default:
        return HistoryEntryType.vaccine;
    }
  }

  static Map<String, dynamic> _parseMetadata(String? rawJson) {
    if (rawJson == null || rawJson.trim().isEmpty) {
      return const {};
    }

    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      // Fall through to an empty metadata object when older rows contain
      // malformed or partial JSON.
    }

    return const {};
  }
}
