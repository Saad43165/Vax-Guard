import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../models/vaccine_record.dart';
import '../../services/database_service.dart';
import '../../utils/app_constants.dart';
import '../widgets/animated_counter.dart';
import '../core/user_profile_notifier.dart';
import '../models/user_profile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();
  List<VaccineRecord> _pendingVaccines = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuart),
    );
    _animationController.forward();
    _loadData();
    UserProfileNotifier.instance.addListener(_onProfileChanged);
  }

  void _onProfileChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadData() async {
    final pending = await DatabaseService.instance.getPendingVaccines();
    if (mounted) {
      setState(() {
        _pendingVaccines = pending;
        _isLoading = false;
      });
    }
  }

  UserProfile get _profile => UserProfileNotifier.instance.profile;

  @override
  void dispose() {
    UserProfileNotifier.instance.removeListener(_onProfileChanged);
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService.instance;
    final total = db.totalVaccines;
    final completed = db.completedVaccines;
    final pendingCount = db.pendingVaccines;
    final progress = db.completionPercentage;

    return Scaffold(
      backgroundColor: AppTheme.background(context),
      appBar: _buildFixedAppBar(),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildClinicalIdentityHeader(),
                    const SizedBox(height: 24),
                    _buildHealthReadinessGauge(progress),
                    const SizedBox(height: 32),
                    _buildProtectionMatrix(progress, completed, pendingCount),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Clinical Quick Actions', Icons.bolt_rounded, AppTheme.secondary),
                    const SizedBox(height: 16),
                    _buildQuickActionGrid(),
                    const SizedBox(height: 32),
                    _buildSectionHeader('AI Health Insights', Icons.auto_awesome_rounded, AppTheme.purple),
                    const SizedBox(height: 16),
                    _buildVisualInsights(progress, total, completed),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Immunization Analytics', Icons.analytics_rounded, AppTheme.primary),
                    const SizedBox(height: 16),
                    _buildStatsRow(total, completed, pendingCount),
                    const SizedBox(height: 16),
                    _buildVaccineProgressChart(completed, pendingCount),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Urgent Requirements', Icons.notification_important_rounded, AppTheme.warning),
                    const SizedBox(height: 16),
                    _buildPriorityActions(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildFixedAppBar() {
    return AppBar(
      backgroundColor: AppTheme.surface(context),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      title: Text(
        'Dashboard',
        style: GoogleFonts.outfit(
          color: AppTheme.textPrimary(context),
          fontWeight: FontWeight.w900,
          fontSize: 18,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: AppTheme.border(context).withOpacity(0.5),
          height: 1,
        ),
      ),
    );
  }

  Widget _buildClinicalIdentityHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border(context).withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _profile.name.isNotEmpty ? _profile.name : 'Health Explorer',
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                Text(
                  '${_profile.age ?? "--"}Y • ${_profile.sex ?? "N/A"} • ${_profile.hasAnyCondition ? "Condition Registered" : "No Conditions"}',
                  style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary(context), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          if (_profile.isHighRisk)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppTheme.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text('HIGH RISK', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.danger)),
            ),
        ],
      ),
    );
  }

  Widget _buildProtectionMatrix(double progress, int total, int pending) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppTheme.border(context).withOpacity(0.5), width: 1.5),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PROTECTION STATUS MATRIX', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textTertiary(context), letterSpacing: 1.5)),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildMatrixCell('Immunity', '${progress.round()}%', Icons.shield_rounded, AppTheme.success),
              _buildMatrixDivider(),
              _buildMatrixCell('Risk level', _getRiskLevel(progress), Icons.analytics_rounded, _getRiskColor(progress)),
              _buildMatrixDivider(),
              _buildMatrixCell('Vulnerability', '${(100 - progress).round()}%', Icons.warning_amber_rounded, AppTheme.danger),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMatrixCell(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textPrimary(context))),
          const SizedBox(height: 4),
          Text(label.toUpperCase(), style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w800, color: AppTheme.textSecondary(context), letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildMatrixDivider() {
    return Container(height: 40, width: 1, color: AppTheme.border(context).withOpacity(0.5));
  }

  String _getRiskLevel(double progress) {
    if (progress >= 80) return 'LOW';
    if (progress >= 50) return 'MEDIUM';
    return 'HIGH';
  }

  Color _getRiskColor(double progress) {
    if (progress >= 80) return AppTheme.success;
    if (progress >= 50) return AppTheme.warning;
    return AppTheme.danger;
  }

  Widget _buildVisualInsights(double progress, int total, int completed) {
    final insights = _generateInsights(progress, total, completed);
    return Column(
      children: insights.map((insight) {
        final color = insight['color'] as Color;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withOpacity(0.2), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
                child: Icon(insight['icon'] as IconData, color: color, size: 24),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight['title'] as String,
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: color),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      insight['text'] as String,
                      style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textSecondary(context), fontWeight: FontWeight.w600, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<Map<String, Object>> _generateInsights(double progress, int total, int completed) {
    final insights = <Map<String, Object>>[];
    if (total == 0) {
      insights.add({
        'title': 'System Initialization',
        'icon': Icons.rocket_launch_rounded,
        'color': AppTheme.primary,
        'text': 'Register your primary vaccinations to begin automated health monitoring.'
      });
    } else if (progress >= 80) {
      insights.add({
        'title': 'Optimal Protection',
        'icon': Icons.verified_rounded,
        'color': AppTheme.success,
        'text': 'Your clinical profile shows high readiness against common seasonal pathogens.'
      });
    } else {
      insights.add({
        'title': 'Coverage Warning',
        'icon': Icons.warning_rounded,
        'color': AppTheme.warning,
        'text': 'Gaps identified in immunization schedule. Risk of breakthrough infection is elevated.'
      });
    }
    insights.add({
      'title': 'Epidemiological Note',
      'icon': Icons.radar_rounded,
      'color': AppTheme.purple,
      'text': 'AI engines suggest monitoring regional outbreak radar for proactive seasonal protection.'
    });
    return insights;
  }

  Widget _buildPriorityActions() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    
    if (_pendingVaccines.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surface(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.border(context).withOpacity(0.5)),
        ),
        child: Column(
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: AppTheme.success, size: 48),
            const SizedBox(height: 16),
            Text('Profile Fully Verified', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              'No immediate clinical interventions required.', 
              style: GoogleFonts.outfit(color: AppTheme.textSecondary(context), fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _pendingVaccines.take(2).map((v) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surface(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.border(context).withOpacity(0.5)),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.notification_important_rounded, color: AppTheme.warning, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(v.vaccineName, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('Scheduled dose is pending. Coordinate with a provider.', style: GoogleFonts.outfit(color: AppTheme.textSecondary(context), fontSize: 12, height: 1.3)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppTheme.textTertiary(context)),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary(context)),
        ),
      ],
    );
  }

  Widget _buildHealthReadinessGauge(double progress) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          Text(
            'HEALTH READINESS SCORE',
            style: GoogleFonts.outfit(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: CircularProgressIndicator(
                  value: progress / 100,
                  strokeWidth: 14,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                children: [
                  AnimatedCounter(
                    value: progress.round(),
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'PERCENT',
                    style: GoogleFonts.outfit(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildGaugeStat('Protection', '${progress.round()}%', Icons.verified_user_rounded),
              _buildGaugeStat('Assessments', '${DatabaseService.instance.totalHistoryCount}', Icons.assignment_turned_in_rounded),
              _buildGaugeStat('Vulnerability', '${100 - progress.round()}%', Icons.warning_amber_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGaugeStat(String label, String val, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.7), size: 18),
        const SizedBox(height: 4),
        Text(val, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
        Text(label, style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildQuickActionGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.35,
      children: [
        _buildActionCard('Animal Bite\nAssessor', Icons.pets_rounded, AppTheme.warning, () => Navigator.pushNamed(context, AppConstants.animalBiteRoute)),
        _buildActionCard('Export\nReports', Icons.picture_as_pdf_rounded, AppTheme.purple, () => Navigator.pushNamed(context, AppConstants.historyRoute)),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.border(context).withOpacity(0.5)),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24),
            ),
            Text(
              title,
              style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.textPrimary(context), height: 1.1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(int total, int completed, int pending) {
    return Row(
      children: [
        Expanded(child: _buildMetricTile('Total Records', '$total', AppTheme.primary)),
        const SizedBox(width: 12),
        Expanded(child: _buildMetricTile('Immunized', '$completed', AppTheme.success)),
        const SizedBox(width: 12),
        Expanded(child: _buildMetricTile('Outstanding', '$pending', AppTheme.warning)),
      ],
    );
  }

  Widget _buildMetricTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border(context).withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w800, color: AppTheme.textSecondary(context), letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildVaccineProgressChart(int completed, int pending) {
    if (completed == 0 && pending == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.border(context).withOpacity(0.5)),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Coverage Distribution', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16)),
              Icon(Icons.pie_chart_rounded, color: AppTheme.textTertiary(context), size: 20),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sections: [
                  if (completed > 0) 
                    PieChartSectionData(
                      value: completed.toDouble(), 
                      color: AppTheme.success, 
                      title: '${((completed/(completed+pending))*100).round()}%',
                      titleStyle: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                      radius: 35,
                    ),
                  if (pending > 0) 
                    PieChartSectionData(
                      value: pending.toDouble(), 
                      color: AppTheme.warning, 
                      title: '${((pending/(completed+pending))*100).round()}%',
                      titleStyle: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                      radius: 35,
                    ),
                ],
                centerSpaceRadius: 45,
                sectionsSpace: 5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _chartLegend(AppTheme.success, 'Fully Immunized'),
              const SizedBox(width: 24),
              _chartLegend(AppTheme.warning, 'Awaiting Doses'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chartLegend(Color color, String label) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary(context), fontWeight: FontWeight.w700)),
      ],
    );
  }
}
