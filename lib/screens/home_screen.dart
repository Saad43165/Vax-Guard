import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme.dart';
import '../core/theme_notifier.dart';
import '../services/notification_service.dart';
import '../utils/app_constants.dart';
import '../services/database_service.dart';
import '../services/medicine_reminder_service.dart';
import '../models/vaccine_record.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _HomeContent(),
          _DashboardContent(),
          _HistoryContent(),
          _SettingsContent(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
                _buildNavItem(1, Icons.bar_chart_rounded, Icons.bar_chart_outlined, 'Dashboard'),
                _buildNavItem(2, Icons.history_rounded, Icons.history_outlined, 'History'),
                _buildNavItem(3, Icons.settings_rounded, Icons.settings_outlined, 'Settings'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = _currentIndex == index;
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? AppTheme.primary : cs.onSurface.withValues(alpha: 0.45),
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.primary : cs.onSurface.withValues(alpha: 0.45),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  int _totalVaccines = 0;
  int _completedVaccines = 0;
  int _pendingVaccines = 0;
  List<MedicineReminder> _activeReminders = [];
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = DatabaseService.instance;
    final reminders = await MedicineReminderService.instance.getActiveReminders();
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _totalVaccines = db.totalVaccines;
        _completedVaccines = db.completedVaccines;
        _pendingVaccines = db.pendingVaccines;
        _activeReminders = reminders;
        _userName = prefs.getString('user_name') ?? '';
      });
    }
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 175,
            pinned: true,
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppTheme.deepBlueGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 42, height: 42,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/Applogo.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Text('🛡️', style: TextStyle(fontSize: 22)),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'VaxGuard',
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                              onPressed: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '$_greeting${_userName.isNotEmpty ? ', $_userName' : ''}! 👋',
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Stay on top of your health today',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEmergencyCard(context),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildStatCard(cs, 'Total', _totalVaccines.toString(), Icons.vaccines_rounded, AppTheme.primary),
                      const SizedBox(width: 10),
                      _buildStatCard(cs, 'Done', _completedVaccines.toString(), Icons.check_circle_rounded, AppTheme.success),
                      const SizedBox(width: 10),
                      _buildStatCard(cs, 'Pending', _pendingVaccines.toString(), Icons.schedule_rounded, AppTheme.warning),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle('Quick Actions'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildQuickAction(context, Icons.pets_rounded, 'Animal Bite', AppConstants.animalBiteRoute, AppTheme.warning)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildQuickAction(context, Icons.local_hospital_rounded, 'Hospital', AppConstants.hospitalMapRoute, AppTheme.danger)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildQuickAction(context, Icons.vaccines_rounded, 'Vaccines', AppConstants.vaccineScheduleRoute, AppTheme.primary)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildQuickAction(context, Icons.medication_rounded, 'Medicine', AppConstants.medicineReminderRoute, AppTheme.purple)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_activeReminders.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _SectionTitle("Today's Medicines"),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, AppConstants.medicineReminderRoute).then((_) => _loadData()),
                          child: const Text('See all'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...List.generate(_activeReminders.length > 3 ? 3 : _activeReminders.length, (i) {
                      final r = _activeReminders[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.purple.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(color: AppTheme.purpleLight, borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.medication_rounded, color: AppTheme.purple, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r.medicineName, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: cs.onSurface)),
                                  Text('${r.dosage} · ${r.time}', style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6))),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(color: AppTheme.purpleLight, borderRadius: BorderRadius.circular(10)),
                              child: const Text('Active', style: TextStyle(color: AppTheme.purple, fontSize: 11, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                  ],
                  _SectionTitle('Health Tools'),
                  const SizedBox(height: 12),
                  _buildToolCard(context, cs, Icons.favorite_border_rounded, 'Health Assessment', 'Evaluate your risk level', AppTheme.danger, AppConstants.triageRoute),
                  const SizedBox(height: 10),
                  _buildToolCard(context, cs, Icons.thermostat_rounded, 'Symptom Checker', 'Check what your symptoms mean', AppTheme.warning, AppConstants.symptomCheckerRoute),
                  const SizedBox(height: 10),
                  _buildToolCard(context, cs, Icons.healing_rounded, 'First Aid Guide', 'Emergency first aid procedures', AppTheme.success, AppConstants.firstAidRoute),
                  const SizedBox(height: 10),
                  _buildToolCard(context, cs, Icons.lightbulb_outline_rounded, 'Health Tips', 'Daily wellness advice', AppTheme.purple, AppConstants.healthTipsRoute),
                  const SizedBox(height: 10),
                  _buildToolCard(context, cs, Icons.health_and_safety_rounded, 'Disease Assessment Hub', 'Check specific disease symptoms', AppTheme.secondary, AppConstants.assessmentsRoute),
                  const SizedBox(height: 10),
                  _buildToolCard(context, cs, Icons.emergency_rounded, 'Emergency Mode', 'Quick access to emergency tools', AppTheme.danger, AppConstants.emergencyModeRoute),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _showEmergencySheet(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppTheme.dangerGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: AppTheme.danger.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.emergency_rounded, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Emergency?', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                  SizedBox(height: 2),
                  Text('Tap for quick emergency actions', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: const Text('911', style: TextStyle(color: AppTheme.danger, fontWeight: FontWeight.w900, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmergencySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, ctrl) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: ctrl,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            children: [
              Center(
                child: Container(
                  width: 40, height: 4, margin: const EdgeInsets.only(top: 8, bottom: 16),
                  decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const Center(
                child: Text('Emergency Options', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 20),
              _buildEmOption(context, Icons.emergency_rounded, 'Emergency Mode', 'Full emergency toolkit & guides', AppTheme.danger, () => Navigator.pushNamed(context, AppConstants.emergencyModeRoute)),
              const SizedBox(height: 10),
              _buildEmOption(context, Icons.local_hospital_rounded, 'Find Hospital', 'Locate nearest hospitals', AppTheme.primary, () => Navigator.pushNamed(context, AppConstants.hospitalMapRoute)),
              const SizedBox(height: 10),
              _buildEmOption(context, Icons.pets_rounded, 'Animal Bite', 'Assess animal bite severity', AppTheme.warning, () => Navigator.pushNamed(context, AppConstants.animalBiteRoute)),
              const SizedBox(height: 10),
              _buildEmOption(context, Icons.medical_services_rounded, 'First Aid', 'Emergency procedures guide', AppTheme.success, () => Navigator.pushNamed(context, AppConstants.firstAidRoute)),
              const SizedBox(height: 10),
              _buildEmOption(context, Icons.favorite_rounded, 'Health Assessment', 'Quick risk check', AppTheme.purple, () => Navigator.pushNamed(context, AppConstants.triageRoute)),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmOption(BuildContext context, IconData icon, String title, String sub, Color color, VoidCallback onTap) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () { Navigator.pop(context); onTap(); },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 22)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 15)),
                Text(sub, style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6))),
              ]),
            ),
            Icon(Icons.chevron_right_rounded, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(ColorScheme cs, String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
            Text(label, style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.6), fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, IconData icon, String label, String route, Color color) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route).then((_) => _loadData()),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 10), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, ColorScheme cs, IconData icon, String title, String sub, Color color, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outline.withValues(alpha: 0.12)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(13)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: cs.onSurface)),
                  const SizedBox(height: 2),
                  Text(sub, style: TextStyle(color: cs.onSurface.withValues(alpha: 0.55), fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 15),
          ],
        ),
      ),
    );
  }
}

class _DashboardContent extends StatefulWidget {
  const _DashboardContent();

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  double _completionPercentage = 0;
  int _totalVaccines = 0;
  int _completedVaccines = 0;
  int _pendingVaccines = 0;
  List<VaccineRecord> _upcomingVaccines = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final db = DatabaseService.instance;
    final upcoming = await db.getUpcomingVaccines();
    if (mounted) {
      setState(() {
        _completionPercentage = db.completionPercentage;
        _totalVaccines = db.totalVaccines;
        _completedVaccines = db.completedVaccines;
        _pendingVaccines = db.pendingVaccines;
        _upcomingVaccines = upcoming;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return RefreshIndicator(
      onRefresh: _loadStats,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Dashboard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
              background: Container(decoration: const BoxDecoration(gradient: AppTheme.primaryGradient)),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.refresh_rounded, color: Colors.white), onPressed: _loadStats),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Health score card
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: AppTheme.deepBlueGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppTheme.shadowPrimary,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.health_and_safety_rounded, color: Colors.white70, size: 18),
                          const SizedBox(width: 6),
                          const Text('Vaccination Score', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                            child: Text(
                              _completionPercentage >= 75 ? '🏆 Excellent' : _completionPercentage >= 50 ? '💪 Good' : '💉 Keep Going',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${_completionPercentage.toStringAsFixed(0)}%',
                        style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -2),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: _completionPercentage / 100,
                          minHeight: 10,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _DashStat(label: 'Total', value: _totalVaccines),
                          const SizedBox(width: 24),
                          _DashStat(label: 'Done', value: _completedVaccines),
                          const SizedBox(width: 24),
                          _DashStat(label: 'Pending', value: _pendingVaccines),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Progress bars
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: cs.outline.withValues(alpha: 0.12)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vaccination Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurface)),
                      const SizedBox(height: 16),
                      _buildProgressRow(cs, 'Completed', _completedVaccines, _totalVaccines, AppTheme.success),
                      const SizedBox(height: 14),
                      _buildProgressRow(cs, 'Pending', _pendingVaccines, _totalVaccines, AppTheme.warning),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                if (_upcomingVaccines.isNotEmpty) ...[
                  Text('Upcoming Vaccinations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurface)),
                  const SizedBox(height: 12),
                  ...List.generate(_upcomingVaccines.length > 3 ? 3 : _upcomingVaccines.length, (i) {
                    final v = _upcomingVaccines[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.warning.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42, height: 42,
                            decoration: BoxDecoration(color: AppTheme.warningLight, borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.vaccines_rounded, color: AppTheme.warning, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(v.vaccineName, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: cs.onSurface)),
                                if (v.nextDoseDate != null)
                                  Text(
                                    'Due: ${v.nextDoseDate!.day}/${v.nextDoseDate!.month}/${v.nextDoseDate!.year}',
                                    style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6)),
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: AppTheme.warningLight, borderRadius: BorderRadius.circular(10)),
                            child: const Text('Due', style: TextStyle(color: AppTheme.warning, fontSize: 11, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                ],

                Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurface)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildActionCard(cs, Icons.add_rounded, 'Add Vaccine', AppConstants.vaccineScheduleRoute, AppTheme.primary)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildActionCard(cs, Icons.picture_as_pdf_rounded, 'Export PDF', AppConstants.pdfViewRoute, AppTheme.success)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildActionCard(cs, Icons.medication_rounded, 'Reminders', AppConstants.medicineReminderRoute, AppTheme.purple)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildActionCard(cs, Icons.map_rounded, 'Hospital Map', AppConstants.hospitalMapRoute, AppTheme.secondary)),
                  ],
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow(ColorScheme cs, String label, int value, int total, Color color) {
    final progress = total > 0 ? value / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface, fontSize: 14)),
            Text('$value / $total', style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress, minHeight: 10,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(ColorScheme cs, IconData icon, String label, String route, Color color) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 13))),
          ],
        ),
      ),
    );
  }
}

class _DashStat extends StatelessWidget {
  final String label;
  final int value;
  const _DashStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(value.toString(), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
      Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 11)),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// HISTORY
// ─────────────────────────────────────────────────────────────────────────────

class _HistoryContent extends StatefulWidget {
  const _HistoryContent();

  @override
  State<_HistoryContent> createState() => _HistoryContentState();
}

class _HistoryContentState extends State<_HistoryContent> {
  List<VaccineRecord> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    final records = await DatabaseService.instance.getAllVaccineRecords();
    if (mounted) setState(() { _records = records; _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return RefreshIndicator(
      onRefresh: _loadRecords,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
              background: Container(decoration: const BoxDecoration(gradient: AppTheme.purpleGradient)),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (_records.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90, height: 90,
                      decoration: BoxDecoration(color: AppTheme.primarySurface, shape: BoxShape.circle),
                      child: const Icon(Icons.history_rounded, size: 44, color: AppTheme.primary),
                    ),
                    const SizedBox(height: 20),
                    Text('No History Yet', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text('Your vaccination records will appear here', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.55), fontSize: 14)),
                    const SizedBox(height: 28),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, AppConstants.vaccineScheduleRoute),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add First Vaccine'),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final r = _records[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cs.outline.withValues(alpha: 0.12)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 46, height: 46,
                            decoration: BoxDecoration(
                              color: r.isCompleted ? AppTheme.successLight : AppTheme.warningLight,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Icon(
                              r.isCompleted ? Icons.check_circle_rounded : Icons.schedule_rounded,
                              color: r.isCompleted ? AppTheme.success : AppTheme.warning,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.vaccineName, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: cs.onSurface)),
                                const SizedBox(height: 3),
                                Text(
                                  'Dose ${r.doseNumber ?? "N/A"} · ${r.vaccinationDate.day}/${r.vaccinationDate.month}/${r.vaccinationDate.year}',
                                  style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: r.isCompleted ? AppTheme.successLight : AppTheme.warningLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              r.isCompleted ? 'Done' : 'Pending',
                              style: TextStyle(
                                color: r.isCompleted ? AppTheme.success : AppTheme.warning,
                                fontWeight: FontWeight.w700, fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: _records.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SETTINGS (inline tab)
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsContent extends StatefulWidget {
  const _SettingsContent();

  @override
  State<_SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends State<_SettingsContent> {
  bool _isDark = false;
  bool _notifEnabled = false;
  String _userName = '';
  final _nameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isDark = ThemeNotifier.instance.isDark;
    _loadPrefs();
    ThemeNotifier.instance.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    ThemeNotifier.instance.removeListener(_onThemeChanged);
    _nameCtrl.dispose();
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() => _isDark = ThemeNotifier.instance.isDark);
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _notifEnabled = prefs.getBool('notifications_enabled') ?? false;
        _userName = prefs.getString('user_name') ?? '';
        _nameCtrl.text = _userName;
      });
    }
  }

  Future<void> _saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name.trim());
    if (mounted) setState(() => _userName = name.trim());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 130,
          pinned: true,
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text('Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
            background: Container(decoration: const BoxDecoration(gradient: AppTheme.deepBlueGradient)),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SLabel('PROFILE'),
                _SCard(children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 52, height: 52,
                          decoration: const BoxDecoration(gradient: AppTheme.deepBlueGradient, shape: BoxShape.circle),
                          child: Center(
                            child: Text(
                              _userName.isEmpty ? '?' : _userName.substring(0, 1).toUpperCase(),
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userName.isEmpty ? 'Set your name' : _userName,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                                    color: _userName.isEmpty ? cs.onSurface.withValues(alpha: 0.5) : cs.onSurface),
                              ),
                              Text('VaxGuard Member', style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5))),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => _editName(context),
                          child: Text(_userName.isEmpty ? 'Add' : 'Edit'),
                        ),
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 20),

                _SLabel('APPEARANCE'),
                _SCard(children: [
                  _STile(
                    icon: Icons.dark_mode_rounded, iconColor: AppTheme.purple,
                    title: 'Dark Mode', sub: _isDark ? 'Dark theme' : 'Light theme',
                    trailing: Switch(value: _isDark, onChanged: (v) => ThemeNotifier.instance.setDark(v), activeColor: AppTheme.purple),
                  ),
                ]),
                const SizedBox(height: 20),

                _SLabel('NOTIFICATIONS'),
                _SCard(children: [
                  _STile(
                    icon: Icons.notifications_rounded, iconColor: AppTheme.warning,
                    title: 'Push Notifications', sub: _notifEnabled ? 'Enabled' : 'Tap to enable',
                    trailing: Switch(
                      value: _notifEnabled, activeColor: AppTheme.warning,
                      onChanged: (v) async {
                        if (v) {
                          final ok = await NotificationService.instance.requestPermissions();
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('notifications_enabled', ok);
                          if (mounted) setState(() => _notifEnabled = ok);
                        } else {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('notifications_enabled', false);
                          if (mounted) setState(() => _notifEnabled = false);
                        }
                      },
                    ),
                  ),
                  const Divider(height: 1, indent: 72),
                  _STile(
                    icon: Icons.medication_rounded, iconColor: AppTheme.purple,
                    title: 'Medicine Reminders', sub: 'Manage medications',
                    onTap: () => Navigator.pushNamed(context, AppConstants.medicineReminderRoute),
                  ),
                ]),
                const SizedBox(height: 20),

                _SLabel('DATA'),
                _SCard(children: [
                  _STile(
                    icon: Icons.vaccines_rounded, iconColor: AppTheme.primary,
                    title: 'Vaccine Records', sub: '${DatabaseService.instance.totalVaccines} records',
                    onTap: () => Navigator.pushNamed(context, AppConstants.vaccineScheduleRoute),
                  ),
                  const Divider(height: 1, indent: 72),
                  _STile(
                    icon: Icons.picture_as_pdf_rounded, iconColor: AppTheme.success,
                    title: 'Export PDF', sub: 'Download records',
                    onTap: () => Navigator.pushNamed(context, AppConstants.pdfViewRoute),
                  ),
                  const Divider(height: 1, indent: 72),
                  _STile(
                    icon: Icons.delete_outline_rounded, iconColor: AppTheme.danger,
                    title: 'Clear All Data', sub: 'Permanently delete records',
                    onTap: () => _confirmClear(context),
                  ),
                ]),
                const SizedBox(height: 20),

                _SLabel('ABOUT'),
                _SCard(children: [
                  _STile(
                    icon: Icons.feedback_rounded, iconColor: AppTheme.secondary,
                    title: 'Send Feedback', sub: 'Help us improve',
                    onTap: () => _feedback(context),
                  ),
                  const Divider(height: 1, indent: 72),
                  _STile(
                    icon: Icons.info_outline_rounded, iconColor: AppTheme.textSecondary,
                    title: 'About VaxGuard', sub: 'Version 1.0.0',
                    onTap: () => _about(context),
                  ),
                ]),
                const SizedBox(height: 32),

                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 52, height: 52,
                        decoration: const BoxDecoration(gradient: AppTheme.deepBlueGradient, shape: BoxShape.circle),
                        child: ClipOval(
                          child: Image.asset('assets/images/Applogo.png', fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(child: Text('🛡️', style: TextStyle(fontSize: 26)))),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('VaxGuard v1.0.0', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: cs.onSurface)),
                      Text('Your Health Companion', style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5))),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _editName(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Your Name'),
        content: TextField(
          controller: _nameCtrl,
          decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person_rounded)),
          textCapitalization: TextCapitalization.words,
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await _saveUserName(_nameCtrl.text);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text('This permanently deletes all your vaccine records.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await DatabaseService.instance.deleteAllRecords();
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All data cleared')));
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _feedback(BuildContext context) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        decoration: BoxDecoration(color: Theme.of(ctx).colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Theme.of(ctx).colorScheme.outline.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text('Send Feedback', style: Theme.of(ctx).textTheme.headlineSmall),
              const SizedBox(height: 16),
              TextField(controller: ctrl, maxLines: 4, decoration: const InputDecoration(hintText: 'Share your thoughts...')),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (ctrl.text.trim().isNotEmpty) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thank you for your feedback! 🙏')));
                  },
                  child: const Text('Submit'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _about(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: const BoxDecoration(gradient: AppTheme.deepBlueGradient, shape: BoxShape.circle),
              child: ClipOval(child: Image.asset('assets/images/Applogo.png', fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Center(child: Text('🛡️', style: TextStyle(fontSize: 40))))),
            ),
            const SizedBox(height: 16),
            const Text('VaxGuard', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('Version 1.0.0', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 12),
            const Text('Your complete health companion for vaccine tracking and emergency care.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5)),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
      ),
    );
  }
}

// ── Shared sub-widgets for settings tab ──────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface),
  );
}

class _SLabel extends StatelessWidget {
  final String label;
  const _SLabel(this.label);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 10),
    child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45), letterSpacing: 0.8)),
  );
}

class _SCard extends StatelessWidget {
  final List<Widget> children;
  const _SCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
        boxShadow: [BoxShadow(color: cs.shadow.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: children),
    );
  }
}

class _STile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String sub;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _STile({required this.icon, required this.iconColor, required this.title, required this.sub, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface)),
                  Text(sub, style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.55))),
                ],
              ),
            ),
            if (trailing != null) trailing!
            else if (onTap != null) Icon(Icons.chevron_right_rounded, color: cs.onSurface.withValues(alpha: 0.3), size: 20),
          ],
        ),
      ),
    );
  }
}