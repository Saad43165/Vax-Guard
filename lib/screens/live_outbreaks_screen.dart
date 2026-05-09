import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme.dart';
import '../services/live_outbreak_service.dart';
import '../services/notification_service.dart';
import '../utils/app_constants.dart';
import '../utils/l10n_helper.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:share_plus/share_plus.dart';

class LiveOutbreaksScreen extends StatefulWidget {
  const LiveOutbreaksScreen({super.key});

  @override
  State<LiveOutbreaksScreen> createState() => _LiveOutbreaksScreenState();
}

class _LiveOutbreaksScreenState extends State<LiveOutbreaksScreen>
    with TickerProviderStateMixin {
  late Future<List<OutbreakAlert>> _outbreaksFuture;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _proximityAlertsEnabled = false;
  String _selectedSeverity = 'All';

  @override
  void initState() {
    super.initState();
    _outbreaksFuture = LiveOutbreakService.instance.fetchActiveOutbreaks();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _loadProximityAlertSetting();
  }

  Future<void> _loadProximityAlertSetting() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _proximityAlertsEnabled = prefs.getBool('proximity_alerts_enabled') ?? false);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() => _outbreaksFuture = LiveOutbreakService.instance.fetchActiveOutbreaks(forceRefresh: true));
  }

  Future<void> _toggleProximityAlerts(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value) {
      final granted = await NotificationService.instance.requestPermissions();
      if (!granted) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(L10n.s(context, 'tap_to_enable')), backgroundColor: AppTheme.warning));
        return;
      }
      await prefs.setBool('proximity_alerts_enabled', true);
      if (mounted) setState(() => _proximityAlertsEnabled = true);
      await NotificationService.instance.scheduleProximityAlertDemo();
    } else {
      await prefs.setBool('proximity_alerts_enabled', false);
      if (mounted) setState(() => _proximityAlertsEnabled = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background(context),
      appBar: AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/appbar_icon.png', height: 26, fit: BoxFit.contain),
          const SizedBox(width: 10),
          Text(L10n.s(context, 'live_outbreak_radar'), style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppTheme.textPrimary(context))),
        ],
      ),
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.textPrimary(context),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.border(context).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary(context), size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppTheme.border(context).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.refresh_rounded, color: AppTheme.textPrimary(context), size: 20),
            ),
            onPressed: _refresh,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<List<OutbreakAlert>>(
        future: _outbreaksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: ScaleTransition(scale: _pulseAnimation, child: Icon(Icons.radar_rounded, size: 80, color: AppTheme.primary)));
          }
          if (snapshot.hasError) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.wifi_off_rounded, color: AppTheme.danger, size: 60), const SizedBox(height: 16), Text(L10n.s(context, 'network_error'))]));
          }
          final allAlerts = snapshot.data ?? [];
          final alerts = _selectedSeverity == 'All' 
              ? allAlerts 
              : allAlerts.where((a) => a.severity.toLowerCase() == _selectedSeverity.toLowerCase()).toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(20), child: _buildProximityToggle(snapshot))),
              SliverToBoxAdapter(child: _buildFilterChips()),
              SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 10, 20, 0), child: _buildSectionHeader(alerts.length))),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                sliver: SliverList(delegate: SliverChildBuilderDelegate((context, index) => _buildAlertCard(alerts[index]), childCount: alerts.length)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(int count) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: AppTheme.danger, shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Text('${L10n.s(context, "active_outbreaks").toUpperCase()} ($count)', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textSecondary(context), letterSpacing: 1)),
      ],
    );
  }

  Widget _buildFilterChips() {
    final severities = ['all', 'critical', 'high', 'moderate', 'low'];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: severities.length,
        itemBuilder: (context, index) {
          final severity = severities[index];
          final isSelected = _selectedSeverity.toLowerCase() == severity.toLowerCase();
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(L10n.s(context, severity)),
              selected: isSelected,
              onSelected: (val) {
                setState(() => _selectedSeverity = severity);
              },
              backgroundColor: AppTheme.surface(context),
              selectedColor: AppTheme.primary.withOpacity(0.2),
              showCheckmark: false,
              labelStyle: GoogleFonts.outfit(
                color: isSelected ? AppTheme.primary : AppTheme.textSecondary(context),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
              side: BorderSide(
                color: isSelected ? AppTheme.primary : AppTheme.border(context),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        },
      ),
    );
  }


  Widget _buildProximityToggle(AsyncSnapshot<List<OutbreakAlert>> snapshot) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: _proximityAlertsEnabled 
          ? AppTheme.primary.withOpacity(0.15) 
          : AppTheme.surface(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _proximityAlertsEnabled ? AppTheme.primary : AppTheme.border(context).withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _proximityAlertsEnabled 
              ? AppTheme.primary.withOpacity(0.1) 
              : Colors.black.withOpacity(0.02),
            blurRadius: 15, offset: const Offset(0, 5)
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _proximityAlertsEnabled ? AppTheme.primary : AppTheme.background(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _proximityAlertsEnabled ? Icons.notifications_active_rounded : Icons.notifications_none_rounded, 
              color: _proximityAlertsEnabled ? Colors.black : AppTheme.textSecondary(context), 
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  L10n.s(context, 'outbreak_proximity_alerts'), 
                  style: GoogleFonts.outfit(
                    fontSize: 16, 
                    fontWeight: FontWeight.w900, 
                    color: AppTheme.textPrimary(context),
                  )
                ),
                Text(
                  _proximityAlertsEnabled 
                    ? 'Monitoring: ${snapshot.hasData && snapshot.data!.isNotEmpty ? snapshot.data!.first.region : "Your Region"}' 
                    : L10n.s(context, 'disabled_tap_activate'), 
                  style: GoogleFonts.outfit(
                    fontSize: 12, 
                    color: _proximityAlertsEnabled ? AppTheme.primary : AppTheme.textSecondary(context), 
                    fontWeight: FontWeight.w700
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _proximityAlertsEnabled, 
            onChanged: _toggleProximityAlerts, 
            activeColor: Colors.black,
            activeTrackColor: AppTheme.primary,
            inactiveTrackColor: AppTheme.border(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(OutbreakAlert alert) {
    final color = _getSeverityColor(alert.severity);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.emergency_rounded, color: color, size: 24),
          ),
          title: Text(
            L10n.s(context, alert.disease), 
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textPrimary(context), height: 1.1)
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Icon(Icons.location_on_rounded, size: 14, color: AppTheme.textTertiary(context)),
                const SizedBox(width: 4),
                Text(L10n.s(context, alert.region), style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary(context), fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Text(
              L10n.s(context, alert.severity).toUpperCase(), 
              style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.8)
            ),
          ),
          children: [
            const Divider(height: 1),
            const SizedBox(height: 16),
            Text(
              L10n.s(context, alert.description), 
              style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textPrimary(context), height: 1.6)
            ),
            const SizedBox(height: 20),
            _buildTipsSection(alert.preventionTips),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, AppConstants.symptomCheckerRoute, arguments: {'initialSearch': alert.disease}),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary, 
                      foregroundColor: Colors.black, 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), 
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(L10n.s(context, 'assess_risk_button'), style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filledTonal(
                  onPressed: () {
                    Share.share(
                      '⚠️ HEALTH ALERT: ${L10n.s(context, alert.disease)}\n\n'
                      '📍 Region: ${L10n.s(context, alert.region)}\n'
                      '🔴 Severity: ${L10n.s(context, alert.severity)}\n\n'
                      '${L10n.s(context, alert.description)}\n\n'
                      'Shared via VaxGuard App.',
                    );
                  },
                  icon: const Icon(Icons.share_rounded, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.surfaceVariant(context),
                    padding: const EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsSection(List<String> tips) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.background(context), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(L10n.s(context, 'recommended_actions').toUpperCase(), style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.textTertiary(context), letterSpacing: 1)),
          const SizedBox(height: 12),
          ...tips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 8), 
            child: Row(
              children: [
                Icon(Icons.check_circle_outline_rounded, size: 14, color: AppTheme.primary), 
                const SizedBox(width: 10), 
                Expanded(child: Text(L10n.s(context, tip), style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondary(context))))
              ]
            )
          )),
        ],
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical': return AppTheme.danger;
      case 'high': return AppTheme.riskHigh;
      case 'moderate': return AppTheme.primary;
      default: return AppTheme.success;
    }
  }
}
