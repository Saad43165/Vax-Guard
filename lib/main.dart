import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme.dart';
import 'core/theme_notifier.dart';
import 'core/locale_notifier.dart';
import 'l10n/app_localizations.dart';
import 'screens/splash_screen.dart';
import 'core/navigation/main_navigation.dart';
import 'screens/triage_quiz_screen.dart';
import 'screens/triage_result_screen.dart';
import 'screens/animal_bite_screen.dart';
import 'screens/animal_bite_result_screen.dart';
import 'screens/first_aid_screen.dart';
import 'screens/vaccine_schedule_screen.dart';
import 'screens/hospital_map_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/health_tips_screen.dart';
import 'screens/symptom_checker_screen.dart';
import 'screens/disease_assessment_hub_screen.dart';
import 'screens/pdf_view_screen.dart';
import 'screens/medicine_reminder_screen.dart';
import 'screens/emergency_mode_screen.dart';
import 'screens/assessment_result_screen.dart';
import 'screens/live_outbreaks_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/disease_library_screen.dart';
import 'screens/history_screen.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'core/user_profile_notifier.dart';
import 'utils/app_constants.dart';
import 'utils/app_strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  await DatabaseService.instance.initialize();
  await NotificationService.instance.initialize();
  await ThemeNotifier.instance.load();
  await LocaleNotifier.instance.load();
  await UserProfileNotifier.instance.load();

  runApp(const VaxGuardApp());
}

class VaxGuardApp extends StatefulWidget {
  const VaxGuardApp({super.key});

  @override
  State<VaxGuardApp> createState() => _VaxGuardAppState();
}

class _VaxGuardAppState extends State<VaxGuardApp> {
  @override
  void initState() {
    super.initState();
    ThemeNotifier.instance.addListener(_onThemeChanged);
    LocaleNotifier.instance.addListener(_onThemeChanged);
    UserProfileNotifier.instance.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    ThemeNotifier.instance.removeListener(_onThemeChanged);
    LocaleNotifier.instance.removeListener(_onThemeChanged);
    UserProfileNotifier.instance.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeNotifier.instance.themeMode,
      locale: LocaleNotifier.instance.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: AppConstants.splashRoute,
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.splashRoute:
        return _buildRoute(const SplashScreen(), settings);
      case AppConstants.homeRoute:
        return _buildRoute(const MainNavigationScreen(), settings);
      case AppConstants.triageRoute:
        return _buildRoute(const TriageQuizScreen(), settings);
      case AppConstants.triageResultRoute:
        return _buildRoute(const TriageResultScreen(), settings);
      case AppConstants.animalBiteRoute:
        return _buildRoute(const AnimalBiteScreen(), settings);
      case AppConstants.animalBiteResultRoute:
        return _buildRoute(const AnimalBiteResultScreen(), settings);
      case AppConstants.firstAidRoute:
        return _buildRoute(const FirstAidScreen(), settings);
      case AppConstants.vaccineScheduleRoute:
        return _buildRoute(const VaccineScheduleScreen(), settings);
      case AppConstants.hospitalMapRoute:
        return _buildRoute(const HospitalMapScreen(), settings);
      case AppConstants.dashboardRoute:
        return _buildRoute(const DashboardScreen(), settings);
      case AppConstants.settingsRoute:
        return _buildRoute(const SettingsScreen(), settings);
      case AppConstants.healthTipsRoute:
        return _buildRoute(const HealthTipsScreen(), settings);
      case AppConstants.symptomCheckerRoute:
        return _buildRoute(const SymptomCheckerScreen(), settings);
      case AppConstants.assessmentsRoute:
        return _buildRoute(const DiseaseAssessmentHubScreen(), settings);
      case AppConstants.historyRoute:
        return _buildRoute(const HistoryScreen(), settings);
      case AppConstants.pdfViewRoute:
        return _buildRoute(const PdfViewScreen(), settings);
      case AppConstants.medicineReminderRoute:
        return _buildRoute(const MedicineReminderScreen(), settings);
      case AppConstants.emergencyModeRoute:
        return _buildRoute(const EmergencyModeScreen(), settings);
      case AppConstants.assessmentResultRoute:
        return _buildRoute(const AssessmentResultScreen(), settings);
      case AppConstants.liveOutbreaksRoute:
        return _buildRoute(const LiveOutbreaksScreen(), settings);
      case AppConstants.onboardingRoute:
        return _buildRoute(const OnboardingScreen(), settings);
      case AppConstants.diseaseLibraryRoute:
        return _buildRoute(const DiseaseLibraryScreen(), settings);
      default:
        return _buildRoute(const MainNavigationScreen(), settings);
    }
  }

  Route<dynamic> _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        final slide = Tween<Offset>(
          begin: const Offset(0.02, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }
}
