import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../models/user_profile.dart';
import '../services/database_service.dart';
import '../services/symptom_analysis_service.dart';
import '../services/user_profile_service.dart';
import '../utils/l10n_helper.dart';
import '../l10n/app_localizations.dart';
import '../utils/app_constants.dart';


class SymptomCheckerScreen extends StatefulWidget {
  const SymptomCheckerScreen({super.key});

  @override
  State<SymptomCheckerScreen> createState() => _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState extends State<SymptomCheckerScreen> with TickerProviderStateMixin {
  final Map<String, UserSymptom> _selectedSymptoms = {};
  final Set<String> _selectedRegions = {};
  final TextEditingController _notesController = TextEditingController();
  bool _showSymptoms = false;
  UserProfile? _profile;
  bool _isAnalyzing = false;
  
  late AnimationController _animController;

  final List<String> _regions = [
    'General', 'Head', 'Chest', 'Heart', 'Abdomen', 'Skin', 'Legs', 'Arms', 'Eyes', 'Ears', 'Musculoskeletal'
  ];

  final Map<String, Color> _regionColors = {
    'General': Color(0xFF00D2FF),
    'Head': Color(0xFF3A86FF),
    'Chest': Color(0xFF00E676),
    'Heart': Color(0xFFFF1744),
    'Abdomen': Color(0xFFF59E0B),
    'Skin': Color(0xFFFF007A),
    'Legs': Color(0xFF8A2BE2),
    'Arms': Color(0xFF00B4DB),
    'Eyes': Color(0xFF3D5AFE),
    'Ears': Color(0xFFD500F9),
    'Musculoskeletal': Color(0xFF607D8B),
  };

  final Map<String, IconData> _regionIcons = {
    'General': Icons.person_rounded,
    'Head': Icons.face_rounded,
    'Chest': Icons.air_rounded,
    'Heart': Icons.favorite_rounded,
    'Abdomen': Icons.spa_rounded,
    'Skin': Icons.dry_cleaning_rounded,
    'Legs': Icons.directions_walk_rounded,
    'Arms': Icons.front_hand_rounded,
    'Eyes': Icons.visibility_rounded,
    'Ears': Icons.hearing_rounded,
    'Musculoskeletal': Icons.accessibility_new_rounded,
  };

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _animController.forward();
    _loadProfile();
  }
  
  @override
  void dispose() {
    _animController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final profile = await UserProfileService.getProfile();
    if (mounted) setState(() => _profile = profile);
  }

  void _toggleSymptom(SymptomDefinition symptom) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_selectedSymptoms.containsKey(symptom.id)) {
        _selectedSymptoms.remove(symptom.id);
      } else {
        _selectedSymptoms[symptom.id] = UserSymptom(id: symptom.id, severity: 5, duration: '1-2 days');
      }
    });
  }

  Widget _buildBodyRegionSelector({Key? key}) {
    return Column(
      key: key,
      children: [
        GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.85,
          ),
          itemCount: _regions.length,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final region = _regions[index];
            final icon = _regionIcons[region] ?? Icons.help_outline_rounded;
            final isSelected = _selectedRegions.contains(region);
            final regionColor = _regionColors[region] ?? AppTheme.primary;
            
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  if (isSelected) {
                    _selectedRegions.remove(region);
                  } else {
                    _selectedRegions.add(region);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutQuart,
                decoration: BoxDecoration(
                  color: isSelected ? regionColor.withOpacity(0.12) : AppTheme.surface(context),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isSelected ? regionColor : AppTheme.border(context).withOpacity(0.4), 
                    width: isSelected ? 3 : 1.5,
                  ),
                  boxShadow: isSelected 
                      ? [BoxShadow(color: regionColor.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 6))]
                      : AppTheme.shadowSm,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? regionColor.withOpacity(0.2) : regionColor.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: isSelected ? regionColor : regionColor.withOpacity(0.6), size: 26),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      L10n.s(context, region.toLowerCase()),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        color: isSelected ? regionColor : AppTheme.textPrimary(context),
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 100), // Space for button
      ],
    );
  }

  Widget _buildSymptomList({Key? key}) {
    final regionSymptoms = SymptomAnalysisService.symptomsForRegions(_selectedRegions);
    
    return Column(
      key: key,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _showSymptoms = false),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary(context), size: 20),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                L10n.s(context, 'select_specific'),
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary(context),
                ),
              ),
            ],
          ),
        ),
        ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: regionSymptoms.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final symptom = regionSymptoms[index];
            return _buildSymptomTile(symptom);
          },
        ),
        _buildManualNotesField(),
        const SizedBox(height: 140),
      ],
    );
  }

  Widget _buildSymptomTile(SymptomDefinition symptom) {
    final isSelected = _selectedSymptoms.containsKey(symptom.id);
    final userSym = _selectedSymptoms[symptom.id];
    final regionColor = _regionColors[symptom.bodyRegion] ?? AppTheme.primary;
    
    // Dynamic color based on severity
    Color getSeverityColor(int value) {
      if (value <= 3) return AppTheme.success;
      if (value <= 7) return AppTheme.warning;
      return AppTheme.danger;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutQuart,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? getSeverityColor(userSym?.severity ?? 5).withOpacity(0.08) : AppTheme.surface(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? getSeverityColor(userSym?.severity ?? 5) : AppTheme.border(context).withOpacity(0.5), 
          width: isSelected ? 2.5 : 1.5,
        ),
        boxShadow: isSelected ? [BoxShadow(color: getSeverityColor(userSym?.severity ?? 5).withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))] : [],
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () => _toggleSymptom(symptom),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? getSeverityColor(userSym?.severity ?? 5).withOpacity(0.15) : regionColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isSelected ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded, 
                color: isSelected ? getSeverityColor(userSym?.severity ?? 5) : regionColor.withOpacity(0.5),
                size: 24,
              ),
            ),
            title: Text(
              L10n.s(context, symptom.id), 
              style: GoogleFonts.outfit(
                fontSize: 17, 
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700, 
                color: AppTheme.textPrimary(context),
              ),
            ),
            trailing: Icon(Icons.tune_rounded, color: isSelected ? getSeverityColor(userSym?.severity ?? 5) : AppTheme.textTertiary(context), size: 20),
          ),
          if (isSelected)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        L10n.s(context, 'severity'), 
                        style: GoogleFonts.outfit(color: AppTheme.textSecondary(context), fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: getSeverityColor(userSym!.severity),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [BoxShadow(color: getSeverityColor(userSym.severity).withOpacity(0.3), blurRadius: 8)],
                        ),
                        child: Text(
                          '${userSym.severity}/10', 
                          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 8,
                      activeTrackColor: getSeverityColor(userSym.severity),
                      inactiveTrackColor: getSeverityColor(userSym.severity).withOpacity(0.15),
                      thumbColor: Colors.white,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12, elevation: 4),
                      overlayColor: getSeverityColor(userSym.severity).withOpacity(0.1),
                      trackShape: const RoundedRectSliderTrackShape(),
                    ),
                    child: Slider(
                      value: userSym.severity.toDouble(),
                      min: 1, max: 10, divisions: 9,
                      onChanged: (v) {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedSymptoms[symptom.id] = UserSymptom(id: symptom.id, severity: v.round(), duration: userSym.duration));
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildManualNotesField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(L10n.s(context, 'additional_details'), style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary(context))),
          const SizedBox(height: 14),
          TextField(
            controller: _notesController,
            maxLines: 4,
            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: L10n.s(context, 'type_notes_here'),
              fillColor: AppTheme.surface(context),
              filled: true,
              hintStyle: GoogleFonts.outfit(color: AppTheme.textTertiary(context)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: AppTheme.border(context))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: AppTheme.border(context))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: AppTheme.primary, width: 2)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_showSymptoms && _selectedRegions.isEmpty,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (_showSymptoms) {
          setState(() => _showSymptoms = false);
        } else if (_selectedRegions.isNotEmpty) {
          setState(() => _selectedRegions.clear());
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.background(context),
        appBar: AppBar(
          title: Text(L10n.s(context, 'symptom_evaluator'), style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 20)),
          backgroundColor: AppTheme.surface(context),
          foregroundColor: AppTheme.textPrimary(context),
          elevation: 0,
          centerTitle: true,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                    child: Text(
                      !_showSymptoms ? L10n.s(context, 'where_discomfort') : L10n.s(context, 'select_specific'),
                      style: GoogleFonts.outfit(fontSize: 30, fontWeight: FontWeight.w900, color: AppTheme.textPrimary(context), letterSpacing: -1),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      L10n.s(context, 'ai_correlate'),
                      style: GoogleFonts.outfit(color: AppTheme.textSecondary(context), fontSize: 16, fontWeight: FontWeight.w500, height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: !_showSymptoms 
                        ? _buildBodyRegionSelector(key: const ValueKey('regions')) 
                        : _buildSymptomList(key: const ValueKey('symptoms')),
                  ),
                ],
              ),
            ),
            if (!_showSymptoms && _selectedRegions.isNotEmpty)
              Positioned(
                left: 24, right: 24, bottom: MediaQuery.of(context).padding.bottom + 24,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 25, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => setState(() => _showSymptoms = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary, 
                      foregroundColor: Colors.white, 
                      padding: const EdgeInsets.symmetric(vertical: 22), 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), 
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Next: Symptoms (${_selectedRegions.length} Regions)', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18)),
                        const SizedBox(width: 10),
                        const Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            if (_showSymptoms && _selectedSymptoms.isNotEmpty)
              Positioned(
                left: 0, right: 0, bottom: 0,
                child: _buildBottomBar(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
        border: Border(top: BorderSide(color: AppTheme.border(context).withOpacity(0.5))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() => _selectedSymptoms.clear()),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                side: BorderSide(color: AppTheme.border(context), width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: Text(L10n.s(context, 'clear'), style: GoogleFonts.outfit(color: AppTheme.textSecondary(context), fontWeight: FontWeight.w800, fontSize: 16)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: ElevatedButton(
                onPressed: _isAnalyzing ? null : _analyze,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 0,
                ),
                child: _isAnalyzing
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.analytics_rounded, size: 20),
                          const SizedBox(width: 10),
                          Text('${L10n.s(context, 'run_ai_analysis')} (${_selectedSymptoms.length})', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16)),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _analyze() async {
    setState(() => _isAnalyzing = true);
    await Future.delayed(const Duration(milliseconds: 2000));

    final result = SymptomAnalysisService.analyze(
      userSymptoms: _selectedSymptoms.values.toList(),
      profile: _profile,
    );

    final answers = <String, String>{
      'Symptoms': _selectedSymptoms.values.map((s) => L10n.s(context, s.id)).join(', '),
      if (_notesController.text.isNotEmpty) 'Additional Notes': _notesController.text,
    };

    await DatabaseService.instance.saveSymptomCheckerAssessment(
      selectedSymptoms: _selectedSymptoms.keys.toSet(),
      severity: result.overallRisk,
      score: result.overallScore,
      summary: result.overallRisk,
      recommendations: result.topRecommendations,
      details: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      AppConstants.assessmentResultRoute,
      arguments: <String, dynamic>{
        'title': L10n.s(context, 'analysis_complete'),
        'subtitle': L10n.s(context, result.overallRisk),
        'severity': result.overallRisk,
        'score': result.overallScore,
        'summary': result.differentialDiagnosis.isNotEmpty
            ? '${L10n.s(context, 'top_match')}: ${result.differentialDiagnosis.first.name} (${result.differentialDiagnosis.first.matchPercentage}%)'
            : L10n.s(context, 'no_strong_pattern'),
        'actions': result.topRecommendations,
        'drivers': result.urgentFlags,
        'details': _notesController.text,
        'type': 'symptom_checker',
        'answers': answers,
        'differential': result.differentialDiagnosis.map((d) => {
          'name': d.name,
          'category': d.category,
          'percentage': d.matchPercentage,
          'riskLevel': d.riskLevel,
          'recommendation': d.recommendation,
        }).toList(),
      },
    );
  }
}
