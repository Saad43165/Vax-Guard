import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/disease_assessment.dart';

class DiseaseAssessmentService {
  DiseaseAssessmentService._();

  static const List<DiseaseAssessmentDefinition> definitions = [
    DiseaseAssessmentDefinition(
      id: 'dengue',
      title: 'Dengue Check',
      subtitle: 'Fever with mosquito exposure',
      summary:
          'Screens for dengue warning signs using symptom severity and exposure history.',
      disclaimer:
          'This does not confirm dengue. Use it to identify warning signs and when to seek care.',
      guidance:
          'Helpful when you have fever, body aches, rash, or recent mosquito exposure.',
      icon: Icons.bug_report_rounded,
      accentColor: AppTheme.danger,
      gradient: AppTheme.dangerGradient,
      urgentFlags: [
        'Severe abdominal pain',
        'Bleeding, fainting, or repeated vomiting',
        'Unable to drink or worsening weakness',
      ],
      defaultActions: [
        'Drink oral fluids regularly unless a clinician told you otherwise.',
        'Avoid self-medicating with NSAIDs unless advised by a clinician.',
        'Track fever, urine output, and any new bleeding signs.',
      ],
      questions: [
        DiseaseAssessmentQuestion(
          id: 'fever_pattern',
          prompt: 'How strong is your fever or body pain?',
          helper: 'Pick the option closest to what you feel now.',
          options: [
            DiseaseAssessmentOption(
              label: 'None or very mild',
              score: 0,
              description: 'No significant fever or aches.',
            ),
            DiseaseAssessmentOption(
              label: 'Mild fever or aches',
              score: 20,
              description: 'Feels manageable at home.',
            ),
            DiseaseAssessmentOption(
              label: 'High fever and strong body pain',
              score: 50,
              description: 'Strong fatigue, headache, or severe body pain.',
            ),
            DiseaseAssessmentOption(
              label: 'Very ill or worsening quickly',
              score: 90,
              description: 'Severe symptoms or fast deterioration.',
            ),
          ],
        ),
        DiseaseAssessmentQuestion(
          id: 'warning_signs',
          prompt: 'Do you have warning signs like bleeding or persistent vomiting?',
          helper: 'These are signs that need urgent attention.',
          options: [
            DiseaseAssessmentOption(
              label: 'No warning signs',
              score: 0,
              description: 'No bleeding or persistent vomiting.',
            ),
            DiseaseAssessmentOption(
              label: 'One mild warning sign',
              score: 35,
              description: 'Some concerning symptoms but stable.',
            ),
            DiseaseAssessmentOption(
              label: 'Several warning signs',
              score: 70,
              description: 'Multiple warning signs are present.',
            ),
            DiseaseAssessmentOption(
              label: 'Bleeding, collapse, or severe vomiting',
              score: 100,
              description: 'Possible severe dengue.',
            ),
          ],
        ),
        DiseaseAssessmentQuestion(
          id: 'mosquito_exposure',
          prompt: 'Have you been in a mosquito-prone area recently?',
          helper: 'Recent exposure can matter in dengue-prone regions.',
          options: [
            DiseaseAssessmentOption(
              label: 'No or unlikely',
              score: 0,
              description: 'No meaningful exposure.',
            ),
            DiseaseAssessmentOption(
              label: 'Maybe',
              score: 15,
              description: 'Some exposure is possible.',
            ),
            DiseaseAssessmentOption(
              label: 'Yes, frequent exposure',
              score: 35,
              description: 'Common mosquito exposure recently.',
            ),
            DiseaseAssessmentOption(
              label: 'Known outbreak area',
              score: 50,
              description: 'Recent exposure in a high-risk location.',
            ),
          ],
        ),
        DiseaseAssessmentQuestion(
          id: 'hydration_state',
          prompt: 'How well are you drinking fluids?',
          helper: 'Dehydration can become dangerous quickly.',
          options: [
            DiseaseAssessmentOption(
              label: 'Drinking normally',
              score: 0,
              description: 'No trouble keeping fluids down.',
            ),
            DiseaseAssessmentOption(
              label: 'Slightly reduced intake',
              score: 15,
              description: 'A bit less than normal.',
            ),
            DiseaseAssessmentOption(
              label: 'Hard to drink enough',
              score: 40,
              description: 'Reduced urine or dizziness.',
            ),
            DiseaseAssessmentOption(
              label: 'Unable to keep fluids down',
              score: 90,
              description: 'Urgent dehydration risk.',
            ),
          ],
        ),
      ],
    ),
    DiseaseAssessmentDefinition(
      id: 'malaria',
      title: 'Malaria Check',
      subtitle: 'Fever, chills, and exposure review',
      summary:
          'Screens for malaria warning signs using fever patterns, exposure, and danger symptoms.',
      disclaimer:
          'This does not confirm malaria. Testing is needed if malaria is suspected.',
      guidance:
          'Useful after travel or residence in malaria-risk regions with fever or chills.',
      icon: Icons.public_rounded,
      accentColor: AppTheme.warning,
      gradient: AppTheme.cyanGradient,
      urgentFlags: [
        'Confusion, fainting, seizures, or severe weakness',
        'Difficulty breathing',
        'Pregnancy, child illness, or rapid worsening',
      ],
      defaultActions: [
        'Seek diagnostic testing if fever follows travel or risk exposure.',
        'Use mosquito protection and avoid delaying medical review.',
        'Watch for confusion, breathing trouble, or inability to drink.',
      ],
      questions: [
        DiseaseAssessmentQuestion(
          id: 'fever_chills',
          prompt: 'How strong are your fever, chills, or sweats?',
          helper: 'Malaria often causes fever with chills or sweats.',
          options: [
            DiseaseAssessmentOption(
              label: 'None',
              score: 0,
              description: 'No notable fever pattern.',
            ),
            DiseaseAssessmentOption(
              label: 'Mild symptoms',
              score: 20,
              description: 'Some fever or chills.',
            ),
            DiseaseAssessmentOption(
              label: 'Repeated fever with chills',
              score: 55,
              description: 'Clear fever/chills episodes.',
            ),
            DiseaseAssessmentOption(
              label: 'Severe fever or collapse',
              score: 95,
              description: 'Severe illness or weakness.',
            ),
          ],
        ),
        DiseaseAssessmentQuestion(
          id: 'exposure',
          prompt: 'What is your recent malaria exposure risk?',
          helper: 'Think about travel, residence, or mosquito exposure.',
          options: [
            DiseaseAssessmentOption(
              label: 'No known risk',
              score: 0,
              description: 'Little or no exposure.',
            ),
            DiseaseAssessmentOption(
              label: 'Possible risk',
              score: 20,
              description: 'Some recent exposure.',
            ),
            DiseaseAssessmentOption(
              label: 'Stayed in risk area',
              score: 45,
              description: 'Recent stay in a malaria-prone setting.',
            ),
            DiseaseAssessmentOption(
              label: 'High risk exposure',
              score: 65,
              description: 'Frequent exposure or known risk.',
            ),
          ],
        ),
        DiseaseAssessmentQuestion(
          id: 'danger_signs',
          prompt: 'Any danger signs like confusion or breathing trouble?',
          helper: 'These signs need urgent care.',
          options: [
            DiseaseAssessmentOption(
              label: 'None',
              score: 0,
              description: 'No severe warning signs.',
            ),
            DiseaseAssessmentOption(
              label: 'Some weakness or vomiting',
              score: 25,
              description: 'Moderate concern.',
            ),
            DiseaseAssessmentOption(
              label: 'Very weak or worsening',
              score: 70,
              description: 'Higher danger level.',
            ),
            DiseaseAssessmentOption(
              label: 'Confusion or breathing trouble',
              score: 100,
              description: 'Medical emergency warning.',
            ),
          ],
        ),
        DiseaseAssessmentQuestion(
          id: 'high_risk_person',
          prompt: 'Are you pregnant, a young child, or medically vulnerable?',
          helper: 'These groups need earlier evaluation.',
          options: [
            DiseaseAssessmentOption(
              label: 'No',
              score: 0,
              description: 'No special risk group.',
            ),
            DiseaseAssessmentOption(
              label: 'Maybe',
              score: 15,
              description: 'Some added risk.',
            ),
            DiseaseAssessmentOption(
              label: 'Yes',
              score: 35,
              description: 'Higher need for medical review.',
            ),
            DiseaseAssessmentOption(
              label: 'Yes and getting worse',
              score: 60,
              description: 'Urgent review recommended.',
            ),
          ],
        ),
      ],
    ),
    DiseaseAssessmentDefinition(
      id: 'typhoid',
      title: 'Typhoid Check',
      subtitle: 'Persistent fever and GI symptoms',
      summary:
          'Screens for typhoid-like illness patterns including sustained fever and food/water exposure.',
      disclaimer:
          'This does not confirm typhoid fever. Lab testing and clinician review are needed.',
      guidance:
          'Useful if you have ongoing fever with abdominal symptoms after food or water exposure.',
      icon: Icons.restaurant_menu_rounded,
      accentColor: AppTheme.secondary,
      gradient: AppTheme.primaryGradient,
      urgentFlags: [
        'Confusion, severe weakness, or persistent vomiting',
        'Blood in stool or severe dehydration',
        'Fever lasting several days with worsening abdominal pain',
      ],
      defaultActions: [
        'Seek medical review if fever persists for multiple days.',
        'Use safe fluids and avoid dehydration.',
        'Watch for confusion, severe abdominal pain, or blood in stool.',
      ],
      questions: [
        DiseaseAssessmentQuestion(
          id: 'persistent_fever',
          prompt: 'How long has your fever lasted?',
          helper: 'Typhoid often causes persistent fever.',
          options: [
            DiseaseAssessmentOption(
              label: 'No fever',
              score: 0,
              description: 'No sustained fever.',
            ),
            DiseaseAssessmentOption(
              label: '1 day or less',
              score: 10,
              description: 'Very short duration.',
            ),
            DiseaseAssessmentOption(
              label: '2 to 3 days',
              score: 35,
              description: 'Moderate duration.',
            ),
            DiseaseAssessmentOption(
              label: 'More than 3 days',
              score: 70,
              description: 'Persistent fever concern.',
            ),
          ],
        ),
        DiseaseAssessmentQuestion(
          id: 'gi_symptoms',
          prompt: 'How strong are your stomach or bowel symptoms?',
          helper: 'Consider abdominal pain, diarrhea, constipation, or nausea.',
          options: [
            DiseaseAssessmentOption(
              label: 'None',
              score: 0,
              description: 'No GI symptoms.',
            ),
            DiseaseAssessmentOption(
              label: 'Mild',
              score: 15,
              description: 'Some GI upset.',
            ),
            DiseaseAssessmentOption(
              label: 'Moderate',
              score: 40,
              description: 'Symptoms affecting eating or routine.',
            ),
            DiseaseAssessmentOption(
              label: 'Severe',
              score: 85,
              description: 'Severe pain or persistent vomiting/diarrhea.',
            ),
          ],
        ),
        DiseaseAssessmentQuestion(
          id: 'food_water_risk',
          prompt: 'Was there unsafe food or water exposure?',
          helper: 'Recent exposure increases concern.',
          options: [
            DiseaseAssessmentOption(
              label: 'No known exposure',
              score: 0,
              description: 'No likely source.',
            ),
            DiseaseAssessmentOption(
              label: 'Possible exposure',
              score: 15,
              description: 'Some uncertainty.',
            ),
            DiseaseAssessmentOption(
              label: 'Likely exposure',
              score: 35,
              description: 'Clear food/water risk.',
            ),
            DiseaseAssessmentOption(
              label: 'Outbreak or repeated exposure',
              score: 55,
              description: 'High-risk exposure context.',
            ),
          ],
        ),
        DiseaseAssessmentQuestion(
          id: 'red_flags',
          prompt: 'Any red flags like confusion, dehydration, or bleeding?',
          helper: 'These need urgent care.',
          options: [
            DiseaseAssessmentOption(
              label: 'No',
              score: 0,
              description: 'No danger signs.',
            ),
            DiseaseAssessmentOption(
              label: 'Some weakness',
              score: 20,
              description: 'Needs closer watching.',
            ),
            DiseaseAssessmentOption(
              label: 'Significant dehydration',
              score: 60,
              description: 'Possible urgent review needed.',
            ),
            DiseaseAssessmentOption(
              label: 'Confusion or bleeding',
              score: 100,
              description: 'Severe warning sign.',
            ),
          ],
        ),
      ],
    ),
    DiseaseAssessmentDefinition(
      id: 'respiratory',
      title: 'Respiratory Infection Check',
      subtitle: 'Flu, COVID-like, or severe breathing review',
      summary:
          'Screens for respiratory illness severity using cough, fever, exposure, and breathing danger signs.',
      disclaimer:
          'This does not confirm COVID-19, flu, pneumonia, or another infection.',
      guidance:
          'Use when you have cough, fever, throat symptoms, or shortness of breath.',
      icon: Icons.air_rounded,
      accentColor: AppTheme.primary,
      gradient: AppTheme.deepBlueGradient,
      urgentFlags: [
        'Shortness of breath at rest',
        'Chest pain, blue lips, or confusion',
        'Rapid worsening in a high-risk person',
      ],
      defaultActions: [
        'Rest, hydrate, and monitor breathing closely.',
        'Reduce exposure to others if illness may be infectious.',
        'Seek care early if symptoms worsen or you are high risk.',
      ],
      questions: [
        DiseaseAssessmentQuestion(
          id: 'breathing',
          prompt: 'How is your breathing right now?',
          helper: 'Breathing difficulty is the most important warning sign here.',
          options: [
            DiseaseAssessmentOption(
              label: 'Normal breathing',
              score: 0,
              description: 'No breathing trouble.',
            ),
            DiseaseAssessmentOption(
              label: 'A little harder than normal',
              score: 25,
              description: 'Mild shortness of breath.',
            ),
            DiseaseAssessmentOption(
              label: 'Breathless with activity',
              score: 55,
              description: 'Moderate concern.',
            ),
            DiseaseAssessmentOption(
              label: 'Breathless at rest or chest pain',
              score: 100,
              description: 'Emergency warning sign.',
            ),
          ],
        ),
        DiseaseAssessmentQuestion(
          id: 'fever_cough',
          prompt: 'How strong are your fever, cough, or sore throat symptoms?',
          helper: 'Think about how much they interfere with daily life.',
          options: [
            DiseaseAssessmentOption(
              label: 'None or mild',
              score: 5,
              description: 'Light symptoms only.',
            ),
            DiseaseAssessmentOption(
              label: 'Moderate',
              score: 25,
              description: 'Noticeable symptoms.',
            ),
            DiseaseAssessmentOption(
              label: 'High fever or strong cough',
              score: 50,
              description: 'Symptoms are significant.',
            ),
            DiseaseAssessmentOption(
              label: 'Severe and worsening',
              score: 75,
              description: 'Strong symptoms with decline.',
            ),
          ],
        ),
        DiseaseAssessmentQuestion(
          id: 'exposure_testing',
          prompt: 'What is your recent exposure or test situation?',
          helper: 'Recent contact or a positive test raises concern.',
          options: [
            DiseaseAssessmentOption(
              label: 'No known exposure',
              score: 0,
              description: 'No known infectious contact.',
            ),
            DiseaseAssessmentOption(
              label: 'Possible exposure',
              score: 15,
              description: 'Uncertain contact history.',
            ),
            DiseaseAssessmentOption(
              label: 'Confirmed exposure',
              score: 35,
              description: 'Known contact with illness.',
            ),
            DiseaseAssessmentOption(
              label: 'Positive test or multiple sick contacts',
              score: 55,
              description: 'Higher probability of infection.',
            ),
          ],
        ),
        DiseaseAssessmentQuestion(
          id: 'high_risk',
          prompt: 'Do you have a high-risk health factor?',
          helper: 'Examples: older age, asthma, heart disease, pregnancy, weak immunity.',
          options: [
            DiseaseAssessmentOption(
              label: 'No',
              score: 0,
              description: 'No known added risk.',
            ),
            DiseaseAssessmentOption(
              label: 'One mild risk factor',
              score: 15,
              description: 'Some added risk.',
            ),
            DiseaseAssessmentOption(
              label: 'Several risk factors',
              score: 35,
              description: 'Higher risk profile.',
            ),
            DiseaseAssessmentOption(
              label: 'Very high-risk profile',
              score: 55,
              description: 'Needs earlier review if sick.',
            ),
          ],
        ),
      ],
    ),
    DiseaseAssessmentDefinition(
      id: 'dehydration',
      title: 'Dehydration Check',
      subtitle: 'Fluid loss and danger sign review',
      summary:
          'Screens for dehydration risk from vomiting, diarrhea, heat illness, or poor intake.',
      disclaimer:
          'This is a screening tool, not a diagnosis. Severe dehydration needs urgent care.',
      guidance:
          'Helpful during diarrhea, vomiting, heat exposure, weakness, or reduced urine.',
      icon: Icons.water_drop_rounded,
      accentColor: AppTheme.success,
      gradient: AppTheme.successGradient,
      urgentFlags: [
        'Unable to drink or keep fluids down',
        'Very little urine, confusion, or fainting',
        'Infant, elderly person, or rapid worsening',
      ],
      defaultActions: [
        'Increase oral fluids in small frequent amounts if tolerated.',
        'Use oral rehydration solution when available.',
        'Seek urgent care if urine drops, confusion develops, or vomiting persists.',
      ],
      questions: [
        DiseaseAssessmentQuestion(
          id: 'fluid_loss',
          prompt: 'How much fluid loss do you have?',
          helper: 'Think about vomiting, diarrhea, sweating, or fever.',
          options: [
            DiseaseAssessmentOption(
              label: 'None',
              score: 0,
              description: 'No meaningful fluid loss.',
            ),
            DiseaseAssessmentOption(
              label: 'Mild',
              score: 15,
              description: 'Limited fluid loss.',
            ),
            DiseaseAssessmentOption(
              label: 'Moderate',
              score: 45,
              description: 'Noticeable and ongoing.',
            ),
            DiseaseAssessmentOption(
              label: 'Heavy or continuous',
              score: 85,
              description: 'High fluid-loss concern.',
            ),
          ],
        ),
        DiseaseAssessmentQuestion(
          id: 'drinking',
          prompt: 'Can you keep fluids down?',
          helper: 'Keeping fluids down matters more than just feeling thirsty.',
          options: [
            DiseaseAssessmentOption(
              label: 'Yes, easily',
              score: 0,
              description: 'Normal drinking.',
            ),
            DiseaseAssessmentOption(
              label: 'Some difficulty',
              score: 20,
              description: 'Less intake than normal.',
            ),
            DiseaseAssessmentOption(
              label: 'Hard to keep enough down',
              score: 50,
              description: 'Fluid intake is not adequate.',
            ),
            DiseaseAssessmentOption(
              label: 'Cannot keep fluids down',
              score: 100,
              description: 'Urgent dehydration risk.',
            ),
          ],
        ),
        DiseaseAssessmentQuestion(
          id: 'dehydration_signs',
          prompt: 'Do you have dry mouth, dizziness, or reduced urine?',
          helper: 'These are common dehydration signs.',
          options: [
            DiseaseAssessmentOption(
              label: 'No',
              score: 0,
              description: 'No clear signs.',
            ),
            DiseaseAssessmentOption(
              label: 'Mild signs',
              score: 20,
              description: 'Some thirst or mild dizziness.',
            ),
            DiseaseAssessmentOption(
              label: 'Clear dehydration signs',
              score: 55,
              description: 'Reduced urine or more dizziness.',
            ),
            DiseaseAssessmentOption(
              label: 'Severe weakness or fainting',
              score: 95,
              description: 'Danger sign present.',
            ),
          ],
        ),
        DiseaseAssessmentQuestion(
          id: 'high_risk_person',
          prompt: 'Is the sick person very young, elderly, or medically fragile?',
          helper: 'These groups can dehydrate faster.',
          options: [
            DiseaseAssessmentOption(
              label: 'No',
              score: 0,
              description: 'Standard risk.',
            ),
            DiseaseAssessmentOption(
              label: 'Maybe',
              score: 10,
              description: 'Some increased concern.',
            ),
            DiseaseAssessmentOption(
              label: 'Yes',
              score: 30,
              description: 'Higher vulnerability.',
            ),
            DiseaseAssessmentOption(
              label: 'Yes and getting worse',
              score: 60,
              description: 'Needs prompt attention.',
            ),
          ],
        ),
      ],
    ),
  ];

  static DiseaseAssessmentDefinition getDefinition(String id) {
    return definitions.firstWhere(
      (definition) => definition.id == id,
      orElse: () => definitions.first,
    );
  }

  static DiseaseAssessmentDefinition? tryGetDefinition(String id) {
    for (final definition in definitions) {
      if (definition.id == id) return definition;
    }
    return null;
  }

  static DiseaseAssessmentResult evaluate({
    required DiseaseAssessmentDefinition definition,
    required Map<String, int> answers,
  }) {
    if (answers.length < definition.questions.length) {
      return const DiseaseAssessmentResult(
        level: 'Insufficient Input',
        score: 0,
        headline: 'Complete all questions',
        summary:
            'Some answers are missing, so this disease check cannot provide a reliable result yet.',
        nextStep:
            'Answer all questions and run the check again for a complete assessment.',
        actions: [
          'Complete every question in this assessment.',
          'Seek direct medical care if severe symptoms are present.',
        ],
        matchedConcerns: [],
      );
    }

    var totalScore = 0;
    final matchedConcerns = <String>[];

    for (final question in definition.questions) {
      final optionIndex = answers[question.id];
      if (optionIndex == null ||
          optionIndex < 0 ||
          optionIndex >= question.options.length) {
        continue;
      }

      final option = question.options[optionIndex];
      totalScore += option.score;
      if (option.score >= 50) {
        matchedConcerns.add('${question.prompt}: ${option.label}');
      }
    }

    final maxScore = definition.questions.length * 100;
    final normalizedScore = maxScore == 0
        ? 0
        : ((totalScore / maxScore) * 100).round().clamp(0, 100);

    if (normalizedScore >= 75) {
      return DiseaseAssessmentResult(
        level: 'Urgent',
        score: normalizedScore,
        headline: 'Urgent medical review recommended',
        summary:
            'Your answers show important warning signs for ${definition.title.toLowerCase()}.',
        nextStep:
            'Seek urgent medical care now, especially if symptoms are worsening or you have any red flags.',
        actions: [
          'Arrange urgent medical evaluation today.',
          'Do not ignore severe warning signs such as fainting, breathing trouble, or confusion.',
          ...definition.defaultActions,
        ],
        matchedConcerns: matchedConcerns,
      );
    }

    if (normalizedScore >= 50) {
      return DiseaseAssessmentResult(
        level: 'High',
        score: normalizedScore,
        headline: 'High concern',
        summary:
            'Your answers suggest that ${definition.title.toLowerCase()} should be assessed by a clinician soon.',
        nextStep:
            'Book medical care soon and escalate faster if symptoms worsen.',
        actions: [
          'Contact a healthcare provider promptly.',
          'Monitor symptoms closely over the next few hours.',
          ...definition.defaultActions,
        ],
        matchedConcerns: matchedConcerns,
      );
    }

    if (normalizedScore >= 25) {
      return DiseaseAssessmentResult(
        level: 'Moderate',
        score: normalizedScore,
        headline: 'Monitor closely',
        summary:
            'There are some concerning features that may need follow-up if they persist or worsen.',
        nextStep:
            'Continue self-care, but seek medical advice if new warning signs appear.',
        actions: [
          'Rest and monitor symptoms carefully.',
          'Use supportive care and hydration as appropriate.',
          ...definition.defaultActions,
        ],
        matchedConcerns: matchedConcerns,
      );
    }

    return DiseaseAssessmentResult(
      level: 'Low',
      score: normalizedScore,
      headline: 'Low current concern',
      summary:
          'Your current answers do not show many warning signs, but continue to monitor symptoms.',
      nextStep:
          'Use routine self-care and repeat the check if symptoms change.',
      actions: [
        'Continue monitoring at home.',
        'Use safe fluids, rest, and supportive care.',
        ...definition.defaultActions,
      ],
      matchedConcerns: matchedConcerns,
    );
  }
}
