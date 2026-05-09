import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:printing/printing.dart';

import '../core/theme.dart';
import '../models/vaccine_record.dart';
import '../services/database_service.dart';
import '../utils/app_constants.dart';
import '../utils/l10n_helper.dart';
import '../l10n/app_localizations.dart';
import '../services/pdf_service.dart';

class VaccineScheduleScreen extends StatefulWidget {
  const VaccineScheduleScreen({super.key});

  @override
  State<VaccineScheduleScreen> createState() => _VaccineScheduleScreenState();
}

class _VaccineScheduleScreenState extends State<VaccineScheduleScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<VaccineRecord> _allRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRecords();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRecords() async {
    final records = await DatabaseService.instance.getAllVaccineRecords();
    records.sort((a, b) => b.vaccinationDate.compareTo(a.vaccinationDate));
    if (mounted) {
      setState(() {
        _allRecords = records;
        _isLoading = false;
      });
    }
  }

  List<VaccineRecord> get _completedRecords => _allRecords.where((r) => r.isCompleted).toList();
  List<VaccineRecord> get _pendingRecords => _allRecords.where((r) => !r.isCompleted).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background(context),
      appBar: AppBar(
        title: Text(L10n.s(context, 'vaccine_records'), style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppTheme.textPrimary(context))),
        backgroundColor: AppTheme.surface(context),
        foregroundColor: AppTheme.textPrimary(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary(context)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf_rounded, color: AppTheme.warning),
            tooltip: L10n.s(context, 'export_pdf'),
            onPressed: () => _exportPdf(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppTheme.border(context)),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildStatsHeader(),
            _buildTabs(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTimeline(_allRecords),
                  _buildTimeline(_completedRecords),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddVaccineSheet(context),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(L10n.s(context, 'save_vaccine'), style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildStatsHeader() {
    final total = _allRecords.length;
    final completed = _completedRecords.length;
    final progress = total > 0 ? completed / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border(context)),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(L10n.s(context, 'total'), total.toString(), AppTheme.primary),
              _buildStatDivider(),
              _buildStatItem(L10n.s(context, 'completed'), completed.toString(), AppTheme.success),
              _buildStatDivider(),
              _buildStatItem(L10n.s(context, 'pending'), _pendingRecords.length.toString(), AppTheme.warning),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                '${L10n.s(context, "protection")}: ',
                style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondary(context), fontWeight: FontWeight.w600),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppTheme.surfaceVariant(context),
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.success),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(progress * 100).round()}%',
                style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.success),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textSecondary(context), fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(height: 30, width: 1, color: AppTheme.border(context));
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppTheme.surface(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border(context)),
        ),
        child: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: AppTheme.textSecondary(context),
          indicator: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          tabs: [
            Tab(child: Text(L10n.s(context, 'all'), style: GoogleFonts.outfit(fontWeight: FontWeight.w700))),
            Tab(child: Text(L10n.s(context, 'completed'), style: GoogleFonts.outfit(fontWeight: FontWeight.w700))),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(List<VaccineRecord> records) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.vaccines_rounded, size: 64, color: AppTheme.textTertiary(context)),
            const SizedBox(height: 20),
            Text(L10n.s(context, 'no_history_yet'), style: GoogleFonts.outfit(fontSize: 18, color: AppTheme.textPrimary(context), fontWeight: FontWeight.w700)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        final isLast = index == records.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 40,
                child: Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: record.isCompleted ? AppTheme.success : AppTheme.warning,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.background(context), width: 4),
                        boxShadow: [
                          BoxShadow(color: (record.isCompleted ? AppTheme.success : AppTheme.warning).withOpacity(0.3), blurRadius: 8)
                        ],
                      ),
                      child: record.isCompleted
                          ? const Icon(Icons.check, size: 12, color: Colors.white)
                          : const Icon(Icons.access_time_filled, size: 12, color: Colors.white),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: AppTheme.border(context).withOpacity(0.5),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface(context),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.border(context)),
                      boxShadow: AppTheme.shadowSm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(record.vaccineName, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary(context)))),
                            _buildRecordMenu(record),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.calendar_month_rounded, size: 14, color: AppTheme.textSecondary(context)),
                            const SizedBox(width: 6),
                            Text(DateFormat('MMM d, yyyy').format(record.vaccinationDate), style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary(context), fontWeight: FontWeight.w600)),
                          ],
                        ),
                        if (record.clinicName != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: AppTheme.surfaceVariant(context).withOpacity(0.5), borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              children: [
                                Icon(Icons.local_hospital_rounded, size: 12, color: AppTheme.primary),
                                const SizedBox(width: 8),
                                Expanded(child: Text(record.clinicName!, style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary(context)))),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecordMenu(VaccineRecord record) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_horiz_rounded, color: AppTheme.textTertiary(context)),
      color: AppTheme.surface(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: AppTheme.border(context))),
      onSelected: (val) {
        if (val == 'delete') _deleteRecord(record);
        if (val == 'complete') _markComplete(record);
      },
      itemBuilder: (context) => [
        if (!record.isCompleted)
          PopupMenuItem(
            value: 'complete',
            child: Row(children: [Icon(Icons.check_circle_outline, color: AppTheme.success, size: 18), const SizedBox(width: 12), Text(L10n.s(context, 'completed'), style: GoogleFonts.outfit())]),
          ),
        PopupMenuItem(
          value: 'delete',
          child: Row(children: [Icon(Icons.delete_outline_rounded, color: AppTheme.danger, size: 18), const SizedBox(width: 12), Text(L10n.s(context, 'cancel'), style: GoogleFonts.outfit(color: AppTheme.danger))]),
        ),
      ],
    );
  }

  Future<void> _exportPdf(BuildContext context) async {
    try {
      final l10n = AppLocalizations.of(context)!;
      final pdf = await PdfService.generateVaccineReport(records: _allRecords, l10n: l10n);
      await Printing.layoutPdf(onLayout: (format) async => pdf.save(), name: 'Vaccination_Report.pdf');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${L10n.s(context, 'pdf_error')}: $e'), backgroundColor: AppTheme.danger));
    }
  }

  Future<void> _deleteRecord(VaccineRecord record) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface(context),
        title: Text(L10n.s(context, 'cancel'), style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
        content: Text('${L10n.s(context, "cancel")} ${record.vaccineName}?', style: GoogleFonts.outfit()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(L10n.s(context, 'cancel'), style: GoogleFonts.outfit())),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(L10n.s(context, 'cancel'), style: GoogleFonts.outfit(color: AppTheme.danger, fontWeight: FontWeight.w800))),
        ],
      ),
    );
    if (ok == true) {
      await DatabaseService.instance.deleteVaccineRecord(record.id);
      _loadRecords();
    }
  }

  Future<void> _markComplete(VaccineRecord record) async {
    await DatabaseService.instance.markVaccineComplete(record.id);
    _loadRecords();
  }

  void _showAddVaccineSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddVaccineSheet(onAdded: _loadRecords),
    );
  }
}

class _AddVaccineSheet extends StatefulWidget {
  final VoidCallback onAdded;
  const _AddVaccineSheet({required this.onAdded});
  @override
  State<_AddVaccineSheet> createState() => _AddVaccineSheetState();
}

class _AddVaccineSheetState extends State<_AddVaccineSheet> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedVaccine;
  String? _selectedDose;
  DateTime _selectedDate = DateTime.now();
  final _lotController = TextEditingController();
  final _clinicController = TextEditingController();
  bool _isCompleted = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(color: AppTheme.surface(context), borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(L10n.s(context, 'save_vaccine'), style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textPrimary(context))),
              const SizedBox(height: 24),
              _buildDropdown(L10n.s(context, 'vaccines'), AppConstants.commonVaccines, (v) => setState(() => _selectedVaccine = v)),
              const SizedBox(height: 16),
              _buildTextField(L10n.s(context, 'hospitals'), _clinicController),
              const SizedBox(height: 16),
              _buildDatePicker(L10n.s(context, 'today'), _selectedDate, (d) => setState(() => _selectedDate = d)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: Text(L10n.s(context, 'save_vaccine'), style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label, filled: true, fillColor: AppTheme.surfaceVariant(context).withOpacity(0.3), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(controller: controller, decoration: InputDecoration(labelText: label, filled: true, fillColor: AppTheme.surfaceVariant(context).withOpacity(0.3), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)));
  }

  Widget _buildDatePicker(String label, DateTime date, Function(DateTime) onChanged) {
    return ListTile(
      title: Text(label),
      subtitle: Text(DateFormat('MMM d, yyyy').format(date)),
      onTap: () async {
        final d = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2000), lastDate: DateTime(2030));
        if (d != null) onChanged(d);
      },
    );
  }

  Future<void> _save() async {
    if (_selectedVaccine == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(L10n.s(context, 'select_vaccine_error')), backgroundColor: AppTheme.danger));
      return;
    }
    final record = VaccineRecord(
      id: const Uuid().v4(),
      vaccineName: _selectedVaccine!,
      vaccinationDate: _selectedDate,
      lotNumber: 'NA',
      clinicName: _clinicController.text,
      isCompleted: _isCompleted,
    );
    await DatabaseService.instance.addVaccineRecord(record);
    widget.onAdded();
    Navigator.pop(context);
  }
}