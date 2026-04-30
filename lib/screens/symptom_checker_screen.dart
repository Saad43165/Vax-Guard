import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/database_service.dart';
import '../utils/app_constants.dart';

class SymptomCheckerScreen extends StatefulWidget {
  const SymptomCheckerScreen({super.key});

  @override
  State<SymptomCheckerScreen> createState() => _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState extends State<SymptomCheckerScreen> {
  final List<_Symptom> _symptoms = const [
    _Symptom(id: 'fever', name: 'Fever', icon: Icons.thermostat_rounded, color: AppTheme.danger),
    _Symptom(id: 'cough', name: 'Cough', icon: Icons.air_rounded, color: AppTheme.warning),
    _Symptom(id: 'fatigue', name: 'Fatigue', icon: Icons.battery_alert_rounded, color: AppTheme.purple),
    _Symptom(id: 'headache', name: 'Headache', icon: Icons.face_rounded, color: AppTheme.primary),
    _Symptom(id: 'body_ache', name: 'Body Aches', icon: Icons.accessibility_new_rounded, color: AppTheme.secondary),
    _Symptom(id: 'sore_throat', name: 'Sore Throat', icon: Icons.mic_rounded, color: AppTheme.warning),
    _Symptom(id: 'nausea', name: 'Nausea', icon: Icons.sick_rounded, color: AppTheme.danger),
    _Symptom(id: 'diarrhea', name: 'Diarrhea', icon: Icons.water_drop_rounded, color: AppTheme.warning),
    _Symptom(id: 'runny_nose', name: 'Runny Nose', icon: Icons.water_rounded, color: AppTheme.primary),
    _Symptom(id: 'shortness_breath', name: 'Shortness of Breath', icon: Icons.zoom_out_rounded, color: AppTheme.danger),
    _Symptom(id: 'chest_pain', name: 'Chest Pain', icon: Icons.favorite_rounded, color: AppTheme.danger),
    _Symptom(id: 'loss_taste', name: 'Loss of Taste/Smell', icon: Icons.restaurant_rounded, color: AppTheme.primary),
  ];

  final Set<String> _selectedSymptoms = {};
  String? _severity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Symptom Checker'),
        centerTitle: false,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => _showdisclaimer(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionTitle('Select Your Symptoms'),
                const SizedBox(height: 12),
                _buildSymptomGrid(),
                const SizedBox(height: 24),
                _buildSeveritySection(),
                if (_selectedSymptoms.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildAnalyzeButton(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Check Your Symptoms',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select all symptoms you are experiencing for a quick assessment',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildSymptomGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: _symptoms.length,
      itemBuilder: (context, index) {
        final symptom = _symptoms[index];
        final isSelected = _selectedSymptoms.contains(symptom.id);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedSymptoms.remove(symptom.id);
              } else {
                _selectedSymptoms.add(symptom.id);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? symptom.color.withValues(alpha: 0.15) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? symptom.color : AppTheme.border,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected ? AppTheme.shadowSm : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  symptom.icon,
                  color: isSelected ? symptom.color : AppTheme.textSecondary,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  symptom.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? symptom.color : AppTheme.textSecondary,
                  ),
                ),
                if (isSelected)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: symptom.color,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSeveritySection() {
    final severities = [
      _SeverityOption('Mild', 'Symptoms are noticeable but manageable', 1),
      _SeverityOption('Moderate', 'Symptoms affect daily activities', 2),
      _SeverityOption('Severe', 'Symptoms significantly impact daily life', 3),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('How Severe Are Your Symptoms?'),
        const SizedBox(height: 12),
        ...severities.map((option) {
          final isSelected = _severity == option.label;
          return GestureDetector(
            onTap: () => setState(() => _severity = option.label),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primarySurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppTheme.primary : AppTheme.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : AppTheme.border,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option.label,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          option.description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAnalyzeButton() {
    return GestureDetector(
      onTap: _analyzeSymptoms,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.shadowPrimary,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_rounded, color: Colors.white),
            SizedBox(width: 12),
            Text(
              'Analyze Symptoms',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _analyzeSymptoms() async {
    if (_severity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select symptom severity first.'),
        ),
      );
      return;
    }

    final result = _getAssessmentResult();
    await DatabaseService.instance.saveSymptomCheckerAssessment(
      selectedSymptoms: _selectedSymptoms,
      severity: result.severity,
      score: result.score,
      summary: result.message,
      recommendations: result.recommendations,
    );
    if (!mounted) return;
    _showResultDialog(result);
  }

  _SymptomResult _getAssessmentResult() {
    if (_selectedSymptoms.isEmpty) {
      return const _SymptomResult(
        severity: 'Insufficient Input',
        score: 0,
        message:
            'No relevant symptoms were selected, so this check cannot suggest a disease pattern.',
        recommendations: [
          'Select symptoms that best match your current condition.',
          'If symptoms are severe, seek medical care directly.',
        ],
      );
    }

    if (_severity == null) {
      return const _SymptomResult(
        severity: 'Insufficient Input',
        score: 0,
        message:
            'Severity was not selected, so this result may be unreliable.',
        recommendations: [
          'Choose Mild, Moderate, or Severe and run the check again.',
        ],
      );
    }

    int score = 0;
    final hasHighRisk = _selectedSymptoms.contains('shortness_breath') ||
        _selectedSymptoms.contains('chest_pain');
    final hasMediumRisk = _selectedSymptoms.contains('fever') && _severity == 'Severe';

    if (hasHighRisk || hasMediumRisk) {
      score = 85;
    } else if (_selectedSymptoms.length >= 5 || _severity == 'Moderate') {
      score = 60;
    } else if (_selectedSymptoms.isNotEmpty) {
      score = 35;
    }

    return _SymptomResult(
      severity: score > 70 ? 'High' : score > 40 ? 'Medium' : 'Low',
      score: score,
      message: score > 70
          ? 'Based on your symptoms, we recommend seeking medical attention soon.'
          : score > 40
              ? 'Your symptoms may require medical attention. Consider consulting a healthcare provider.'
              : 'Your symptoms currently suggest low concern and no clear disease-specific warning pattern.',
      recommendations: _getRecommendations(score),
      drivers: _selectedSymptoms.take(3).map((s) => s.replaceAll('_', ' ')).toList(),
    );
  }

  List<String> _getRecommendations(int score) {
    if (score > 70) {
      return [
        'Seek medical attention promptly',
        'Call ahead to your healthcare provider',
        'Rest and stay hydrated',
        'Avoid contact with others',
      ];
    } else if (score > 40) {
      return [
        'Schedule a medical consultation',
        'Rest and monitor symptoms',
        'Stay hydrated',
        'Consider over-the-counter remedies',
      ];
    }
    return [
      'Rest and stay hydrated',
      'Monitor for worsening symptoms',
      'Get plenty of sleep',
      'Consult a doctor if symptoms persist',
    ];
  }

  void _showResultDialog(_SymptomResult result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: result.score > 40 ? AppTheme.dangerLight : AppTheme.successLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        result.score > 70
                            ? Icons.warning_rounded
                            : result.score > 40
                                ? Icons.info_rounded
                                : Icons.check_circle_rounded,
                        color: result.score > 70 ? AppTheme.danger : result.score > 40 ? AppTheme.warning : AppTheme.success,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      result.severity,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: result.score > 70 ? AppTheme.danger : result.score > 40 ? AppTheme.warning : AppTheme.success,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      result.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primarySurface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.coronavirus_rounded, color: AppTheme.primary),
                          const SizedBox(width: 12),
                          Text(
                            '${result.score}% Risk Level',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Recommended Actions:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...result.recommendations.map((rec) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppTheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  rec,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        )),
                    if (result.drivers.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Why this result:',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...result.drivers.map(
                        (driver) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              const Icon(Icons.circle, size: 8, color: AppTheme.primary),
                              const SizedBox(width: 10),
                              Expanded(child: Text(driver)),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppConstants.hospitalMapRoute);
                        },
                        icon: const Icon(Icons.local_hospital_rounded),
                        label: const Text('Find Nearby Hospital'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showdisclaimer(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disclaimer'),
        content: const Text(
          'This symptom checker is for informational purposes only and is NOT a substitute for professional medical advice, diagnosis, or treatment. Always seek the advice of your physician or other qualified health provider with any questions you may have regarding a medical condition.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('I Understand'),
          ),
        ],
      ),
    );
  }
}

class _Symptom {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const _Symptom({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

class _SeverityOption {
  final String label;
  final String description;
  final int level;

  const _SeverityOption(this.label, this.description, this.level);
}

class _SymptomResult {
  final String severity;
  final int score;
  final String message;
  final List<String> recommendations;
  final List<String> drivers;

  const _SymptomResult({
    required this.severity,
    required this.score,
    required this.message,
    required this.recommendations,
    this.drivers = const [],
  });
}