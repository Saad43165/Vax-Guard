import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../core/theme.dart';
import '../services/pdf_service.dart';
import '../services/database_service.dart';
import '../models/vaccine_record.dart';
import '../models/history_entry.dart';

class PdfViewScreen extends StatefulWidget {
  const PdfViewScreen({super.key});

  @override
  State<PdfViewScreen> createState() => _PdfViewScreenState();
}

class _PdfViewScreenState extends State<PdfViewScreen> {
  _PdfType? _selectedType;
  bool _isLoading = false;
  Future<List<int>>? _pdfFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showOptionsDialog());
  }

  Future<void> _showOptionsDialog() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildOptionsSheet(ctx),
    );
    if (_selectedType == null && mounted) {
      Navigator.pop(context);
    }
  }

  Widget _buildOptionsSheet(BuildContext ctx) {
    final options = [
      _PdfOption(
        type: _PdfType.vaccines,
        title: 'Vaccine Records',
        subtitle: 'Full history of all vaccinations',
        icon: Icons.vaccines_rounded,
        color: AppTheme.primary,
      ),
      _PdfOption(
        type: _PdfType.assessments,
        title: 'Health Assessments',
        subtitle: 'Triage, symptom & disease results',
        icon: Icons.analytics_rounded,
        color: AppTheme.secondary,
      ),
      _PdfOption(
        type: _PdfType.full,
        title: 'Complete Health Report',
        subtitle: 'All records in a single document',
        icon: Icons.description_rounded,
        color: AppTheme.success,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24, top: 8),
            decoration: BoxDecoration(
              color: AppTheme.border(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.picture_as_pdf_rounded, color: AppTheme.warning, size: 22),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Export Health Records', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary(context))),
                  Text('Choose what to include in your PDF', style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondary(context))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...options.map((opt) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                setState(() => _selectedType = opt.type);
                Navigator.pop(ctx);
                _generatePdf(opt.type);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.background(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border(context)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: opt.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(opt.icon, color: opt.color, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(opt.title, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.textPrimary(context))),
                          Text(opt.subtitle, style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary(context))),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.textTertiary(context)),
                  ],
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Future<void> _generatePdf(_PdfType type) async {
    setState(() => _isLoading = true);
    try {
      final l10n = AppLocalizations.of(context)!;
      switch (type) {
        case _PdfType.vaccines:
          final records = await DatabaseService.instance.getAllVaccineRecords();
          final pdf = await PdfService.generateVaccineReport(records: records, l10n: l10n);
          await Printing.layoutPdf(
            onLayout: (fmt) async => pdf.save(),
            name: 'VaxGuard_Vaccines.pdf',
          );
          break;
        case _PdfType.assessments:
          final history = await DatabaseService.instance.getHistoryEntries();
          final assessments = history.where((e) => e.type != HistoryEntryType.vaccine).toList();
          final pdf = await PdfService.generateAssessmentsReport(entries: assessments, l10n: l10n);
          await Printing.layoutPdf(
            onLayout: (fmt) async => pdf.save(),
            name: 'VaxGuard_Assessments.pdf',
          );
          break;
        case _PdfType.full:
          final records = await DatabaseService.instance.getAllVaccineRecords();
          final history = await DatabaseService.instance.getHistoryEntries();
          final pdf = await PdfService.generateFullReport(records: records, history: history, l10n: l10n);
          await Printing.layoutPdf(
            onLayout: (fmt) async => pdf.save(),
            name: 'VaxGuard_Full_Report.pdf',
          );
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e', style: GoogleFonts.outfit()),
            backgroundColor: AppTheme.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background(context),
      appBar: AppBar(
        title: Text('Export PDF', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppTheme.textPrimary(context))),
        backgroundColor: AppTheme.surface(context),
        foregroundColor: AppTheme.textPrimary(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppTheme.border(context)),
        ),
      ),
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.primary),
                  const SizedBox(height: 20),
                  Text('Generating your PDF...', style: GoogleFonts.outfit(color: AppTheme.textSecondary(context), fontSize: 16)),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.picture_as_pdf_rounded, size: 80, color: AppTheme.textTertiary(context)),
                  const SizedBox(height: 20),
                   Text(
                    _selectedType == null ? 'Select a report type to export' : 'PDF exported successfully',
                    style: GoogleFonts.outfit(color: AppTheme.textSecondary(context), fontSize: 16, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _showOptionsDialog,
                    icon: const Icon(Icons.add_rounded),
                    label: Text('Export Another Report', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

enum _PdfType { vaccines, assessments, full }

class _PdfOption {
  final _PdfType type;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _PdfOption({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}