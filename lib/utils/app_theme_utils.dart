import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color secondary = Color(0xFF0891B2);
  static const Color success = Color(0xFF059669);
  static const Color warning = Color(0xFFD97706);
  static const Color danger = Color(0xFFDC2626);
  static const Color purple = Color(0xFF7C3AED);
  
  static const Color background = Color(0xFFF1F5F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);
  
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double full = 9999;
}

class AppIconSize {
  static const double xs = 16;
  static const double sm = 20;
  static const double md = 24;
  static const double lg = 32;
  static const double xl = 48;
  static const double xxl = 64;
}

class AppFontSize {
  static const double xs = 11;
  static const double sm = 13;
  static const double md = 15;
  static const double lg = 17;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

class AppDuration {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration xslow = Duration(milliseconds: 800);
}

class AppAnimation {
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve springCurve = Curves.elasticOut;
  static const Curve bounceCurve = Curves.bounceOut;
}

class AppStrings {
  static const String appName = 'VaxGuard';
  static const String tagline = 'Your Health Companion';
  
  // Common
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String done = 'Done';
  static const String next = 'Next';
  static const String back = 'Back';
  static const String continue_ = 'Continue';
  static const String submit = 'Submit';
  static const String retry = 'Retry';
  static const String close = 'Close';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String sort = 'Sort';
  static const String refresh = 'Refresh';
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String warning = 'Warning';
  static const String info = 'Info';
  
  // Messages
  static const String noData = 'No data available';
  static const String noResults = 'No results found';
  static const String networkError = 'Network error. Please check your connection.';
  static const String somethingWentWrong = 'Something went wrong';
  static const String tryAgain = 'Please try again';
  static const String noInternet = 'No internet connection';
  
  // Validation
  static const String required = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email';
  static const String invalidPhone = 'Please enter a valid phone number';
  static const String invalidUrl = 'Please enter a valid URL';
  static const String minLength = 'Minimum length is';
  static const String maxLength = 'Maximum length is';
}

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String healthAssessment = '/health-assessment';
  static const String animalBite = '/animal-bite';
  static const String symptomChecker = '/symptom-checker';
  static const String vaccineSchedule = '/vaccine-schedule';
  static const String hospitalMap = '/hospital-map';
  static const String firstAid = '/first-aid';
  static const String dashboard = '/dashboard';
  static const String notifications = '/notifications';
  static const String reminders = '/reminders';
  static const String articles = '/articles';
}

class AppAssets {
  static const String logo = 'assets/images/logo.png';
  static const String splashBackground = 'assets/images/splash_bg.png';
  static const String emptyState = 'assets/images/empty_state.png';
  static const String errorState = 'assets/images/error_state.png';
}

class AppKeys {
  static const String userToken = 'user_token';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String userName = 'user_name';
  static const String themeMode = 'theme_mode';
  static const String language = 'language';
  static const String firstLaunch = 'first_launch';
  static const String lastSync = 'last_sync';
}