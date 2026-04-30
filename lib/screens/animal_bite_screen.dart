import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../core/theme.dart';
import '../../services/sqlite_service.dart';
import '../../utils/app_constants.dart';

class AnimalBiteScreen extends StatefulWidget {
  const AnimalBiteScreen({super.key});

  @override
  State<AnimalBiteScreen> createState() => _AnimalBiteScreenState();
}

class _AnimalBiteScreenState extends State<AnimalBiteScreen> with SingleTickerProviderStateMixin {
  String _step = 'landing';
  final Map<String, String> _answers = {};
  XFile? _woundImage;
  String _result = '';
  int _currentQ = 0;
  final TextEditingController _inputController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, String>> _questions = [
    {'id': 'animal', 'label': 'Which animal bit you?', 'placeholder': 'e.g. dog, cat, bat, rabbit, fox...'},
    {'id': 'time', 'label': 'How long ago did the bite occur?', 'placeholder': 'e.g. 30 minutes, 2 hours, yesterday...'},
    {'id': 'location', 'label': 'Where on the body is the bite?', 'placeholder': 'e.g. hand, leg, face, arm...'},
    {'id': 'depth', 'label': 'How deep does the wound look?', 'placeholder': 'e.g. scratch, broke skin, deep puncture...'},
    {'id': 'bleeding', 'label': 'Is/was it bleeding?', 'placeholder': 'e.g. yes heavily, minor bleeding, no bleeding...'},
    {'id': 'animal_status', 'label': 'Do you know the animal status?', 'placeholder': 'e.g. vaccinated, stray, unknown, foaming...'},
    {'id': 'region', 'label': 'What country/region are you in?', 'placeholder': 'e.g. India, USA, Southeast Asia...'},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: AppTheme.danger),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context);
                final image = await picker.pickImage(source: ImageSource.camera, maxWidth: 800, maxHeight: 800, imageQuality: 70);
                if (image != null) setState(() => _woundImage = image);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppTheme.danger),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800, maxHeight: 800, imageQuality: 70);
                if (image != null) setState(() => _woundImage = image);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _nextQuestion() {
    if (_inputController.text.trim().isEmpty) return;
    final q = _questions[_currentQ];
    setState(() {
      _answers[q['id']!] = _inputController.text.trim();
      _inputController.text = '';
    });
    if (_currentQ < _questions.length - 1) {
      setState(() => _currentQ++);
    } else {
      _analyzeCase();
    }
  }

  void _goBack() {
    if (_currentQ > 0) {
      setState(() {
        _currentQ--;
        _inputController.text = _answers[_questions[_currentQ]['id']] ?? '';
      });
    }
  }

  void _analyzeCase() {
    setState(() => _step = 'analyzing');
    Future.delayed(const Duration(seconds: 2), () {
      final analysis = _performWHOAssessment();
      _animController.forward();
      setState(() {
        _result = analysis;
        _step = 'result';
      });
      _saveAssessment();
    });
  }

  String _performWHOAssessment() {
    final animal = (_answers['animal'] ?? '').toLowerCase();
    final depth = (_answers['depth'] ?? '').toLowerCase();
    final bleeding = (_answers['bleeding'] ?? '').toLowerCase();
    final animalStatus = (_answers['animal_status'] ?? '').toLowerCase();
    
    final highRiskAnimals = ['dog', 'cat', 'bat', 'raccoon', 'fox', 'skunk', 'wolf', 'coyote'];
    final lowRiskAnimals = ['rabbit', 'hamster', 'guinea pig', 'squirrel', 'mouse', 'rat'];
    
    bool isHighRisk = highRiskAnimals.any((a) => animal.contains(a));
    bool isLowRisk = lowRiskAnimals.any((a) => animal.contains(a));
    bool isDeep = depth.contains('deep') || depth.contains('puncture');
    bool isSevereBleeding = bleeding.contains('heavy') || bleeding.contains('severely');
    bool isStrayOrWild = animalStatus.contains('stray') || animalStatus.contains('unknown') || animalStatus.contains('wild') || animalStatus.contains('foaming');
    
    String severity, firstAid, medicalTreatment, timeUrgency, riskFactors, recos;
    
    if (isHighRisk && (isDeep || isSevereBleeding || isStrayOrWild)) {
      severity = '🚨 EMERGENCY';
      firstAid = '1. 🧼 Wash wound with soap for 15+ MINUTES\n2. 🧴 Apply povidone-iodine\n3. 🩹 DO NOT suture wound\n4. 🧊 Keep clean and elevated\n5. 🚑 Seek emergency care NOW';
      medicalTreatment = '✅ RABIES PEP REQUIRED:\n• Vaccine series (day 0, 3, 7, 14, 28)\n• Rabies Immune Globulin\n• Tetanus booster\n• Antibiotics';
      timeUrgency = '⚠️ WITHIN 24 HOURS';
      riskFactors = '• High-risk animal: $animal\n• ${isDeep ? "Deep wound" : "Open wound"}\n• $bleeding';
      recos = '1. Go to ER IMMEDIATELY\n2. Start PEP today\n3. Keep wound clean\n4. Monitor for infection';
    } else if (isHighRisk) {
      severity = '🟠 URGENT';
      firstAid = '1. 🧼 Wash wound for 10-15 minutes\n2. 🧴 Apply antiseptic\n3. 🩹 Cover with dressing\n4. 🚑 Seek care within 48h';
      medicalTreatment = '⚠️ MEDICAL CARE NEEDED:\n• Rabies PEP discussion\n• Tetanus check\n• Wound assessment';
      timeUrgency = '⏰ WITHIN 48 HOURS';
      riskFactors = '• $animal - potential risk\n• ${depth.isNotEmpty ? depth : "Standard wound"}';
      recos = '1. Schedule doctor visit\n2. Get rabies vaccines\n3. Monitor wound daily';
    } else if (isLowRisk) {
      severity = '🟢 LOW RISK';
      firstAid = '1. 🧼 Clean with soap/water\n2. 🧴 Apply antibiotic\n3. 🩹 Keep covered\n4. 👀 Watch for infection';
      medicalTreatment = 'ℹ️ BASIC FIRST AID:\n• Tetanus if needed\n• Monitor only\n• Rabies risk very low';
      timeUrgency = '✅ WITHIN 72 HOURS';
      riskFactors = '• Low-risk: $animal\n• Rare rabies carrier';
      recos = '1. Clean wound daily\n2. No rabies vaccine\n3. Should heal in 1-2 weeks';
    } else {
      severity = '🟡 MODERATE';
      firstAid = '1. 🧼 Clean wound 10+ min\n2. 🧴 Apply antiseptic\n3. 🩹 Apply clean dressing';
      medicalTreatment = '⚠️ CONSULT PROVIDER:\n• Check tetanus status\n• Assess rabies risk';
      timeUrgency = '⏰ WITHIN 48-72 HOURS';
      riskFactors = '• General assessment\n• Check local rabies';
      recos = '1. Contact healthcare\n2. Update tetanus\n3. Document incident';
    }

    return '''
$severity

🩺 ASSESSMENT SUMMARY:
━━━━━━━━━━━━━━━━━━━━━━━

📍 YOUR ANSWERS:
• Animal: ${_answers['animal'] ?? 'N/A'}
• Time: ${_answers['time'] ?? 'N/A'}
• Location: ${_answers['location'] ?? 'N/A'}
• Depth: ${_answers['depth'] ?? 'N/A'}
• Bleeding: ${_answers['bleeding'] ?? 'N/A'}
• Status: ${_answers['animal_status'] ?? 'N/A'}

━━━━━━━━━━━━━━━━━━━━━━━

🩹 FIRST AID STEPS:
$firstAid

💉 MEDICAL TREATMENT:
$medicalTreatment

⏰ TIME URGENCY:
$timeUrgency

⚠️ RISK FACTORS:
$riskFactors

📋 RECOMMENDATIONS:
$recos

━━━━━━━━━━━━━━━━━━━━━━━

ℹ️ DISCLAIMER:
AI guidance based on WHO. 
Consult doctor immediately.
Emergency: call 911.
''';
  }

  Future<void> _saveAssessment() async {
    final db = await SQLiteService.instance.database;
    await db.insert('triage_results', {
      'symptoms': '${_answers['animal']} - ${_answers['time']}',
      'risk_level': _result.contains('EMERGENCY') ? 'Critical' : _result.contains('URGENT') ? 'High' : _result.contains('MODERATE') ? 'Medium' : 'Low',
      'risk_score': _result.contains('EMERGENCY') ? 90 : _result.contains('URGENT') ? 70 : _result.contains('MODERATE') ? 40 : 20,
      'recommendations': _result,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Color _getSeverityColor() {
    if (_result.contains('EMERGENCY')) return AppTheme.danger;
    if (_result.contains('URGENT')) return Colors.orange;
    if (_result.contains('MODERATE')) return AppTheme.warning;
    return AppTheme.success;
  }

  void _reset() {
    _animController.reset();
    setState(() {
      _step = 'landing';
      _answers.clear();
      _woundImage = null;
      _result = '';
      _currentQ = 0;
      _inputController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Animal Bite Advisor'),
        backgroundColor: AppTheme.danger,
        foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _step == 'landing' ? _buildLanding() :
               _step == 'intake' ? _buildIntake() :
               _step == 'analyzing' ? _buildAnalyzing() :
               FadeTransition(key: const ValueKey('result'), opacity: _fadeAnimation, child: _buildResult()),
      ),
    );
  }

  Widget _buildLanding() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.dangerLight, borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              const Icon(Icons.warning_rounded, color: AppTheme.danger, size: 28),
              const SizedBox(width: 12),
              Expanded(child: Text('For emergencies, call 911 immediately. This is AI guidance based on WHO.', style: TextStyle(fontSize: 13, color: AppTheme.danger, fontWeight: FontWeight.w500))),
            ]),
          ),
          const SizedBox(height: 20),
          Container(width: 90, height: 90, decoration: BoxDecoration(color: AppTheme.dangerLight, shape: BoxShape.circle), child: const Icon(Icons.pets_rounded, size: 45, color: AppTheme.danger)),
          const SizedBox(height: 16),
          const Text('Animal Bite Advisor', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('WHO-guideline based assessment', style: TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _woundImage != null ? AppTheme.successLight : AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _woundImage != null ? AppTheme.success : AppTheme.border, width: 2),
              ),
              child: Column(
                children: [
                  Icon(_woundImage != null ? Icons.check_circle_rounded : Icons.add_photo_alternate_rounded, size: 40, color: _woundImage != null ? AppTheme.success : AppTheme.textTertiary),
                  const SizedBox(height: 8),
                  Text(_woundImage != null ? 'Image Selected' : 'Upload Wound Photo', style: TextStyle(fontSize: 15, color: _woundImage != null ? AppTheme.success : AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                  if (_woundImage != null) ...[
                    const SizedBox(height: 12),
                    ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(_woundImage!.path), height: 100, width: double.infinity, fit: BoxFit.cover)),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() => _step = 'intake'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger, foregroundColor: Colors.white, padding: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Start Assessment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)), SizedBox(width: 8), Icon(Icons.arrow_forward_rounded)]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntake() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Question ${_currentQ + 1}/${_questions.length}', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            Text('${((_currentQ + 1) / _questions.length * 100).round()}%', style: const TextStyle(fontSize: 13, color: AppTheme.danger, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 8),
          ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: (_currentQ + 1) / _questions.length, minHeight: 8, backgroundColor: AppTheme.border, valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.danger))),
          const SizedBox(height: 32),
          Container(width: 70, height: 70, decoration: BoxDecoration(color: AppTheme.dangerLight, shape: BoxShape.circle), child: Center(child: Text('${_currentQ + 1}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.danger)))),
          const SizedBox(height: 20),
          Text(_questions[_currentQ]['label']!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          TextField(
            controller: _inputController,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(hintText: _questions[_currentQ]['placeholder'], filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.danger, width: 2)), contentPadding: const EdgeInsets.all(18)),
            onSubmitted: (_) => _nextQuestion(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextQuestion,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger, foregroundColor: Colors.white, padding: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: Text(_currentQ < _questions.length - 1 ? 'Next →' : 'Analyze Now 🔍', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
          if (_currentQ > 0) ...[
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: OutlinedButton(onPressed: _goBack, style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.arrow_back_rounded), SizedBox(width: 8), Text('Back')]))),
          ],
        ],
      ),
    );
  }

  Widget _buildAnalyzing() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 90, height: 90, child: CircularProgressIndicator(strokeWidth: 6, valueColor: AlwaysStoppedAnimation<Color>(AppTheme.danger))),
          const SizedBox(height: 24),
          const Text('Analyzing your case...', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Applying WHO protocols', style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildResult() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: _getSeverityColor().withAlpha(26), borderRadius: BorderRadius.circular(16), border: Border.all(color: _getSeverityColor().withAlpha(128))),
            child: Row(children: [
              Container(width: 50, height: 50, decoration: BoxDecoration(color: _getSeverityColor(), shape: BoxShape.circle), child: Icon(_result.contains('EMERGENCY') ? Icons.warning_rounded : _result.contains('URGENT') ? Icons.priority_high_rounded : _result.contains('MODERATE') ? Icons.info_rounded : Icons.check_circle_rounded, color: Colors.white, size: 26)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_result.contains('EMERGENCY') ? '🚨 EMERGENCY' : _result.contains('URGENT') ? '🟠 URGENT' : _result.contains('MODERATE') ? '🟡 MODERATE' : '🟢 LOW RISK', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _getSeverityColor())),
                const Text('Assessment Complete', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              ])),
            ]),
          ),
          if (_woundImage != null) ...[
            const SizedBox(height: 16),
            ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(File(_woundImage!.path), width: double.infinity, height: 150, fit: BoxFit.cover)),
          ],
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.shadowSm),
            child: Column(
              children: _result.split('\n').map((line) {
                if (line.startsWith('━')) return const SizedBox(height: 12);
                if (line.isEmpty) return const SizedBox(height: 4);
                Color color = AppTheme.textPrimary;
                double size = 14;
                FontWeight weight = FontWeight.w400;
                if (line.contains('🚨') || line.contains('🟠') || line.contains('🟡') || line.contains('🟢')) { 
                  color = _getSeverityColor(); weight = FontWeight.w700; size = 16; 
                } else if (line.contains('🩺') || line.contains('📍')) { 
                  weight = FontWeight.w700; size = 15; 
                } else if (line.contains('•')) {
                  size = 13;
                }
                return Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Text(line, style: TextStyle(fontSize: size, color: color, fontWeight: weight, height: 1.4)));
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppTheme.dangerLight, borderRadius: BorderRadius.circular(16)),
            child: Row(children: [const Icon(Icons.medical_information_rounded, color: AppTheme.danger), const SizedBox(width: 12), Expanded(child: Text('Always consult a doctor. In emergencies call 911.', style: TextStyle(fontSize: 13, color: AppTheme.danger, fontWeight: FontWeight.w500)))])),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: _reset, icon: const Icon(Icons.refresh_rounded), label: const Text('New Assessment'), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger, foregroundColor: Colors.white, padding: const EdgeInsets.all(14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))))),
        ],
      ),
    );
  }
}