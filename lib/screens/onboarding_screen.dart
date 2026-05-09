import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../models/user_profile.dart';
import '../core/user_profile_notifier.dart';
import '../utils/app_constants.dart';
import '../utils/l10n_helper.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  String? _sex;
  bool _isPregnant = false;
  bool _hasDiabetes = false;
  bool _hasHypertension = false;
  bool _hasHeartDisease = false;
  bool _hasAsthma = false;
  bool _hasKidneyDisease = false;
  bool _isImmunocompromised = false;

  late List<_OnboardingPage> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _OnboardingPage(title: 'welcome', build: _buildWelcomePage),
      _OnboardingPage(title: 'about_you', build: _buildProfilePage),
      _OnboardingPage(title: 'health_profile', build: _buildHealthPage),
      _OnboardingPage(title: 'all_set', build: _buildCompletePage),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, index) => SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _pages[index].build(context),
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          if (_currentPage > 0)
            IconButton(
              onPressed: () => _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
              icon: const Icon(Icons.arrow_back_rounded),
            )
          else
            const SizedBox(width: 48),
          const Spacer(),
          if (_currentPage > 0 && _currentPage < _pages.length - 1)
            TextButton(
              onPressed: _finish,
              child: Text(
                'Skip',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ),
          const SizedBox(width: 16),
          Text(
            '${_currentPage + 1} / ${_pages.length}',
            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textSecondary(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final isLast = _currentPage == _pages.length - 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: List.generate(_pages.length, (i) {
              final isActive = i == _currentPage;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive ? AppTheme.primary : AppTheme.border(context).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isLast ? _finish : _next,
              child: Text(
                isLast ? L10n.s(context, 'get_started') : L10n.s(context, 'continue'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _next() {
    if (_currentPage == 1) {
      if (_nameCtrl.text.trim().isEmpty) {
        _showSnack(L10n.s(context, 'enter_name'));
        return;
      }
      if (_ageCtrl.text.trim().isEmpty) {
        _showSnack(L10n.s(context, 'enter_age'));
        return;
      }
      if (_sex == null) {
        _showSnack(L10n.s(context, 'select_sex'));
        return;
      }
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _finish() async {
    final profile = UserProfile(
      name: _nameCtrl.text.trim(),
      age: int.tryParse(_ageCtrl.text.trim()),
      sex: _sex,
      isPregnant: _isPregnant,
      hasDiabetes: _hasDiabetes,
      hasHypertension: _hasHypertension,
      hasHeartDisease: _hasHeartDisease,
      hasAsthma: _hasAsthma,
      hasKidneyDisease: _hasKidneyDisease,
      isImmunocompromised: _isImmunocompromised,
      hasCompletedOnboarding: true,
    );
    await UserProfileNotifier.instance.updateProfile(profile);
    if (mounted) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        Navigator.pushReplacementNamed(context, AppConstants.homeRoute);
      }
    }
  }

  Widget _buildWelcomePage(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        // Zoomed in App Logo
        Container(
          width: 150, 
          height: 150, 
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 40, offset: const Offset(0, 10)),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/splash_icon.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.health_and_safety_rounded,
                color: Colors.white,
                size: 70,
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
        Text(
          'VAXGUARD',
          style: GoogleFonts.outfit(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            color: AppTheme.textPrimary(context),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          L10n.s(context, 'onboarding_welcome_desc'),
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textSecondary(context), height: 1.5),
        ),
        const SizedBox(height: 48),
        _buildFeatureItem(Icons.analytics_rounded, AppTheme.primary, 'Health Analysis', 'AI-powered clinical assessment'),
        const SizedBox(height: 16),
        _buildFeatureItem(Icons.vaccines_rounded, AppTheme.purple, 'Vaccine Tracking', 'Smart schedule & record management'),
        const SizedBox(height: 16),
        _buildFeatureItem(Icons.emergency_rounded, AppTheme.danger, 'Emergency Mode', 'Quick access to first aid & help'),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, Color color, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border(context).withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16)),
                Text(desc, style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondary(context))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(L10n.s(context, 'tell_us_about_you'), style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text(L10n.s(context, 'personalize_experience'), style: GoogleFonts.outfit(color: AppTheme.textSecondary(context))),
        const SizedBox(height: 32),
        _buildInputField(_nameCtrl, 'Full Name', Icons.person_rounded),
        const SizedBox(height: 20),
        _buildInputField(_ageCtrl, 'Age', Icons.calendar_today_rounded, isNumeric: true),
        const SizedBox(height: 32),
        Text('Select Sex', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildSexChip('Male', Icons.male_rounded),
            const SizedBox(width: 12),
            _buildSexChip('Female', Icons.female_rounded),
            const SizedBox(width: 12),
            _buildSexChip('Other', Icons.transgender_rounded),
          ],
        ),
      ],
    );
  }

  Widget _buildInputField(TextEditingController ctrl, String label, IconData icon, {bool isNumeric = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textSecondary(context))),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          inputFormatters: isNumeric ? [FilteringTextInputFormatter.digitsOnly] : null,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20),
            hintText: 'Enter your $label',
          ),
        ),
      ],
    );
  }

  Widget _buildSexChip(String label, IconData icon) {
    final isSelected = _sex == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _sex = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : AppTheme.surface(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? AppTheme.primary : AppTheme.border(context)),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.black : AppTheme.textSecondary(context)),
              const SizedBox(height: 4),
              Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 12, color: isSelected ? Colors.black : AppTheme.textSecondary(context))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthPage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(L10n.s(context, 'medical_profile'), style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text(L10n.s(context, 'select_relevant_conditions'), style: GoogleFonts.outfit(color: AppTheme.textSecondary(context))),
        const SizedBox(height: 24),
        _buildToggleCard('Diabetes', Icons.bloodtype_rounded, _hasDiabetes, (v) => setState(() => _hasDiabetes = v)),
        _buildToggleCard('Hypertension', Icons.monitor_heart_rounded, _hasHypertension, (v) => setState(() => _hasHypertension = v)),
        _buildToggleCard('Heart Disease', Icons.favorite_rounded, _hasHeartDisease, (v) => setState(() => _hasHeartDisease = v)),
        _buildToggleCard('Asthma', Icons.air_rounded, _hasAsthma, (v) => setState(() => _hasAsthma = v)),
        _buildToggleCard('Kidney Disease', Icons.opacity_rounded, _hasKidneyDisease, (v) => setState(() => _hasKidneyDisease = v)),
        _buildToggleCard('Immunocompromised', Icons.shield_rounded, _isImmunocompromised, (v) => setState(() => _isImmunocompromised = v)),
        if (_sex == 'Female')
          _buildToggleCard('Is Pregnant', Icons.pregnant_woman_rounded, _isPregnant, (v) => setState(() => _isPregnant = v)),
      ],
    );
  }

  Widget _buildToggleCard(String title, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border(context).withOpacity(0.5)),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        secondary: Icon(icon, color: AppTheme.primary),
        activeColor: AppTheme.primary,
      ),
    );
  }

  Widget _buildCompletePage(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          width: 120,
          height: 120,
          decoration: const BoxDecoration(gradient: AppTheme.successGradient, shape: BoxShape.circle),
          child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 64),
        ),
        const SizedBox(height: 32),
        Text('All Set!', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        Text(
          'Your medical profile has been encrypted and saved securely. You can now access all diagnostic tools.',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textSecondary(context), height: 1.5),
        ),
        const SizedBox(height: 48),
        _buildSummaryRow('Name', _nameCtrl.text),
        _buildSummaryRow('Age', _ageCtrl.text),
        _buildSummaryRow('Sex', _sex ?? 'N/A'),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppTheme.textSecondary(context))),
          Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppTheme.textPrimary(context))),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final String title;
  final Widget Function(BuildContext) build;
  _OnboardingPage({required this.title, required this.build});
}
