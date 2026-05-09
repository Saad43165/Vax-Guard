import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../services/database_service.dart';
import '../services/animal_bite_triage_service.dart';
import '../utils/app_constants.dart';
import '../utils/l10n_helper.dart';

class AnimalBiteScreen extends StatefulWidget {
  const AnimalBiteScreen({super.key});

  @override
  State<AnimalBiteScreen> createState() => _AnimalBiteScreenState();
}

class _AnimalBiteScreenState extends State<AnimalBiteScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final Map<String, String> _answers = {};
  XFile? _woundImage;
  final TextEditingController _notesController = TextEditingController();
  bool _isAnalyzing = false;

  @override
  void dispose() {
    _pageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 7) {
      _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOutCubic);
      setState(() => _currentStep++);
    } else {
      _analyzeBite();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOutCubic);
      setState(() => _currentStep--);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera, maxWidth: 800, maxHeight: 800);
    if (image != null) setState(() => _woundImage = image);
  }

  Future<void> _analyzeBite() async {
    setState(() => _isAnalyzing = true);
    
    // Simulate high-fidelity clinical analysis
    await Future.delayed(const Duration(seconds: 2));

    final triage = AnimalBiteTriageService.instance;
    final category = triage.calculateCategory(
      exposureType: _answers['exposure_type'] ?? 'none',
      anatomicalLocation: _answers['location'] ?? 'none',
      animalBehavior: _answers['behavior'] ?? 'none',
      isStray: (_answers['species'] ?? '').contains('stray'),
    );

    String risk;
    double score;
    switch (category) {
      case ExposureCategory.categoryIII:
        risk = 'Critical';
        score = 0.95;
        break;
      case ExposureCategory.categoryII:
        risk = 'High';
        score = 0.65;
        break;
      case ExposureCategory.categoryI:
        risk = 'Low';
        score = 0.15;
        break;
      default:
        risk = 'Low';
        score = 0.0;
    }

    final findings = triage.getRecommendations(category);
    final schedule = triage.generatePEPSchedule(DateTime.now());
    final categoryStr = category.toString().split('.').last.toUpperCase().replaceAll('CATEGORY', 'Category ');

    await DatabaseService.instance.saveAnimalBiteAssessment(
      answers: _answers,
      result: '$categoryStr - $risk Risk',
      details: _notesController.text.trim(),
    );

    if (mounted) {
      setState(() => _isAnalyzing = false);
      Navigator.pushReplacementNamed(
        context, 
        AppConstants.animalBiteResultRoute,
        arguments: {
          'risk': risk,
          'category': categoryStr,
          'score': score,
          'findings': findings,
          'schedule': schedule.map((d) => d.toIso8601String()).toList(),
          'answers': _answers,
          'notes': _notesController.text.trim(),
          'imagePath': _woundImage?.path,
        }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background(context),
    appBar: AppBar(
  backgroundColor: AppTheme.surface(context),
  elevation: 0,
  scrolledUnderElevation: 0,
  centerTitle: true,
  leading: IconButton(
    icon: Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary(context)),
    onPressed: _currentStep > 0 ? _prevStep : () => Navigator.pop(context),
  ),
  title: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Image.asset('assets/images/appbar_icon.png', height: 26, fit: BoxFit.contain),
      const SizedBox(width: 10),
      Text(
        L10n.s(context, 'animal_bite'),
        style: GoogleFonts.outfit(
          color: AppTheme.textPrimary(context),
          fontWeight: FontWeight.w900,
          fontSize: 18,
        ),
      ),
    ],
  ),
  bottom: PreferredSize(
    preferredSize: const Size.fromHeight(1),
    child: Container(
      color: AppTheme.border(context).withOpacity(0.5),
      height: 1,
    ),
  ),
),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildLanding(),
                _buildAnimalStep(),
                _buildAnatomicalStep(),
                _buildExposureStep(),
                _buildFirstAidStep(),
                _buildPhotoStep(),
                _buildManualNotesStep(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(8, (index) {
          final isActive = index <= _currentStep;
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(color: isActive ? AppTheme.danger : AppTheme.border(context).withOpacity(0.2), borderRadius: BorderRadius.circular(2)),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLanding() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.danger.withOpacity(0.2), AppTheme.danger.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: AppTheme.danger.withOpacity(0.1), blurRadius: 24, offset: const Offset(0, 12)),
              ],
            ),
            child: Icon(Icons.medical_information_rounded, color: AppTheme.danger, size: 64),
          ),
          const SizedBox(height: 40),
          Text(L10n.s(context, 'animal_bite_assessor'), textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 34, fontWeight: FontWeight.w900, color: AppTheme.textPrimary(context))),
          const SizedBox(height: 16),
          Text(
            L10n.s(context, 'rabies_risk_desc'), 
            textAlign: TextAlign.center, 
            style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textSecondary(context), height: 1.5),
          ),
          const SizedBox(height: 64),
          Container(
            width: double.infinity,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: AppTheme.danger.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.danger, 
                foregroundColor: Colors.white, 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: Text(L10n.s(context, 'start_assessment'), style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalStep() {
    return _buildOptionStep('species', 'animal_type', 'select_animal_desc', Icons.pets_rounded, [
      'dog_stray', 'cat_stray', 'wildlife', 'pet_vax', 'rodent'
    ]);
  }

  Widget _buildAnatomicalStep() {
    return _buildOptionStep('location', 'bite_location', 'select_location_desc', Icons.person_rounded, [
      'head_neck_face', 'hands_fingers', 'arms_shoulders', 'trunk_legs'
    ]);
  }

  Widget _buildExposureStep() {
    return _buildOptionStep('exposure_type', 'exposure_severity', 'select_severity_desc', Icons.healing_rounded, [
      'bite_broken', 'scratch_minor', 'licks_broken', 'licks_intact', 'bat_contact'
    ]);
  }

  Widget _buildFirstAidStep() {
    return _buildOptionStep('first_aid', 'immediate_care', 'select_first_aid_desc', Icons.clean_hands_rounded, [
      'washed_soap', 'antiseptic_applied', 'none'
    ]);
  }

  Widget _buildOptionStep(String id, String titleKey, String descKey, IconData icon, List<String> options) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppTheme.danger, size: 24),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    L10n.s(context, 'step').toUpperCase() + ' $_currentStep',
                    style: GoogleFonts.outfit(color: AppTheme.danger, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5),
                  ),
                  Text(
                    'CLINICAL PROTOCOL',
                    style: GoogleFonts.outfit(color: AppTheme.textTertiary(context), fontWeight: FontWeight.w700, fontSize: 10, letterSpacing: 0.5),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(L10n.s(context, titleKey), style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.textPrimary(context))),
          const SizedBox(height: 8),
          Text(L10n.s(context, descKey), style: GoogleFonts.outfit(color: AppTheme.textSecondary(context), fontSize: 15, height: 1.4)),
          const SizedBox(height: 32),
          ...options.map((opt) {
            final isSelected = _answers[id] == opt;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: InkWell(
                onTap: () {
                  setState(() => _answers[id] = opt);
                  Future.delayed(const Duration(milliseconds: 200), _nextStep);
                },
                borderRadius: BorderRadius.circular(18),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.danger.withOpacity(0.08) : AppTheme.surface(context),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? AppTheme.danger : AppTheme.border(context),
                      width: isSelected ? 2.5 : 1,
                    ),
                    boxShadow: isSelected ? [BoxShadow(color: AppTheme.danger.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 4))] : [],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          L10n.s(context, opt),
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                            color: isSelected ? AppTheme.danger : AppTheme.textPrimary(context),
                          ),
                        ),
                      ),
                      if (isSelected) Icon(Icons.check_circle_rounded, color: AppTheme.danger, size: 24),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPhotoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12), 
                decoration: BoxDecoration(color: AppTheme.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(14)), 
                child: Icon(Icons.camera_alt_rounded, color: AppTheme.danger, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                L10n.s(context, 'wound_documentation').toUpperCase(), 
                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.textPrimary(context), letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 320,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.surface(context),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppTheme.border(context), 
                  style: _woundImage == null ? BorderStyle.solid : BorderStyle.none,
                ),
                image: _woundImage != null ? DecorationImage(image: FileImage(File(_woundImage!.path)), fit: BoxFit.cover) : null,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: _woundImage == null 
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_rounded, size: 64, color: AppTheme.textTertiary(context).withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text('Tap to capture photo', style: GoogleFonts.outfit(color: AppTheme.textTertiary(context), fontWeight: FontWeight.w600)),
                      ],
                    ) 
                  : null,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: _nextStep, 
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.danger, 
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ), 
              child: Text(L10n.s(context, 'next_step'), style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualNotesStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12), 
                decoration: BoxDecoration(color: AppTheme.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(14)), 
                child: Icon(Icons.edit_note_rounded, color: AppTheme.danger, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                L10n.s(context, 'additional_details').toUpperCase(), 
                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.textPrimary(context), letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _notesController, 
            maxLines: 6, 
            decoration: InputDecoration(
              hintText: L10n.s(context, 'notes_hint'), 
              hintStyle: GoogleFonts.outfit(color: AppTheme.textTertiary(context)),
              filled: true,
              fillColor: AppTheme.surface(context),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: AppTheme.border(context))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: AppTheme.border(context))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: AppTheme.danger)),
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: _analyzeBite, 
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.danger, 
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ), 
              child: _isAnalyzing 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) 
                  : Text(L10n.s(context, 'analyze_risk'), style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
