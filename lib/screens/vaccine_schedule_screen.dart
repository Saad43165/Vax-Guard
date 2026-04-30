import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../models/vaccine_record.dart';
import '../services/database_service.dart';
import '../utils/app_constants.dart';
import '../utils/app_strings.dart';
import '../widgets/vaccine_card.dart';
import 'package:uuid/uuid.dart';

class VaccineScheduleScreen extends StatefulWidget {
  const VaccineScheduleScreen({super.key});

  @override
  State<VaccineScheduleScreen> createState() => _VaccineScheduleScreenState();
}

class _VaccineScheduleScreenState extends State<VaccineScheduleScreen>
    with SingleTickerProviderStateMixin {
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
    setState(() {
      _allRecords = records;
      _isLoading = false;
    });
  }

  List<VaccineRecord> get _completedRecords =>
      _allRecords.where((r) => r.isCompleted).toList();

  List<VaccineRecord> get _pendingRecords =>
      _allRecords.where((r) => !r.isCompleted).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Vaccine Schedule'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'All (${_allRecords.length})'),
            Tab(text: 'Completed (${_completedRecords.length})'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddVaccineSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Vaccine'),
        backgroundColor: AppTheme.primary,
      ),
      body: Column(
        children: [
          _buildStatsBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVaccineList(_allRecords),
                _buildVaccineList(_completedRecords),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    final total = _allRecords.length;
    final completed = _completedRecords.length;
    final progress = total > 0 ? completed / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              _buildStat('Total', total.toString(), AppTheme.primary),
              _buildStatDivider(),
              _buildStat('Completed', completed.toString(), AppTheme.success),
              _buildStatDivider(),
              _buildStat('Pending', _pendingRecords.length.toString(), AppTheme.warning),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Progress: ',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppTheme.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.success),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color),
          ),
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(height: 40, width: 1, color: AppTheme.border);
  }

  Widget _buildVaccineList(List<VaccineRecord> records) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('💉', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            const Text(
              AppStrings.noVaccines,
              style: TextStyle(fontSize: 16, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text('Tap + to add your first vaccine record', style: TextStyle(fontSize: 13, color: AppTheme.textTertiary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return VaccineCard(
          record: record,
          onDelete: () => _deleteRecord(record),
          onMarkComplete: record.isCompleted ? null : () => _markComplete(record),
        );
      },
    );
  }

  Future<void> _deleteRecord(VaccineRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: Text('Are you sure you want to delete ${record.vaccineName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await DatabaseService.instance.deleteVaccineRecord(record.id);
      _loadRecords();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(AppStrings.vaccineDeleted)));
      }
    }
  }

  Future<void> _markComplete(VaccineRecord record) async {
    await DatabaseService.instance.markVaccineComplete(record.id);
    _loadRecords();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${record.vaccineName} marked as completed!')));
    }
  }

  void _showAddVaccineSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
  DateTime? _nextDoseDate;
  final _lotController = TextEditingController();
  final _adminByController = TextEditingController();
  final _clinicController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isCompleted = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _lotController.dispose();
    _adminByController.dispose();
    _clinicController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSheetHandle(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add Vaccine Record',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 20),
                      _buildVaccineDropdown(),
                      const SizedBox(height: 16),
                      _buildDoseDropdown(),
                      const SizedBox(height: 16),
                      _buildDatePicker(label: 'Vaccination Date *', date: _selectedDate, onChanged: (d) => setState(() => _selectedDate = d)),
                      const SizedBox(height: 16),
                      _buildTextField(controller: _lotController, label: 'Lot Number *', hint: 'e.g. EK4241', validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                      const SizedBox(height: 16),
                      _buildTextField(controller: _clinicController, label: 'Clinic / Hospital', hint: 'Optional'),
                      const SizedBox(height: 16),
                      _buildTextField(controller: _adminByController, label: 'Administered By', hint: 'Optional'),
                      const SizedBox(height: 16),
                      _buildDatePicker(label: 'Next Dose Date (Optional)', date: _nextDoseDate, onChanged: (d) => setState(() => _nextDoseDate = d), allowNull: true),
                      const SizedBox(height: 16),
                      _buildTextField(controller: _notesController, label: 'Notes', hint: 'Optional notes', maxLines: 2),
                      const SizedBox(height: 16),
                      _buildCompletedToggle(),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveRecord,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                )
                              : const Text(AppStrings.saveVaccine, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetHandle() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2)),
    );
  }

  Widget _buildVaccineDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedVaccine,
      decoration: InputDecoration(
        labelText: 'Vaccine Name *',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      hint: const Text('Select vaccine'),
      items: AppConstants.commonVaccines.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
      onChanged: (v) => setState(() => _selectedVaccine = v),
      validator: (v) => v == null ? 'Please select a vaccine' : null,
    );
  }

  Widget _buildDoseDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedDose,
      decoration: InputDecoration(
        labelText: 'Dose Number',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      hint: const Text('Select dose (optional)'),
      items: AppConstants.doseNumbers.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
      onChanged: (v) => setState(() => _selectedDose = v),
    );
  }

  Widget _buildDatePicker({required String label, DateTime? date, required Function(DateTime) onChanged, bool allowNull = false}) {
    DateTime effectiveDate = date ?? DateTime.now();
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: effectiveDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2030),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppTheme.border), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 18, color: AppTheme.textSecondary),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                Text(
                  date != null ? DateFormat('MMM d, yyyy').format(date) : 'Not selected',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: date != null ? AppTheme.textPrimary : AppTheme.textTertiary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, String? hint, int maxLines = 1, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, hintText: hint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white),
      validator: validator,
    );
  }

  Widget _buildCompletedToggle() {
    return Row(
      children: [
        const Text('Mark as Completed', style: TextStyle(fontSize: 14, color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
        const Spacer(),
        Switch(value: _isCompleted, onChanged: (v) => setState(() => _isCompleted = v), activeTrackColor: AppTheme.success),
      ],
    );
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final record = VaccineRecord(
        id: const Uuid().v4(),
        vaccineName: _selectedVaccine!,
        vaccinationDate: _selectedDate,
        lotNumber: _lotController.text.trim(),
        administeredBy: _adminByController.text.trim().isEmpty ? null : _adminByController.text.trim(),
        clinicName: _clinicController.text.trim().isEmpty ? null : _clinicController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        isCompleted: _isCompleted,
        nextDoseDate: _nextDoseDate,
        doseNumber: _selectedDose,
      );

      await DatabaseService.instance.addVaccineRecord(record);

      if (mounted) {
        Navigator.pop(context);
        widget.onAdded();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(AppStrings.vaccineAdded)));
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving record: $e')));
    }
  }
}