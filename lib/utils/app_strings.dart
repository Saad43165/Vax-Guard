import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../core/locale_notifier.dart';

class AppStrings {
  static String translate(String key) {
    return key; 
  }

  // App
  static String get appName => 'VaxGuard';
  static String get appTagline => 'Your Health, Protected';

  // Navigation
  static String get home => 'Home';
  static String get dashboard => 'Dashboard';
  static String get vaccines => 'Vaccines';
  static String get firstAid => 'First Aid';
  static String get hospitals => 'Hospitals';

  // Home Screen
  static String get emergencyBanner => '🚨 Emergency? Call 911 immediately';
  static String get quickActions => 'Quick Actions';
  static String get triageAssessment => 'Triage Assessment';
  static String get triageDesc => 'Check your risk level';
  static String get vaccineSchedule => 'Vaccine Schedule';
  static String get vaccineDesc => 'Track your vaccinations';
  static String get firstAidGuide => 'First Aid Guide';
  static String get firstAidDesc => 'Wound care & emergencies';
  static String get nearbyHospitals => 'Nearby Hospitals';
  static String get nearbyHospitalsDesc => 'Find care near you';
  static String get healthDashboard => 'Health Dashboard';
  static String get healthDashboardDesc => 'Your health analytics';

  // Triage & Clinical
  static String get triageTitle => 'Clinical Triage';
  static String get noVaccines => 'No vaccines recorded';
  static String get vaccineDeleted => 'Vaccine record deleted';
  static String get saveVaccine => 'Save Vaccine Record';
  static String get vaccineAdded => 'Vaccine record added';

  // General
  static String get cancel => 'Cancel';
  static String get confirm => 'Confirm';
  static String get delete => 'Delete';
  static String get edit => 'Edit';
  static String get save => 'Save';
  static String get loading => 'Loading...';
  static String get error => 'Something went wrong';
  static String get retry => 'Retry';
  static String get close => 'Close';
  static String get ok => 'OK';
  static String get yes => 'Yes';
  static String get no => 'No';
}
