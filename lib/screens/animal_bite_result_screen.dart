import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import '../core/theme.dart';
import '../services/pdf_service.dart';
import '../utils/l10n_helper.dart';
import '../l10n/app_localizations.dart';

class AnimalBiteResultScreen extends StatelessWidget {
  const AnimalBiteResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final risk = args['risk'] as String? ?? 'Low';
    final category = args['category'] as String? ?? 'Category I';
    final score = (args['score'] as num?)?.toDouble() ?? 0.0;
    final findings = (args['findings'] as List<dynamic>?)?.cast<String>() ?? [];
    final answers = (args['answers'] as Map<String, String>?) ?? {};
    final notes = args['notes'] as String? ?? '';

    Color riskColor;
    IconData riskIcon;
    String riskTitleKey;
    String riskDescKey;
    List<_ActionKey> actions;

    switch (risk.toLowerCase()) {
      case 'critical':
        riskColor = AppTheme.danger;
        riskIcon = Icons.report_gmailerrorred_rounded;
        riskTitleKey = 'critical_risk';
        riskDescKey = 'critical_risk_desc';
        actions = _criticalActionKeys;
        break;
      case 'high':
        riskColor = AppTheme.riskHigh;
        riskIcon = Icons.warning_amber_rounded;
        riskTitleKey = 'high_risk';
        riskDescKey = 'high_risk_desc';
        actions = _highActionKeys;
        break;
      case 'moderate':
      case 'medium':
        riskColor = AppTheme.warning;
        riskIcon = Icons.info_outline_rounded;
        riskTitleKey = 'medium_risk';
        riskDescKey = 'medium_risk_desc';
        actions = _moderateActionKeys;
        break;
      default:
        riskColor = AppTheme.success;
        riskIcon = Icons.check_circle_outline_rounded;
        riskTitleKey = 'low_risk';
        riskDescKey = 'low_risk_desc';
        actions = _lowActionKeys;
    }

    final progress = score.clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppTheme.background(context),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, riskColor),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildResultHeader(context, riskColor, riskIcon, riskTitleKey, category, progress),
                  const SizedBox(height: 24),
                  _buildNotesCard(context, notes),
                  const SizedBox(height: 32),
                  _buildSectionHeader(context, L10n.s(context, 'clinical_findings'), Icons.fact_check_rounded, AppTheme.primary),
                  const SizedBox(height: 16),
                  _buildFindingsList(context, findings),
                  const SizedBox(height: 32),
                  _buildSectionHeader(context, L10n.s(context, 'recommended_actions'), Icons.healing_rounded, riskColor),
                  const SizedBox(height: 16),
                  ...actions.asMap().entries.map((e) => _buildActionCard(context, e.key + 1, e.value, riskColor)),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, riskColor, risk, category, score, findings, answers, notes, riskTitleKey, riskDescKey, actions),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Color color) {
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
              L10n.s(context, 'medical_report'),
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
                child: Icon(Icons.pets_rounded, color: Colors.white.withOpacity(0.1), size: 180),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Icon(Icons.assignment_turned_in_rounded, color: Colors.white.withOpacity(0.9), size: 44),
                    const SizedBox(height: 8),
                    Text(
                      'DIAGNOSTIC ANALYSIS',
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

  Widget _buildNotesCard(BuildContext context, String notes) {
    final cleanNotes = notes.trim();
    final hasProperNotes = cleanNotes.isNotEmpty && cleanNotes.length > 3;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note_rounded, color: AppTheme.primary, size: 20),
              const SizedBox(width: 12),
              Text(L10n.s(context, 'additional_details').toUpperCase(), style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textTertiary(context), letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            hasProperNotes ? cleanNotes : L10n.s(context, 'no_additional_details'),
            style: GoogleFonts.outfit(
              fontSize: 15,
              color: hasProperNotes ? AppTheme.textSecondary(context) : AppTheme.textTertiary(context).withOpacity(0.5),
              height: 1.5,
              fontStyle: hasProperNotes ? FontStyle.normal : FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultHeader(BuildContext context, Color color, IconData icon, String titleKey, String category, double progress) {
    // Simplify for non-technical users
    String userFriendlyTitle;
    String userFriendlySubtitle;
    
    if (titleKey == 'critical_risk') {
      userFriendlyTitle = 'EMERGENCY ACTION';
      userFriendlySubtitle = 'Immediate medical attention required';
    } else if (titleKey == 'high_risk') {
      userFriendlyTitle = 'HIGH RISK ALERT';
      userFriendlySubtitle = 'See a doctor within 24 hours';
    } else {
      userFriendlyTitle = 'LOW RISK';
      userFriendlySubtitle = 'Basic wound care & monitoring';
    }

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 48),
          ),
          const SizedBox(height: 24),
          Text(
            userFriendlyTitle, 
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w900, color: color, letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          Text(
            userFriendlySubtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: color.withOpacity(0.8)),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Text(
              'Clinical: $category',
              style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: color, letterSpacing: 0.5),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(value: progress, minHeight: 12, backgroundColor: color.withOpacity(0.1), valueColor: AlwaysStoppedAnimation<Color>(color)),
                ),
              ),
              const SizedBox(width: 16),
              Text('${(progress * 100).round()}%', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Text(title.toUpperCase(), style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.textPrimary(context), letterSpacing: 1)),
      ],
    );
  }

  Widget _buildFindingsList(BuildContext context, List<String> findings) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.surface(context), borderRadius: BorderRadius.circular(24), border: Border.all(color: AppTheme.border(context))),
      child: Column(
        children: findings.map((f) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_rounded, color: AppTheme.warning, size: 16),
              const SizedBox(width: 12),
              Expanded(child: Text(L10n.s(context, f), style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textSecondary(context), height: 1.5))),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, int index, _ActionKey action, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.surface(context), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.border(context))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 28, height: 28, decoration: BoxDecoration(color: color, shape: BoxShape.circle), child: Center(child: Text('$index', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(L10n.s(context, action.titleKey), style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary(context))),
                const SizedBox(height: 4),
                Text(L10n.s(context, action.descKey), style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondary(context), height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidanceNote(BuildContext context, String risk) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surface(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.border(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CLINICAL ADVICE', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textTertiary(context), letterSpacing: 1)),
            const SizedBox(height: 12),
            Text(
              _getClinicalGuidance(risk),
              style: GoogleFonts.outfit(fontSize: 15, color: AppTheme.textPrimary(context), height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  String _getClinicalGuidance(String risk) {
    switch (risk.toLowerCase()) {
      case 'critical':
        return 'Immediate hospitalization is required. This assessment indicates a very high probability of viral transmission. Do not delay seeking medical care for any reason.';
      case 'high':
        return 'You should visit a medical facility today. Vaccination and wound treatment are necessary to prevent infection. Keep the clinical report ready for the doctor.';
      case 'moderate':
        return 'Schedule a visit with your primary care provider. While not an immediate emergency, clinical evaluation of the bite and your vaccination history is needed.';
      default:
        return 'Continue to monitor the wound for signs of infection such as redness, swelling, or pus. Maintain proper hygiene and ensure your tetanus vaccination is up to date.';
    }
  }

  Widget _buildBottomBar(BuildContext context, Color color, String risk, String category, double score, List<String> findings, Map<String, String> answers, String notes, String riskTitleKey, String riskDescKey, List<_ActionKey> actions) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      decoration: BoxDecoration(color: AppTheme.surface(context), border: Border(top: BorderSide(color: AppTheme.border(context)))),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), side: BorderSide(color: AppTheme.border(context))),
              child: Text(L10n.s(context, 'home'), style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => _exportPdf(context, risk, category, score, findings, answers, notes, riskTitleKey, riskDescKey, actions),
              icon: const Icon(Icons.picture_as_pdf_rounded),
              label: Text(L10n.s(context, 'export_pdf'), style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.surface(context), 
                foregroundColor: color, 
                padding: const EdgeInsets.symmetric(vertical: 16), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: color, width: 2)), 
                elevation: 0
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportPdf(BuildContext context, String risk, String category, double score, List<String> findings, Map<String, String> answers, String notes, String riskTitleKey, String riskDescKey, List<_ActionKey> actions) async {
    try {
      final l10n = AppLocalizations.of(context)!;
      final pdf = await PdfService.buildAssessmentDocument(
        title: l10n.translate('animal_bite'),
        subtitle: category,
        severity: l10n.translate(riskTitleKey),
        score: ((score / 2.5).clamp(0.0, 1.0) * 100).round(),
        summary: l10n.translate(riskDescKey),
        actions: actions.map((a) => '${l10n.translate(a.titleKey)}: ${l10n.translate(a.descKey)}').toList(),
        drivers: findings,
        details: notes,
        answers: answers,
        l10n: l10n,
      );
      await Printing.layoutPdf(onLayout: (format) async => pdf.save(), name: 'ClinicalReport.pdf');
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${L10n.s(context, 'error')}: $e'), backgroundColor: AppTheme.danger));
    }
  }

  static const _criticalActionKeys = [
    _ActionKey('contact_doctor_imm', 'call_911_imm'),
    _ActionKey('go_to_er', 'do_not_drive'),
  ];
  static const _highActionKeys = [
    _ActionKey('schedule_doctor', 'urgent_care_visit'),
    _ActionKey('stay_uptodate_vax', 'monitor_symptoms'),
  ];
  static const _moderateActionKeys = [
    _ActionKey('schedule_doctor', 'rest_hydration'),
  ];
  static const _lowActionKeys = [
    _ActionKey('monitor_symptoms', 'rest_hydration'),
  ];
}

class _ActionKey {
  final String titleKey;
  final String descKey;
  const _ActionKey(this.titleKey, this.descKey);
}
