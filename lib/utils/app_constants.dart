class AppConstants {
  // Hive Boxes
  static const String vaccineBox = 'vaccine_records';
  static const String settingsBox = 'settings';
  static const String reminderBox = 'medicine_reminders';

  // Routes
  static const String splashRoute = '/';
  static const String homeRoute = '/home';
  static const String triageRoute = '/triage';
  static const String triageResultRoute = '/triage-result';
  static const String animalBiteRoute = '/animal-bite';
  static const String animalBiteResultRoute = '/animal-bite-result';
  static const String firstAidRoute = '/first-aid';
  static const String vaccineScheduleRoute = '/vaccine-schedule';
  static const String hospitalMapRoute = '/hospital-map';
  static const String dashboardRoute = '/dashboard';
  static const String settingsRoute = '/settings';
  static const String healthTipsRoute = '/health-tips';
  static const String symptomCheckerRoute = '/symptom-checker';
  static const String pdfViewRoute = '/pdf-view';
  static const String medicineReminderRoute = '/medicine-reminder';
  static const String profileRoute = '/profile';

  // Notification IDs
  static const int vaccineReminderNotificationId = 1001;
  static const String vaccineReminderChannelId = 'vaccine_reminders';
  static const String vaccineReminderChannelName = 'Vaccine Reminders';

  // Triage Risk Thresholds
  static const int lowRiskThreshold = 25;
  static const int mediumRiskThreshold = 50;
  static const int highRiskThreshold = 75;

  // Timer
  static const int woundWashDurationMinutes = 15;

  // Map
  static const double defaultLatitude = 37.7749;
  static const double defaultLongitude = -122.4194;
  static const double searchRadiusKm = 5.0;

  // Animation Durations
  static const int splashDuration = 3000;
  static const int animationDuration = 300;
  static const int longAnimationDuration = 600;

  // Common Vaccines
  static const List<String> commonVaccines = [
    'COVID-19 (Pfizer)',
    'COVID-19 (Moderna)',
    'COVID-19 (Johnson & Johnson)',
    'Influenza (Flu)',
    'Hepatitis A',
    'Hepatitis B',
    'MMR (Measles, Mumps, Rubella)',
    'Varicella (Chickenpox)',
    'Tdap (Tetanus, Diphtheria, Pertussis)',
    'Pneumococcal',
    'Shingles (Zoster)',
    'HPV',
    'Meningococcal',
    'Rabies',
    'Yellow Fever',
    'Typhoid',
    'Cholera',
    'Other',
  ];

  // Dose Numbers
  static const List<String> doseNumbers = [
    '1st Dose',
    '2nd Dose',
    '3rd Dose',
    '4th Dose',
    'Booster',
    'Annual',
  ];
}