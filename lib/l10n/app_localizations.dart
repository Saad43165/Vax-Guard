import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ur'),
    Locale('hi'),
  ];

  static final Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      'appName': 'VaxGuard',
      'appTagline': 'Your Health, Protected',
      'home': 'Home',
      'dashboard': 'Dashboard',
      'vaccines': 'Vaccines',
      'firstAid': 'First Aid',
      'hospitals': 'Hospitals',
      'triageAssessment': 'Triage Assessment',
      'vaccineSchedule': 'Vaccine Schedule',
      'firstAidGuide': 'First Aid Guide',
      'nearbyHospitals': 'Nearby Hospitals',
      'healthDashboard': 'Health Dashboard',
      'emergencyCall': 'Emergency? Call 911',
      'addVaccine': 'Add Vaccine',
      'saveRecord': 'Save Record',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'yes': 'Yes',
      'no': 'No',
      'loading': 'Loading...',
      'error': 'Something went wrong',
      'retry': 'Retry',
      'lowRisk': 'Low Risk',
      'mediumRisk': 'Medium Risk',
      'highRisk': 'High Risk',
      'criticalRisk': 'Critical Risk',
      'startTimer': 'Start 15-Minute Timer',
      'timerRunning': 'Timer Running...',
      'getDirections': 'Get Directions',
      'callHospital': 'Call Hospital',
    },
    'es': {
      'appName': 'VaxGuard',
      'appTagline': 'Tu Salud, Protegida',
      'home': 'Inicio',
      'dashboard': 'Panel',
      'vaccines': 'Vacunas',
      'firstAid': 'Primeros Auxilios',
      'hospitals': 'Hospitales',
      'triageAssessment': 'Evaluación de Triaje',
      'vaccineSchedule': 'Calendario de Vacunas',
      'firstAidGuide': 'Guía de Primeros Auxilios',
      'nearbyHospitals': 'Hospitales Cercanos',
      'healthDashboard': 'Panel de Salud',
      'emergencyCall': '¿Emergencia? Llama al 112',
      'addVaccine': 'Agregar Vacuna',
      'saveRecord': 'Guardar Registro',
      'cancel': 'Cancelar',
      'delete': 'Eliminar',
      'yes': 'Sí',
      'no': 'No',
      'loading': 'Cargando...',
      'error': 'Algo salió mal',
      'retry': 'Reintentar',
      'lowRisk': 'Riesgo Bajo',
      'mediumRisk': 'Riesgo Medio',
      'highRisk': 'Riesgo Alto',
      'criticalRisk': 'Riesgo Crítico',
      'startTimer': 'Iniciar Temporizador 15 Min',
      'timerRunning': 'Temporizador en Curso...',
      'getDirections': 'Obtener Indicaciones',
      'callHospital': 'Llamar al Hospital',
    },
    'fr': {
      'appName': 'VaxGuard',
      'appTagline': 'Votre Santé, Protégée',
      'home': 'Accueil',
      'dashboard': 'Tableau de Bord',
      'vaccines': 'Vaccins',
      'firstAid': 'Premiers Secours',
      'hospitals': 'Hôpitaux',
      'triageAssessment': 'Évaluation du Triage',
      'vaccineSchedule': 'Calendrier Vaccinal',
      'firstAidGuide': 'Guide de Premiers Secours',
      'nearbyHospitals': 'Hôpitaux à Proximité',
      'healthDashboard': 'Tableau de Bord Santé',
      'emergencyCall': 'Urgence? Appelez le 15',
      'addVaccine': 'Ajouter un Vaccin',
      'saveRecord': 'Enregistrer',
      'cancel': 'Annuler',
      'delete': 'Supprimer',
      'yes': 'Oui',
      'no': 'Non',
      'loading': 'Chargement...',
      'error': 'Quelque chose s\'est mal passé',
      'retry': 'Réessayer',
      'lowRisk': 'Faible Risque',
      'mediumRisk': 'Risque Moyen',
      'highRisk': 'Risque Élevé',
      'criticalRisk': 'Risque Critique',
      'startTimer': 'Démarrer le Minuteur 15 Min',
      'timerRunning': 'Minuteur en Cours...',
      'getDirections': 'Obtenir l\'Itinéraire',
      'callHospital': 'Appeler l\'Hôpital',
    },
    'ur': {
      'appName': 'ویکس گارڈ',
      'appTagline': 'آپ کی صحت، محفوظ',
      'home': 'گھر',
      'dashboard': 'ڈیش بورڈ',
      'vaccines': 'ویکسین',
      'firstAid': 'ابتدائی طبی امداد',
      'hospitals': 'ہسپتال',
      'triageAssessment': 'خطرے کا جائزہ',
      'vaccineSchedule': 'ویکسین شیڈول',
      'firstAidGuide': 'ابتدائی طبی امداد گائیڈ',
      'nearbyHospitals': 'قریبی ہسپتال',
      'healthDashboard': 'صحت ڈیش بورڈ',
      'emergencyCall': 'ہنگامی صورتحال? 1122 کال کریں',
      'addVaccine': 'ویکسین شامل کریں',
      'saveRecord': 'ریکارڈ محفوظ کریں',
      'cancel': 'منسوخ کریں',
      'delete': 'حذف کریں',
      'yes': 'ہاں',
      'no': 'نہیں',
      'loading': 'لوڈ ہو رہا ہے...',
      'error': 'کچھ غلط ہوا',
      'retry': 'دوبارہ کوشش کریں',
      'lowRisk': 'کم خطرہ',
      'mediumRisk': 'درمیانہ خطرہ',
      'highRisk': 'زیادہ خطرہ',
      'criticalRisk': 'انتہائی خطرہ',
      'startTimer': '15 منٹ ٹائمر شروع کریں',
      'timerRunning': 'ٹائمر چل رہا ہے...',
      'getDirections': 'راستہ حاصل کریں',
      'callHospital': 'ہسپتال کو کال کریں',
    },
    'hi': {
      'appName': 'वैक्सगार्ड',
      'appTagline': 'आपका स्वास्थ्य, सुरक्षित',
      'home': 'होम',
      'dashboard': 'डैशबोर्ड',
      'vaccines': 'टीके',
      'firstAid': 'प्राथमिक उपचार',
      'hospitals': 'अस्पताल',
      'triageAssessment': 'ट्राइएज आकलन',
      'vaccineSchedule': 'टीकाकरण कार्यक्रम',
      'firstAidGuide': 'प्राथमिक उपचार गाइड',
      'nearbyHospitals': 'पास के अस्पताल',
      'healthDashboard': 'स्वास्थ्य डैशबोर्ड',
      'emergencyCall': 'आपातकाल? 112 कॉल करें',
      'addVaccine': 'टीका जोड़ें',
      'saveRecord': 'रिकॉर्ड सहेजें',
      'cancel': 'रद्द करें',
      'delete': 'हटाएं',
      'yes': 'हाँ',
      'no': 'नहीं',
      'loading': 'लोड हो रहा है...',
      'error': 'कुछ गलत हुआ',
      'retry': 'पुनः प्रयास करें',
      'lowRisk': 'कम जोखिम',
      'mediumRisk': 'मध्यम जोखिम',
      'highRisk': 'उच्च जोखिम',
      'criticalRisk': 'गंभीर जोखिम',
      'startTimer': '15 मिनट टाइमर शुरू करें',
      'timerRunning': 'टाइमर चल रहा है...',
      'getDirections': 'दिशा-निर्देश प्राप्त करें',
      'callHospital': 'अस्पताल को कॉल करें',
    },
  };

  String translate(String key) {
    final languageCode = locale.languageCode;
    final strings = _localizedStrings[languageCode] ?? _localizedStrings['en']!;
    return strings[key] ?? _localizedStrings['en']![key] ?? key;
  }

  // Convenience getters
  String get appName => translate('appName');
  String get appTagline => translate('appTagline');
  String get home => translate('home');
  String get dashboard => translate('dashboard');
  String get vaccines => translate('vaccines');
  String get firstAid => translate('firstAid');
  String get hospitals => translate('hospitals');
  String get emergencyCall => translate('emergencyCall');
  String get addVaccine => translate('addVaccine');
  String get saveRecord => translate('saveRecord');
  String get cancel => translate('cancel');
  String get lowRisk => translate('lowRisk');
  String get mediumRisk => translate('mediumRisk');
  String get highRisk => translate('highRisk');
  String get criticalRisk => translate('criticalRisk');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es', 'fr', 'ur', 'hi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
