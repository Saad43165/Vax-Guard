import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/theme_notifier.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../utils/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = false;
  String _userName = '';
  final _nameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isDarkMode = ThemeNotifier.instance.isDark;
    _loadPrefs();
    ThemeNotifier.instance.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    ThemeNotifier.instance.removeListener(_onThemeChanged);
    _nameCtrl.dispose();
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() => _isDarkMode = ThemeNotifier.instance.isDark);
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
        _userName = prefs.getString('user_name') ?? '';
        _nameCtrl.text = _userName;
      });
    }
  }

  Future<void> _saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name.trim());
    if (mounted) setState(() => _userName = name.trim());
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
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
              background: Container(
                decoration: const BoxDecoration(gradient: AppTheme.deepBlueGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 52),
                    child: Row(
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.settings_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Text('Customize your experience', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Profile ────────────────────────────────────────────
                  _SectionHeader(label: 'Profile'),
                  _SettingsCard(children: [
                    _ProfileTile(
                      userName: _userName,
                      nameCtrl: _nameCtrl,
                      onSave: _saveUserName,
                    ),
                  ]),
                  const SizedBox(height: 20),

                  // ── Appearance ─────────────────────────────────────────
                  _SectionHeader(label: 'Appearance'),
                  _SettingsCard(children: [
                    _SwitchTile(
                      icon: Icons.dark_mode_rounded,
                      iconColor: AppTheme.purple,
                      title: 'Dark Mode',
                      subtitle: _isDarkMode ? 'Dark theme active' : 'Light theme active',
                      value: _isDarkMode,
                      onChanged: (v) {
                        ThemeNotifier.instance.setDark(v);
                      },
                    ),
                  ]),
                  const SizedBox(height: 20),

                  // ── Notifications ──────────────────────────────────────
                  _SectionHeader(label: 'Notifications'),
                  _SettingsCard(children: [
                    _SwitchTile(
                      icon: Icons.notifications_rounded,
                      iconColor: AppTheme.warning,
                      title: 'Push Notifications',
                      subtitle: _notificationsEnabled ? 'Notifications enabled' : 'Tap to enable notifications',
                      value: _notificationsEnabled,
                      onChanged: (v) async {
                        if (v) {
                          final granted = await NotificationService.instance.requestPermissions();
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('notifications_enabled', granted);
                          if (mounted) setState(() => _notificationsEnabled = granted);
                          if (!granted && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Notification permission denied')),
                            );
                          }
                        } else {
                          await NotificationService.instance.cancelAllNotifications();
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('notifications_enabled', false);
                          if (mounted) setState(() => _notificationsEnabled = false);
                        }
                      },
                    ),
                    const Divider(height: 1, indent: 72),
                    _NavTile(
                      icon: Icons.medication_rounded,
                      iconColor: AppTheme.purple,
                      title: 'Medicine Reminders',
                      subtitle: 'Manage your medication schedule',
                      onTap: () => Navigator.pushNamed(context, AppConstants.medicineReminderRoute),
                    ),
                  ]),
                  const SizedBox(height: 20),

                  // ── Data ───────────────────────────────────────────────
                  _SectionHeader(label: 'Data Management'),
                  _SettingsCard(children: [
                    _NavTile(
                      icon: Icons.vaccines_rounded,
                      iconColor: AppTheme.primary,
                      title: 'Vaccine Records',
                      subtitle: '${DatabaseService.instance.totalVaccines} records stored',
                      onTap: () => Navigator.pushNamed(context, AppConstants.vaccineScheduleRoute),
                    ),
                    const Divider(height: 1, indent: 72),
                    _NavTile(
                      icon: Icons.picture_as_pdf_rounded,
                      iconColor: AppTheme.success,
                      title: 'Export Records',
                      subtitle: 'Download your vaccine history as PDF',
                      onTap: () => Navigator.pushNamed(context, AppConstants.pdfViewRoute),
                    ),
                    const Divider(height: 1, indent: 72),
                    _NavTile(
                      icon: Icons.delete_outline_rounded,
                      iconColor: AppTheme.danger,
                      title: 'Clear All Data',
                      subtitle: 'Permanently delete all records',
                      onTap: () => _confirmClearData(context),
                    ),
                  ]),
                  const SizedBox(height: 20),

                  // ── Support ────────────────────────────────────────────
                  _SectionHeader(label: 'Support'),
                  _SettingsCard(children: [
                    _NavTile(
                      icon: Icons.feedback_rounded,
                      iconColor: AppTheme.secondary,
                      title: 'Send Feedback',
                      subtitle: 'Help us improve the app',
                      onTap: () => _showFeedbackSheet(context),
                    ),
                    const Divider(height: 1, indent: 72),
                    _NavTile(
                      icon: Icons.info_outline_rounded,
                      iconColor: AppTheme.textSecondary,
                      title: 'About VaxGuard',
                      subtitle: 'Version 1.0.0',
                      onTap: () => _showAboutDialog(context),
                    ),
                  ]),
                  const SizedBox(height: 32),

                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 52, height: 52,
                          decoration: const BoxDecoration(
                            gradient: AppTheme.deepBlueGradient,
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/Applogo.png',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(child: Text('🛡️', style: TextStyle(fontSize: 26))),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('VaxGuard', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: cs.onSurface)),
                        Text('v1.0.0 • Your Health Companion', style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearData(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text('This will permanently delete all your vaccine records. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await DatabaseService.instance.deleteAllRecords();
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data cleared successfully')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackSheet(BuildContext context) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          decoration: BoxDecoration(
            color: Theme.of(ctx).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: Theme.of(ctx).colorScheme.outline.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Send Feedback', style: Theme.of(ctx).textTheme.headlineSmall),
                const SizedBox(height: 6),
                Text('Your feedback helps us improve', style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 13)),
                const SizedBox(height: 20),
                TextField(
                  controller: ctrl,
                  maxLines: 4,
                  decoration: const InputDecoration(hintText: 'Tell us what you think or report an issue...'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      if (ctrl.text.trim().isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Thank you for your feedback! 🙏')),
                        );
                      }
                    },
                    child: const Text('Submit Feedback'),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: const BoxDecoration(gradient: AppTheme.deepBlueGradient, shape: BoxShape.circle),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/Applogo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(child: Text('🛡️', style: TextStyle(fontSize: 40))),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('VaxGuard', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('Version 1.0.0', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 16),
            const Text(
              'Your complete health companion for vaccine tracking, health assessments, and emergency preparedness.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 16),
            const Text('© 2024 VaxGuard. All rights reserved.', style: TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(color: cs.shadow.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.55))),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: iconColor),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface)),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.55))),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: cs.onSurface.withValues(alpha: 0.3), size: 20),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final String userName;
  final TextEditingController nameCtrl;
  final Future<void> Function(String) onSave;

  const _ProfileTile({required this.userName, required this.nameCtrl, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: const BoxDecoration(gradient: AppTheme.deepBlueGradient, shape: BoxShape.circle),
            child: Center(
              child: Text(
                userName.isEmpty ? '?' : userName.substring(0, 1).toUpperCase(),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName.isEmpty ? 'Set your name' : userName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: userName.isEmpty ? cs.onSurface.withValues(alpha: 0.5) : cs.onSurface,
                  ),
                ),
                Text('VaxGuard Member', style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5))),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _showEditName(context),
            child: Text(userName.isEmpty ? 'Add' : 'Edit', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showEditName(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Your Name'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Name',
            prefixIcon: Icon(Icons.person_rounded),
          ),
          textCapitalization: TextCapitalization.words,
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await onSave(nameCtrl.text);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
