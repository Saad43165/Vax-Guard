import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme.dart';
import '../models/disease_assessment.dart';
import '../services/database_service.dart';
import '../services/disease_assessment_service.dart';
import '../utils/app_constants.dart';
import '../utils/l10n_helper.dart';


class DiseaseAssessmentQuizScreen extends StatefulWidget {
  final String definitionId;

  const DiseaseAssessmentQuizScreen({
    super.key,
    required this.definitionId,
  });

  @override
  State<DiseaseAssessmentQuizScreen> createState() =>
      _DiseaseAssessmentQuizScreenState();
}

class _DiseaseAssessmentQuizScreenState
    extends State<DiseaseAssessmentQuizScreen> {
  late final DiseaseAssessmentDefinition _definition;
  final Map<String, int> _answers = {};
  final List<int> _history = [0];
  final TextEditingController _notesController = TextEditingController();
  bool _showNotesStep = false;
  bool _saving = false;

  int get _currentIndex => _history.last;

  @override
  void initState() {
    super.initState();
    _definition = DiseaseAssessmentService.tryGetDefinition(widget.definitionId) ??
        DiseaseAssessmentService.definitions.first;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex >= _definition.questions.length) {
      return Scaffold(
        backgroundColor: AppTheme.background(context),
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    final question = _definition.questions[_currentIndex];
    final progress = (_currentIndex + 1) / _definition.questions.length;

    return Scaffold(
      backgroundColor: AppTheme.background(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(progress),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: SingleChildScrollView(
                  key: ValueKey(_showNotesStep ? 'notes' : question.id),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!_showNotesStep && _history.length == 1) ...[
                        _buildIntroCard(),
                        const SizedBox(height: 20),
                      ],
                      _showNotesStep ? _buildNotesStep() : _buildQuestionCard(question),
                      const SizedBox(height: 20),
                      if (!_showNotesStep) _buildUrgentFlagsCard(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(question),
    );
  }

  Widget _buildHeader(double progress) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surface(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border(context)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.background(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.close_rounded, color: AppTheme.textPrimary(context), size: 20),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        L10n.s(context, 'clinical_evaluation'),
                        style: GoogleFonts.outfit(
                          color: AppTheme.textTertiary(context),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        L10n.s(context, _definition.title),
                        style: GoogleFonts.outfit(
                          color: AppTheme.textPrimary(context),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _definition.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_definition.icon, color: _definition.accentColor),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: AppTheme.background(context),
                valueColor: AlwaysStoppedAnimation<Color>(_definition.accentColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_definition.accentColor.withOpacity(0.15), _definition.accentColor.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _definition.accentColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: _definition.accentColor, shape: BoxShape.circle),
                child: const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  L10n.s(context, 'about_this_assessment'),
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 18, color: AppTheme.textPrimary(context)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _definition.subtitle,
            style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textSecondary(context), height: 1.5, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesStep() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppTheme.surface(context), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.border(context))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note_rounded, color: AppTheme.primary, size: 24),
              const SizedBox(width: 12),
              Text(L10n.s(context, 'additional_details'), style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary(context))),
            ],
          ),
          const SizedBox(height: 16),
          Text(L10n.s(context, 'notes_hint_desc'), style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textSecondary(context), height: 1.4)),
          const SizedBox(height: 24),
          TextField(
            controller: _notesController,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: L10n.s(context, 'type_notes_here'),
              fillColor: AppTheme.background(context),
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppTheme.border(context))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppTheme.border(context))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(DiseaseAssessmentQuestion question) {
    final selectedIndex = _answers[question.id];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.background(context),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              L10n.s(context, 'observation').toUpperCase(),
              style: GoogleFonts.outfit(
                color: AppTheme.textTertiary(context),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            L10n.s(context, question.prompt),
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary(context),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          ...question.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = selectedIndex == index;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => setState(() => _answers[question.id] = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _definition.accentColor.withOpacity(0.1)
                        : AppTheme.background(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? _definition.accentColor
                          : AppTheme.border(context),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: isSelected ? _definition.accentColor : AppTheme.textTertiary(context),
                        size: 20,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              L10n.s(context, option.label),
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: AppTheme.textPrimary(context),
                              ),
                            ),
                            Text(
                              L10n.s(context, option.description),
                              style: GoogleFonts.outfit(
                                color: AppTheme.textSecondary(context),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildUrgentFlagsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.danger.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.danger.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppTheme.danger, size: 20),
              const SizedBox(width: 10),
              Text(
                L10n.s(context, 'urgent_warning_signs'),
                style: GoogleFonts.outfit(
                  color: AppTheme.danger,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._definition.urgentFlags.map(
            (flag) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_outline_rounded, size: 14, color: AppTheme.danger),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      L10n.s(context, flag),
                      style: GoogleFonts.outfit(
                        color: AppTheme.textPrimary(context),
                        height: 1.4,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(DiseaseAssessmentQuestion question) {
    final hasSelection = _answers.containsKey(question.id);
    final isLast = _currentIndex == _definition.questions.length - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        border: Border(top: BorderSide(color: AppTheme.border(context))),
      ),
      child: Row(
        children: [
          if (_history.length > 1)
            Expanded(
              child: OutlinedButton(
                onPressed: _goBack,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppTheme.border(context)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Back', style: GoogleFonts.outfit(color: AppTheme.textSecondary(context), fontWeight: FontWeight.w600)),
              ),
            ),
          if (_history.length > 1) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: hasSelection && !_saving
                  ? (isLast ? _finishAssessment : _goNext)
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: _definition.accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(
                _saving ? 'Saving...' : (_showNotesStep || (isLast && _answers.containsKey(question.id)) ? 'See Results' : 'Continue'),
                style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goBack() {
    if (_showNotesStep) {
      setState(() => _showNotesStep = false);
    } else if (_history.length > 1) {
      setState(() => _history.removeLast());
    }
  }

  void _goNext() {
    if (_showNotesStep) {
      _finishAssessment();
      return;
    }
    
    final question = _definition.questions[_currentIndex];
    if (!_answers.containsKey(question.id)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(L10n.s(context, 'review_select_option')), backgroundColor: AppTheme.warning));
      return;
    }

    int nextIndex = _currentIndex + 1;
    
    // Find next valid question based on dependencies
    while (nextIndex < _definition.questions.length) {
      final nextQ = _definition.questions[nextIndex];
      if (nextQ.dependsOnQuestionId != null) {
        final dependentAnswerIndex = _answers[nextQ.dependsOnQuestionId];
        if (dependentAnswerIndex != null) {
          final dependentQ = _definition.questions.firstWhere((q) => q.id == nextQ.dependsOnQuestionId);
          final score = dependentQ.options[dependentAnswerIndex].score;
          if (score >= (nextQ.minScoreDependency ?? 0)) {
            break; // Include this question
          }
        }
        // Skip this question and check the next one
        nextIndex++;
      } else {
        break; // No dependency, include this question
      }
    }

    if (nextIndex < _definition.questions.length) {
      setState(() => _history.add(nextIndex));
    } else {
      // If we finished all questions, go to notes step
      setState(() => _showNotesStep = true);
    }
  }

  Future<void> _finishAssessment() async {
    if (_saving) return;

    final result = DiseaseAssessmentService.evaluate(
      definition: _definition,
      answers: _answers,
    );

    setState(() => _saving = true);

    await DatabaseService.instance.saveDiseaseAssessment(
      assessmentId: _definition.id,
      assessmentName: _definition.title,
      subtitle: _definition.subtitle,
      result: result,
      answers: _answers,
      questions: _definition.questions,
      urgentFlags: _definition.urgentFlags,
      details: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    if (!mounted) return;
    setState(() => _saving = false);

    final answerStrings = <String, String>{};
    for (final entry in _answers.entries) {
      // Only include answers for questions we actually visited
      if (_history.any((idx) => _definition.questions[idx].id == entry.key)) {
        final question = _definition.questions.firstWhere((q) => q.id == entry.key);
        answerStrings[question.prompt] = question.options[entry.value].label;
      }
    }

    Navigator.pushReplacementNamed(
      context,
      AppConstants.assessmentResultRoute,
      arguments: <String, dynamic>{
        'title': result.headline,
        'subtitle': _definition.title,
        'severity': result.level,
        'score': result.score,
        'summary': result.summary,
        'actions': result.actions,
        'drivers': result.matchedConcerns,
        'details': _notesController.text,
        'type': 'disease_assessment',
        'answers': answerStrings,
      },
    );
  }
}
