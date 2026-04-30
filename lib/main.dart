import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme.dart';
import 'core/theme_notifier.dart';
import 'l10n/app_localizations.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/triage_quiz_screen.dart';
import 'screens/triage_result_screen.dart';
import 'screens/animal_bite_screen.dart';
import 'screens/first_aid_screen.dart';
import 'screens/vaccine_schedule_screen.dart';
import 'screens/hospital_map_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/health_tips_screen.dart';
import 'screens/symptom_checker_screen.dart';
import 'screens/pdf_view_screen.dart';
import 'screens/medicine_reminder_screen.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'services/sqlite_service.dart';
import 'utils/app_constants.dart';

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
  }

  @override
  void dispose() {
    ThemeNotifier.instance.removeListener(_onThemeChanged);
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
      locale: const Locale('en'),
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
        return _buildRoute(const HomeScreen(), settings);
      case AppConstants.triageRoute:
        return _buildRoute(const TriageQuizScreen(), settings);
      case AppConstants.triageResultRoute:
        return _buildRoute(const TriageResultScreen(), settings);
      case AppConstants.animalBiteRoute:
        return _buildRoute(const AnimalBiteScreen(), settings);
      case AppConstants.animalBiteResultRoute:
        return _buildRoute(const AnimalBiteScreen(), settings);
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
      case AppConstants.pdfViewRoute:
        return _buildRoute(const PdfViewScreen(), settings);
      case AppConstants.medicineReminderRoute:
        return _buildRoute(const MedicineReminderScreen(), settings);
      default:
        return _buildRoute(const HomeScreen(), settings);
    }
  }

  Route<dynamic> _buildRoute(Widget page, RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => page,
      settings: settings,
    );
  }
}

class AppStrings {
  static const String appName = 'VaxGuard';
}