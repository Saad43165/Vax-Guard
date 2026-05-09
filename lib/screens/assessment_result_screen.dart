import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';

import '../core/theme.dart';
import '../utils/app_constants.dart';
import '../services/pdf_service.dart';
import '../utils/l10n_helper.dart';
import '../l10n/app_localizations.dart';

class AssessmentResultScreen extends StatefulWidget {
  const AssessmentResultScreen({super.key});

  @override
  State<AssessmentResultScreen> createState() => _AssessmentResultScreenState();
}

class _AssessmentResultScreenState extends State<AssessmentResultScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final collapsed = _scrollController.offset > 120;
      if (collapsed != _isCollapsed) setState(() => _isCollapsed = collapsed);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args == null) {
      return Scaffold(
        backgroundColor: AppTheme.background(context),
        appBar: AppBar(title: Text(L10n.s(context, 'error')), backgroundColor: AppTheme.surface(context)),
        body: Center(child: Text(L10n.s(context, 'error'), style: GoogleFonts.outfit())),
      );
    }

    final title = args['title'] as String? ?? 'Assessment';
    final subtitle = args['subtitle'] as String? ?? '';
    final severity = args['severity'] as String? ?? 'Low';
    final score = args['score'] as int?;
    final actions = args['actions'] as List<String>? ?? [];
    final drivers = args['drivers'] as List<String>? ?? [];
    final differential = args['differential'] as List<dynamic>? ?? [];
    final type = args['type'] as String? ?? 'general';
    final answers = args['answers'] as Map<String, String>? ?? {};

    final severityInfo = _getSeverityInfo(severity);
    final color = severityInfo.color;

    return Scaffold(
      backgroundColor: AppTheme.background(context),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(context, color, title, subtitle),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildScoreCard(context, color, severity, score),
                  const SizedBox(height: 24),
                  _buildGuidanceSection(context, severity, color),
                  const SizedBox(height: 24),
                  if (differential.isNotEmpty) _buildDifferentialCard(context, differential),
                  if (differential.isNotEmpty) const SizedBox(height: 24),
                  if (actions.isNotEmpty) _buildActionsCard(context, actions, color),
                  if (actions.isNotEmpty) const SizedBox(height: 24),
                  if (drivers.isNotEmpty) _buildDriversCard(context, drivers, color),
                  if (drivers.isNotEmpty) const SizedBox(height: 24),
                  if (answers.isNotEmpty) _buildAnswersCard(context, answers),
                  const SizedBox(height: 32),
                  _buildBottomActions(context, type),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Color color, String title, String subtitle) {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: color,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Image.asset('assets/images/appbar_icon.png', fit: BoxFit.contain),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              L10n.s(context, title),
              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white),
            ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withOpacity(0.7)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -40, top: -20,
                child: Icon(Icons.assignment_turned_in_rounded, color: Colors.white.withOpacity(0.1), size: 180),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Icon(Icons.analytics_rounded, color: Colors.white.withOpacity(0.9), size: 44),
                    const SizedBox(height: 8),
                    Text(
                      'CLINICAL ANALYSIS REPORT',
                      style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuidanceSection(BuildContext context, String severity, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.medical_services_rounded, color: color, size: 20),
              const SizedBox(width: 10),
              Text('CLINICAL GUIDANCE', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w900, color: color, letterSpacing: 1.5)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _getGuidanceText(severity),
            style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textPrimary(context), height: 1.6, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  String _getGuidanceText(String severity) {
    final s = severity.toLowerCase();
    if (s.contains('emergency') || s.contains('critical') || s.contains('urgent')) {
      return 'IMMEDIATE ACTION REQUIRED: The pattern of symptoms identified suggests a critical medical condition. Do not wait for symptoms to worsen. Seek emergency medical care at the nearest hospital immediately.';
    }
    if (s.contains('high')) {
      return 'CONCERNING FINDINGS: Your assessment results show high-risk clinical markers. A professional medical examination is required within the next 24 hours to prevent potential complications.';
    }
    if (s.contains('medium') || s.contains('moderate')) {
      return 'MODERATE CONCERN: Several clinical indicators have been flagged. While not an immediate emergency, you should schedule a consultation with your primary physician to discuss these findings.';
    }
    return 'OBSERVATION RECOMMENDED: Your symptom profile does not currently indicate a high-risk condition. Monitor the progression of symptoms and re-assess if you experience any worsening or new warning signs.';
  }

  Widget _buildScoreCard(BuildContext context, Color color, String severity, int? score) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.border(context), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(L10n.s(context, 'document_no'), style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textTertiary(context), fontWeight: FontWeight.w800, letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Text('VG-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary(context))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(_getSeverityInfo(severity).icon, color: color, size: 24),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(height: 1)),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(L10n.s(context, 'clinical_status'), style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondary(context), fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(L10n.s(context, severity).toUpperCase(), style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w900, color: color, letterSpacing: -0.5)),
                  ],
                ),
              ),
              if (score != null)
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.4), width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$score%', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
                      Text(L10n.s(context, 'probability').toUpperCase(), style: GoogleFonts.outfit(fontSize: 8, color: color, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard(BuildContext context, List<String> actions, Color color) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.border(context), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(L10n.s(context, 'recommended_actions').toUpperCase(), style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.textPrimary(context), letterSpacing: 1)),
          const SizedBox(height: 24),
          ...actions.map((action) => Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  child: Icon(Icons.check_circle_rounded, color: color, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(child: Text(L10n.s(context, action), style: GoogleFonts.outfit(fontSize: 16, height: 1.5, color: AppTheme.textPrimary(context), fontWeight: FontWeight.w600))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildDriversCard(BuildContext context, List<String> drivers, Color color) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.danger.withOpacity(0.05),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.danger.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppTheme.danger, size: 20),
              const SizedBox(width: 10),
              Text(L10n.s(context, 'urgent_warning_signs').toUpperCase(), style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.danger, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 20),
          ...drivers.map((d) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.danger, size: 14),
                const SizedBox(width: 12),
                Expanded(child: Text(L10n.s(context, d), style: GoogleFonts.outfit(fontSize: 15, color: AppTheme.textPrimary(context), fontWeight: FontWeight.w700, height: 1.4))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildAnswersCard(BuildContext context, Map<String, String> answers) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.border(context), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(L10n.s(context, 'reported_observations').toUpperCase(), style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.textPrimary(context), letterSpacing: 1)),
          const SizedBox(height: 24),
          ...answers.entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(L10n.s(context, e.key).toUpperCase(), style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.textTertiary(context), letterSpacing: 0.5)),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppTheme.background(context), borderRadius: BorderRadius.circular(16)),
                  child: Text(L10n.s(context, e.value), style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textPrimary(context), fontWeight: FontWeight.w700, height: 1.5)),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildDifferentialCard(BuildContext context, List<dynamic> differential) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.border(context), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(L10n.s(context, 'differential_diagnosis').toUpperCase(), style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.textPrimary(context), letterSpacing: 1)),
          const SizedBox(height: 24),
          ...differential.asMap().entries.map((entry) {
            final index = entry.key;
            final d = entry.value as Map<String, dynamic>;
            final name = d['name'] as String? ?? 'Unknown';
            final percentage = d['percentage'] as int? ?? 0;
            final recommendation = d['recommendation'] as String? ?? '';

            final barColor = percentage >= 75
                ? AppTheme.danger
                : percentage >= 50
                    ? AppTheme.warning
                    : percentage >= 30
                        ? AppTheme.primary
                        : AppTheme.success;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(L10n.s(context, name), style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.textPrimary(context))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: barColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text('$percentage%', style: GoogleFonts.outfit(color: barColor, fontWeight: FontWeight.w900, fontSize: 14)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Stack(
                  children: [
                    Container(height: 10, decoration: BoxDecoration(color: AppTheme.background(context), borderRadius: BorderRadius.circular(5))),
                    AnimatedContainer(
                      duration: const Duration(seconds: 1),
                      height: 10, width: MediaQuery.of(context).size.width * (percentage / 100) * 0.7,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [barColor.withOpacity(0.6), barColor]),
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [BoxShadow(color: barColor.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(L10n.s(context, recommendation), style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondary(context), fontWeight: FontWeight.w600, height: 1.4)),
                if (index < differential.length - 1) const SizedBox(height: 24),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, String type) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton.icon(
            onPressed: () {
              final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
              if (args != null) {
                _exportPdf(
                  context,
                  args['title'] as String? ?? 'Assessment',
                  args['subtitle'] as String? ?? '',
                  args['severity'] as String? ?? 'Low',
                  args['score'] as int?,
                  args['summary'] as String? ?? '',
                  args['actions'] as List<String>? ?? [],
                  args['drivers'] as List<String>? ?? [],
                  args['details'] as String? ?? '',
                  args['answers'] as Map<String, String>? ?? {},
                );
              }
            },
            icon: const Icon(Icons.picture_as_pdf_rounded, size: 22),
            label: Text(L10n.s(context, 'clinical_feedback'), style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 8,
              shadowColor: AppTheme.primary.withOpacity(0.4),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppConstants.hospitalMapRoute),
            icon: const Icon(Icons.local_hospital_rounded),
            label: Text(L10n.s(context, 'hospitals'), style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 17)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppTheme.primary, width: 2),
              foregroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _exportPdf(
    BuildContext context,
    String title,
    String subtitle,
    String severity,
    int? score,
    String summary,
    List<String> actions,
    List<String> drivers,
    String details,
    Map<String, String> answers,
  ) async {
    try {
      final l10n = AppLocalizations.of(context)!;
      final pdf = await PdfService.buildAssessmentDocument(
        title: title,
        subtitle: subtitle,
        severity: severity,
        score: score,
        summary: summary,
        actions: actions,
        drivers: drivers,
        details: details,
        answers: answers,
        l10n: l10n,
      );
      await Printing.layoutPdf(onLayout: (format) async => pdf.save(), name: 'Assessment_Report.pdf');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${L10n.s(context, 'pdf_error')}: $e'), backgroundColor: AppTheme.danger),
        );
      }
    }
  }

  _SeverityInfo _getSeverityInfo(String severity) {
    final s = severity.toLowerCase();
    if (s.contains('emergency') || s.contains('critical') || s.contains('urgent')) {
      return const _SeverityInfo(color: AppTheme.danger, icon: Icons.emergency_rounded);
    }
    if (s.contains('high')) {
      return const _SeverityInfo(color: AppTheme.riskHigh, icon: Icons.warning_rounded);
    }
    if (s.contains('medium') || s.contains('moderate')) {
      return const _SeverityInfo(color: AppTheme.warning, icon: Icons.info_rounded);
    }
    return const _SeverityInfo(color: AppTheme.success, icon: Icons.check_circle_rounded);
  }
}

class _SeverityInfo {
  final Color color;
  final IconData icon;
  const _SeverityInfo({required this.color, required this.icon});
}
