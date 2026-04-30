import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/disease_assessment.dart';
import '../services/database_service.dart';
import '../services/disease_assessment_service.dart';
import '../utils/app_constants.dart';

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
  int _currentIndex = 0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _definition = DiseaseAssessmentService.tryGetDefinition(widget.definitionId) ??
        DiseaseAssessmentService.definitions.first;
  }

  @override
  Widget build(BuildContext context) {
    final question = _definition.questions[_currentIndex];
    final progress = (_currentIndex + 1) / _definition.questions.length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(progress),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                child: SingleChildScrollView(
                  key: ValueKey(question.id),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildIntroCard(),
                      const SizedBox(height: 16),
                      _buildQuestionCard(question),
                      const SizedBox(height: 16),
                      _buildUrgentFlagsCard(),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomBar(question),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double progress) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: _definition.gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.shadowPrimary,
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _definition.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Question ${_currentIndex + 1} of ${_definition.questions.length}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.84),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_definition.icon, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.18),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroCard() {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Before You Start',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _definition.disclaimer,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(DiseaseAssessmentQuestion question) {
    final cs = Theme.of(context).colorScheme;
    final selectedIndex = _answers[question.id];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _definition.accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              _definition.subtitle,
              style: TextStyle(
                color: _definition.accentColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            question.prompt,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            question.helper,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          ...question.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = selectedIndex == index;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => setState(() => _answers[question.id] = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _definition.accentColor.withValues(alpha: 0.10)
                        : AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? _definition.accentColor
                          : AppTheme.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? _definition.accentColor
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? _definition.accentColor
                                : AppTheme.border,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check_rounded,
                                size: 14,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option.label,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: isSelected
                                    ? _definition.accentColor
                                    : AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              option.description,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                height: 1.4,
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
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.dangerLight,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.danger.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppTheme.danger),
              SizedBox(width: 10),
              Text(
                'Urgent Warning Signs',
                style: TextStyle(
                  color: AppTheme.danger,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._definition.urgentFlags.map(
            (flag) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    margin: const EdgeInsets.only(top: 7, right: 10),
                    decoration: const BoxDecoration(
                      color: AppTheme.danger,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      flag,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        height: 1.4,
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          if (_currentIndex > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _goBack,
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Back'),
              ),
            ),
          if (_currentIndex > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: hasSelection && !_saving
                  ? (isLast ? _finishAssessment : _goNext)
                  : null,
              icon: Icon(
                isLast ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
              ),
              label: Text(_saving
                  ? 'Saving...'
                  : isLast
                      ? 'See Result'
                      : 'Continue'),
            ),
          ),
        ],
      ),
    );
  }

  void _goBack() {
    setState(() => _currentIndex -= 1);
  }

  void _goNext() {
    setState(() => _currentIndex += 1);
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
    );

    if (!mounted) return;
    setState(() => _saving = false);

    _showResultSheet(result);
  }

  void _showResultSheet(DiseaseAssessmentResult result) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final severityColor = _severityColor(result.level);

        return Container(
          height: MediaQuery.of(context).size.height * 0.82,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    result.level == 'Urgent'
                        ? Icons.emergency_rounded
                        : result.level == 'High'
                            ? Icons.warning_rounded
                            : Icons.health_and_safety_rounded,
                    color: severityColor,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  result.headline,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  result.summary,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${result.score}%',
                        style: TextStyle(
                          color: severityColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${result.level} concern level',
                          style: TextStyle(
                            color: severityColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _ResultBlock(
                  title: 'What To Do Next',
                  child: Text(
                    result.nextStep,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _ResultBlock(
                  title: 'Recommended Actions',
                  child: Column(
                    children: result.actions
                        .map(
                          (action) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  margin: const EdgeInsets.only(top: 7, right: 10),
                                  decoration: BoxDecoration(
                                    color: severityColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    action,
                                    style: const TextStyle(height: 1.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                if (result.matchedConcerns.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _ResultBlock(
                    title: 'Matched Concerns',
                    child: Column(
                      children: result.matchedConcerns
                          .map(
                            (concern) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.circle,
                                    size: 8,
                                    color: AppTheme.warning,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(child: Text(concern)),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.of(this.context).pop();
                        },
                        icon: const Icon(Icons.history_rounded),
                        label: const Text('Back To Hub'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            this.context,
                            AppConstants.hospitalMapRoute,
                          );
                        },
                        icon: const Icon(Icons.local_hospital_rounded),
                        label: const Text('Find Help'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _severityColor(String level) {
    switch (level.toLowerCase()) {
      case 'urgent':
        return AppTheme.danger;
      case 'high':
        return AppTheme.warning;
      case 'moderate':
        return AppTheme.secondary;
      default:
        return AppTheme.success;
    }
  }
}

class _ResultBlock extends StatelessWidget {
  final String title;
  final Widget child;

  const _ResultBlock({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
