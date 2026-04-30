import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../core/theme.dart';
import '../../services/pdf_service.dart';

class PdfViewScreen extends StatefulWidget {
  const PdfViewScreen({super.key});

  @override
  State<PdfViewScreen> createState() => _PdfViewScreenState();
}

class _PdfViewScreenState extends State<PdfViewScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Report', style: TextStyle(color: isDark ? Colors.white : Colors.white)),
        centerTitle: false,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: PdfPreview(
        build: (format) async {
          final pdf = await PdfService.instance.generateVaccineRecordPdf();
          return pdf.save();
        },
        canChangeOrientation: false,
        canChangePageFormat: false,
        allowPrinting: true,
        allowSharing: true,
        pdfFileName: 'VaxGuard_Report.pdf',
        loadingWidget: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppTheme.primary),
              const SizedBox(height: 16),
              Text('Generating PDF...', style: TextStyle(color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}