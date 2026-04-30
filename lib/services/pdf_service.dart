import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../models/history_entry.dart';

class PdfService {
  static PdfService? _instance;

  PdfService._();

  static PdfService get instance {
    _instance ??= PdfService._();
    return _instance!;
  }

  Future<pw.Document> generateVaccineRecordPdf() async {
    final pdf = pw.Document();
    final db = DatabaseService.instance;
    final records = await db.getAllVaccineRecords();
    final pending = await db.getUpcomingVaccines();
    final history = await db.getHistoryEntries();
    final assessments = history
        .where((entry) => entry.type != HistoryEntryType.vaccine)
        .toList();
    final urgentAssessments = assessments
        .where(
          (e) =>
              (e.riskScore ?? 0) >= 70 ||
              e.statusLabel.toLowerCase().contains('urgent') ||
              e.statusLabel.toLowerCase().contains('high'),
        )
        .take(5)
        .toList();
    final total = db.totalVaccines;
    final completedCount = db.completedVaccines;
    final percentage = db.completionPercentage;

    final dateFormat = DateFormat('MMMM dd, yyyy');
    final dateTimeFormat = DateFormat('MMMM dd, yyyy HH:mm');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(context, 'Vaccination Record Report'),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF2563EB),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'VaxGuard',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Vaccination Record Certificate',
                      style: const pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        '${percentage.toStringAsFixed(0)}%',
                        style: pw.TextStyle(
                          color: PdfColor.fromInt(0xFF2563EB),
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'Complete',
                        style: const pw.TextStyle(
                          color: PdfColors.grey700,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildStatBox('Total', total.toString(), PdfColors.blue),
                _buildStatBox('Completed', completedCount.toString(), PdfColors.green),
                _buildStatBox('Pending', pending.length.toString(), PdfColors.orange),
              ],
            ),
          ),
          pw.SizedBox(height: 30),
          pw.Text(
            'Emergency Summary',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromInt(0xFF991B1B),
            ),
          ),
          pw.SizedBox(height: 10),
          if (urgentAssessments.isEmpty)
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.green50,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(
                'No recent urgent findings in saved assessments.',
                style: const pw.TextStyle(fontSize: 12),
              ),
            )
          else
            pw.Column(
              children: urgentAssessments
                  .map(
                    (e) => pw.Container(
                      width: double.infinity,
                      margin: const pw.EdgeInsets.only(bottom: 8),
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.red50,
                        borderRadius: pw.BorderRadius.circular(8),
                        border: pw.Border.all(color: PdfColors.red200),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            '${_assessmentTypeLabel(e.type)} • ${e.statusLabel}',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.red800,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(e.title, style: const pw.TextStyle(fontSize: 11)),
                          pw.Text(e.summary, style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          pw.SizedBox(height: 24),
          pw.Text(
            'Vaccination History',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromInt(0xFF1E293B),
            ),
          ),
          pw.SizedBox(height: 12),
          if (records.isEmpty)
            pw.Container(
              padding: const pw.EdgeInsets.all(30),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Center(
                child: pw.Text(
                  'No vaccination records found.\nAdd your vaccine records to generate a certificate.',
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(
                    color: PdfColors.grey600,
                    fontSize: 12,
                  ),
                ),
              ),
            )
          else
            pw.TableHelper.fromTextArray(
              headers: ['Vaccine', 'Dose', 'Date', 'Location', 'Status'],
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFF2563EB),
              ),
              headerPadding: const pw.EdgeInsets.all(8),
              cellPadding: const pw.EdgeInsets.all(8),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.center,
                2: pw.Alignment.center,
                3: pw.Alignment.centerLeft,
                4: pw.Alignment.center,
              },
              data: records.map((record) => [
                record.vaccineName,
                record.doseNumber ?? 'N/A',
                dateFormat.format(record.vaccinationDate),
                record.clinicName ?? 'N/A',
                record.isCompleted ? '✓ Completed' : '○ Pending',
              ]).toList(),
            ),
          pw.SizedBox(height: 30),
          if (records.isNotEmpty) ...[
            pw.Text(
              'Certificate Details',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromInt(0xFF1E293B),
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Report Generated', dateTimeFormat.format(DateTime.now())),
                  pw.SizedBox(height: 8),
                  _buildDetailRow('Total Vaccinations', total.toString()),
                  pw.SizedBox(height: 8),
                  _buildDetailRow('Completion Rate', '${percentage.toStringAsFixed(1)}%'),
                  pw.SizedBox(height: 8),
                  _buildDetailRow('Next Scheduled Doses', pending.length.toString()),
                ],
              ),
            ),
          ],
          pw.SizedBox(height: 24),
          pw.Text(
            'Assessment Summary',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromInt(0xFF1E293B),
            ),
          ),
          pw.SizedBox(height: 10),
          if (assessments.isEmpty)
            pw.Text(
              'No assessment records available.',
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
            )
          else ...[
            _buildAssessmentTypeSection(
              'Health Assessments',
              assessments.where((e) => e.type == HistoryEntryType.triage).toList(),
              dateFormat,
            ),
            _buildAssessmentTypeSection(
              'Animal Bite Assessments',
              assessments.where((e) => e.type == HistoryEntryType.animalBite).toList(),
              dateFormat,
            ),
            _buildAssessmentTypeSection(
              'Symptom Checks',
              assessments
                  .where((e) => e.type == HistoryEntryType.symptomChecker)
                  .toList(),
              dateFormat,
            ),
            _buildAssessmentTypeSection(
              'Disease-Specific Checks',
              assessments
                  .where((e) => e.type == HistoryEntryType.diseaseAssessment)
                  .toList(),
              dateFormat,
            ),
          ],
        ],
      ),
    );

    return pdf;
  }

  pw.Widget _buildHeader(pw.Context context, String title) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            title,
            style: const pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey600,
            ),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generated by VaxGuard App',
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
            ),
          ),
          pw.Text(
            DateFormat('yyyy-MM-dd').format(DateTime.now()),
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildStatBox(String label, String value, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      child: pw.Column(
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            label,
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildDetailRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey700,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Future<void> shareVaccineRecordsPdf() async {
    final pdf = await generateVaccineRecordPdf();
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'VaxGuard_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  Future<void> printVaccineRecordsPdf() async {
    final pdf = await generateVaccineRecordPdf();
    await Printing.layoutPdf(
      onLayout: (format) => pdf.save(),
      name: 'VaxGuard Report',
    );
  }

  String _assessmentTypeLabel(HistoryEntryType type) {
    switch (type) {
      case HistoryEntryType.triage:
        return 'General';
      case HistoryEntryType.animalBite:
        return 'Animal Bite';
      case HistoryEntryType.symptomChecker:
        return 'Symptom';
      case HistoryEntryType.diseaseAssessment:
        return 'Disease';
      case HistoryEntryType.vaccine:
        return 'Vaccine';
    }
  }

  pw.Widget _buildAssessmentTypeSection(
    String title,
    List<HistoryEntry> items,
    DateFormat format,
  ) {
    if (items.isEmpty) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 10),
        child: pw.Text(
          '$title: none',
          style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
        ),
      );
    }
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          ...items.take(5).map(
            (entry) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 6),
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '${entry.title} • ${entry.statusLabel}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                  ),
                  pw.Text(
                    '${entry.summary}\nDate: ${format.format(entry.createdAt)}${entry.riskScore != null ? ' • Score ${entry.riskScore}%' : ''}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
