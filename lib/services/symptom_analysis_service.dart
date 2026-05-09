import 'dart:math';
import '../models/user_profile.dart';

class SymptomDefinition {
  final String id;
  final String name;
  final String bodyRegion;
  final double baseFrequency; // Commonness of this symptom globally (0.01 to 0.99)

  const SymptomDefinition({
    required this.id,
    required this.name,
    required this.bodyRegion,
    this.baseFrequency = 0.1,
  });
}

class DiseaseProfile {
  final String id;
  final String name;
  final String category;
  final double basePrevalence; // Base probability of having this disease

  // Probabilities of having these symptoms GIVEN you have the disease P(S|D)
  final Map<String, double> symptomProbabilities;
  final List<String> exclusionSymptoms;
  final List<String> highRiskGroups;
  final Map<String, double> synergisticPairs; // If both are present, multiply probability

  const DiseaseProfile({
    required this.id,
    required this.name,
    required this.category,
    this.basePrevalence = 0.05,
    this.symptomProbabilities = const {},
    this.exclusionSymptoms = const [],
    this.highRiskGroups = const [],
    this.synergisticPairs = const {},
  });
}

class UserSymptom {
  final String id;
  final int severity; // 1 to 10
  final String duration; // e.g. "1-2 days", "More than 2 weeks"

  const UserSymptom({
    required this.id,
    this.severity = 5,
    this.duration = '1-2 days',
  });
}

class DiseaseMatch {
  final String id;
  final String name;
  final String category;
  final int matchPercentage;
  final double rawProbability;
  final List<String> matchedSymptoms;
  final List<String> missingKeySymptoms;
  final String riskLevel;
  final String recommendation;

  const DiseaseMatch({
    required this.id,
    required this.name,
    required this.category,
    required this.matchPercentage,
    required this.rawProbability,
    required this.matchedSymptoms,
    required this.missingKeySymptoms,
    required this.riskLevel,
    required this.recommendation,
  });
}

class SymptomAnalysisResult {
  final List<DiseaseMatch> differentialDiagnosis;
  final String overallRisk;
  final int overallScore;
  final List<String> topRecommendations;
  final List<String> urgentFlags;

  const SymptomAnalysisResult({
    required this.differentialDiagnosis,
    required this.overallRisk,
    required this.overallScore,
    required this.topRecommendations,
    required this.urgentFlags,
  });
}

class SymptomAnalysisService {
  static const List<SymptomDefinition> allSymptoms = [
    SymptomDefinition(id: 'fever', name: 'Fever', bodyRegion: 'General', baseFrequency: 0.3),
    SymptomDefinition(id: 'chills', name: 'Chills', bodyRegion: 'General', baseFrequency: 0.2),
    SymptomDefinition(id: 'fatigue', name: 'Fatigue', bodyRegion: 'General', baseFrequency: 0.4),
    SymptomDefinition(id: 'weakness', name: 'Weakness', bodyRegion: 'General', baseFrequency: 0.25),
    SymptomDefinition(id: 'loss_appetite', name: 'Loss of Appetite', bodyRegion: 'General', baseFrequency: 0.15),
    SymptomDefinition(id: 'night_sweats', name: 'Night Sweats', bodyRegion: 'General', baseFrequency: 0.05),
    SymptomDefinition(id: 'weight_loss', name: 'Unexplained Weight Loss', bodyRegion: 'General', baseFrequency: 0.05),
    SymptomDefinition(id: 'body_ache', name: 'Body Aches', bodyRegion: 'General', baseFrequency: 0.2),
    SymptomDefinition(id: 'sweats', name: 'Excessive Sweating', bodyRegion: 'General', baseFrequency: 0.1),
    SymptomDefinition(id: 'dry_mouth', name: 'Dry Mouth', bodyRegion: 'General', baseFrequency: 0.1),
    SymptomDefinition(id: 'thirst', name: 'Excessive Thirst', bodyRegion: 'General', baseFrequency: 0.08),

    SymptomDefinition(id: 'headache', name: 'Headache', bodyRegion: 'Head', baseFrequency: 0.35),
    SymptomDefinition(id: 'dizziness', name: 'Dizziness', bodyRegion: 'Head', baseFrequency: 0.15),
    SymptomDefinition(id: 'confusion', name: 'Confusion', bodyRegion: 'Head', baseFrequency: 0.02),
    SymptomDefinition(id: 'stiff_neck', name: 'Stiff Neck', bodyRegion: 'Head', baseFrequency: 0.03),
    SymptomDefinition(id: 'sore_throat', name: 'Sore Throat', bodyRegion: 'Head', baseFrequency: 0.2),
    SymptomDefinition(id: 'runny_nose', name: 'Runny Nose', bodyRegion: 'Head', baseFrequency: 0.25),
    SymptomDefinition(id: 'ear_pain', name: 'Ear Pain', bodyRegion: 'Head', baseFrequency: 0.1),
    SymptomDefinition(id: 'eye_redness', name: 'Red Eyes', bodyRegion: 'Head', baseFrequency: 0.05),
    SymptomDefinition(id: 'loss_taste_smell', name: 'Loss of Taste/Smell', bodyRegion: 'Head', baseFrequency: 0.04),
    SymptomDefinition(id: 'cough', name: 'Cough', bodyRegion: 'Head', baseFrequency: 0.3),
    SymptomDefinition(id: 'sneezing', name: 'Sneezing', bodyRegion: 'Head', baseFrequency: 0.2),
    SymptomDefinition(id: 'photophobia', name: 'Light Sensitivity', bodyRegion: 'Head', baseFrequency: 0.03),
    SymptomDefinition(id: 'sunken_eyes', name: 'Sunken Eyes', bodyRegion: 'Head', baseFrequency: 0.02),
    SymptomDefinition(id: 'irritability', name: 'Irritability', bodyRegion: 'Head', baseFrequency: 0.1),

    SymptomDefinition(id: 'shortness_breath', name: 'Shortness of Breath', bodyRegion: 'Chest', baseFrequency: 0.1),
    SymptomDefinition(id: 'chest_pain', name: 'Chest Pain', bodyRegion: 'Chest', baseFrequency: 0.08),
    SymptomDefinition(id: 'wheezing', name: 'Wheezing', bodyRegion: 'Chest', baseFrequency: 0.05),
    SymptomDefinition(id: 'coughing_blood', name: 'Coughing Blood', bodyRegion: 'Chest', baseFrequency: 0.01),

    SymptomDefinition(id: 'rapid_heartbeat', name: 'Rapid Heartbeat', bodyRegion: 'Heart', baseFrequency: 0.04),
    SymptomDefinition(id: 'palpitations', name: 'Heart Palpitations', bodyRegion: 'Heart', baseFrequency: 0.06),
    SymptomDefinition(id: 'chest_tightness', name: 'Chest Tightness', bodyRegion: 'Heart', baseFrequency: 0.07),

    SymptomDefinition(id: 'nausea', name: 'Nausea', bodyRegion: 'Abdomen', baseFrequency: 0.2),
    SymptomDefinition(id: 'vomiting', name: 'Vomiting', bodyRegion: 'Abdomen', baseFrequency: 0.1),
    SymptomDefinition(id: 'diarrhea', name: 'Diarrhea', bodyRegion: 'Abdomen', baseFrequency: 0.15),
    SymptomDefinition(id: 'abdominal_pain', name: 'Abdominal Pain', bodyRegion: 'Abdomen', baseFrequency: 0.18),
    SymptomDefinition(id: 'jaundice', name: 'Yellow Eyes/Skin', bodyRegion: 'Abdomen', baseFrequency: 0.01),

    SymptomDefinition(id: 'rash', name: 'Rash', bodyRegion: 'Skin', baseFrequency: 0.08),
    SymptomDefinition(id: 'itching', name: 'Itching', bodyRegion: 'Skin', baseFrequency: 0.12),
    SymptomDefinition(id: 'lesions', name: 'Skin Lesions/Sores', bodyRegion: 'Skin', baseFrequency: 0.03),

    SymptomDefinition(id: 'leg_pain', name: 'Leg Pain', bodyRegion: 'Legs', baseFrequency: 0.1),
    SymptomDefinition(id: 'leg_swelling', name: 'Leg Swelling (Edema)', bodyRegion: 'Legs', baseFrequency: 0.05),
    SymptomDefinition(id: 'numbness_legs', name: 'Leg Numbness', bodyRegion: 'Legs', baseFrequency: 0.04),

    SymptomDefinition(id: 'arm_pain', name: 'Arm Pain', bodyRegion: 'Arms', baseFrequency: 0.08),
    SymptomDefinition(id: 'shoulder_pain', name: 'Shoulder Pain', bodyRegion: 'Arms', baseFrequency: 0.1),
    SymptomDefinition(id: 'tingling_arms', name: 'Tingling in Arms', bodyRegion: 'Arms', baseFrequency: 0.05),

    SymptomDefinition(id: 'vision_blur', name: 'Blurred Vision', bodyRegion: 'Eyes', baseFrequency: 0.06),
    SymptomDefinition(id: 'eye_pain', name: 'Eye Pain', bodyRegion: 'Eyes', baseFrequency: 0.04),
    SymptomDefinition(id: 'photophobia', name: 'Light Sensitivity', bodyRegion: 'Eyes', baseFrequency: 0.03),

    SymptomDefinition(id: 'ear_pain', name: 'Ear Pain', bodyRegion: 'Ears', baseFrequency: 0.07),
    SymptomDefinition(id: 'tinnitus', name: 'Ringing in Ears', bodyRegion: 'Ears', baseFrequency: 0.05),
    SymptomDefinition(id: 'hearing_loss', name: 'Hearing Loss', bodyRegion: 'Ears', baseFrequency: 0.02),

    SymptomDefinition(id: 'joint_pain', name: 'Joint Pain', bodyRegion: 'Musculoskeletal', baseFrequency: 0.15),
    SymptomDefinition(id: 'muscle_pain', name: 'Muscle Pain', bodyRegion: 'Musculoskeletal', baseFrequency: 0.18),
    SymptomDefinition(id: 'back_pain', name: 'Back Pain', bodyRegion: 'Musculoskeletal', baseFrequency: 0.25),
  ];

  static const List<DiseaseProfile> diseases = [
    DiseaseProfile(
      id: 'common_cold',
      name: 'Common Cold',
      category: 'Respiratory',
      basePrevalence: 0.1,
      symptomProbabilities: {
        'runny_nose': 0.9, 'sore_throat': 0.8, 'cough': 0.7, 'sneezing': 0.8,
        'fatigue': 0.4, 'headache': 0.3, 'fever': 0.1,
      },
      exclusionSymptoms: ['shortness_breath', 'coughing_blood'],
      synergisticPairs: {'runny_nose|sore_throat': 1.5},
    ),
    DiseaseProfile(
      id: 'influenza',
      name: 'Influenza (Flu)',
      category: 'Respiratory',
      basePrevalence: 0.05,
      symptomProbabilities: {
        'fever': 0.95, 'chills': 0.8, 'fatigue': 0.9, 'body_ache': 0.85,
        'headache': 0.8, 'cough': 0.7, 'sore_throat': 0.5,
      },
      highRiskGroups: ['elderly', 'pregnant', 'asthma'],
      synergisticPairs: {'fever|body_ache': 2.0, 'fever|chills': 1.8},
    ),
    DiseaseProfile(
      id: 'covid19',
      name: 'COVID-19',
      category: 'Respiratory',
      basePrevalence: 0.04,
      symptomProbabilities: {
        'fever': 0.8, 'cough': 0.7, 'loss_taste_smell': 0.6,
        'fatigue': 0.7, 'shortness_breath': 0.4, 'body_ache': 0.5,
      },
      synergisticPairs: {'fever|loss_taste_smell': 3.0, 'cough|shortness_breath': 2.0},
    ),
    DiseaseProfile(
      id: 'dengue',
      name: 'Dengue Fever',
      category: 'Vector-borne',
      basePrevalence: 0.02,
      symptomProbabilities: {
        'fever': 0.98, 'body_ache': 0.9, 'headache': 0.85, 'eye_redness': 0.6,
        'rash': 0.5, 'nausea': 0.4, 'joint_pain': 0.8,
      },
      synergisticPairs: {'fever|joint_pain': 2.5, 'fever|rash': 2.0},
    ),
    DiseaseProfile(
      id: 'malaria',
      name: 'Malaria',
      category: 'Vector-borne',
      basePrevalence: 0.02,
      symptomProbabilities: {
        'fever': 0.95, 'chills': 0.9, 'sweats': 0.8, 'headache': 0.7,
        'nausea': 0.5, 'fatigue': 0.8, 'vomiting': 0.4,
      },
      synergisticPairs: {'fever|chills': 2.0, 'chills|sweats': 2.5},
    ),
    DiseaseProfile(
      id: 'typhoid',
      name: 'Typhoid Fever',
      category: 'Gastrointestinal',
      basePrevalence: 0.02,
      symptomProbabilities: {
        'fever': 0.9, 'abdominal_pain': 0.7, 'headache': 0.6,
        'constipation': 0.4, 'diarrhea': 0.3, 'loss_appetite': 0.7,
      },
    ),
    DiseaseProfile(
      id: 'pneumonia',
      name: 'Pneumonia',
      category: 'Respiratory',
      basePrevalence: 0.03,
      symptomProbabilities: {
        'cough': 0.9, 'fever': 0.8, 'shortness_breath': 0.8,
        'chest_pain': 0.7, 'rapid_heartbeat': 0.6, 'fatigue': 0.7,
      },
      synergisticPairs: {'fever|shortness_breath': 3.0, 'chest_pain|cough': 2.0},
    ),
    DiseaseProfile(
      id: 'gastroenteritis',
      name: 'Gastroenteritis',
      category: 'Gastrointestinal',
      basePrevalence: 0.06,
      symptomProbabilities: {
        'diarrhea': 0.9, 'vomiting': 0.8, 'nausea': 0.9,
        'abdominal_pain': 0.8, 'fever': 0.4, 'weakness': 0.6,
      },
      synergisticPairs: {'diarrhea|vomiting': 2.0},
    ),
    DiseaseProfile(
      id: 'hantavirus',
      name: 'Hantavirus Pulmonary Syndrome',
      category: 'Respiratory/Zoonotic',
      basePrevalence: 0.005,
      symptomProbabilities: {
        'fever': 0.95, 'muscle_pain': 0.9, 'fatigue': 0.85, 'shortness_breath': 0.8,
        'headache': 0.7, 'dizziness': 0.6, 'chills': 0.7, 'abdominal_pain': 0.5,
      },
      highRiskGroups: ['rural workers', 'campers'],
      synergisticPairs: {'fever|shortness_breath': 3.5, 'muscle_pain|fatigue': 2.0},
    ),
    DiseaseProfile(
      id: 'uti',
      name: 'Urinary Tract Infection',
      category: 'Urinary',
      basePrevalence: 0.04,
      symptomProbabilities: {
        'burning_urination': 0.95, 'frequent_urination': 0.9,
        'pelvic_pain': 0.6, 'cloudy_urine': 0.5, 'blood_in_urine': 0.2,
      },
      synergisticPairs: {'burning_urination|frequent_urination': 3.0},
    ),
  ];

  static List<String> get bodyRegions {
    final regions = <String>{};
    for (final s in allSymptoms) {
      regions.add(s.bodyRegion);
    }
    return regions.toList()..sort();
  }

  static List<SymptomDefinition> symptomsForRegion(String region) {
    return allSymptoms.where((s) => s.bodyRegion == region).toList();
  }

  static List<SymptomDefinition> symptomsForRegions(Iterable<String> regions) {
    return allSymptoms.where((s) => regions.contains(s.bodyRegion)).toList();
  }

  static SymptomAnalysisResult analyze({
    required List<UserSymptom> userSymptoms,
    UserProfile? profile,
  }) {
    if (userSymptoms.isEmpty) {
      return const SymptomAnalysisResult(
        differentialDiagnosis: [],
        overallRisk: 'Insufficient Input',
        overallScore: 0,
        topRecommendations: [
          'select_symptoms_desc',
          'include_severity_desc',
        ],
        urgentFlags: [],
      );
    }

    final symptomMap = {for (final s in userSymptoms) s.id: s};
    final matches = <DiseaseMatch>[];
    final urgentFlags = <String>[];

    // Identify urgent flags based on critical symptoms directly
    _checkUrgentFlags(symptomMap, urgentFlags);

    for (final disease in diseases) {
      final match = _evaluateProbabilistic(disease, symptomMap, profile);
      if (match != null) {
        matches.add(match);
      }
    }

    // Sort by calculated probability
    matches.sort((a, b) => b.rawProbability.compareTo(a.rawProbability));

    // Normalize probabilities to percentages
    final topProbability = matches.isNotEmpty ? matches.first.rawProbability : 1.0;
    
    final normalizedMatches = matches.map((m) {
      // Scale matches relative to the top match, ensuring top match is high if it exists
      double relativeProb = m.rawProbability / (topProbability + 1e-15);
      
      // Calculate confidence scale based on number of symptoms provided
      double confidenceScale = (symptomMap.length / 5.0).clamp(0.5, 1.0);
      
      int percentage = (relativeProb * 95 * confidenceScale).round().clamp(0, 99);
      
      // Ensure top match is always visible and credible if it's the primary suspect
      if (m.id == matches.first.id) {
        if (percentage < 45) percentage = 45; 
      } else if (percentage < 15) {
        // Hide negligible secondary matches
        percentage = 0;
      }
      
      final riskLevel = percentage >= 75 ? 'critical_risk' : percentage >= 50 ? 'high_risk' : percentage >= 30 ? 'medium_risk' : 'low_risk';
      final recommendation = percentage >= 80 ? 'highly_probable' : percentage >= 50 ? 'moderate_probable' : 'low_probable';
      
      return DiseaseMatch(
        id: m.id,
        name: m.name,
        category: m.category,
        matchPercentage: percentage,
        rawProbability: m.rawProbability,
        matchedSymptoms: m.matchedSymptoms,
        missingKeySymptoms: m.missingKeySymptoms,
        riskLevel: riskLevel,
        recommendation: recommendation,
      );
    }).where((m) => m.matchPercentage > 10).toList();

    final top = normalizedMatches.isNotEmpty ? normalizedMatches.first : null;
    String overallRisk = 'Low';
    int overallScore = 0;

    if (top != null) {
      overallScore = top.matchPercentage;
      if (top.matchPercentage >= 75 || top.riskLevel == 'critical_risk') {
        overallRisk = 'high_risk';
      } else if (top.matchPercentage >= 50 || top.riskLevel == 'high_risk') {
        overallRisk = 'medium_risk';
      } else if (top.matchPercentage >= 30) {
        overallRisk = 'medium_risk';
      }
    }

    final recommendations = _buildRecommendations(normalizedMatches, urgentFlags, profile);

    return SymptomAnalysisResult(
      differentialDiagnosis: normalizedMatches.take(5).toList(),
      overallRisk: overallRisk,
      overallScore: overallScore,
      topRecommendations: recommendations,
      urgentFlags: urgentFlags,
    );
  }

  static DiseaseMatch? _evaluateProbabilistic(
      DiseaseProfile disease,
      Map<String, UserSymptom> symptomMap,
      UserProfile? profile,
  ) {
    // Exclusion check
    if (disease.exclusionSymptoms.any((s) => symptomMap.containsKey(s))) {
      return null;
    }

    // Base probability
    double probability = disease.basePrevalence;
    final matched = <String>[];
    final missing = <String>[];

    // Adjust for high risk profile
    if (profile != null) {
      for (final risk in disease.highRiskGroups) {
        if (_userHasRiskFactor(profile, risk)) {
          probability *= 1.5; // 50% increase in base probability
        }
      }
    }

    int strongSymptomsMatched = 0;
    int strongSymptomsTotal = 0;

    // Apply Naive Bayes-like conditional updates
    disease.symptomProbabilities.forEach((symId, pSymGivenDisease) {
      final isStrongSymptom = pSymGivenDisease >= 0.7;
      if (isStrongSymptom) strongSymptomsTotal++;

      if (symptomMap.containsKey(symId)) {
        final userSym = symptomMap[symId]!;
        matched.add(symId);
        if (isStrongSymptom) strongSymptomsMatched++;

        // Severity weight modifier
        double severityWeight = 0.5 + (userSym.severity / 10.0); // 0.6 to 1.5
        
        // P(S|D) / P(S) --> how much more likely is this symptom under this disease vs average
        final globalFreq = allSymptoms.firstWhere((s) => s.id == symId).baseFrequency;
        double likelihoodRatio = (pSymGivenDisease / globalFreq) * severityWeight;
        
        probability *= likelihoodRatio;
      } else {
        // Symptom is absent. If it's a very common symptom for this disease, penalty applies.
        if (isStrongSymptom) {
          missing.add(symId);
          probability *= (1.0 - pSymGivenDisease); 
        }
      }
    });

    // Synergistic pairs (if 2 symptoms appear together, they strongly indicate this disease)
    disease.synergisticPairs.forEach((pairKey, multiplier) {
      final parts = pairKey.split('|');
      if (parts.length == 2 && symptomMap.containsKey(parts[0]) && symptomMap.containsKey(parts[1])) {
        probability *= multiplier;
      }
    });

    // If disease has strong defining symptoms but user has none of them, discard
    if (strongSymptomsTotal > 0 && strongSymptomsMatched == 0) {
      probability *= 0.1;
    }

    if (probability < 1e-10) probability = 1e-10; // Floor to prevent 0

    return DiseaseMatch(
      id: disease.id,
      name: disease.name,
      category: disease.category,
      matchPercentage: 0, // Calculated later
      rawProbability: probability,
      matchedSymptoms: matched,
      missingKeySymptoms: missing,
      riskLevel: '',
      recommendation: '',
    );
  }

  static bool _userHasRiskFactor(UserProfile profile, String risk) {
    if (risk == 'elderly' && profile.age != null && profile.age! >= 65) return true;
    if (risk == 'children' && profile.age != null && profile.age! <= 5) return true;
    if (risk == 'pregnant' && profile.isPregnant) return true;
    if (risk == 'diabetes' && profile.hasDiabetes) return true;
    if (risk == 'asthma' && profile.hasAsthma) return true;
    return false;
  }

  static void _checkUrgentFlags(Map<String, UserSymptom> map, List<String> flags) {
    if (map.containsKey('shortness_breath') && (map['shortness_breath']?.severity ?? 0) >= 7) {
      flags.add('urgent_breath');
    }
    if (map.containsKey('chest_pain') && (map['chest_pain']?.severity ?? 0) >= 7) {
      flags.add('urgent_chest');
    }
    if (map.containsKey('confusion') && (map['confusion']?.severity ?? 0) >= 6) {
      flags.add('urgent_confusion');
    }
    if (map.containsKey('stiff_neck') && map.containsKey('fever') && (map['stiff_neck']?.severity ?? 0) >= 6) {
      flags.add('urgent_stiff_neck');
    }
  }

  static String _diseaseRecommendation(String diseaseId, int percentage) {
    if (percentage >= 80) return 'Highly probable. Medical evaluation is strongly advised.';
    if (percentage >= 50) return 'Moderate probability. Monitor symptoms closely.';
    return 'Low probability pattern match.';
  }

  static List<String> _buildRecommendations(List<DiseaseMatch> matches, List<String> urgentFlags, UserProfile? profile) {
    final recs = <String>[];
    if (urgentFlags.isNotEmpty) {
      recs.add('immediate_care_needed');
    }
    if (matches.isNotEmpty && matches.first.matchPercentage >= 70) {
      recs.add('highly_probable');
    }
    if (profile?.isHighRisk ?? false) {
      recs.add('risk_profile_notice');
    }
    recs.add('rest_hydration_isolate');
    recs.add('avoid_self_prescribe');
    return recs;
  }
}