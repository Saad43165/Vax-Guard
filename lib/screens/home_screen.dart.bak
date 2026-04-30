import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../utils/app_constants.dart';
import '../../services/database_service.dart';
import '../../models/vaccine_record.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
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
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Home'),
              _buildNavItem(1, Icons.dashboard_rounded, 'Dashboard'),
              _buildNavItem(2, Icons.history_rounded, 'History'),
              _buildNavItem(3, Icons.settings_rounded, 'Settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? AppTheme.primary : AppTheme.textSecondary, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
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

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final db = DatabaseService.instance;
    final total = db.totalVaccines;
    final completed = db.completedVaccines;
    final pending = db.pendingVaccines;
    if (mounted) {
      setState(() {
        _totalVaccines = total;
        _completedVaccines = completed;
        _pendingVaccines = pending;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadStats,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'VaxGuard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(gradient: AppTheme.deepBlueGradient),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_rounded),
                onPressed: () {},
              ),
            ],
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
                      _buildStatCard('Total', _totalVaccines.toString(), Icons.vaccines_rounded, AppTheme.primary),
                      const SizedBox(width: 12),
                      _buildStatCard('Done', _completedVaccines.toString(), Icons.check_circle_rounded, AppTheme.success),
                      const SizedBox(width: 12),
                      _buildStatCard('Pending', _pendingVaccines.toString(), Icons.schedule_rounded, AppTheme.warning),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildQuickAction(context, Icons.pets_rounded, 'Animal Bite', AppConstants.animalBiteRoute, AppTheme.warning)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildQuickAction(context, Icons.medical_services_rounded, 'Hospital', AppConstants.hospitalMapRoute, AppTheme.danger)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildQuickAction(context, Icons.vaccines_rounded, 'Vaccines', AppConstants.vaccineScheduleRoute, AppTheme.primary)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Health Tools', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _buildToolCard(context, Icons.favorite_rounded, 'Health Assessment', 'Evaluate your health risks', AppTheme.danger, AppConstants.triageRoute),
                  const SizedBox(height: 12),
                  _buildToolCard(context, Icons.thermostat_rounded, 'Symptom Checker', 'Check your symptoms', AppTheme.warning, AppConstants.symptomCheckerRoute),
                  const SizedBox(height: 12),
                  _buildToolCard(context, Icons.healing_rounded, 'First Aid Guide', 'Emergency first aid tips', AppTheme.success, AppConstants.firstAidRoute),
                  const SizedBox(height: 12),
                  _buildToolCard(context, Icons.article_rounded, 'Health Tips', 'Daily health advice', AppTheme.purple, AppConstants.healthTipsRoute),
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
          boxShadow: [BoxShadow(color: AppTheme.danger.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.emergency_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Emergency?', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  SizedBox(height: 2),
                  Text('Tap for quick actions', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: const Text('911', style: TextStyle(color: AppTheme.danger, fontWeight: FontWeight.w800, fontSize: 13)),
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
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text('Emergency Options', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 24),
              _buildEmergencyOption(context, Icons.phone_rounded, 'Call Emergency', 'Call 911 or local emergency', AppTheme.danger, () {}),
              const SizedBox(height: 12),
              _buildEmergencyOption(context, Icons.local_hospital_rounded, 'Find Hospital', 'Locate nearby hospitals', AppTheme.primary, () => Navigator.pushNamed(context, AppConstants.hospitalMapRoute)),
              const SizedBox(height: 12),
              _buildEmergencyOption(context, Icons.pets_rounded, 'Animal Bite', 'Assess animal bite severity', AppTheme.warning, () => Navigator.pushNamed(context, AppConstants.animalBiteRoute)),
              const SizedBox(height: 12),
              _buildEmergencyOption(context, Icons.medical_services_rounded, 'First Aid', 'Emergency first aid guide', AppTheme.success, () => Navigator.pushNamed(context, AppConstants.firstAidRoute)),
              const SizedBox(height: 12),
              _buildEmergencyOption(context, Icons.favorite_rounded, 'Health Assessment', 'Quick health risk check', AppTheme.danger, () => Navigator.pushNamed(context, AppConstants.triageRoute)),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyOption(BuildContext context, IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () { Navigator.pop(context); onTap(); },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 15)),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppTheme.shadowSm),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, IconData icon, String label, String route, Color color) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, IconData icon, String title, String subtitle, Color color, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppTheme.shadowSm),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_rounded, color: color, size: 18),
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
    final percentage = db.completionPercentage;
    final total = db.totalVaccines;
    final completed = db.completedVaccines;
    final pending = db.pendingVaccines;
    final upcoming = await db.getUpcomingVaccines();
    if (mounted) {
      setState(() {
        _completionPercentage = percentage;
        _totalVaccines = total;
        _completedVaccines = completed;
        _pendingVaccines = pending;
        _upcomingVaccines = upcoming;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadStats,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Dashboard',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              background: Container(
                decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
              ),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _loadStats),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(gradient: AppTheme.deepBlueGradient, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.shadowPrimary),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Health Score', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 8),
                        Text('${_completionPercentage.toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _completionPercentage / 100,
                            minHeight: 8,
                            backgroundColor: Colors.white.withAlpha(51),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(_completionPercentage >= 75 ? '🏆 Excellent' : _completionPercentage >= 50 ? '💪 Good Progress' : '💉 Keep Going',
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Vaccination Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppTheme.shadowSm),
                    child: Column(
                      children: [
                        _buildProgressRow('Completed', _completedVaccines, _totalVaccines, AppTheme.success),
                        const SizedBox(height: 16),
                        _buildProgressRow('Pending', _pendingVaccines, _totalVaccines, AppTheme.warning),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_upcomingVaccines.isNotEmpty) ...[
                    const Text('Upcoming Vaccinations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    ...List.generate(_upcomingVaccines.length > 3 ? 3 : _upcomingVaccines.length, (i) {
                      final vaccine = _upcomingVaccines[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: AppTheme.shadowSm),
                        child: Row(
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(color: AppTheme.warningLight, borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.vaccines_rounded, color: AppTheme.warning, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(vaccine.vaccineName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                  if (vaccine.nextDoseDate != null)
                                    Text('Due: ${vaccine.nextDoseDate!.day}/${vaccine.nextDoseDate!.month}/${vaccine.nextDoseDate!.year}',
                                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 20),
                  const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildActionCard(Icons.add_rounded, 'Add Vaccine', AppConstants.vaccineScheduleRoute, AppTheme.primary)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildActionCard(Icons.picture_as_pdf_rounded, 'Export PDF', AppConstants.pdfViewRoute, AppTheme.success)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildActionCard(Icons.share_rounded, 'Share', AppConstants.pdfViewRoute, AppTheme.purple)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildActionCard(Icons.download_rounded, 'Backup', AppConstants.pdfViewRoute, AppTheme.warning)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow(String label, int value, int total, Color color) {
    final progress = total > 0 ? value / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text('$value of $total', style: TextStyle(color: color, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(value: progress, minHeight: 12, backgroundColor: AppTheme.border, valueColor: AlwaysStoppedAnimation<Color>(color)),
        ),
      ],
    );
  }

  Widget _buildActionCard(IconData icon, String label, String route, Color color) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
            ),
          ],
        ),
      ),
    );
  }
}

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
    final db = DatabaseService.instance;
    final records = await db.getAllVaccineRecords();
    if (mounted) {
      setState(() {
        _records = records;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadRecords,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100,
            pinned: true,
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'History',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              background: Container(
                decoration: const BoxDecoration(gradient: AppTheme.purpleGradient),
              ),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_records.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 80, height: 80, decoration: BoxDecoration(color: AppTheme.primarySurface, shape: BoxShape.circle),
                        child: const Icon(Icons.history_rounded, size: 40, color: AppTheme.primary)),
                    const SizedBox(height: 16),
                    const Text('No history yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    const Text('Your vaccination records will appear here', style: TextStyle(color: AppTheme.textSecondary)),
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
                    final record = _records[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppTheme.shadowSm),
                      child: Row(
                        children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: record.isCompleted ? AppTheme.successLight : AppTheme.warningLight,
                              borderRadius: BorderRadius.circular(12)),
                            child: Icon(record.isCompleted ? Icons.check_circle_rounded : Icons.schedule_rounded,
                                color: record.isCompleted ? AppTheme.success : AppTheme.warning, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(record.vaccineName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                const SizedBox(height: 2),
                                Text('Dose: ${record.doseNumber ?? "N/A"} • ${record.vaccinationDate.day}/${record.vaccinationDate.month}/${record.vaccinationDate.year}',
                                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: record.isCompleted ? AppTheme.successLight : AppTheme.warningLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              record.isCompleted ? 'Done' : 'Pending',
                              style: TextStyle(
                                color: record.isCompleted ? AppTheme.success : AppTheme.warning,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
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

class _SettingsContent extends StatelessWidget {
  const _SettingsContent();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 100,
          pinned: true,
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text(
              'Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            background: Container(
              decoration: const BoxDecoration(gradient: AppTheme.deepBlueGradient),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSettingsSection('App Settings', [
                  _SettingsTile(Icons.dark_mode_outlined, 'Dark Mode', 'Enable dark theme', () => _showDarkModeDialog(context)),
                  _SettingsTile(Icons.language_outlined, 'Language', 'English (US)', () => _showLanguageDialog(context)),
                  _SettingsTile(Icons.notifications_outlined, 'Notifications', 'Push notification settings', () {}),
                ]),
                const SizedBox(height: 20),
                _buildSettingsSection('Data', [
                  _SettingsTile(Icons.storage_outlined, 'Storage', 'Manage app data', () => _showStorageDialog(context)),
                  _SettingsTile(Icons.picture_as_pdf_outlined, 'Export PDF', 'Download your records', () => Navigator.pushNamed(context, AppConstants.pdfViewRoute)),
                  _SettingsTile(Icons.backup_outlined, 'Backup', 'Cloud backup settings', () {}),
                ]),
                const SizedBox(height: 20),
                _buildSettingsSection('App', [
                  _SettingsTile(Icons.info_outline_rounded, 'About', 'Version 1.0.0', () => _showAboutDialog(context)),
                  _SettingsTile(Icons.help_outline_rounded, 'Help Center', 'FAQs and support', () {}),
                  _SettingsTile(Icons.feedback_outlined, 'Send Feedback', 'Help us improve', () {}),
                ]),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(String title, List<_SettingsTile> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppTheme.shadowSm),
          child: Column(
            children: tiles.asMap().entries.map((entry) {
              final index = entry.key;
              final tile = entry.value;
              return Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: AppTheme.primarySurface, borderRadius: BorderRadius.circular(10)),
                      child: Icon(tile.icon, color: AppTheme.primary, size: 20),
                    ),
                    title: Text(tile.title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                    subtitle: Text(tile.subtitle, style: const TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right, color: AppTheme.textTertiary),
                    onTap: tile.onTap,
                  ),
                  if (index < tiles.length - 1) const Divider(height: 1, indent: 72),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showDarkModeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dark Mode'),
        content: const Text('Dark mode feature coming soon!'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Language'),
        content: const Text('Language selection coming soon!'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  void _showStorageDialog(BuildContext context) {
    final db = DatabaseService.instance;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Storage'),
        content: Text('Vaccine Records: ${db.totalVaccines}'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [Text('🛡️ '), Text('VaxGuard')],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('Your Health Companion'),
            Text('Track vaccines, assess risks, and find healthcare.'),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }
}

class _SettingsTile {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  _SettingsTile(this.icon, this.title, this.subtitle, this.onTap);
}