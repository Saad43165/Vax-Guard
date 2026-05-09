import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../services/emergency_sos_service.dart';
import '../utils/l10n_helper.dart';

class FirstAidScreen extends StatefulWidget {
  const FirstAidScreen({super.key});

  @override
  State<FirstAidScreen> createState() => _FirstAidScreenState();
}

class _FirstAidScreenState extends State<FirstAidScreen>
    with SingleTickerProviderStateMixin {
  int _selectedCategory = 0;
  late TabController _tabController;

  List<_Category> _getCategories(BuildContext context) => [
    _Category(L10n.s(context, 'animal_bite'), Icons.pets_rounded, AppTheme.danger),
    _Category(L10n.s(context, 'bleeding'), Icons.water_drop_rounded, AppTheme.warning),
    _Category(L10n.s(context, 'burns'), Icons.local_fire_department_rounded, AppTheme.riskHigh),
    _Category(L10n.s(context, 'fracture'), Icons.accessibility_new_rounded, AppTheme.secondary),
    _Category(L10n.s(context, 'choking'), Icons.air_rounded, AppTheme.primary),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedCategory = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = _getCategories(context);
    return Scaffold(
      backgroundColor: AppTheme.background(context),
      appBar: AppBar(
        title: Text(L10n.s(context, 'first_aid_guide'), style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppTheme.textPrimary(context))),
        backgroundColor: AppTheme.surface(context),
        foregroundColor: AppTheme.textPrimary(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary(context)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Column(
        children: [
          _buildEmergencyBanner(),
          _buildCategoryTabs(categories),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _AnimalBiteGuide(),
                _BleedingGuide(),
                _BurnsGuide(),
                _FractureGuide(),
                _ChokingGuide(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.danger.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.danger.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppTheme.danger.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(Icons.emergency_rounded, color: AppTheme.danger, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  L10n.s(context, 'emergency_call'),
                  style: GoogleFonts.outfit(color: AppTheme.danger, fontWeight: FontWeight.w800, fontSize: 15),
                ),
                Text(
                  L10n.s(context, 'life_threatening'),
                  style: GoogleFonts.outfit(color: AppTheme.danger.withOpacity(0.7), fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => EmergencySOSService.instance.callEmergency(),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text(L10n.s(context, 'call_now').toUpperCase(), style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(List<_Category> categories) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == index;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategory = index);
              _tabController.animateTo(index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? cat.color : AppTheme.surface(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? cat.color : AppTheme.border(context)),
              ),
              alignment: Alignment.center,
              child: Row(
                children: [
                  Icon(cat.icon, color: isSelected ? Colors.white : cat.color, size: 16),
                  const SizedBox(width: 8),
                  Text(cat.name, style: GoogleFonts.outfit(color: isSelected ? Colors.white : AppTheme.textPrimary(context), fontWeight: FontWeight.w700, fontSize: 13)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AnimalBiteGuide extends StatefulWidget {
  @override
  State<_AnimalBiteGuide> createState() => _AnimalBiteGuideState();
}

class _AnimalBiteGuideState extends State<_AnimalBiteGuide> {
  final List<bool> _stepsChecked = [false, false, false, false, false];
  int _timerSeconds = 900;
  bool _timerRunning = false;
  bool _timerDone = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() => _timerRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        if (_timerSeconds > 0) {
          _timerSeconds--;
        } else {
          _timerRunning = false;
          _timerDone = true;
          t.cancel();
          _stepsChecked[0] = true;
        }
      });
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _timerSeconds = 900;
      _timerRunning = false;
      _timerDone = false;
    });
  }

  String get _timerLabel {
    final m = _timerSeconds ~/ 60;
    final s = _timerSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      children: [
        _buildStepItem(0, L10n.s(context, 'wash_wound_title'), L10n.s(context, 'wash_wound_desc'), Icons.wash_rounded, AppTheme.danger, hasTimer: true),
        _buildStepItem(1, L10n.s(context, 'apply_soap_title'), L10n.s(context, 'apply_soap_desc'), Icons.healing_rounded, AppTheme.warning),
        _buildStepItem(2, L10n.s(context, 'rinse_dry_title'), L10n.s(context, 'rinse_dry_desc'), Icons.dry_rounded, AppTheme.primary),
        _buildStepItem(3, L10n.s(context, 'apply_antiseptic_title'), L10n.s(context, 'apply_antiseptic_desc'), Icons.medical_services_rounded, AppTheme.success),
        _buildStepItem(4, L10n.s(context, 'seek_medical_title'), L10n.s(context, 'seek_medical_desc'), Icons.local_hospital_rounded, AppTheme.secondary),
      ],
    );
  }

  Widget _buildStepItem(int index, String title, String desc, IconData icon, Color color, {bool hasTimer = false}) {
    final isChecked = _stepsChecked[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isChecked ? color : AppTheme.border(context)),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  '${L10n.s(context, "step")} ${index + 1}: $title',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.textPrimary(context)),
                ),
              ),
              Checkbox(
                value: isChecked,
                onChanged: (v) => setState(() => _stepsChecked[index] = v!),
                activeColor: color,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(desc, style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textSecondary(context), height: 1.5)),
          if (hasTimer) _buildAdvancedTimer(),
        ],
      ),
    );
  }

  Widget _buildAdvancedTimer() {
    final progress = 1.0 - (_timerSeconds / 900.0);
    final color = _timerDone ? AppTheme.success : AppTheme.danger;

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.background(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: AppTheme.surfaceVariant(context),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_timerLabel, style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.textPrimary(context))),
                  Text(L10n.s(context, 'pending').toUpperCase(), style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textTertiary(context))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_timerRunning && !_timerDone)
                ElevatedButton.icon(
                  onPressed: _startTimer,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(L10n.s(context, 'start_timer')),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              if (_timerRunning)
                OutlinedButton.icon(
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.stop_rounded),
                  label: Text(L10n.s(context, 'reset_timer')),
                  style: OutlinedButton.styleFrom(foregroundColor: AppTheme.danger, side: BorderSide(color: AppTheme.danger), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              if (_timerDone)
                Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppTheme.success),
                    const SizedBox(width: 8),
                    Text(L10n.s(context, 'wash_complete'), style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppTheme.success)),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BleedingGuide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      children: [
        _buildInfoCard(context, L10n.s(context, 'apply_pressure_title'), L10n.s(context, 'apply_pressure_desc'), Icons.front_hand_rounded, AppTheme.danger),
        _buildInfoCard(context, L10n.s(context, 'elevate_title'), L10n.s(context, 'elevate_desc'), Icons.upload_rounded, AppTheme.primary),
        _buildInfoCard(context, L10n.s(context, 'add_layers_title'), L10n.s(context, 'add_layers_desc'), Icons.layers_rounded, AppTheme.warning),
        _buildInfoCard(context, L10n.s(context, 'tourniquet_title'), L10n.s(context, 'tourniquet_desc'), Icons.settings_input_component_rounded, Colors.black),
      ],
    );
  }
}

class _BurnsGuide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      children: [
        _buildInfoCard(context, L10n.s(context, 'cool_burn_title'), L10n.s(context, 'cool_burn_desc'), Icons.water_drop_rounded, AppTheme.primary),
        _buildInfoCard(context, L10n.s(context, 'remove_jewelry_title'), L10n.s(context, 'remove_jewelry_desc'), Icons.watch_rounded, AppTheme.warning),
        _buildInfoCard(context, L10n.s(context, 'cover_loosely_title'), L10n.s(context, 'cover_loosely_desc'), Icons.grid_view_rounded, AppTheme.success),
        _buildInfoCard(context, L10n.s(context, 'seek_help_title'), L10n.s(context, 'seek_help_desc'), Icons.local_hospital_rounded, AppTheme.danger),
      ],
    );
  }
}

class _FractureGuide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      children: [
        _buildInfoCard(context, L10n.s(context, 'immobilize_title'), L10n.s(context, 'immobilize_desc'), Icons.do_not_disturb_on_rounded, AppTheme.secondary),
        _buildInfoCard(context, L10n.s(context, 'stop_bleeding_title'), L10n.s(context, 'apply_pressure_desc'), Icons.water_drop_rounded, AppTheme.danger),
        _buildInfoCard(context, L10n.s(context, 'apply_ice_title'), L10n.s(context, 'apply_ice_desc'), Icons.ac_unit_rounded, AppTheme.primary),
        _buildInfoCard(context, L10n.s(context, 'check_circulation_title'), L10n.s(context, 'check_circulation_desc'), Icons.remove_red_eye_rounded, AppTheme.warning),
      ],
    );
  }
}

class _ChokingGuide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      children: [
        _buildInfoCard(context, L10n.s(context, 'encourage_coughing_title'), L10n.s(context, 'encourage_coughing_desc'), Icons.record_voice_over_rounded, AppTheme.success),
        _buildInfoCard(context, L10n.s(context, 'back_blows_title'), L10n.s(context, 'back_blows_desc'), Icons.back_hand_rounded, AppTheme.warning),
        _buildInfoCard(context, L10n.s(context, 'abdominal_thrusts_title'), L10n.s(context, 'abdominal_thrusts_desc'), Icons.accessibility_new_rounded, AppTheme.danger),
        _buildInfoCard(context, L10n.s(context, 'repeat_call_911_title'), L10n.s(context, 'repeat_call_911_desc'), Icons.phone_in_talk_rounded, AppTheme.danger),
      ],
    );
  }
}

Widget _buildInfoCard(BuildContext context, String title, String desc, IconData icon, Color color) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppTheme.surface(context),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppTheme.border(context).withOpacity(0.5)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary(context))),
              const SizedBox(height: 8),
              Text(desc, style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textSecondary(context), height: 1.5)),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Category {
  final String name;
  final IconData icon;
  final Color color;
  const _Category(this.name, this.icon, this.color);
}