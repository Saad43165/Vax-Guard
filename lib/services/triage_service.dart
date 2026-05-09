import '../utils/app_constants.dart';

class TriageQuestion {
  final String id;
  final String questionKey;
  final List<TriageOption> options;
  final String categoryKey;

  const TriageQuestion({
    required this.id,
    required this.questionKey,
    required this.options,
    required this.categoryKey,
  });
}

class TriageOption {
  final String textKey;
  final int score;
  final String emoji;

  const TriageOption({
    required this.textKey,
    required this.score,
    required this.emoji,
  });
}

enum RiskLevel { low, medium, high, critical }

class TriageResult {
  final RiskLevel level;
  final int score;
  final String titleKey;
  final String descriptionKey;
  final String recommendationKey;
  final List<String> actionKeys;
  final String emoji;
  final bool isInputInsufficient;
  final List<String> drivers;

  const TriageResult({
    required this.level,
    required this.score,
    required this.titleKey,
    required this.descriptionKey,
    required this.recommendationKey,
    required this.actionKeys,
    required this.emoji,
    this.isInputInsufficient = false,
    this.drivers = const [],
  });
}

class TriageService {
  static const List<TriageQuestion> questions = [
    TriageQuestion(
      id: 'q1',
      questionKey: 'symptoms_question',
      categoryKey: 'symptoms',
      options: [
        TriageOption(textKey: 'no_symptoms', score: 0, emoji: '😊'),
        TriageOption(textKey: 'mild_symptoms', score: 25, emoji: '🤒'),
        TriageOption(textKey: 'moderate_symptoms', score: 50, emoji: '🤧'),
        TriageOption(textKey: 'severe_symptoms', score: 100, emoji: '😰'),
      ],
    ),
    TriageQuestion(
      id: 'q2',
      questionKey: 'exposure_question',
      categoryKey: 'exposure',
      options: [
        TriageOption(textKey: 'no_exposure', score: 0, emoji: '✅'),
        TriageOption(textKey: 'possible_exposure', score: 20, emoji: '⚠️'),
        TriageOption(textKey: 'confirmed_exposure', score: 40, emoji: '🔴'),
        TriageOption(textKey: 'direct_contact', score: 60, emoji: '🚨'),
      ],
    ),
    TriageQuestion(
      id: 'q3',
      questionKey: 'vaccination_status_question',
      categoryKey: 'vaccination',
      options: [
        TriageOption(textKey: 'fully_vax_boosted', score: 0, emoji: '💉'),
        TriageOption(textKey: 'fully_vax', score: 10, emoji: '🩺'),
        TriageOption(textKey: 'partially_vax', score: 30, emoji: '⚠️'),
        TriageOption(textKey: 'not_vax', score: 50, emoji: '❌'),
      ],
    ),
    TriageQuestion(
      id: 'q4',
      questionKey: 'health_conditions_question',
      categoryKey: 'risk_factors',
      options: [
        TriageOption(textKey: 'no_conditions', score: 0, emoji: '💪'),
        TriageOption(textKey: 'mild_conditions', score: 10, emoji: '🌿'),
        TriageOption(textKey: 'moderate_conditions', score: 25, emoji: '⚕️'),
        TriageOption(textKey: 'severe_conditions', score: 40, emoji: '❤️‍🩹'),
      ],
    ),
  ];

  static TriageResult calculateRisk(Map<String, int> answers) {
    if (answers.length < questions.length) {
      return const TriageResult(
        level: RiskLevel.low,
        score: 0,
        emoji: 'ℹ️',
        titleKey: 'insufficient_input',
        descriptionKey: 'answer_all_questions',
        recommendationKey: 'complete_before_submitting',
        actionKeys: [
          'review_select_option',
          'submit_again_full',
        ],
        isInputInsufficient: true,
      );
    }

    int totalScore = 0;
    final drivers = <String>[];
    for (final question in questions) {
      final optionIndex = answers[question.id];
      if (optionIndex == null) {
        return const TriageResult(
          level: RiskLevel.low,
          score: 0,
          emoji: 'ℹ️',
          titleKey: 'insufficient_input',
          descriptionKey: 'answer_all_questions',
          recommendationKey: 'complete_before_submitting',
          actionKeys: [
            'review_select_option',
            'submit_again_full',
          ],
          isInputInsufficient: true,
        );
      }
      if (optionIndex >= 0 && optionIndex < question.options.length) {
        final selected = question.options[optionIndex];
        totalScore += selected.score;
        if (selected.score >= 30) {
          drivers.add('${question.categoryKey}|${selected.textKey}');
        }
      } else {
        return const TriageResult(
          level: RiskLevel.low,
          score: 0,
          emoji: '⚠️',
          titleKey: 'error',
          descriptionKey: 'error',
          recommendationKey: 'retry',
          actionKeys: ['retry'],
          isInputInsufficient: true,
        );
      }
    }

    const maxPossibleScore = 100 + 60 + 50 + 40; // 250
    final normalizedScore = ((totalScore / maxPossibleScore) * 100).round();

    return _buildResult(normalizedScore, totalScore, drivers);
  }

  static TriageResult _buildResult(
    int normalizedScore,
    int rawScore,
    List<String> drivers,
  ) {
    if (normalizedScore < AppConstants.lowRiskThreshold) {
      return TriageResult(
        level: RiskLevel.low,
        score: normalizedScore,
        emoji: '✅',
        titleKey: 'low_risk',
        descriptionKey: 'low_risk_desc',
        recommendationKey: 'low_risk_desc',
        actionKeys: const [
          'wash_hands_regularly',
          'stay_uptodate_vax',
          'monitor_symptoms',
          'healthy_lifestyle',
        ],
        drivers: drivers,
      );
    } else if (normalizedScore < AppConstants.mediumRiskThreshold) {
      return TriageResult(
        level: RiskLevel.medium,
        score: normalizedScore,
        emoji: '⚠️',
        titleKey: 'medium_risk',
        descriptionKey: 'medium_risk_desc',
        recommendationKey: 'medium_risk_desc',
        actionKeys: const [
          'rest_hydration',
          'monitor_symptoms',
          'schedule_doctor',
          'avoid_vulnerable',
          'wear_mask',
        ],
        drivers: drivers,
      );
    } else if (normalizedScore < AppConstants.highRiskThreshold) {
      return TriageResult(
        level: RiskLevel.high,
        score: normalizedScore,
        emoji: '🔴',
        titleKey: 'high_risk',
        descriptionKey: 'high_risk_desc',
        recommendationKey: 'high_risk_desc',
        actionKeys: const [
          'contact_doctor_imm',
          'urgent_care_visit',
          'isolate_others',
          'emergency_contacts_ready',
        ],
        drivers: drivers,
      );
    } else {
      return TriageResult(
        level: RiskLevel.critical,
        score: normalizedScore,
        emoji: '🚨',
        titleKey: 'critical_risk',
        descriptionKey: 'critical_risk_desc',
        recommendationKey: 'critical_risk_desc',
        actionKeys: const [
          'call_911_imm',
          'go_to_er',
          'do_not_drive',
          'inform_someone',
        ],
        drivers: drivers,
      );
    }
  }

  static String getRiskLevelEmoji(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return '✅';
      case RiskLevel.medium:
        return '⚠️';
      case RiskLevel.high:
        return '🔴';
      case RiskLevel.critical:
        return '🚨';
    }
  }
}
