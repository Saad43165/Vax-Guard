import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/disease_assessment.dart';

class DiseaseAssessmentService {
  DiseaseAssessmentService._();

  static final List<DiseaseAssessmentDefinition> definitions = [
    DiseaseAssessmentDefinition(
      id: 'hantavirus',
      title: 'hantavirus_title',
      subtitle: 'hantavirus_subtitle',
      summary: 'hantavirus_desc',
      disclaimer: 'hantavirus_disclaimer',
      guidance: 'hantavirus_guidance',
      icon: Icons.pets_rounded,
      accentColor: AppTheme.danger,
      gradient: AppTheme.dangerGradient,
      urgentFlags: [
        'severe_breathlessness',
        'body_aches',
        'confirmed_exposure',
      ],
      defaultActions: [
        'contact_doctor_imm',
        'monitor_symptoms',
        'avoid_vulnerable',
      ],
      questions: [
        DiseaseAssessmentQuestion(
          id: 'exposure',
          prompt: 'Recent rodent exposure history?',
          helper: 'Have you cleaned or stayed in rodent-infested areas (sheds, barns, cabins)?',
          options: [
            DiseaseAssessmentOption(
              label: 'No exposure',
              score: 0,
              description: 'No known contact with rodents or droppings.',
            ),
            DiseaseAssessmentOption(
              label: 'Possible exposure',
              score: 25,
              description: 'Stayed in a rural or dusty area recently.',
            ),
            DiseaseAssessmentOption(
              label: 'Known exposure',
              score: 60,
              description: 'Cleaned a space with visible rodent droppings.',
            ),
            DiseaseAssessmentOption(
              label: 'Direct contact',
              score: 90,
              description: 'Handled rodents or their waste directly.',
            ),
          ],
        ),
        DiseaseAssessmentQuestion(
          id: 'lung_symptoms',
          prompt: 'Any breathing difficulties?',
          helper: 'Hantavirus often targets the lungs (HPS).',
          options: [
            DiseaseAssessmentOption(
              label: 'Normal breathing',
              score: 0,
              description: 'No respiratory issues.',
            ),
            DiseaseAssessmentOption(
              label: 'Mild cough',
              score: 20,
              description: 'Occasional dry cough.',
            ),
            DiseaseAssessmentOption(
              label: 'Shortness of breath',
              score: 70,
              description: 'Harder to breathe during activity.',
            ),
            DiseaseAssessmentOption(
              label: 'Severe breathlessness',
              score: 100,
              description: 'Struggling to breathe even at rest.',
            ),
          ],
        ),
      ],
    ),
    DiseaseAssessmentDefinition(
      id: 'dengue',
      title: 'dengue_title',
      subtitle: 'dengue_subtitle',
      summary: 'dengue_desc',
      disclaimer: 'dengue_disclaimer',
      guidance: 'dengue_guidance',
      icon: Icons.bug_report_rounded,
      accentColor: AppTheme.danger,
      gradient: AppTheme.dangerGradient,
      urgentFlags: [
        'abdominal_pain_severe',
        'bleeding_signs',
        'nausea_vomiting',
      ],
      defaultActions: [
        'rest_hydration',
        'monitor_symptoms',
        'avoid_vulnerable',
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
          dependsOnQuestionId: 'warning_signs',
          minScoreDependency: 30,
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
      title: 'malaria_title',
      subtitle: 'malaria_subtitle',
      summary: 'malaria_desc',
      disclaimer: 'malaria_disclaimer',
      guidance: 'malaria_guidance',
      icon: Icons.public_rounded,
      accentColor: AppTheme.warning,
      gradient: AppTheme.cyanGradient,
      urgentFlags: [
        'confusion_warning',
        'severe_breathlessness',
        'high_fever',
      ],
      defaultActions: [
        'urgent_care_visit',
        'monitor_symptoms',
        'stay_uptodate_vax',
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
      title: 'typhoid_title',
      subtitle: 'typhoid_subtitle',
      summary: 'typhoid_desc',
      disclaimer: 'typhoid_disclaimer',
      guidance: 'typhoid_guidance',
      icon: Icons.restaurant_menu_rounded,
      accentColor: AppTheme.secondary,
      gradient: AppTheme.primaryGradient,
      urgentFlags: [
        'confusion_warning',
        'bleeding_signs',
        'abdominal_pain_severe',
      ],
      defaultActions: [
        'schedule_doctor',
        'rest_hydration',
        'monitor_symptoms',
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
      title: 'respiratory_title',
      subtitle: 'respiratory_subtitle',
      summary: 'respiratory_desc',
      disclaimer: 'respiratory_disclaimer',
      guidance: 'respiratory_guidance',
      icon: Icons.air_rounded,
      accentColor: AppTheme.primary,
      gradient: AppTheme.deepBlueGradient,
      urgentFlags: [
        'severe_breathlessness',
        'confusion_warning',
        'high_fever',
      ],
      defaultActions: [
        'rest_hydration',
        'isolate_others',
        'monitor_symptoms',
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
      title: 'dehydration_title',
      subtitle: 'dehydration_subtitle',
      summary: 'dehydration_desc',
      disclaimer: 'dehydration_disclaimer',
      guidance: 'dehydration_guidance',
      icon: Icons.water_drop_rounded,
      accentColor: AppTheme.success,
      gradient: AppTheme.successGradient,
      urgentFlags: [
        'nausea_vomiting',
        'low_urine_output',
        'confusion_warning',
      ],
      defaultActions: [
        'rest_hydration',
        'monitor_symptoms',
        'urgent_care_visit',
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
    DiseaseAssessmentDefinition(
      id: 'cholera',
      title: 'cholera_title',
      subtitle: 'cholera_subtitle',
      summary: 'cholera_desc',
      disclaimer: 'cholera_disclaimer',
      guidance: 'cholera_guidance',
      icon: Icons.water_rounded,
      accentColor: AppTheme.warning,
      gradient: AppTheme.orangeGradient,
      urgentFlags: [
        'severe_symptoms',
        'low_urine_output',
        'nausea_vomiting',
      ],
      defaultActions: [
        'rest_hydration',
        'urgent_care_visit',
        'isolate_others',
      ],
      questions: [
        DiseaseAssessmentQuestion(
          id: 'stool_pattern',
          prompt: 'What is your stool pattern like?',
          helper: 'Cholera often causes sudden, profuse, watery diarrhea.',
          options: [
            DiseaseAssessmentOption(
              label: 'Normal stools',
              score: 0,
              description: 'No diarrhea.',
            ),
            DiseaseAssessmentOption(
              label: 'Loose stools',
              score: 20,
              description: 'Some diarrhea but not severe.',
            ),
            DiseaseAssessmentOption(
              label: 'Frequent watery stools',
              score: 60,
              description: 'Clear watery diarrhea several times.',
            ),
            DiseaseAssessmentOption(
              label: 'Profuse rice-water stools',
              score: 100,
              description: 'Very severe, continuous watery diarrhea.',
            ),
          ],
        ),
        DiseaseAssessmentQuestion(
          id: 'vomiting',
          prompt: 'Are you vomiting?',
          helper: 'Vomiting with diarrhea increases dehydration risk quickly.',
          options: [
            DiseaseAssessmentOption(
              label: 'No vomiting',
              score: 0,
              description: 'Able to keep things down.',
            ),
            DiseaseAssessmentOption(
              label: 'Mild nausea or once',
              score: 15,
              description: 'Minimal vomiting.',
            ),
            DiseaseAssessmentOption(
              label: 'Repeated vomiting',
              score: 50,
              description: 'Struggling to keep fluids down.',
            ),
            DiseaseAssessmentOption(
              label: 'Constant vomiting',
              score: 90,
              description: 'Cannot retain any fluids.',
            ),
          ],
        ),
        DiseaseAssessmentQuestion(
          id: 'dehydration_level',
          prompt: 'Do you show signs of dehydration?',
          helper: 'Think about thirst, dry mouth, reduced urine, or dizziness.',
          options: [
            DiseaseAssessmentOption(
              label: 'No signs',
              score: 0,
              description: 'Hydration seems adequate.',
            ),
            DiseaseAssessmentOption(
              label: 'Mild thirst',
              score: 20,
              description: 'Some dehydration signs.',
            ),
            DiseaseAssessmentOption(
              label: 'Dry mouth and less urine',
              score: 55,
              description: 'Moderate dehydration.',
            ),
            DiseaseAssessmentOption(
              label: 'Severe dehydration signs',
              score: 95,
              description: 'Sunken eyes, very little urine, fainting.',
            ),
          ],
        ),
        DiseaseAssessmentQuestion(
          id: 'exposure_risk',
          prompt: 'Any recent exposure risk?',
          helper: 'Recent unsafe water, outbreak area, or contact with a case.',
          options: [
            DiseaseAssessmentOption(
              label: 'No known risk',
              score: 0,
              description: 'No exposure concerns.',
            ),
            DiseaseAssessmentOption(
              label: 'Possible unsafe water',
              score: 20,
              description: 'Some risk factor.',
            ),
            DiseaseAssessmentOption(
              label: 'Known outbreak area',
              score: 45,
              description: 'Active cholera risk context.',
            ),
            DiseaseAssessmentOption(
              label: 'Confirmed contact or outbreak',
              score: 65,
              description: 'High probability exposure.',
            ),
          ],
        ),
      ],
    ),
    DiseaseAssessmentDefinition(
      id: 'hepatitis',
      title: 'Hepatitis Check',
      subtitle: 'Jaundice, fatigue, and liver-related symptoms',
      summary:
          'Screens for hepatitis warning signs including jaundice, dark urine, fatigue, and abdominal discomfort.',
      disclaimer:
          'This does not confirm hepatitis. Blood tests are required for diagnosis.',
      guidance:
          'Useful if you notice yellowing eyes or skin, dark urine, or prolonged fatigue.',
      icon: Icons.biotech_rounded,
      accentColor: AppTheme.warning,
      gradient: AppTheme.orangeGradient,
      urgentFlags: [
        'Confusion or extreme sleepiness',
        'Severe abdominal swelling or vomiting blood',
        'Deep jaundice with rapidly worsening condition',
      ],
      defaultActions: [
        'Avoid alcohol and hepatotoxic medications until reviewed.',
        'Seek blood tests for liver function and viral markers.',
        'Rest and maintain hydration while awaiting care.',
      ],
      questions: [
        DiseaseAssessmentQuestion(
          id: 'jaundice',
          prompt: 'Have you noticed yellowing of eyes or skin?',
          helper: 'Jaundice is a key sign of liver involvement.',
          options: [
            DiseaseAssessmentOption(
              label: 'No yellowing',
              score: 0,
              description: 'No visible jaundice.',
            ),
            DiseaseAssessmentOption(
              label: 'Slight yellowing',
              score: 30,
              description: 'Mild discoloration noticed.',
            ),
            DiseaseAssessmentOption(
              label: 'Clear yellowing',
              score: 65,
              description: 'Obvious jaundice in eyes or skin.',
            ),
            DiseaseAssessmentOption(
              label: 'Deep jaundice',
              score: 95,
              description: 'Severe yellowing with worsening.',
            ),
          ],
        ),
        DiseaseAssessmentQuestion(
          id: 'urine_stool',
          prompt: 'Any dark urine or pale stools?',
          helper: 'These changes suggest bile flow problems.',
          options: [
            DiseaseAssessmentOption(
              label: 'Normal',
              score: 0,
              description: 'No color changes.',
            ),
            DiseaseAssessmentOption(
              label: 'Slightly dark urine',
              score: 20,
              description: 'Minor change.',
            ),
            DiseaseAssessmentOption(
              label: 'Dark urine or pale stools',
              score: 55,
              description: 'Clear abnormal color.',
            ),
            DiseaseAssessmentOption(
              label: 'Very dark urine and pale stools',
              score: 85,
              description: 'Significant bile obstruction signs.',
            ),
          ],
        ),
        DiseaseAssessmentQuestion(
          id: 'fatigue_appetite',
          prompt: 'How is your energy and appetite?',
          helper: 'Hepatitis often causes prolonged fatigue and poor appetite.',
          options: [
            DiseaseAssessmentOption(
              label: 'Normal',
              score: 0,
              description: 'Usual energy and appetite.',
            ),
            DiseaseAssessmentOption(
              label: 'Slightly reduced',
              score: 15,
              description: 'A bit more tired than usual.',
            ),
            DiseaseAssessmentOption(
              label: 'Markedly reduced',
              score: 45,
              description: 'Significant fatigue and poor appetite.',
            ),
            DiseaseAssessmentOption(
              label: 'Severe fatigue or unable to eat',
              score: 75,
              description: 'Profound weakness and appetite loss.',
            ),
          ],
        ),
        DiseaseAssessmentQuestion(
          id: 'pain_nausea',
          prompt: 'Any abdominal pain, nausea, or fever?',
          helper: 'Right upper abdominal pain and nausea are common.',
          options: [
            DiseaseAssessmentOption(
              label: 'None',
              score: 0,
              description: 'No abdominal symptoms.',
            ),
            DiseaseAssessmentOption(
              label: 'Mild discomfort',
              score: 15,
              description: 'Some mild symptoms.',
            ),
            DiseaseAssessmentOption(
              label: 'Moderate pain or nausea',
              score: 40,
              description: 'Noticeable abdominal symptoms.',
            ),
            DiseaseAssessmentOption(
              label: 'Severe pain or persistent vomiting',
              score: 80,
              description: 'Serious abdominal warning signs.',
            ),
          ],
        ),
      ],
    ),
    DiseaseAssessmentDefinition(
      id: 'tuberculosis',
      title: 'Tuberculosis Check',
      subtitle: 'Persistent cough and systemic symptoms',
      summary:
          'Screens for TB warning signs using cough duration, night sweats, weight loss, and hemoptysis.',
      disclaimer:
          'This does not confirm TB. Sputum testing and chest imaging are needed.',
      guidance:
          'Useful if you have a cough lasting weeks, night sweats, or unexplained weight loss.',
      icon: Icons.coronavirus_rounded,
      accentColor: AppTheme.purple,
      gradient: AppTheme.purpleGradient,
      urgentFlags: [
        'Coughing up blood',
        'Severe shortness of breath or chest pain',
        'High fever with rapid deterioration',
      ],
      defaultActions: [
        'Seek sputum testing and chest X-ray if cough persists.',
        'Cover coughs and avoid close contact until evaluated.',
        'Monitor temperature and weight changes.',
      ],
      questions: [
        DiseaseAssessmentQuestion(
          id: 'cough_duration',
          prompt: 'How long have you had a cough?',
          helper: 'TB typically causes a cough lasting more than 2-3 weeks.',
          options: [
            DiseaseAssessmentOption(
              label: 'No cough',
              score: 0,
              description: 'No significant cough.',
            ),
            DiseaseAssessmentOption(
              label: 'Less than 2 weeks',
              score: 15,
              description: 'Short-term cough.',
            ),
            DiseaseAssessmentOption(
              label: '2 to 3 weeks',
              score: 45,
              description: 'Prolonged cough.',
            ),
            DiseaseAssessmentOption(
              label: 'More than 3 weeks',
              score: 80,
              description: 'Chronic cough concern.',
            ),
          ],
        ),
        DiseaseAssessmentQuestion(
          id: 'night_sweats',
          prompt: 'Do you have night sweats or low-grade fever?',
          helper: 'TB often causes drenching night sweats and evening fever.',
          options: [
            DiseaseAssessmentOption(
              label: 'None',
              score: 0,
              description: 'No night sweats or fever.',
            ),
            DiseaseAssessmentOption(
              label: 'Occasional',
              score: 20,
              description: 'Rare episodes.',
            ),
            DiseaseAssessmentOption(
              label: 'Regular night sweats or fever',
              score: 55,
              description: 'Frequent systemic symptoms.',
            ),
            DiseaseAssessmentOption(
              label: 'Severe drenching sweats or high fever',
              score: 85,
              description: 'Significant TB warning signs.',
            ),
          ],
        ),
        DiseaseAssessmentQuestion(
          id: 'weight_loss',
          prompt: 'Any unexplained weight loss?',
          helper: 'Unintentional weight loss is a classic TB sign.',
          options: [
            DiseaseAssessmentOption(
              label: 'No weight loss',
              score: 0,
              description: 'Weight stable.',
            ),
            DiseaseAssessmentOption(
              label: 'Slight loss',
              score: 20,
              description: 'A few kilograms lost.',
            ),
            DiseaseAssessmentOption(
              label: 'Noticeable loss',
              score: 50,
              description: 'Clear unintentional weight loss.',
            ),
            DiseaseAssessmentOption(
              label: 'Severe loss',
              score: 75,
              description: 'Dramatic weight decline.',
            ),
          ],
        ),
        DiseaseAssessmentQuestion(
          id: 'hemoptysis',
          prompt: 'Any blood in sputum or severe chest symptoms?',
          helper: 'Coughing blood needs urgent evaluation.',
          options: [
            DiseaseAssessmentOption(
              label: 'None',
              score: 0,
              description: 'No blood in sputum.',
            ),
            DiseaseAssessmentOption(
              label: 'Chest tightness only',
              score: 20,
              description: 'Mild chest symptoms.',
            ),
            DiseaseAssessmentOption(
              label: 'Blood-streaked sputum',
              score: 70,
              description: 'Hemoptysis present.',
            ),
            DiseaseAssessmentOption(
              label: 'Significant blood or severe pain',
              score: 100,
              description: 'Urgent warning sign.',
            ),
          ],
        ),
      ],
    ),
    DiseaseAssessmentDefinition(
      id: 'measles',
      title: 'Measles Check',
      subtitle: 'Fever, rash, and respiratory symptoms',
      summary:
          'Screens for measles-like illness using fever, rash pattern, cough, and known exposure.',
      disclaimer:
          'This does not confirm measles. Laboratory confirmation may be needed.',
      guidance:
          'Useful if you have fever with rash, cough, red eyes, or known measles exposure.',
      icon: Icons.sentiment_very_dissatisfied_rounded,
      accentColor: AppTheme.danger,
      gradient: AppTheme.dangerGradient,
      urgentFlags: [
        'Severe breathing difficulty',
        'Confusion, seizures, or extreme lethargy',
        'Dehydration or inability to drink',
      ],
      defaultActions: [
        'Isolate and avoid contact with unvaccinated individuals.',
        'Seek medical review and notify public health if suspected.',
        'Use supportive care: fluids, rest, and fever control.',
      ],
      questions: [
        DiseaseAssessmentQuestion(
          id: 'fever_rash',
          prompt: 'Do you have fever with a rash?',
          helper: 'Measles typically starts with high fever followed by a body rash.',
          options: [
            DiseaseAssessmentOption(
              label: 'No fever or rash',
              score: 0,
              description: 'Neither symptom present.',
            ),
            DiseaseAssessmentOption(
              label: 'Fever only',
              score: 20,
              description: 'Fever without rash so far.',
            ),
            DiseaseAssessmentOption(
              label: 'Fever with mild rash',
              score: 60,
              description: 'Both symptoms present.',
            ),
            DiseaseAssessmentOption(
              label: 'High fever with spreading rash',
              score: 95,
              description: 'Classic measles pattern.',
            ),
          ],
        ),
        DiseaseAssessmentQuestion(
          id: 'respiratory_eye',
          prompt: 'Any cough, runny nose, or red eyes?',
          helper: 'Measles causes cough, coryza, and conjunctivitis.',
          options: [
            DiseaseAssessmentOption(
              label: 'None',
              score: 0,
              description: 'No respiratory or eye symptoms.',
            ),
            DiseaseAssessmentOption(
              label: 'Mild cold-like symptoms',
              score: 15,
              description: 'Slight respiratory symptoms.',
            ),
            DiseaseAssessmentOption(
              label: 'Clear cough and red eyes',
              score: 50,
              description: 'Prominent respiratory and eye signs.',
            ),
            DiseaseAssessmentOption(
              label: 'Severe cough or eye discharge',
              score: 80,
              description: 'Strong measles-like presentation.',
            ),
          ],
        ),
        DiseaseAssessmentQuestion(
          id: 'measles_exposure',
          prompt: 'Any known measles exposure or unvaccinated status?',
          helper: 'Recent contact with a measles case raises concern.',
          options: [
            DiseaseAssessmentOption(
              label: 'No exposure and vaccinated',
              score: 0,
              description: 'Low risk.',
            ),
            DiseaseAssessmentOption(
              label: 'Unsure or unsure vaccine status',
              score: 20,
              description: 'Some uncertainty.',
            ),
            DiseaseAssessmentOption(
              label: 'Known exposure or not vaccinated',
              score: 50,
              description: 'Higher risk context.',
            ),
            DiseaseAssessmentOption(
              label: 'Direct contact with confirmed case',
              score: 70,
              description: 'High probability exposure.',
            ),
          ],
        ),
        DiseaseAssessmentQuestion(
          id: ' Koplik_or_worsening',
          prompt: 'Any mouth spots or rapidly worsening condition?',
          helper: 'Koplik spots inside the cheek are an early measles sign.',
          options: [
            DiseaseAssessmentOption(
              label: 'No',
              score: 0,
              description: 'No mouth spots or rapid decline.',
            ),
            DiseaseAssessmentOption(
              label: 'Mild mouth irritation',
              score: 20,
              description: 'Some oral symptoms.',
            ),
            DiseaseAssessmentOption(
              label: 'Small white mouth spots',
              score: 60,
              description: 'Possible Koplik spots.',
            ),
            DiseaseAssessmentOption(
              label: 'Rapidly worsening or very ill',
              score: 90,
              description: 'Severe deterioration.',
            ),
          ],
        ),
      ],
    ),
    DiseaseAssessmentDefinition(
      id: 'covid19',
      title: 'COVID-19 Check',
      subtitle: 'Respiratory and systemic symptom review',
      summary:
          'Screens for COVID-19 likelihood using fever, cough, loss of taste or smell, and exposure history.',
      disclaimer:
          'This does not confirm COVID-19. Testing is needed for diagnosis.',
      guidance:
          'Useful when you have respiratory symptoms, fever, or known exposure to COVID-19.',
      icon: Icons.masks_rounded,
      accentColor: AppTheme.primary,
      gradient: AppTheme.primaryGradient,
      urgentFlags: [
        'Difficulty breathing or chest pain',
        'Confusion, inability to stay awake',
        'Bluish lips or face, very low oxygen feeling',
      ],
      defaultActions: [
        'Isolate and reduce contact with others.',
        'Seek testing if symptoms or exposure are present.',
        'Monitor breathing and seek care if it worsens.',
      ],
      questions: [
        DiseaseAssessmentQuestion(
          id: 'fever_systemic',
          prompt: 'Do you have fever, chills, or body aches?',
          helper: 'COVID-19 often presents with fever and muscle aches.',
          options: [
            DiseaseAssessmentOption(
              label: 'None',
              score: 0,
              description: 'No systemic symptoms.',
            ),
            DiseaseAssessmentOption(
              label: 'Mild',
              score: 20,
              description: 'Slight fever or mild aches.',
            ),
            DiseaseAssessmentOption(
              label: 'Moderate fever and aches',
              score: 50,
              description: 'Clear systemic symptoms.',
            ),
            DiseaseAssessmentOption(
              label: 'High fever or severe aches',
              score: 80,
              description: 'Strong systemic illness.',
            ),
          ],
        ),
        DiseaseAssessmentQuestion(
          id: 'respiratory_symptoms',
          prompt: 'How strong are your cough, sore throat, or breathing symptoms?',
          helper: 'Respiratory symptoms are central to COVID-19.',
          options: [
            DiseaseAssessmentOption(
              label: 'None',
              score: 0,
              description: 'No respiratory symptoms.',
            ),
            DiseaseAssessmentOption(
              label: 'Mild',
              score: 15,
              description: 'Slight cough or sore throat.',
            ),
            DiseaseAssessmentOption(
              label: 'Moderate cough or breathlessness',
              score: 50,
              description: 'Noticeable respiratory symptoms.',
            ),
            DiseaseAssessmentOption(
              label: 'Severe breathing difficulty',
              score: 100,
              description: 'Emergency respiratory warning.',
            ),
          ],
        ),
        DiseaseAssessmentQuestion(
          id: 'taste_smell',
          prompt: 'Any loss of taste or smell?',
          helper: 'Loss of taste or smell is a characteristic COVID-19 sign.',
          options: [
            DiseaseAssessmentOption(
              label: 'No loss',
              score: 0,
              description: 'Taste and smell normal.',
            ),
            DiseaseAssessmentOption(
              label: 'Slightly reduced',
              score: 25,
              description: 'Minor change.',
            ),
            DiseaseAssessmentOption(
              label: 'Noticeably reduced',
              score: 60,
              description: 'Clear loss of taste or smell.',
            ),
            DiseaseAssessmentOption(
              label: 'Complete loss',
              score: 85,
              description: 'Total anosmia or ageusia.',
            ),
          ],
        ),
        DiseaseAssessmentQuestion(
          id: 'covid_exposure',
          prompt: 'Any recent COVID-19 exposure or positive contact?',
          helper: 'Recent contact with a confirmed case raises likelihood.',
          options: [
            DiseaseAssessmentOption(
              label: 'No known exposure',
              score: 0,
              description: 'No contact history.',
            ),
            DiseaseAssessmentOption(
              label: 'Possible exposure',
              score: 15,
              description: 'Uncertain contact.',
            ),
            DiseaseAssessmentOption(
              label: 'Known exposure',
              score: 40,
              description: 'Close contact with a case.',
            ),
            DiseaseAssessmentOption(
              label: 'Confirmed contact or outbreak',
              score: 60,
              description: 'High-risk exposure context.',
            ),
          ],
        ),
      ],
    ),
    DiseaseAssessmentDefinition(
      id: 'meningitis',
      title: 'Meningitis Check',
      subtitle: 'Severe headache, neck stiffness, and fever',
      summary:
          'Screens for meningitis warning signs using neck stiffness, severe headache, fever, and altered mental status.',
      disclaimer:
          'This does not confirm meningitis. Lumbar puncture and clinician review are needed.',
      guidance:
          'Useful if you have severe headache with fever, neck stiffness, or confusion.',
      icon: Icons.psychology_rounded,
      accentColor: AppTheme.primary,
      gradient: AppTheme.deepBlueGradient,
      urgentFlags: [
        'Severe headache with stiff neck and fever',
        'Confusion, altered behavior, or seizures',
        'Rash that does not fade when pressed (petechiae)',
      ],
      defaultActions: [
        'Seek emergency medical care immediately if suspected.',
        'Do not delay evaluation — meningitis can progress rapidly.',
        'Note when symptoms began and any recent infections.',
      ],
      questions: [
        DiseaseAssessmentQuestion(
          id: 'neck_stiffness',
          prompt: 'Can you bend your neck forward comfortably?',
          helper: 'Neck stiffness is a classic sign of meningitis.',
          options: [
            DiseaseAssessmentOption(
              label: 'Yes, fully flexible',
              score: 0,
              description: 'No neck stiffness.',
            ),
            DiseaseAssessmentOption(
              label: 'Slightly stiff',
              score: 30,
              description: 'Minor discomfort bending neck.',
            ),
            DiseaseAssessmentOption(
              label: 'Clearly stiff and painful',
              score: 75,
              description: 'Significant neck rigidity.',
            ),
            DiseaseAssessmentOption(
              label: 'Cannot bend neck',
              score: 100,
              description: 'Severe meningeal irritation.',
            ),
          ],
        ),
        DiseaseAssessmentQuestion(
          id: 'headache_severity',
          prompt: 'How severe is your headache?',
          helper: 'Meningitis headaches are typically severe and sudden.',
          options: [
            DiseaseAssessmentOption(
              label: 'No headache',
              score: 0,
              description: 'No significant headache.',
            ),
            DiseaseAssessmentOption(
              label: 'Mild',
              score: 15,
              description: 'Manageable headache.',
            ),
            DiseaseAssessmentOption(
              label: 'Severe',
              score: 60,
              description: 'Intense, persistent headache.',
            ),
            DiseaseAssessmentOption(
              label: 'Worst headache ever / thunderclap',
              score: 100,
              description: 'Sudden, excruciating headache.',
            ),
          ],
        ),
        DiseaseAssessmentQuestion(
          id: 'fever_rash',
          prompt: 'Do you have fever, rash, or light sensitivity?',
          helper: 'Fever with rash or photophobia supports meningitis concern.',
          options: [
            DiseaseAssessmentOption(
              label: 'None',
              score: 0,
              description: 'No fever, rash, or photophobia.',
            ),
            DiseaseAssessmentOption(
              label: 'Fever only',
              score: 25,
              description: 'Fever without rash or light sensitivity.',
            ),
            DiseaseAssessmentOption(
              label: 'Fever with rash or photophobia',
              score: 70,
              description: 'Concerning combination.',
            ),
            DiseaseAssessmentOption(
              label: 'Non-blanching rash with fever',
              score: 100,
              description: 'Possible meningococcal rash.',
            ),
          ],
        ),
        DiseaseAssessmentQuestion(
          id: 'mental_status',
          prompt: 'Any confusion, drowsiness, or behavior changes?',
          helper: 'Altered mental status is a red flag in meningitis.',
          options: [
            DiseaseAssessmentOption(
              label: 'Fully alert',
              score: 0,
              description: 'Normal mental status.',
            ),
            DiseaseAssessmentOption(
              label: 'Slightly drowsy',
              score: 25,
              description: 'Mild sleepiness.',
            ),
            DiseaseAssessmentOption(
              label: 'Confused or very drowsy',
              score: 75,
              description: 'Significant altered mental status.',
            ),
            DiseaseAssessmentOption(
              label: 'Unresponsive or seizures',
              score: 100,
              description: 'Critical neurological emergency.',
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
