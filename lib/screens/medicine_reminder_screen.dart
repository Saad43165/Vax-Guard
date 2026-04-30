import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/medicine_reminder_service.dart';
import '../services/notification_service.dart';

class MedicineReminderScreen extends StatefulWidget {
  const MedicineReminderScreen({super.key});

  @override
  State<MedicineReminderScreen> createState() => _MedicineReminderScreenState();
}

class _MedicineReminderScreenState extends State<MedicineReminderScreen> {
  List<MedicineReminder> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    setState(() => _isLoading = true);
    final list = await MedicineReminderService.instance.getAllReminders();
    if (mounted) setState(() { _reminders = list; _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            backgroundColor: AppTheme.purple,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Medicine Reminders',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              titlePadding: const EdgeInsetsDirectional.only(start: 24, bottom: 16),
              background: Container(
                decoration: const BoxDecoration(gradient: AppTheme.purpleGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 20, 52),
                    child: Row(
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.medication_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Never miss a dose', style: TextStyle(color: Colors.white70, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (_reminders.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.purpleLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.medication_rounded, size: 52, color: AppTheme.purple),
                    ),
                    const SizedBox(height: 20),
                    Text('No Reminders Yet', style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(
                      'Add reminders so you never miss\na medication dose',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => _showAddSheet(context),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add Reminder'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildOverviewCard(context),
                  const SizedBox(height: 14),
                  ...List.generate(_reminders.length, (i) {
                    return _ReminderCard(
                      reminder: _reminders[i],
                      onToggle: (active) async {
                        await MedicineReminderService.instance.toggleReminder(_reminders[i].id!, active);
                        _loadReminders();
                      },
                      onDelete: () async {
                        await MedicineReminderService.instance.deleteReminder(_reminders[i].id!);
                        _loadReminders();
                      if (!context.mounted) return;
                      if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Reminder for "${_reminders[i].medicineName}" deleted'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    );
                  }),
                ]),
              ),
            ),
        ],
      ),
      floatingActionButton: _reminders.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _showAddSheet(context),
              backgroundColor: AppTheme.purple,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text('Add Reminder', style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddReminderSheet(
        onSaved: (reminder) async {
          await MedicineReminderService.instance.addReminder(reminder);
          await NotificationService.instance.showImmediateNotification(
            title: '💊 Reminder Set',
            body: 'Reminder added for ${reminder.medicineName} at ${reminder.time}',
          );
          _loadReminders();
        },
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final active = _reminders.where((r) => r.isActive).length;
    final paused = _reminders.length - active;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Expanded(child: _miniStat('Total', _reminders.length.toString(), AppTheme.primary)),
          Expanded(child: _miniStat('Active', active.toString(), AppTheme.success)),
          Expanded(child: _miniStat('Paused', paused.toString(), AppTheme.warning)),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final MedicineReminder reminder;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const _ReminderCard({
    required this.reminder,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isActive = reminder.isActive;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? AppTheme.purple.withValues(alpha: 0.3) : cs.outline.withValues(alpha: 0.2),
        ),
        boxShadow: isActive ? [
          BoxShadow(
            color: AppTheme.purple.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ] : [],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: isActive ? AppTheme.purpleLight : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.medication_rounded,
                color: isActive ? AppTheme.purple : cs.onSurface.withValues(alpha: 0.4),
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          reminder.medicineName,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: isActive ? cs.onSurface : cs.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      if (!isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('Paused', style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.5), fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: [
                      _InfoChip(icon: Icons.schedule_rounded, label: reminder.time, active: isActive),
                      _InfoChip(icon: Icons.repeat_rounded, label: reminder.frequency, active: isActive),
                      _InfoChip(icon: Icons.medication_liquid_rounded, label: reminder.dosage, active: isActive),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                Switch(
                  value: isActive,
                  onChanged: onToggle,
                  activeThumbColor: AppTheme.purple,
                ),
                IconButton(
                  onPressed: () => _confirmDelete(context),
                  icon: Icon(Icons.delete_outline_rounded, color: cs.onSurface.withValues(alpha: 0.4), size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Reminder?'),
        content: Text('Remove reminder for "${reminder.medicineName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () { Navigator.pop(ctx); onDelete(); },
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _InfoChip({required this.icon, required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: active ? AppTheme.purple : cs.onSurface.withValues(alpha: 0.4)),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: active ? cs.onSurface.withValues(alpha: 0.7) : cs.onSurface.withValues(alpha: 0.4),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _AddReminderSheet extends StatefulWidget {
  final Future<void> Function(MedicineReminder) onSaved;

  const _AddReminderSheet({required this.onSaved});

  @override
  State<_AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<_AddReminderSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  String _frequency = 'Once daily';
  TimeOfDay _time = TimeOfDay.now();
  bool _saving = false;

  static const _frequencies = ['Once daily', 'Twice daily', 'Three times daily', 'Every 4 hours', 'Every 6 hours', 'Every 8 hours', 'Every 12 hours', 'Weekly', 'As needed'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dosageCtrl.dispose();
    super.dispose();
  }

  String get _timeString {
    final h = _time.hourOfPeriod == 0 ? 12 : _time.hourOfPeriod;
    final m = _time.minute.toString().padLeft(2, '0');
    final period = _time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Container(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: cs.outline.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: AppTheme.purpleLight, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.medication_rounded, color: AppTheme.purple, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text('Add Medicine Reminder', style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Medicine Name',
                  prefixIcon: Icon(Icons.medication_rounded),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter medicine name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dosageCtrl,
                decoration: const InputDecoration(
                  labelText: 'Dosage (e.g., 500mg, 1 tablet)',
                  prefixIcon: Icon(Icons.scale_rounded),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter dosage' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _frequency,
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  prefixIcon: Icon(Icons.repeat_rounded),
                ),
                items: _frequencies.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                onChanged: (v) { if (v != null) setState(() => _frequency = v); },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final picked = await showTimePicker(context: context, initialTime: _time);
                  if (picked != null) setState(() => _time = picked);
                },
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Reminder Time',
                    prefixIcon: Icon(Icons.access_time_rounded),
                    suffixIcon: Icon(Icons.chevron_right_rounded),
                  ),
                  child: Text(_timeString, style: const TextStyle(fontSize: 15)),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                  child: _saving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Save Reminder', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final reminder = MedicineReminder(
      medicineName: _nameCtrl.text.trim(),
      dosage: _dosageCtrl.text.trim(),
      frequency: _frequency,
      time: _timeString,
      startDate: DateTime.now(),
    );
    await widget.onSaved(reminder);
    if (mounted) Navigator.pop(context);
  }
}
