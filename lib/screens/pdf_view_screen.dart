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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Vaccine Report'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () async {
              await PdfService.instance.shareVaccineRecordsPdf();
            },
            tooltip: 'Share PDF',
          ),
          IconButton(
            icon: const Icon(Icons.print_rounded),
            onPressed: () async {
              await PdfService.instance.printVaccineRecordsPdf();
            },
            tooltip: 'Print',
          ),
        ],
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
        loadingWidget: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Generating PDF...'),
            ],
          ),
        ),
      ),
    );
  }
}