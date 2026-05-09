import 'package:flutter/material.dart';

class DiseaseAssessmentOption {
  final String label;
  final int score;
  final String description;

  const DiseaseAssessmentOption({
    required this.label,
    required this.score,
    required this.description,
  });
}

class DiseaseAssessmentQuestion {
  final String id;
  final String prompt;
  final String helper;
  final List<DiseaseAssessmentOption> options;
  final String? dependsOnQuestionId;
  final int? minScoreDependency;

  const DiseaseAssessmentQuestion({
    required this.id,
    required this.prompt,
    required this.helper,
    required this.options,
    this.dependsOnQuestionId,
    this.minScoreDependency,
  });
}

class DiseaseAssessmentDefinition {
  final String id;
  final String title;
  final String subtitle;
  final String summary;
  final String disclaimer;
  final String guidance;
  final IconData icon;
  final Color accentColor;
  final LinearGradient gradient;
  final List<DiseaseAssessmentQuestion> questions;
  final List<String> urgentFlags;
  final List<String> defaultActions;

  const DiseaseAssessmentDefinition({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.summary,
    required this.disclaimer,
    required this.guidance,
    required this.icon,
    required this.accentColor,
    required this.gradient,
    required this.questions,
    required this.urgentFlags,
    required this.defaultActions,
  });
}

class DiseaseAssessmentResult {
  final String level;
  final int score;
  final String headline;
  final String summary;
  final String nextStep;
  final List<String> actions;
  final List<String> matchedConcerns;

  const DiseaseAssessmentResult({
    required this.level,
    required this.score,
    required this.headline,
    required this.summary,
    required this.nextStep,
    required this.actions,
    required this.matchedConcerns,
  });
}
