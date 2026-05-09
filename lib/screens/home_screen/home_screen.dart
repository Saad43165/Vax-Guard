import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../models/history_entry.dart';
import '../../services/database_service.dart';
import '../../services/medicine_reminder_service.dart';
import '../../services/user_profile_service.dart';
import '../../models/user_profile.dart';
import '../../utils/app_constants.dart';
import '../../widgets/cards/emergancy_card.dart';
import '../../widgets/cards/reminder_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _totalVaccines = 0;
  int _totalAssessments = 0;
  List<MedicineReminder> _activeReminders = [];
  String _userName = '';
  final ScrollController _scrollController = ScrollController();

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _loadData();
  }

  @override
  void dispose() {
    _animController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final db = DatabaseService.instance;
    final reminders = await MedicineReminderService.instance.getActiveReminders();
    final profile = await UserProfileService.getProfile();
    final history = await db.getHistoryEntries();

    if (mounted) {
      setState(() {
        _totalVaccines = db.totalVaccines;
        _totalAssessments = history.where((e) => e.type != HistoryEntryType.vaccine).length;
        _activeReminders = reminders;
        _userName = profile.name;
      });
      _animController.forward(from: 0.0);
    }
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background(context),
      appBar: _buildFixedAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppTheme.primary,
        backgroundColor: AppTheme.surface(context),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            children: [
              const EmergencyCard(),
              const SizedBox(height: 24),
              _buildHeader(),
              const SizedBox(height: 24),
              _buildTopStatsRow(),
              const SizedBox(height: 24),
              _buildBigButton(
                'Live Outbreak Radar',
                'Monitor real-time disease outbreaks and regional health alerts.',
                Icons.radar_rounded,
                AppTheme.warningGradient,
                () => Navigator.pushNamed(context, AppConstants.liveOutbreaksRoute),
              ),
              const SizedBox(height: 16),
              _buildBigButton(
                'Disease Risk Assessment',
                'Comprehensive screening for endemic and respiratory diseases.',
                Icons.coronavirus_rounded,
                AppTheme.cyanGradient,
                () => Navigator.pushNamed(context, AppConstants.assessmentsRoute),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSquareButton(
                      'Symptom Checker',
                      'AI Clinical Analysis',
                      Icons.psychology_rounded,
                      AppTheme.primaryGradient,
                      () => Navigator.pushNamed(context, AppConstants.symptomCheckerRoute),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSquareButton(
                      'Health Library',
                      'Medical Research',
                      Icons.menu_book_rounded,
                      AppTheme.purpleGradient,
                      () => Navigator.pushNamed(context, AppConstants.diseaseLibraryRoute),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTwoButtonRow(),
              const SizedBox(height: 16),
              _buildThreeButtonRow(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildFixedAppBar() {
  return AppBar(
    backgroundColor: AppTheme.surface(context),
    elevation: 0,
    scrolledUnderElevation: 0,
    leading: Padding(
      padding: const EdgeInsets.all(8),
      child: ClipOval(
        child: Image.asset(
          'assets/images/splash_icon.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 24),
          ),
        ),
      ),
    ),
    centerTitle: true,
    title: Text(
      'VaxGuard',
      style: GoogleFonts.outfit(
        color: AppTheme.textPrimary(context),
        fontWeight: FontWeight.w900,
        fontSize: 18,
        letterSpacing: -0.5,
      ),
    ),
    actions: const [
      SizedBox(width: 48),
    ],
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(
        color: AppTheme.border(context).withOpacity(0.5),
        height: 1,
      ),
    ),
  );
}

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _greeting, 
          style: GoogleFonts.outfit(
            color: AppTheme.textSecondary(context), 
            fontSize: 14, 
            fontWeight: FontWeight.w600,
          )
        ),
        Text(
          _userName.isNotEmpty ? _userName : 'Health Explorer', 
          style: GoogleFonts.outfit(
            color: AppTheme.textPrimary(context), 
            fontSize: 28, 
            fontWeight: FontWeight.w900, 
            letterSpacing: -1.0
          ), 
          overflow: TextOverflow.ellipsis
        ),
      ],
    );
  }

  Widget _buildTopStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildSmallStatCard('$_totalVaccines', 'Vaccines', Icons.vaccines_rounded, AppTheme.primary, () => Navigator.pushNamed(context, AppConstants.vaccineScheduleRoute))),
        const SizedBox(width: 12),
        Expanded(child: _buildSmallStatCard('$_totalAssessments', 'Assessments', Icons.analytics_rounded, AppTheme.purple, () => Navigator.pushNamed(context, AppConstants.assessmentsRoute))),
        const SizedBox(width: 12),
        Expanded(child: _buildSmallStatCard('Map', 'Hospitals', Icons.local_hospital_rounded, AppTheme.success, () => Navigator.pushNamed(context, AppConstants.hospitalMapRoute))),
      ],
    );
  }

  Widget _buildSmallStatCard(String value, String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.surface(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.border(context).withValues(alpha: 0.5)),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 12),
            Text(value, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
            const SizedBox(height: 2),
            Text(label, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary(context))),
          ],
        ),
      ),
    );
  }

  Widget _buildBigButton(String title, String sub, IconData icon, LinearGradient gradient, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(color: gradient.colors.last.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: Colors.white, size: 32),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 24),
              ],
            ),
            const SizedBox(height: 20),
            Text(title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(sub, style: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.85), fontSize: 13, fontWeight: FontWeight.w500, height: 1.4)),
          ],
        ),
      ),
    );
  }

  Widget _buildTwoButtonRow() {
    return Row(
      children: [
        Expanded(
          child: _buildSquareButton(
            'Animal Bite',
            'Rabies Risk',
            Icons.pets_rounded,
            AppTheme.purpleGradient,
            () => Navigator.pushNamed(context, AppConstants.animalBiteRoute),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSquareButton(
            'Emergency',
            'Triage Quiz',
            Icons.emergency_rounded,
            AppTheme.dangerGradient,
            () => Navigator.pushNamed(context, AppConstants.triageRoute),
          ),
        ),
      ],
    );
  }

  Widget _buildThreeButtonRow() {
    return Row(
      children: [
        Expanded(
          child: _buildMiniButton(
            'Reports',
            Icons.picture_as_pdf_rounded,
            AppTheme.success,
            () => Navigator.pushNamed(context, AppConstants.historyRoute),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMiniButton(
            'First Aid',
            Icons.medical_services_rounded,
            AppTheme.success,
            () => Navigator.pushNamed(context, AppConstants.firstAidRoute),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMiniButton(
            'Health Tips',
            Icons.tips_and_updates_rounded,
            AppTheme.warning,
            () => Navigator.pushNamed(context, AppConstants.healthTipsRoute),
          ),
        ),
      ],
    );
  }

  Widget _buildSquareButton(String title, String sub, IconData icon, LinearGradient gradient, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        height: 140,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: gradient.colors.last.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const Spacer(),
            Text(title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
            Text(sub, style: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.8), fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.surface(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border(context).withValues(alpha: 0.5)),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(label, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.textPrimary(context))),
          ],
        ),
      ),
    );
  }
}
