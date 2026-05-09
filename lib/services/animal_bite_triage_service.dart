import 'package:flutter/material.dart';

enum ExposureCategory { categoryI, categoryII, categoryIII }

class AnimalBiteTriageService {
  static final AnimalBiteTriageService instance = AnimalBiteTriageService._();
  AnimalBiteTriageService._();

  /// Calculates the WHO Exposure Category based on clinical inputs.
  ExposureCategory calculateCategory({
    required String exposureType,
    required String anatomicalLocation,
    required String animalBehavior,
    required bool isStray,
  }) {
    // Category III: High Risk (Any transdermal bite/scratch with bleeding, licks on broken skin, or any contact with bats)
    if (exposureType == 'bite_broken' || 
        exposureType == 'bat_contact' || 
        anatomicalLocation == 'head_neck_face' || 
        anatomicalLocation == 'hands_fingers') {
      return ExposureCategory.categoryIII;
    }

    // Category II: Moderate Risk (Minor scratches or abrasions without bleeding, nibbling of uncovered skin)
    if (exposureType == 'scratch_minor' || exposureType == 'licks_broken') {
      return ExposureCategory.categoryII;
    }

    // Category I: Low Risk (Licks on intact skin, contact with animal without skin breach)
    return ExposureCategory.categoryI;
  }

  /// Generates a Rabies Post-Exposure Prophylaxis (PEP) schedule.
  List<DateTime> generatePEPSchedule(DateTime exposureDate) {
    // WHO Standard Intramuscular Regimen (Essen protocol: Days 0, 3, 7, 14, 28)
    // Note: Some modern protocols use 4 doses (0, 3, 7, 14-28). We will use the standard 5-dose for maximum safety coverage.
    return [
      exposureDate,
      exposureDate.add(const Duration(days: 3)),
      exposureDate.add(const Duration(days: 7)),
      exposureDate.add(const Duration(days: 14)),
      exposureDate.add(const Duration(days: 28)),
    ];
  }

  /// Determines if Rabies Immunoglobulin (RIG) is required.
  bool requiresRIG(ExposureCategory category) {
    return category == ExposureCategory.categoryIII;
  }

  /// Gets clinical recommendations based on category.
  List<String> getRecommendations(ExposureCategory category) {
    switch (category) {
      case ExposureCategory.categoryIII:
        return [
          'Immediate wound washing for 15 minutes with soap and water.',
          'Immediate administration of Rabies Immunoglobulin (RIG).',
          'Full course of Rabies Vaccine (Days 0, 3, 7, 14, 28).',
          'Consult a specialized Rabies Center immediately.'
        ];
      case ExposureCategory.categoryII:
        return [
          'Immediate wound washing for 15 minutes with soap and water.',
          'Full course of Rabies Vaccine (Days 0, 3, 7, 14, 28).',
          'Tetanus prophylaxis check.'
        ];
      case ExposureCategory.categoryI:
        return [
          'Wound washing is recommended for hygiene.',
          'No specific Rabies prophylaxis required if skin is intact.',
          'Monitor animal behavior for 10 days if possible.'
        ];
    }
  }
}
