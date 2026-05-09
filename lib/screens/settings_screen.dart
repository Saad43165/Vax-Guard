import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme.dart';
import '../core/theme_notifier.dart';
import '../core/locale_notifier.dart';
import '../utils/l10n_helper.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../services/user_profile_service.dart';
import '../models/user_profile.dart';
import '../core/user_profile_notifier.dart';
import '../utils/app_constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    UserProfileNotifier.instance.addListener(_onProfileChanged);
  }

  @override
  void dispose() {
    UserProfileNotifier.instance.removeListener(_onProfileChanged);
    super.dispose();
  }

  void _onProfileChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
      });
    }
  }

  Future<void> _updateProfile(UserProfile newProfile) async {
    await UserProfileNotifier.instance.updateProfile(newProfile);
  }
  
  UserProfile get _profile => UserProfileNotifier.instance.profile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background(context),
      appBar: AppBar(
        title: Text(L10n.s(context, 'settings'), style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Clinical Identity'),
            _buildMedicalProfileCard(),
            const SizedBox(height: 32),
            _buildSectionHeader('Preferences'),
            _buildSettingsGroup([
              _buildSwitchTile(
                Icons.dark_mode_rounded,
                AppTheme.purple,
                L10n.s(context, 'dark_mode'),
                ThemeNotifier.instance.isDark ? L10n.s(context, 'dark_theme_active') : L10n.s(context, 'light_theme_active'),
                ThemeNotifier.instance.isDark,
                (v) => ThemeNotifier.instance.setDark(v),
              ),
              const Divider(height: 1, indent: 72),
              _buildNavTile(
                Icons.language_rounded, 
                AppTheme.secondary, 
                L10n.s(context, 'language'), 
                'Select your preferred language', 
                () => _showLanguageSheet(context)
              ),
            ]),
            const SizedBox(height: 32),
            _buildSectionHeader(L10n.s(context, 'notifications')),
            _buildSettingsGroup([
              _buildSwitchTile(
                Icons.notifications_active_rounded,
                AppTheme.warning,
                L10n.s(context, 'push_notifications'),
                _notificationsEnabled ? L10n.s(context, 'notifications_enabled') : L10n.s(context, 'tap_to_enable'),
                _notificationsEnabled,
                (v) async {
                  final granted = v ? await NotificationService.instance.requestPermissions() : false;
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('notifications_enabled', granted);
                  if (mounted) setState(() => _notificationsEnabled = granted);
                },
              ),
            ]),
            const SizedBox(height: 32),
            _buildSectionHeader('Safety & Data'),
            _buildSettingsGroup([
              _buildNavTile(Icons.delete_forever_rounded, AppTheme.danger, L10n.s(context, 'clear_data'), 'Remove all clinical history and logs', () => _confirmClearData(context)),
            ]),
            const SizedBox(height: 32),
            _buildSectionHeader('Support'),
            _buildSettingsGroup([
              _buildNavTile(Icons.feedback_rounded, AppTheme.primary, L10n.s(context, 'feedback'), L10n.s(context, 'feedback_desc'), () => _showFeedbackSheet(context)),
              const Divider(height: 1, indent: 72),
              _buildNavTile(Icons.info_outline_rounded, AppTheme.secondary, L10n.s(context, 'about'), L10n.s(context, 'developed_by'), () => _showAboutDialog(context)),
            ]),
            const SizedBox(height: 60),
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Image.asset('assets/images/appbar_icon.png', height: 40, fit: BoxFit.contain),
                  const SizedBox(height: 16),
                  Text('VaxGuard', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.textPrimary(context))),
                  Text('Version 1.0.0 • Clinical Production', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textTertiary(context))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildMedicalProfileCard() {
    final conditions = [
      if (_profile.hasDiabetes) 'Diabetes',
      if (_profile.hasHypertension) 'Hypertension',
      if (_profile.hasHeartDisease) 'Heart Disease',
      if (_profile.hasAsthma) 'Asthma',
      if (_profile.hasKidneyDisease) 'Kidney Disease',
      if (_profile.isImmunocompromised) 'Immunocompromised',
      if (_profile.isPregnant) 'Pregnant',
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.border(context).withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 30, offset: const Offset(0, 15)),
          BoxShadow(color: AppTheme.primary.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _profile.name.isNotEmpty ? _profile.name : 'Clinical Explorer',
                        style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textPrimary(context)),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.badge_rounded, size: 12, color: AppTheme.textSecondary(context)),
                          const SizedBox(width: 6),
                          Text(
                            '${_profile.age ?? "--"} Yrs • ${_profile.sex ?? "N/A"}',
                            style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondary(context), fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (_profile.isHighRisk)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: AppTheme.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: Text('HIGH RISK', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.danger, letterSpacing: 0.5)),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant(context).withOpacity(0.2),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.medical_services_rounded, color: AppTheme.primary, size: 16),
                    const SizedBox(width: 10),
                    Text('CLINICAL CONDITIONS', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textTertiary(context), letterSpacing: 1.2)),
                    const Spacer(),
                    InkWell(
                      onTap: () => _showEditMedical(),
                      child: Text('UPDATE', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.primary, letterSpacing: 1)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (conditions.isEmpty)
                  Text('No clinical conditions declared.', style: GoogleFonts.outfit(color: AppTheme.textSecondary(context), fontSize: 13, fontWeight: FontWeight.w600))
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: conditions.map((c) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.background(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border(context)),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
                      ),
                      child: Text(c, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary(context))),
                    )).toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(padding: const EdgeInsets.only(left: 4, bottom: 12), child: Text(title.toUpperCase(), style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.textTertiary(context), letterSpacing: 1)));
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border(context).withOpacity(0.5)),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile(IconData icon, Color color, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary(context))), Text(subtitle, style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary(context)))])),
          Switch.adaptive(value: value, onChanged: onChanged, activeColor: color),
        ],
      ),
    );
  }

  Widget _buildNavTile(IconData icon, Color color, String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 20)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary(context))), Text(subtitle, style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary(context)))])),
            Icon(Icons.chevron_right_rounded, color: AppTheme.textTertiary(context)),
          ],
        ),
      ),
    );
  }

  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppTheme.surface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(L10n.s(context, 'select_language'), style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 24),
            ...LocaleNotifier.supportedLanguages.map((lang) {
              final isSelected = LocaleNotifier.instance.locale.languageCode == lang['code'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    LocaleNotifier.instance.setLocale(lang['code']!);
                    Navigator.pop(ctx);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary.withOpacity(0.1) : AppTheme.background(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? AppTheme.primary : AppTheme.border(context)),
                    ),
                    child: Row(
                      children: [
                        Text(lang['flag']!, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 16),
                        Text(lang['native']!, style: GoogleFonts.outfit(fontSize: 16, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600, color: isSelected ? AppTheme.primary : AppTheme.textPrimary(context))),
                        const Spacer(),
                        if (isSelected) const Icon(Icons.check_circle_rounded, color: AppTheme.primary),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }


  void _showEditMedical() {
    final nameCtrl = TextEditingController(text: _profile.name);
    final ageCtrl = TextEditingController(text: _profile.age?.toString() ?? '');
    String? localSex = _profile.sex;
    bool pDiabetes = _profile.hasDiabetes;
    bool pHyper = _profile.hasHypertension;
    bool pHeart = _profile.hasHeartDisease;
    bool pAsthma = _profile.hasAsthma;
    bool pKidney = _profile.hasKidneyDisease;
    bool pImmun = _profile.isImmunocompromised;
    bool pPreg = _profile.isPregnant;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          decoration: BoxDecoration(color: AppTheme.surface(context), borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Clinical Identity', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900)),
                const SizedBox(height: 24),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_rounded))),
                const SizedBox(height: 16),
                TextField(controller: ageCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Age', prefixIcon: Icon(Icons.calendar_today_rounded))),
                const SizedBox(height: 24),
                Text('Select Sex', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 12),
                Row(
                  children: ['Male', 'Female', 'Other'].map((s) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(s),
                        selected: localSex == s,
                        onSelected: (v) => setModalState(() => localSex = v ? s : null),
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                Text('Medical Conditions', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                _buildModalSwitch('Diabetes', pDiabetes, (v) => setModalState(() => pDiabetes = v)),
                _buildModalSwitch('Hypertension', pHyper, (v) => setModalState(() => pHyper = v)),
                _buildModalSwitch('Heart Disease', pHeart, (v) => setModalState(() => pHeart = v)),
                _buildModalSwitch('Asthma', pAsthma, (v) => setModalState(() => pAsthma = v)),
                _buildModalSwitch('Kidney Disease', pKidney, (v) => setModalState(() => pKidney = v)),
                _buildModalSwitch('Immunocompromised', pImmun, (v) => setModalState(() => pImmun = v)),
                _buildModalSwitch('Pregnancy Status', pPreg, (v) => setModalState(() => pPreg = v)),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      _updateProfile(_profile.copyWith(
                        name: nameCtrl.text,
                        age: int.tryParse(ageCtrl.text),
                        sex: localSex,
                        hasDiabetes: pDiabetes,
                        hasHypertension: pHyper,
                        hasHeartDisease: pHeart,
                        hasAsthma: pAsthma,
                        hasKidneyDisease: pKidney,
                        isImmunocompromised: pImmun,
                        isPregnant: pPreg,
                      ));
                      Navigator.pop(ctx);
                    },
                    child: const Text('Update Complete Profile'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModalSwitch(String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile.adaptive(
      title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primary,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _confirmClearData(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(L10n.s(context, 'clear_all_data?')),
        content: Text(L10n.s(context, 'clear_data_warning')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(L10n.s(context, 'cancel'))),
          TextButton(onPressed: () async { await DatabaseService.instance.deleteAllRecords(); Navigator.pop(ctx); }, style: TextButton.styleFrom(foregroundColor: AppTheme.danger), child: Text(L10n.s(context, 'delete'))),
        ],
      ),
    );
  }

  void _showFeedbackSheet(BuildContext context) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        decoration: BoxDecoration(color: AppTheme.surface(context), borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(L10n.s(context, 'feedback'), style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text(L10n.s(context, 'feedback_desc'), style: GoogleFonts.outfit(color: AppTheme.textSecondary(context))),
              const SizedBox(height: 24),
              TextField(controller: ctrl, maxLines: 4, decoration: InputDecoration(hintText: L10n.s(context, 'your_thoughts'), filled: true, fillColor: AppTheme.background(context), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
              const SizedBox(height: 24),
              SizedBox(width: double.infinity, height: 56, child: ElevatedButton(onPressed: () async {
                if (ctrl.text.isEmpty) return;
                try {
                  final response = await http.post(
                    Uri.parse('https://formspree.io/f/mgodnklp'),
                    headers: {
                      'Content-Type': 'application/json',
                      'Accept': 'application/json',
                    },
                    body: json.encode({
                      'name': _profile.name,
                      'message': ctrl.text,
                      '_subject': 'VaxGuard App Feedback',
                    }),
                  );
                  if (response.statusCode == 200) {
                    if (mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(L10n.s(context, 'feedback_success')), backgroundColor: AppTheme.success));
                    }
                  } else {
                    throw Exception('Server error');
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Submission failed. Please try again.'), backgroundColor: AppTheme.danger));
                  }
                }
              }, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: Text(L10n.s(context, 'submit_feedback')))),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🛡️', style: TextStyle(fontSize: 50)),
            const SizedBox(height: 16),
            Text('VaxGuard', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w900)),
            Text('Version 1.0.0', style: GoogleFonts.outfit(color: AppTheme.textSecondary(context))),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            _buildAboutInfo(Icons.person_rounded, L10n.s(context, 'developed_by_label'), 'Saad Ikram'),
            _buildAboutInfo(Icons.code_rounded, 'GitHub', '@saad43165', url: 'https://github.com/saad43165'),
            _buildAboutInfo(Icons.email_rounded, 'Email', 'saadnaz43165@gmail.com', url: 'mailto:saadnaz43165@gmail.com'),
            const SizedBox(height: 24),
            Text('© 2024 VaxGuard. All rights reserved.', style: GoogleFonts.outfit(fontSize: 10, color: AppTheme.textTertiary(context))),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutInfo(IconData icon, String label, String value, {String? url}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: url != null ? () async => await launchUrl(Uri.parse(url)) : null,
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.primary),
            const SizedBox(width: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: GoogleFonts.outfit(fontSize: 10, color: AppTheme.textTertiary(context), fontWeight: FontWeight.w700)), Text(value, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: url != null ? AppTheme.primary : AppTheme.textPrimary(context)))]),
          ],
        ),
      ),
    );
  }
}
