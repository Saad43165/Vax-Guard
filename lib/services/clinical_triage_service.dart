import '../utils/app_constants.dart';

enum ClinicalRiskLevel { low, medium, high, critical }

class ClinicalTriageResult {
  final ClinicalRiskLevel level;
  final int score;
  final String titleKey;
  final String descriptionKey;
  final String recommendationKey;
  final List<String> actionKeys;
  final List<String> clinicalFindings;
  final bool hasRedFlags;

  const ClinicalTriageResult({
    required this.level,
    required this.score,
    required this.titleKey,
    required this.descriptionKey,
    required this.recommendationKey,
    required this.actionKeys,
    this.clinicalFindings = const [],
    this.hasRedFlags = false,
  });
}

class TriageEntry {
  final String id;
  final String labelKey;
  final double weight;
  final bool isRedFlag;
  final String category;

  const TriageEntry({
    required this.id,
    required this.labelKey,
    this.weight = 1.0,
    this.isRedFlag = false,
    this.category = 'general',
  });
}

class ClinicalTriageService {
  static const List<TriageEntry> symptoms = [
    TriageEntry(id: 'dyspnea', labelKey: 'difficulty_breathing', weight: 50.0, isRedFlag: true, category: 'respiratory'),
    TriageEntry(id: 'chest_pain', labelKey: 'chest_pain', weight: 50.0, isRedFlag: true, category: 'cardiac'),
    TriageEntry(id: 'consciousness', labelKey: 'loss_consciousness', weight: 50.0, isRedFlag: true, category: 'neurological'),
    TriageEntry(id: 'slurred_speech', labelKey: 'slurred_speech', weight: 45.0, isRedFlag: true, category: 'neurological'),
    TriageEntry(id: 'paralysis', labelKey: 'sudden_weakness_paralysis', weight: 50.0, isRedFlag: true, category: 'neurological'),
    TriageEntry(id: 'confusion', labelKey: 'confusion_disorientation', weight: 40.0, isRedFlag: true, category: 'neurological'),
    TriageEntry(id: 'stiff_neck', labelKey: 'stiff_neck_warning', weight: 45.0, isRedFlag: true, category: 'neurological'),
    TriageEntry(id: 'seizures', labelKey: 'seizures_warning', weight: 50.0, isRedFlag: true, category: 'neurological'),
    TriageEntry(id: 'severe_abdominal_pain', labelKey: 'intense_abdominal_pain', weight: 40.0, isRedFlag: true, category: 'gastrointestinal'),
    TriageEntry(id: 'bleeding', labelKey: 'bleeding', weight: 50.0, isRedFlag: true, category: 'trauma'),
    TriageEntry(id: 'cyanosis', labelKey: 'blue_lips_warning', weight: 50.0, isRedFlag: true, category: 'respiratory'),
    TriageEntry(id: 'high_fever', labelKey: 'high_fever_over_103', weight: 25.0, category: 'general'),
    TriageEntry(id: 'persistent_cough', labelKey: 'persistent_cough', weight: 15.0, category: 'respiratory'),
    TriageEntry(id: 'sore_throat', labelKey: 'sore_throat', weight: 8.0, category: 'respiratory'),
    TriageEntry(id: 'runny_nose', labelKey: 'runny_nose', weight: 5.0, category: 'respiratory'),
    TriageEntry(id: 'diarrhea', labelKey: 'diarrhea', weight: 10.0, category: 'gastrointestinal'),
    TriageEntry(id: 'nausea_vomiting', labelKey: 'nausea_vomiting', weight: 10.0, category: 'gastrointestinal'),
    TriageEntry(id: 'fatigue', labelKey: 'severe_fatigue', weight: 10.0, category: 'general'),
    TriageEntry(id: 'loss_taste', labelKey: 'loss_taste_smell', weight: 5.0, category: 'sensory'),
  ];

  static const List<TriageEntry> riskFactors = [
    TriageEntry(id: 'age_65', labelKey: 'age_over_65', weight: 20.0, category: 'demographic'),
    TriageEntry(id: 'diabetes', labelKey: 'diabetes', weight: 15.0, category: 'comorbidity'),
    TriageEntry(id: 'hypertension', labelKey: 'hypertension', weight: 10.0, category: 'comorbidity'),
    TriageEntry(id: 'heart_disease', labelKey: 'chronic_heart_disease', weight: 20.0, category: 'comorbidity'),
    TriageEntry(id: 'lung_disease', labelKey: 'chronic_lung_disease', weight: 20.0, category: 'comorbidity'),
    TriageEntry(id: 'kidney_disease', labelKey: 'kidney_disease', weight: 20.0, category: 'comorbidity'),
    TriageEntry(id: 'liver_disease', labelKey: 'liver_disease', weight: 15.0, category: 'comorbidity'),
    TriageEntry(id: 'pregnancy', labelKey: 'pregnancy', weight: 15.0, category: 'physiological'),
    TriageEntry(id: 'asthma', labelKey: 'asthma', weight: 15.0, category: 'comorbidity'),
    TriageEntry(id: 'obesity', labelKey: 'obesity_warning', weight: 10.0, category: 'comorbidity'),
    TriageEntry(id: 'immunocompromised', labelKey: 'immunocompromised_status', weight: 30.0, category: 'comorbidity'),
  ];

  static ClinicalTriageResult evaluate({
    required List<String> selectedSymptoms,
    required List<String> selectedRiskFactors,
    required int age,
    required bool hadContact,
  }) {
    double totalScore = 0;
    bool redFlagDetected = false;
    List<String> findings = [];

    // Check Symptoms
    for (var id in selectedSymptoms) {
      final entry = symptoms.firstWhere((s) => s.id == id);
      totalScore += entry.weight;
      if (entry.isRedFlag) {
        redFlagDetected = true;
        findings.add('Critical: ${entry.labelKey}');
      } else {
        findings.add('Symptom: ${entry.labelKey}');
      }
    }

    // Check Risk Factors
    double riskMultiplier = 1.0;
    for (var id in selectedRiskFactors) {
      final entry = riskFactors.firstWhere((r) => r.id == id);
      totalScore += entry.weight;
      findings.add('Risk Factor: ${entry.labelKey}');
      riskMultiplier += (entry.weight / 100);
    }

    // Age Factor
    if (age >= 65) {
      totalScore += 20;
      riskMultiplier += 0.2;
      findings.add('Age-related risk escalation');
    }

    // Contact Factor
    if (hadContact) {
      totalScore += 30;
      findings.add('Epidemiological exposure detected');
    }

    // Apply multiplier to score
    double finalScore = totalScore * riskMultiplier;
    
    // Hard jump to critical for red flags
    if (redFlagDetected) {
      finalScore = (finalScore < 85) ? 85 : finalScore;
    }

    int normalizedScore = finalScore.round().clamp(0, 100);

    return _mapToResult(normalizedScore, redFlagDetected, findings);
  }

  static ClinicalTriageResult _mapToResult(int score, bool hasRedFlags, List<String> findings) {
    if (hasRedFlags || score >= 80) {
      return ClinicalTriageResult(
        level: ClinicalRiskLevel.critical,
        score: score,
        titleKey: 'critical_risk',
        descriptionKey: 'critical_risk_desc',
        recommendationKey: 'call_911_imm',
        actionKeys: ['go_to_er', 'call_911_imm', 'do_not_drive', 'inform_someone'],
        clinicalFindings: findings,
        hasRedFlags: hasRedFlags,
      );
    } else if (score >= 60) {
      return ClinicalTriageResult(
        level: ClinicalRiskLevel.high,
        score: score,
        titleKey: 'high_risk',
        descriptionKey: 'high_risk_desc',
        recommendationKey: 'contact_doctor_imm',
        actionKeys: ['contact_doctor_imm', 'urgent_care_visit', 'isolate_others'],
        clinicalFindings: findings,
      );
    } else if (score >= 30) {
      return ClinicalTriageResult(
        level: ClinicalRiskLevel.medium,
        score: score,
        titleKey: 'medium_risk',
        descriptionKey: 'medium_risk_desc',
        recommendationKey: 'schedule_doctor',
        actionKeys: ['rest_hydration', 'monitor_symptoms', 'schedule_doctor', 'wear_mask'],
        clinicalFindings: findings,
      );
    } else {
      return ClinicalTriageResult(
        level: ClinicalRiskLevel.low,
        score: score,
        titleKey: 'low_risk',
        descriptionKey: 'low_risk_desc',
        recommendationKey: 'monitor_symptoms',
        actionKeys: ['wash_hands_regularly', 'stay_uptodate_vax', 'monitor_symptoms'],
        clinicalFindings: findings,
      );
    }
  }
}
