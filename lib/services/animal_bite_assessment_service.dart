class AnimalBiteAssessmentResult {
  final String severityLabel;
  final int riskScore;
  final String exposureCategory;
  final String urgency;
  final String summary;
  final List<String> firstAidSteps;
  final List<String> medicalTreatment;
  final List<String> riskFactors;
  final List<String> recommendations;
  final bool pepRecommended;
  final bool rigRecommended;
  final bool inputInvalid;

  const AnimalBiteAssessmentResult({
    required this.severityLabel,
    required this.riskScore,
    required this.exposureCategory,
    required this.urgency,
    required this.summary,
    required this.firstAidSteps,
    required this.medicalTreatment,
    required this.riskFactors,
    required this.recommendations,
    required this.pepRecommended,
    required this.rigRecommended,
    this.inputInvalid = false,
  });
}

class AnimalBiteAssessment {
  static const _highRiskAnimals = [
    'dog',
    'cat',
    'bat',
    'raccoon',
    'fox',
    'skunk',
    'wolf',
    'coyote'
  ];
  static const _lowRiskAnimals = [
    'rabbit',
    'hamster',
    'guinea pig',
    'squirrel',
    'mouse',
    'rat'
  ];

  static AnimalBiteAssessmentResult assess(Map<String, String> answers) {
    final animal = (answers['animal'] ?? '').trim().toLowerCase();
    final depth = (answers['depth'] ?? '').trim().toLowerCase();
    final bleeding = (answers['bleeding'] ?? '').trim().toLowerCase();
    final animalStatus = (answers['animal_status'] ?? '').trim().toLowerCase();
    final location = (answers['location'] ?? '').trim().toLowerCase();

    // Add minimum validation - inputs must be at least 2 characters
    if (animal.length < 2 || depth.length < 2 || bleeding.length < 2 || animalStatus.length < 2) {
      return const AnimalBiteAssessmentResult(
        severityLabel: 'INSUFFICIENT INPUT',
        riskScore: 0,
        exposureCategory: 'Unknown',
        urgency: 'PLEASE ANSWER ALL QUESTIONS',
        summary:
            'Please answer all questions with valid details to get an accurate assessment.',
        firstAidSteps: [
          'Wash the wound with soap and running water for at least 15 minutes.',
          'Apply antiseptic if available.',
        ],
        medicalTreatment: [
          'Complete all questions to get a proper assessment.',
        ],
        riskFactors: [
          'Missing required information.',
        ],
        recommendations: [
          'Please answer all questions properly.',
          'Seek medical care if wound is severe.',
        ],
        pepRecommended: false,
        rigRecommended: false,
        inputInvalid: true,
      );
    }

    final isHighRiskAnimal = _highRiskAnimals.any((a) => animal.contains(a));
    final isLowRiskAnimal = _lowRiskAnimals.any((a) => animal.contains(a));
    final isUnknownAnimal = !isHighRiskAnimal && !isLowRiskAnimal;
    final isDeep = depth.contains('deep') ||
        depth.contains('puncture') ||
        depth.contains('laceration') ||
        depth.contains('tear');
    final isBleedingHeavy = bleeding.contains('heavy') || bleeding.contains('moderate');
    final isWildOrUnobservable = animalStatus.contains('stray') ||
        animalStatus.contains('unknown') ||
        animalStatus.contains('wild') ||
        animalStatus.contains('foaming');
    final highRiskLocation = location.contains('face') ||
        location.contains('neck') ||
        location.contains('head') ||
        location.contains('finger') ||
        location.contains('hand');

    final category = _whoCategory(
      isDeep: isDeep,
      isBleedingHeavy: isBleedingHeavy,
      isWildOrUnobservable: isWildOrUnobservable,
      isHighRiskAnimal: isHighRiskAnimal,
      isUnknownAnimal: isUnknownAnimal,
      highRiskLocation: highRiskLocation,
    );

    if (category == 'III') {
      return AnimalBiteAssessmentResult(
        severityLabel: 'HIGH RISK',
        riskScore: 90,
        exposureCategory: 'WHO Category III',
        urgency: 'WITHIN 24 HOURS',
        summary:
            'Severe exposure pattern detected. WHO-aligned guidance suggests urgent post-exposure management.',
        firstAidSteps: const [
          'Wash the wound with soap and running water for at least 15 minutes.',
          'Apply povidone-iodine or alcohol-based antiseptic.',
          'Do not close or suture the wound before medical evaluation.',
          'Control bleeding with gentle pressure.',
        ],
        medicalTreatment: const [
          'Urgent rabies vaccine (PEP) is recommended.',
          'Rabies immunoglobulin (RIG) should be considered for Category III exposure.',
          'Assess tetanus booster and antibiotics based on wound condition.',
        ],
        riskFactors: [
          'Likely high-risk exposure pattern.',
          'Animal: ${answers['animal'] ?? 'Unknown'}',
          'Wound: ${answers['depth'] ?? 'Unknown'}',
        ],
        recommendations: const [
          'Go to emergency care now.',
          'Start rabies PEP without delay.',
          'Follow full vaccine schedule as advised by clinician.',
          'Report bite incident to local health authority where applicable.',
        ],
        pepRecommended: true,
        rigRecommended: true,
      );
    }

    if (category == 'II') {
      return AnimalBiteAssessmentResult(
        severityLabel: 'URGENT',
        riskScore: 68,
        exposureCategory: 'WHO Category II',
        urgency: 'WITHIN 48 HOURS',
        summary:
            'Moderate exposure pattern detected. WHO-aligned guidance usually recommends vaccine-based PEP.',
        firstAidSteps: const [
          'Wash wound thoroughly for at least 15 minutes.',
          'Use antiseptic after washing.',
          'Keep wound clean and covered with sterile dressing.',
        ],
        medicalTreatment: const [
          'Rabies vaccine (PEP) is generally recommended.',
          'RIG is not typically required unless upgraded by clinician findings.',
          'Check tetanus and infection prophylaxis needs.',
        ],
        riskFactors: [
          'Potential transdermal or scratch exposure.',
          'Animal observability/vaccination uncertainty may increase risk.',
        ],
        recommendations: const [
          'Visit a clinician promptly for rabies PEP decision.',
          'Do not wait for symptoms.',
          'Monitor wound for redness, swelling, fever, or pus.',
        ],
        pepRecommended: true,
        rigRecommended: false,
      );
    }

    if (isLowRiskAnimal && !isDeep && !isBleedingHeavy) {
      return AnimalBiteAssessmentResult(
        severityLabel: 'LOW RISK',
        riskScore: 18,
        exposureCategory: 'WHO Category I (likely)',
        urgency: 'ROUTINE MEDICAL REVIEW',
        summary:
            'Low-risk exposure pattern. WHO-aligned guidance usually does not indicate rabies PEP for Category I.',
        firstAidSteps: const [
          'Clean area with soap and water.',
          'Apply antiseptic and monitor wound.',
        ],
        medicalTreatment: const [
          'Rabies PEP usually not indicated for Category I exposure.',
          'Evaluate tetanus status and routine wound care.',
        ],
        riskFactors: const [
          'No strong severe-exposure signals detected.',
        ],
        recommendations: const [
          'Observe and seek care if symptoms worsen.',
          'Get routine wound review if unsure.',
        ],
        pepRecommended: false,
        rigRecommended: false,
      );
    }

    return AnimalBiteAssessmentResult(
      severityLabel: 'MODERATE',
      riskScore: 45,
      exposureCategory: 'Unclear / Needs Clinical Review',
      urgency: 'WITHIN 48-72 HOURS',
      summary:
          'Exposure pattern is unclear or mixed. A clinician should classify definitive WHO category.',
      firstAidSteps: const [
        'Wash wound with soap and water for at least 15 minutes.',
        'Apply antiseptic and keep the wound clean.',
      ],
      medicalTreatment: const [
        'Clinical review needed to decide PEP urgency.',
        'Tetanus and antibiotics may be needed depending on wound.',
      ],
      riskFactors: const [
        'Animal profile or exposure details are partially unclear.',
      ],
      recommendations: const [
        'Seek clinical assessment soon.',
        'If animal is unobservable or symptoms worsen, escalate urgently.',
      ],
      pepRecommended: isHighRiskAnimal || isUnknownAnimal || isWildOrUnobservable,
      rigRecommended: false,
    );
  }

  static String _whoCategory({
    required bool isDeep,
    required bool isBleedingHeavy,
    required bool isWildOrUnobservable,
    required bool isHighRiskAnimal,
    required bool isUnknownAnimal,
    required bool highRiskLocation,
  }) {
    if (isDeep || isBleedingHeavy || highRiskLocation) return 'III';
    if (isHighRiskAnimal || isUnknownAnimal || isWildOrUnobservable) return 'II';
    return 'I';
  }
}
