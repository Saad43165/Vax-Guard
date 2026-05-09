import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../services/clinical_triage_service.dart';
import '../utils/app_constants.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../widgets/custom_button.dart';
import '../utils/l10n_helper.dart';
import '../l10n/app_localizations.dart';
import '../services/pdf_service.dart';
import 'package:printing/printing.dart';

class TriageResultScreen extends StatefulWidget {
  const TriageResultScreen({super.key});

  @override
  State<TriageResultScreen> createState() => _TriageResultScreenState();
}

class _TriageResultScreenState extends State<TriageResultScreen> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _slideAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _slideController.forward();
    _scrollController.addListener(() {
      final collapsed = _scrollController.offset > 140;
      if (collapsed != _isCollapsed) setState(() => _isCollapsed = collapsed);
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Color _getRiskColor(ClinicalRiskLevel level) {
    switch (level) {
      case ClinicalRiskLevel.low: return AppTheme.riskLow;
      case ClinicalRiskLevel.medium: return AppTheme.riskMedium;
      case ClinicalRiskLevel.high: return AppTheme.riskHigh;
      case ClinicalRiskLevel.critical: return AppTheme.riskCritical;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ClinicalTriageResult? result = ModalRoute.of(context)?.settings.arguments as ClinicalTriageResult?;

    if (result == null) {
      return Scaffold(
        backgroundColor: AppTheme.background(context),
        appBar: AppBar(title: Text(L10n.s(context, 'error'))),
        body: Center(child: Text(L10n.s(context, 'error'))),
      );
    }

    final riskColor = _getRiskColor(result.level);

    return Scaffold(
      backgroundColor: AppTheme.background(context),
      appBar: _buildFixedAppBar(context, result, riskColor),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildScoreCard(result, riskColor),
                    const SizedBox(height: 20),
                    _buildGuidanceSection(context, result, riskColor),
                    const SizedBox(height: 20),
                    _buildFindingsCard(result, riskColor),
                    const SizedBox(height: 20),
                    _buildActionsCard(result, riskColor),
                    const SizedBox(height: 32),
                    _buildBottomActions(context, result),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildFixedAppBar(BuildContext context, ClinicalTriageResult result, Color riskColor) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      title: Text(
        L10n.s(context, result.titleKey),
        style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white),
      ),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildGuidanceSection(BuildContext context, ClinicalTriageResult result, Color color) {
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
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CLINICAL GUIDANCE', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: color, letterSpacing: 1)),
            const SizedBox(height: 12),
            Text(
              _getTriageGuidance(result.level),
              style: GoogleFonts.outfit(fontSize: 15, color: AppTheme.textPrimary(context), height: 1.6, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  String _getTriageGuidance(ClinicalRiskLevel level) {
    switch (level) {
      case ClinicalRiskLevel.critical:
        return 'IMMEDIATE ACTION REQUIRED. Your symptoms indicate a high probability of a life-threatening condition. Call emergency services or go to the nearest ER right now.';
      case ClinicalRiskLevel.high:
        return 'URGENT EVALUATION NEEDED. You should seek medical attention within the next few hours. Do not wait for symptoms to worsen.';
      case ClinicalRiskLevel.medium:
        return 'CLINICAL FOLLOW-UP RECOMMENDED. Contact your healthcare provider today to discuss your symptoms and determine if an in-person visit is necessary.';
      case ClinicalRiskLevel.low:
        return 'MONITOR AT HOME. Your risk level appears low. Continue to rest, stay hydrated, and monitor for any new or worsening symptoms.';
    }
  }

  Widget _buildScoreCard(ClinicalTriageResult result, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border(context)),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(L10n.s(context, 'probability_score').toUpperCase(), style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textTertiary(context), letterSpacing: 1)),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: color.withOpacity(0.3), width: 1.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${result.score}%', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
                    Text(L10n.s(context, 'probability').toUpperCase(), style: GoogleFonts.outfit(fontSize: 8, color: color, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(value: result.score / 100, minHeight: 12, backgroundColor: AppTheme.surfaceVariant(context), valueColor: AlwaysStoppedAnimation<Color>(color)),
          ),
          if (result.hasRedFlags) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.danger.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.danger.withOpacity(0.2))),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppTheme.danger, size: 24),
                  const SizedBox(width: 12),
                  Expanded(child: Text(L10n.s(context, 'life_threatening_signs'), style: GoogleFonts.outfit(color: AppTheme.danger, fontWeight: FontWeight.w700, fontSize: 14))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFindingsCard(ClinicalTriageResult result, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppTheme.surface(context), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.border(context))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(L10n.s(context, 'clinical_findings').toUpperCase(), style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textTertiary(context), letterSpacing: 1)),
          const SizedBox(height: 20),
          ...result.clinicalFindings.map((finding) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(Icons.analytics_outlined, color: AppTheme.textTertiary(context), size: 18),
                const SizedBox(width: 12),
                Expanded(child: Text(finding.startsWith('Critical:') ? L10n.s(context, finding.split(': ')[1]) : (finding.contains(': ') ? L10n.s(context, finding.split(': ')[1]) : finding), style: GoogleFonts.outfit(fontSize: 14, fontWeight: finding.startsWith('Critical:') ? FontWeight.w700 : FontWeight.w500, color: finding.startsWith('Critical:') ? AppTheme.danger : AppTheme.textPrimary(context)))),
              ],
            ),
          )),
          const SizedBox(height: 16),
          Text(L10n.s(context, result.descriptionKey), style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textSecondary(context), height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildActionsCard(ClinicalTriageResult result, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppTheme.surface(context), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.border(context))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(L10n.s(context, 'recommended_actions').toUpperCase(), style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textTertiary(context), letterSpacing: 1)),
          const SizedBox(height: 20),
          ...result.actionKeys.map((key) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_outline_rounded, color: color, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(L10n.s(context, key), style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary(context)))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, ClinicalTriageResult result) {
    return Column(
      children: [
        if (result.level == ClinicalRiskLevel.critical || result.level == ClinicalRiskLevel.high)
          CustomButton(
            label: '🏥 ${L10n.s(context, "hospitals")}',
            onPressed: () => Navigator.pushNamed(context, AppConstants.hospitalMapRoute),
            variant: ButtonVariant.danger,
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () => _exportPdf(context, result),
            icon: const Icon(Icons.picture_as_pdf_rounded, size: 20),
            label: Text(L10n.s(context, 'clinical_feedback'), style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 12),
        CustomButton(label: L10n.s(context, 'home'), onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppConstants.homeRoute, (route) => false), variant: ButtonVariant.secondary),
      ],
    );
  }

  Future<void> _exportPdf(BuildContext context, ClinicalTriageResult result) async {
    try {
      final l10n = AppLocalizations.of(context)!;
      final pdf = await PdfService.buildAssessmentDocument(
        title: l10n.translate(result.titleKey),
        subtitle: l10n.translate('triage_assessment'),
        severity: result.level.name.toUpperCase(),
        score: result.score,
        summary: l10n.translate(result.descriptionKey),
        actions: result.actionKeys.map((k) => l10n.translate(k)).toList(),
        drivers: result.clinicalFindings,
        details: '',
        answers: {},
        l10n: l10n,
      );
      await Printing.layoutPdf(onLayout: (format) async => pdf.save(), name: 'TriageReport.pdf');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${L10n.s(context, 'error')}: $e'), backgroundColor: AppTheme.danger));
      }
    }
  }
}