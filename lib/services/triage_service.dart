import '../utils/app_constants.dart';
class TriageQuestion {
  final String id;
  final String question;
  final List<TriageOption> options;
  final String category;

  const TriageQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.category,
  });
}

class TriageOption {
  final String text;
  final int score;
  final String emoji;

  const TriageOption({
    required this.text,
    required this.score,
    required this.emoji,
  });
}

enum RiskLevel { low, medium, high, critical }

class TriageResult {
  final RiskLevel level;
  final int score;
  final String title;
  final String description;
  final String recommendation;
  final List<String> actions;
  final String emoji;
  final bool isInputInsufficient;
  final List<String> drivers;

  const TriageResult({
    required this.level,
    required this.score,
    required this.title,
    required this.description,
    required this.recommendation,
    required this.actions,
    required this.emoji,
    this.isInputInsufficient = false,
    this.drivers = const [],
  });
}

class TriageService {
  static const List<TriageQuestion> questions = [
    TriageQuestion(
      id: 'q1',
      question: 'Do you have any of the following symptoms?',
      category: 'Symptoms',
      options: [
        TriageOption(text: 'No symptoms', score: 0, emoji: '😊'),
        TriageOption(text: 'Mild fever or cough', score: 25, emoji: '🤒'),
        TriageOption(text: 'High fever, body aches', score: 50, emoji: '🤧'),
        TriageOption(
            text: 'Difficulty breathing, chest pain', score: 100, emoji: '😰'),
      ],
    ),
    TriageQuestion(
      id: 'q2',
      question: 'Have you been recently exposed to a contagious illness?',
      category: 'Exposure',
      options: [
        TriageOption(text: 'No known exposure', score: 0, emoji: '✅'),
        TriageOption(text: 'Possible exposure (1–2 weeks ago)', score: 20, emoji: '⚠️'),
        TriageOption(text: 'Confirmed exposure (in last 7 days)', score: 40, emoji: '🔴'),
        TriageOption(text: 'Direct contact with confirmed case', score: 60, emoji: '🚨'),
      ],
    ),
    TriageQuestion(
      id: 'q3',
      question: 'What is your vaccination status?',
      category: 'Vaccination',
      options: [
        TriageOption(text: 'Fully vaccinated & boosted', score: 0, emoji: '💉'),
        TriageOption(text: 'Fully vaccinated', score: 10, emoji: '🩺'),
        TriageOption(text: 'Partially vaccinated', score: 30, emoji: '⚠️'),
        TriageOption(text: 'Not vaccinated', score: 50, emoji: '❌'),
      ],
    ),
    TriageQuestion(
      id: 'q4',
      question: 'Do you have any underlying health conditions?',
      category: 'Risk Factors',
      options: [
        TriageOption(text: 'No conditions', score: 0, emoji: '💪'),
        TriageOption(text: 'Mild conditions (allergies)', score: 10, emoji: '🌿'),
        TriageOption(
            text: 'Moderate conditions (asthma, diabetes)', score: 25, emoji: '⚕️'),
        TriageOption(
            text: 'Severe conditions (heart disease, immunocompromised)',
            score: 40,
            emoji: '❤️‍🩹'),
      ],
    ),
  ];

  static TriageResult calculateRisk(Map<String, int> answers) {
    if (answers.length < questions.length) {
      return const TriageResult(
        level: RiskLevel.low,
        score: 0,
        emoji: 'ℹ️',
        title: 'Insufficient Input',
        description:
            'Please answer all triage questions to get a reliable risk result.',
        recommendation: 'Complete all questions before submitting.',
        actions: [
          'Review each question and select one option.',
          'Submit again to generate a full assessment.',
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
          title: 'Insufficient Input',
          description:
              'One or more triage answers are missing, so risk cannot be estimated yet.',
          recommendation: 'Complete all questions before submitting.',
          actions: [
            'Go back and answer the missing questions.',
            'Submit again to receive your assessment.',
          ],
          isInputInsufficient: true,
        );
      }
      if (optionIndex >= 0 && optionIndex < question.options.length) {
        final selected = question.options[optionIndex];
        totalScore += selected.score;
        if (selected.score >= 30) {
          drivers.add('${question.category}: ${selected.text}');
        }
      } else {
        return const TriageResult(
          level: RiskLevel.low,
          score: 0,
          emoji: '⚠️',
          title: 'Invalid Input',
          description:
              'An invalid answer was detected for one of the triage questions.',
          recommendation: 'Retake the triage quiz using the listed options only.',
          actions: [
            'Restart the assessment.',
            'Select one listed option per question.',
          ],
          isInputInsufficient: true,
        );
      }
    }

    // Normalize score to 0–100
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
        title: 'Low Risk',
        description:
            'Based on your responses, you appear to be at low risk. Continue maintaining good health practices.',
        recommendation: 'You appear safe. Continue healthy habits.',
        actions: const [
          'Wash hands regularly',
          'Stay up to date with vaccinations',
          'Monitor for any new symptoms',
          'Maintain a healthy lifestyle',
        ],
        drivers: drivers,
      );
    } else if (normalizedScore < AppConstants.mediumRiskThreshold) {
      return TriageResult(
        level: RiskLevel.medium,
        score: normalizedScore,
        emoji: '⚠️',
        title: 'Medium Risk',
        description:
            'You show some risk factors. Consider consulting a healthcare professional if symptoms persist or worsen.',
        recommendation: 'Monitor symptoms and consult a doctor if needed.',
        actions: const [
          'Rest and stay hydrated',
          'Monitor symptoms closely',
          'Schedule an appointment with your doctor',
          'Avoid contact with vulnerable individuals',
          'Wear a mask in public',
        ],
        drivers: drivers,
      );
    } else if (normalizedScore < AppConstants.highRiskThreshold) {
      return TriageResult(
        level: RiskLevel.high,
        score: normalizedScore,
        emoji: '🔴',
        title: 'High Risk',
        description:
            'Your symptoms and risk factors indicate high risk. Please consult a healthcare provider as soon as possible.',
        recommendation: 'Consult a doctor soon. Do not delay medical care.',
        actions: const [
          'Contact your doctor immediately',
          'Consider urgent care visit',
          'Isolate from others',
          'Keep emergency contacts ready',
          'Document your symptoms',
          'Follow healthcare provider instructions',
        ],
        drivers: drivers,
      );
    } else {
      return TriageResult(
        level: RiskLevel.critical,
        score: normalizedScore,
        emoji: '🚨',
        title: 'Critical Risk',
        description:
            'Your symptoms indicate a potentially serious condition requiring immediate medical attention.',
        recommendation:
            'Seek emergency medical care immediately. Call 911 or go to the nearest emergency room.',
        actions: const [
          'Call 911 immediately',
          'Go to the nearest emergency room',
          'Do not drive yourself',
          'Inform someone of your condition',
          'Bring your medical history',
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
