import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/vaccine_record.dart';
import '../models/history_entry.dart';
import '../l10n/app_localizations.dart';

class PdfService {
  PdfService._();

  static final _dateFormat = DateFormat('dd MMM yyyy');
  static final _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');

  // ─── Vaccine Report ──────────────────────────────────────────────────────
  static Future<pw.Document> generateVaccineReport({
    required List<VaccineRecord> records,
    required AppLocalizations l10n,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr = _dateTimeFormat.format(now);
    final docId = 'VG-VAC-${now.millisecondsSinceEpoch.toString().substring(7)}';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (ctx) => _buildHeader(l10n.translate('vaccine_records').toUpperCase(), docId, dateStr, l10n),
        footer: (ctx) => _buildFooter(ctx, l10n),
        build: (ctx) => [
          pw.SizedBox(height: 20),
          pw.Text(
            '${l10n.translate('total')}: ${records.length}  •  ${l10n.translate('completed')}: ${records.where((r) => r.isCompleted).length}  •  ${l10n.translate('pending')}: ${records.where((r) => !r.isCompleted).length}',
            style: const pw.TextStyle(fontSize: 12),
          ),
          pw.SizedBox(height: 16),
          pw.Divider(thickness: 1),
          pw.SizedBox(height: 16),
          if (records.isEmpty)
            pw.Center(child: pw.Text(l10n.translate('no_history_yet'), style: const pw.TextStyle(fontSize: 14))),
          ...records.map((r) => _buildVaccineEntry(r, l10n)),
        ],
      ),
    );
    return pdf;
  }

  static pw.Widget _buildVaccineEntry(VaccineRecord r, AppLocalizations l10n) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 0.5, color: PdfColors.grey400),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(r.vaccineName, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: pw.BoxDecoration(
                  color: r.isCompleted ? PdfColors.green100 : PdfColors.orange100,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Text(
                  l10n.translate(r.isCompleted ? 'completed' : 'pending').toUpperCase(),
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: r.isCompleted ? PdfColors.green800 : PdfColors.orange800),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(children: [
            pw.Text('${l10n.translate('today')}: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
            pw.Text(_dateFormat.format(r.vaccinationDate), style: const pw.TextStyle(fontSize: 11)),
            if (r.nextDoseDate != null) ...[
              pw.SizedBox(width: 24),
              pw.Text('${l10n.translate('next_step')}: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
              pw.Text(_dateFormat.format(r.nextDoseDate!), style: const pw.TextStyle(fontSize: 11)),
            ],
          ]),
        ],
      ),
    );
  }

  // ─── Assessments Report ──────────────────────────────────────────────────
  static Future<pw.Document> generateAssessmentsReport({
    required List<HistoryEntry> entries,
    required AppLocalizations l10n,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr = _dateTimeFormat.format(now);
    final docId = 'VG-ASS-${now.millisecondsSinceEpoch.toString().substring(7)}';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (ctx) => _buildHeader(l10n.translate('assessments').toUpperCase(), docId, dateStr, l10n),
        footer: (ctx) => _buildFooter(ctx, l10n),
        build: (ctx) => [
          pw.SizedBox(height: 20),
          pw.Text(
            '${l10n.translate('total')}: ${entries.length}',
            style: const pw.TextStyle(fontSize: 12),
          ),
          pw.SizedBox(height: 16),
          pw.Divider(thickness: 1),
          pw.SizedBox(height: 16),
          if (entries.isEmpty)
            pw.Center(child: pw.Text(l10n.translate('no_history_yet'), style: const pw.TextStyle(fontSize: 14))),
          ...entries.map((e) => _buildHistoryEntry(e, l10n)),
        ],
      ),
    );
    return pdf;
  }

  static pw.Widget _buildHistoryEntry(HistoryEntry e, AppLocalizations l10n) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 0.5, color: PdfColors.grey400),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(e.title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Text(e.type.name.toUpperCase(), style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Text('${l10n.translate('today')}: ${_dateFormat.format(e.createdAt)}', style: const pw.TextStyle(fontSize: 11)),
          if (e.summary.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text('${l10n.translate('clinical_findings')}: ${e.summary}', style: const pw.TextStyle(fontSize: 11)),
          ],
          if (e.riskScore != null) ...[
            pw.SizedBox(height: 4),
            pw.Text('${l10n.translate('probability_score')}: ${e.riskScore}%', style: const pw.TextStyle(fontSize: 11)),
          ],
        ],
      ),
    );
  }

  // ─── Header & Footer ─────────────────────────────────────────────────────
  static pw.Widget _buildHeader(String title, String docId, String dateStr, AppLocalizations l10n) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(width: 2)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('VAX-GUARD MEDICAL REPORT', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.Text(title, style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('DOC NO: $docId', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.Text('${l10n.translate('today').toUpperCase()}: $dateStr', style: const pw.TextStyle(fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context ctx, AppLocalizations l10n) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 12),
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(width: 0.5, color: PdfColors.grey400)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Disclaimer: AI generated summary. Not a diagnosis.',
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey500),
          ),
          pw.Text('${ctx.pageNumber} / ${ctx.pagesCount}', style: const pw.TextStyle(fontSize: 9)),
        ],
      ),
    );
  }

  // ─── Static Assessment Document ──────────────────────────────────────────
  static Future<pw.Document> buildAssessmentDocument({
    required String title,
    required String subtitle,
    required String severity,
    required int? score,
    required String summary,
    required List<String> actions,
    required List<String> drivers,
    String? details,
    required Map<String, String> answers,
    required AppLocalizations l10n,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr = _dateTimeFormat.format(now);
    final docId = 'VG-${now.millisecondsSinceEpoch.toString().substring(7)}';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(l10n.translate('risk_assessment').toUpperCase(), docId, dateStr, l10n),
              pw.SizedBox(height: 20),
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 1),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(l10n.translate('assessments').toUpperCase(), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        pw.Text(subtitle),
                        pw.SizedBox(height: 10),
                        pw.Text(l10n.translate('critical_risk').toUpperCase(), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        pw.Text(severity, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                    if (score != null)
                      pw.Column(
                        children: [
                          pw.Text('$score%', style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold)),
                          pw.Text(l10n.translate('probability_score').toUpperCase(), style: const pw.TextStyle(fontSize: 8)),
                        ],
                      ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(l10n.translate('clinical_findings').toUpperCase(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              pw.Text(summary),
              if (details != null && details.isNotEmpty) ...[
                pw.SizedBox(height: 15),
                pw.Text(l10n.translate('additional_details').toUpperCase(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                pw.Text(details, style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 10, color: PdfColors.grey700)),
              ],
              pw.SizedBox(height: 20),
              if (actions.isNotEmpty) ...[
                pw.Text(l10n.translate('recommended_actions').toUpperCase(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Divider(),
                ...actions.map((a) => pw.Bullet(text: a)),
              ],
              pw.Spacer(),
              pw.Text(
                'Disclaimer: Not a clinical diagnosis. Consult a doctor.',
                style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey500),
              ),
            ],
          );
        },
      ),
    );
    return pdf;
  }

  // ─── Full Report ─────────────────────────────────────────────────────────
  static Future<pw.Document> generateFullReport({
    required List<VaccineRecord> records,
    required List<HistoryEntry> history,
    required AppLocalizations l10n,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr = _dateTimeFormat.format(now);
    final docId = 'VG-FULL-${now.millisecondsSinceEpoch.toString().substring(7)}';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (ctx) => _buildHeader(l10n.translate('complete_health_report').toUpperCase(), docId, dateStr, l10n),
        footer: (ctx) => _buildFooter(ctx, l10n),
        build: (ctx) => [
          pw.SizedBox(height: 20),
          pw.Header(level: 0, text: l10n.translate('vaccine_records').toUpperCase()),
          pw.Divider(thickness: 1),
          pw.SizedBox(height: 10),
          if (records.isEmpty)
            pw.Text(l10n.translate('no_history_yet'))
          else
            ...records.map((r) => _buildVaccineEntry(r, l10n)),
          
          pw.SizedBox(height: 30),
          pw.Header(level: 0, text: l10n.translate('assessments').toUpperCase()),
          pw.Divider(thickness: 1),
          pw.SizedBox(height: 10),
          if (history.isEmpty)
            pw.Text(l10n.translate('no_history_yet'))
          else
            ...history.map((e) => _buildHistoryEntry(e, l10n)),
        ],
      ),
    );
    return pdf;
  }

  // ─── Daily Report ────────────────────────────────────────────────────────
  static Future<pw.Document> generateDailyReport({
    required List<VaccineRecord> records,
    required List<HistoryEntry> history,
    required AppLocalizations l10n,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr = _dateFormat.format(now);
    final docId = 'VG-DAY-${now.millisecondsSinceEpoch.toString().substring(7)}';

    // Filter for today only
    final today = DateTime(now.year, now.month, now.day);
    final todayRecords = records.where((r) => 
      r.vaccinationDate.year == today.year && 
      r.vaccinationDate.month == today.month && 
      r.vaccinationDate.day == today.day
    ).toList();
    
    final todayHistory = history.where((e) => 
      e.createdAt.year == today.year && 
      e.createdAt.month == today.month && 
      e.createdAt.day == today.day
    ).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (ctx) => _buildHeader('${l10n.translate('daily_health_log').toUpperCase()} - $dateStr', docId, dateStr, l10n),
        footer: (ctx) => _buildFooter(ctx, l10n),
        build: (ctx) => [
          pw.SizedBox(height: 20),
          pw.Text('${l10n.translate('summary_for')} $dateStr', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 20),
          
          if (todayRecords.isNotEmpty) ...[
            pw.Header(level: 1, text: l10n.translate('vaccine_records').toUpperCase()),
            ...todayRecords.map((r) => _buildVaccineEntry(r, l10n)),
            pw.SizedBox(height: 20),
          ],
          
          if (todayHistory.isNotEmpty) ...[
            pw.Header(level: 1, text: l10n.translate('assessments').toUpperCase()),
            ...todayHistory.map((e) => _buildHistoryEntry(e, l10n)),
          ],

          if (todayRecords.isEmpty && todayHistory.isEmpty)
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(40),
                child: pw.Text(l10n.translate('no_activity_today'), style: pw.TextStyle(fontSize: 14, color: PdfColors.grey600)),
              ),
            ),
        ],
      ),
    );
    return pdf;
  }
}
