import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme.dart';
import '../services/database_service.dart';
import '../services/clinical_triage_service.dart';
import '../utils/app_constants.dart';
import '../utils/l10n_helper.dart';

class TriageQuizScreen extends StatefulWidget {
  const TriageQuizScreen({super.key});

  @override
  State<TriageQuizScreen> createState() => _TriageQuizScreenState();
}

class _TriageQuizScreenState extends State<TriageQuizScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final List<String> _selectedSymptoms = [];
  final List<String> _selectedRiskFactors = [];
  int _age = 25;
  bool _hadContact = false;
  final TextEditingController _ageController = TextEditingController(text: '25');
  bool _isSubmitting = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _age = prefs.getInt('user_age') ?? 25;
        _ageController.text = _age.toString();
        
        if (prefs.getBool('has_diabetes') ?? false) _selectedRiskFactors.add('diabetes');
        if (prefs.getBool('has_hypertension') ?? false) _selectedRiskFactors.add('hypertension');
        if (prefs.getBool('has_heart_disease') ?? false) _selectedRiskFactors.add('heart_disease');
        if (prefs.getBool('is_immunocompromised') ?? false) _selectedRiskFactors.add('immunocompromised');
        if (prefs.getBool('has_asthma') ?? false) _selectedRiskFactors.add('asthma');
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _ageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _nextStep() {
    HapticFeedback.mediumImpact();
    if (_currentStep < 4) {
      _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeOutQuart);
      setState(() => _currentStep++);
    } else {
      _submitAssessment();
    }
  }

  void _prevStep() {
    HapticFeedback.lightImpact();
    if (_currentStep > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 500), curve: Curves.easeOutQuart);
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _submitAssessment() async {
    setState(() => _isSubmitting = true);
    HapticFeedback.selectionClick();
    
    await Future.delayed(const Duration(milliseconds: 1200));

    final result = ClinicalTriageService.evaluate(
      selectedSymptoms: _selectedSymptoms,
      selectedRiskFactors: _selectedRiskFactors,
      age: int.tryParse(_ageController.text) ?? _age,
      hadContact: _hadContact,
    );
    
    await DatabaseService.instance.saveHealthAssessment(
      title: L10n.s(context, result.titleKey),
      description: L10n.s(context, result.descriptionKey),
      recommendation: L10n.s(context, result.recommendationKey),
      score: result.score,
      actions: result.actionKeys.map((k) => L10n.s(context, k)).toList(),
      details: result.clinicalFindings.join(', '),
    );

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppConstants.triageResultRoute, arguments: result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background(context),
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildStepIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildIntakeStep(
                    title: L10n.s(context, 'emergency_screening'),
                    subtitle: L10n.s(context, 'seek_care_desc'),
                    icon: Icons.emergency_rounded,
                    color: AppTheme.danger,
                    items: ClinicalTriageService.symptoms.where((s) => s.isRedFlag).toList(),
                    targetList: _selectedSymptoms,
                  ),
                  _buildIntakeStep(
                    title: L10n.s(context, 'symptom_profile'),
                    subtitle: L10n.s(context, 'select_symptoms'),
                    icon: Icons.medical_services_rounded,
                    color: AppTheme.primary,
                    items: ClinicalTriageService.symptoms.where((s) => !s.isRedFlag).toList(),
                    targetList: _selectedSymptoms,
                  ),
                  _buildIntakeStep(
                    title: L10n.s(context, 'medical_history_check'),
                    subtitle: L10n.s(context, 'any_conditions'),
                    icon: Icons.history_edu_rounded,
                    color: AppTheme.purple,
                    items: ClinicalTriageService.riskFactors,
                    targetList: _selectedRiskFactors,
                  ),
                  _buildAgeStep(),
                  _buildContextStep(),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.surface(context),
      elevation: 0,
      centerTitle: true,
      title: Text(
        L10n.s(context, 'triage_quiz'),
        style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.textPrimary(context)),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary(context)),
        onPressed: _prevStep,
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Row(
        children: List.generate(5, (index) {
          final isActive = index <= _currentStep;
          final isCurrent = index == _currentStep;
          final stepColor = index == 0 ? AppTheme.danger : AppTheme.primary;
          
          return Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: isCurrent ? 8 : 4,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isActive ? stepColor : AppTheme.border(context).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isCurrent ? [BoxShadow(color: stepColor.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 2))] : [],
                  ),
                ),
                if (isCurrent)
                  Positioned(
                    top: -10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: stepColor, borderRadius: BorderRadius.circular(10)),
                      child: Text('${index + 1}/5', style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildIntakeStep({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<TriageEntry> items,
    required List<String> targetList,
  }) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(title, subtitle, icon, color),
          const SizedBox(height: 32),
          ...items.map((item) => _buildSelectionCard(item, targetList)),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStepHeader(String title, String subtitle, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color.withOpacity(0.2), color.withOpacity(0.05)]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 32),
        ),
        const SizedBox(height: 24),
        Text(
          title, 
          style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.textPrimary(context), height: 1.1, letterSpacing: -1),
        ),
        const SizedBox(height: 12),
        Text(
          subtitle, 
          style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textSecondary(context), height: 1.4, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildSelectionCard(TriageEntry entry, List<String> targetList) {
    final isSelected = targetList.contains(entry.id);
    final baseColor = entry.isRedFlag ? AppTheme.danger : AppTheme.primary;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          setState(() {
            if (isSelected) targetList.remove(entry.id);
            else targetList.add(entry.id);
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutQuart,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isSelected ? baseColor.withOpacity(0.1) : AppTheme.surface(context),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isSelected ? baseColor : AppTheme.border(context).withOpacity(0.5), 
              width: isSelected ? 3 : 1.5,
            ),
            boxShadow: isSelected 
                ? [BoxShadow(color: baseColor.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8))] 
                : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      L10n.s(context, entry.labelKey), 
                      style: GoogleFonts.outfit(
                        fontSize: 18, 
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700, 
                        color: isSelected ? baseColor : AppTheme.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isSelected ? baseColor : AppTheme.textTertiary(context)).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        L10n.s(context, entry.category).toUpperCase(), 
                        style: GoogleFonts.outfit(
                          fontSize: 10, 
                          fontWeight: FontWeight.w900, 
                          color: isSelected ? baseColor : AppTheme.textTertiary(context), 
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected ? baseColor : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: isSelected ? baseColor : AppTheme.border(context), width: 2),
                  boxShadow: isSelected ? [BoxShadow(color: baseColor.withOpacity(0.3), blurRadius: 8)] : [],
                ),
                child: isSelected ? const Icon(Icons.check_rounded, color: Colors.white, size: 20) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgeStep() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            L10n.s(context, 'about_you'),
            L10n.s(context, 'personalize_desc'),
            Icons.person_pin_rounded,
            AppTheme.success,
          ),
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.surface(context),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppTheme.border(context).withOpacity(0.5), width: 1.5),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 30, offset: const Offset(0, 15))],
            ),
            child: Column(
              children: [
                Text(L10n.s(context, 'age').toUpperCase(), style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppTheme.textTertiary(context), fontSize: 13, letterSpacing: 2)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(_ageController.text, style: GoogleFonts.outfit(fontSize: 72, fontWeight: FontWeight.w900, color: AppTheme.primary, letterSpacing: -2)),
                    const SizedBox(width: 8),
                    Text(L10n.s(context, 'years_old'), style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textSecondary(context))),
                  ],
                ),
                const SizedBox(height: 32),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 12,
                    activeTrackColor: AppTheme.primary,
                    inactiveTrackColor: AppTheme.primary.withOpacity(0.1),
                    thumbColor: Colors.white,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 16, elevation: 6),
                    overlayColor: AppTheme.primary.withOpacity(0.1),
                    trackShape: const RoundedRectSliderTrackShape(),
                  ),
                  child: Slider(
                    value: double.tryParse(_ageController.text)?.clamp(0.0, 100.0) ?? 25.0,
                    min: 0, max: 100,
                    onChanged: (v) {
                      HapticFeedback.selectionClick();
                      setState(() => _ageController.text = v.round().toString());
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('0', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppTheme.textTertiary(context))),
                    Text('100', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppTheme.textTertiary(context))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextStep() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            L10n.s(context, 'exposure_context'),
            L10n.s(context, 'exposure_question'),
            Icons.gpp_maybe_rounded,
            AppTheme.warning,
          ),
          const SizedBox(height: 40),
          _buildRadioCard(L10n.s(context, 'direct_contact'), true, _hadContact, (v) => setState(() => _hadContact = v!)),
          const SizedBox(height: 20),
          _buildRadioCard(L10n.s(context, 'no_exposure'), false, _hadContact, (v) => setState(() => _hadContact = v!)),
        ],
      ),
    );
  }

  Widget _buildRadioCard(String label, bool value, bool groupValue, ValueChanged<bool?> onChanged) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onChanged(value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withOpacity(0.1) : AppTheme.surface(context),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border(context).withOpacity(0.5), 
            width: isSelected ? 3 : 1.5,
          ),
          boxShadow: isSelected ? [BoxShadow(color: AppTheme.primary.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8))] : [],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label, 
                style: GoogleFonts.outfit(
                  fontSize: 20, 
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                  color: isSelected ? AppTheme.primary : AppTheme.textPrimary(context),
                ),
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? AppTheme.primary : AppTheme.border(context), width: isSelected ? 10 : 2),
                color: Colors.white,
              ),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 25, offset: const Offset(0, -10))],
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _prevStep,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                side: BorderSide(color: AppTheme.border(context), width: 2),
              ),
              child: Text(
                _currentStep == 0 ? L10n.s(context, 'cancel') : L10n.s(context, 'back'), 
                style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppTheme.textSecondary(context), fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentStep == 4 ? L10n.s(context, 'analyze_risk') : L10n.s(context, 'continue'), 
                            style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18),
                          ),
                          const SizedBox(width: 10),
                          Icon(_currentStep == 4 ? Icons.analytics_rounded : Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
