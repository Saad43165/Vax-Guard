import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../services/medicine_reminder_service.dart';
import '../services/notification_service.dart';
import '../widgets/glass_container.dart';
import '../widgets/custom_button.dart';
import '../utils/l10n_helper.dart';

class MedicineReminderScreen extends StatefulWidget {
  const MedicineReminderScreen({super.key});

  @override
  State<MedicineReminderScreen> createState() => _MedicineReminderScreenState();
}

class _MedicineReminderScreenState extends State<MedicineReminderScreen> {
  List<MedicineReminder> _reminders = [];
  bool _isLoading = true;
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _loadReminders();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadReminders() async {
    setState(() => _isLoading = true);
    final list = await MedicineReminderService.instance.getAllReminders();
    if (mounted) setState(() { _reminders = list; _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: AppTheme.background(context),
      body: Stack(
        children: [
          Positioned(
            top: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.purple.withOpacity(isDark ? 0.15 : 0.08),
                boxShadow: [
                  BoxShadow(color: AppTheme.purple.withOpacity(isDark ? 0.2 : 0.1), blurRadius: 100, spreadRadius: 50)
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildOverviewStats(),
                const SizedBox(height: 20),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.purple)))
                      : _reminders.isEmpty
                          ? _buildEmptyState()
                          : _buildSwipeableCards(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppTheme.purple.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: ElevatedButton(
          onPressed: () => _showAddSheet(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.purple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(L10n.s(context, 'add_reminder'), style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17)),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          CustomIconButton(
            icon: Icons.arrow_back_rounded, 
            onPressed: () => Navigator.of(context).maybePop(),
            background: AppTheme.surface(context),
            color: AppTheme.textPrimary(context),
          ),
          const SizedBox(width: 16),
          Text(
            L10n.s(context, 'medicine_reminders'),
            style: GoogleFonts.outfit(
              color: AppTheme.textPrimary(context),
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStats() {
    final active = _reminders.where((r) => r.isActive).length;
    final paused = _reminders.length - active;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.purple.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppTheme.purple.withOpacity(0.25), width: 1.5),
          boxShadow: isDark ? [] : [
            BoxShadow(color: AppTheme.purple.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _miniStat(L10n.s(context, 'total'), _reminders.length.toString(), AppTheme.textPrimary(context)),
            Container(height: 40, width: 1, color: AppTheme.border(context).withOpacity(0.3)),
            _miniStat(L10n.s(context, 'active'), active.toString(), AppTheme.success),
            Container(height: 40, width: 1, color: AppTheme.border(context).withOpacity(0.3)),
            _miniStat(L10n.s(context, 'paused'), paused.toString(), AppTheme.warning),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w900, color: color)),
        Text(label, style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondary(context), fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.purple.withOpacity(0.2), AppTheme.purple.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.medication_rounded, size: 64, color: AppTheme.purple),
          ),
          const SizedBox(height: 32),
          Text(L10n.s(context, 'no_reminders_yet'), style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.textPrimary(context))),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              L10n.s(context, 'no_reminders_desc'),
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: AppTheme.textSecondary(context), fontSize: 16, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeableCards() {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: _reminders.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = _pageController.page! - index;
                    value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                  }
                  return Center(
                    child: SizedBox(
                      height: Curves.easeOut.transform(value) * 440,
                      width: Curves.easeOut.transform(value) * 350,
                      child: child,
                    ),
                  );
                },
                child: _ReminderCard(
                  reminder: _reminders[index],
                  onToggle: (active) async {
                    await MedicineReminderService.instance.toggleReminder(_reminders[index].id!, active);
                    _loadReminders();
                  },
                  onDelete: () async {
                    await MedicineReminderService.instance.deleteReminder(_reminders[index].id!);
                    _loadReminders();
                    if (!context.mounted) return;
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${L10n.s(context, 'reminder_deleted')} "${_reminders[index].medicineName}"'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _reminders.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index ? AppTheme.purple : AppTheme.border(context).withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 80),
      ],
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
            title: L10n.s(context, 'reminder_set_title'),
            body: '${L10n.s(context, 'reminder_added_for')} ${reminder.medicineName} ${L10n.s(context, 'at')} ${reminder.time}',
          );
          _loadReminders();
        },
      ),
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
    final isActive = reminder.isActive;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: isDark 
              ? (isActive ? AppTheme.primary.withOpacity(0.12) : AppTheme.surface(context))
              : Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: isActive ? AppTheme.primary.withOpacity(0.3) : AppTheme.border(context).withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive ? AppTheme.success.withOpacity(0.12) : AppTheme.warning.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          color: isActive ? AppTheme.success : AppTheme.warning,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isActive ? L10n.s(context, 'active').toUpperCase() : L10n.s(context, 'paused').toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: isActive ? AppTheme.success : AppTheme.warning,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_horiz_rounded, color: AppTheme.textSecondary(context), size: 24),
                  color: AppTheme.surface(context),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onSelected: (value) {
                    if (value == 'delete') {
                      _confirmDelete(context);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, color: AppTheme.danger, size: 20),
                          const SizedBox(width: 12),
                          Text(L10n.s(context, 'remove'), style: GoogleFonts.outfit(color: AppTheme.danger, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                color: isActive ? AppTheme.primary.withOpacity(0.1) : AppTheme.surfaceVariant(context).withOpacity(0.5),
                shape: BoxShape.circle,
                border: Border.all(color: isActive ? AppTheme.primary : AppTheme.border(context), width: 2),
                boxShadow: isActive ? [BoxShadow(color: AppTheme.primary.withOpacity(0.2), blurRadius: 30, spreadRadius: 5)] : [],
              ),
              child: Icon(
                Icons.medication_rounded,
                color: isActive ? AppTheme.primary : AppTheme.textTertiary(context),
                size: 44,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              reminder.medicineName,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w900,
                fontSize: 34,
                color: isActive ? AppTheme.textPrimary(context) : AppTheme.textSecondary(context),
                letterSpacing: -1,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: AppTheme.background(context).withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.border(context).withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _InfoColumn(icon: Icons.access_time_rounded, label: reminder.time, active: isActive),
                  _InfoColumn(icon: Icons.repeat_rounded, label: reminder.frequency, active: isActive),
                  _InfoColumn(icon: Icons.water_drop_rounded, label: reminder.dosage, active: isActive),
                ],
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isActive ? L10n.s(context, 'active_reminder') : L10n.s(context, 'tap_to_resume'),
                  style: GoogleFonts.outfit(
                    color: isActive ? AppTheme.textPrimary(context) : AppTheme.textSecondary(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 16),
                Switch.adaptive(
                  value: isActive,
                  onChanged: onToggle,
                  activeColor: AppTheme.primary,
                  activeTrackColor: AppTheme.primary.withOpacity(0.3),
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
        title: Text(L10n.s(context, 'delete_reminder?'), style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
        content: Text('${L10n.s(context, "delete")} "${reminder.medicineName}"?', style: GoogleFonts.outfit()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(L10n.s(context, 'cancel'), style: GoogleFonts.outfit(color: AppTheme.textSecondary(context)))),
          ElevatedButton(
            onPressed: () { Navigator.pop(ctx); onDelete(); },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger, foregroundColor: Colors.white, elevation: 0),
            child: Text(L10n.s(context, 'delete'), style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _InfoColumn({required this.icon, required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24, color: active ? AppTheme.purpleLight : Colors.white30),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 13,
            color: active ? Colors.white70 : Colors.white30,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
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
  String _frequency = 'freq_once_daily';
  TimeOfDay _time = TimeOfDay.now();
  bool _saving = false;

  static const _frequencies = [
    'freq_once_daily',
    'freq_twice_daily',
    'freq_three_times_daily',
    'freq_every_4_hours',
    'freq_every_6_hours',
    'freq_every_8_hours',
    'freq_every_12_hours',
    'freq_weekly',
    'freq_as_needed'
  ];

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
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Container(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
                  width: 48, height: 6,
                  decoration: BoxDecoration(color: AppTheme.border(context).withOpacity(0.5), borderRadius: BorderRadius.circular(3)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: AppTheme.purple.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.medication_rounded, color: AppTheme.purple, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Text(L10n.s(context, 'add_reminder'), style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.textPrimary(context))),
                ],
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameCtrl,
                style: GoogleFonts.outfit(color: AppTheme.textPrimary(context), fontSize: 16),
                decoration: InputDecoration(
                  labelText: L10n.s(context, 'medicine_name'),
                  prefixIcon: Icon(Icons.medication_rounded, color: AppTheme.textSecondary(context)),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().isEmpty) ? L10n.s(context, 'enter_medicine_name') : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dosageCtrl,
                style: GoogleFonts.outfit(color: AppTheme.textPrimary(context), fontSize: 16),
                decoration: InputDecoration(
                  labelText: L10n.s(context, 'dosage_hint'),
                  prefixIcon: Icon(Icons.scale_rounded, color: AppTheme.textSecondary(context)),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? L10n.s(context, 'enter_dosage') : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _frequency,
                dropdownColor: AppTheme.surface(context),
                style: GoogleFonts.outfit(color: AppTheme.textPrimary(context), fontSize: 16),
                decoration: InputDecoration(
                  labelText: L10n.s(context, 'frequency'),
                  prefixIcon: Icon(Icons.repeat_rounded, color: AppTheme.textSecondary(context)),
                ),
                items: _frequencies.map((f) => DropdownMenuItem(value: f, child: Text(L10n.s(context, f)))).toList(),
                onChanged: (v) { if (v != null) setState(() => _frequency = v); },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  final picked = await showTimePicker(
                    context: context, 
                    initialTime: _time,
                    builder: (context, child) {
                      return Theme(
                        data: isDark ? ThemeData.dark().copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: AppTheme.purple,
                            onPrimary: Colors.white,
                            surface: Color(0xFF1E293B),
                            onSurface: Colors.white,
                          ),
                        ) : ThemeData.light().copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: AppTheme.purple,
                            onPrimary: Colors.white,
                            surface: Colors.white,
                            onSurface: Colors.black,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) setState(() => _time = picked);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant(context).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.border(context).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time_rounded, color: AppTheme.textSecondary(context)),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(L10n.s(context, 'reminder_time'), style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary(context), fontWeight: FontWeight.w600)),
                          Text(_timeString, style: GoogleFonts.outfit(fontSize: 18, color: AppTheme.textPrimary(context), fontWeight: FontWeight.w800)),
                        ],
                      ),
                      const Spacer(),
                      Icon(Icons.chevron_right_rounded, color: AppTheme.textTertiary(context)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  child: _saving
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                      : Text(L10n.s(context, 'save_reminder'), style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18)),
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
      frequency: L10n.s(context, _frequency),
      time: _timeString,
      startDate: DateTime.now(),
    );
    await widget.onSaved(reminder);
    if (mounted) Navigator.pop(context);
  }
}
