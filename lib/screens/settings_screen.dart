import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/database_service.dart';
import '../../utils/app_constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            'App Settings',
            [
              _buildSettingsTile(
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                subtitle: _isDarkMode ? 'Enabled' : 'Disabled',
                trailing: Switch(
                  value: _isDarkMode,
                  onChanged: (v) {
                    setState(() => _isDarkMode = v);
                    _showSnackBar(context, 'Dark mode coming soon!');
                  },
                  activeColor: AppTheme.primary,
                ),
              ),
              _buildSettingsTile(
                icon: Icons.language_outlined,
                title: 'Language',
                subtitle: _selectedLanguage,
                onTap: () => _showLanguageSheet(context),
              ),
              _buildSettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Configure notifications',
                onTap: () => _showSnackBar(context, 'Notification settings coming soon!'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSection(
            'Data Management',
            [
              _buildSettingsTile(
                icon: Icons.storage_outlined,
                title: 'Storage',
                subtitle: 'Manage app data',
                onTap: () => _showStorageSheet(context),
              ),
              _buildSettingsTile(
                icon: Icons.picture_as_pdf_outlined,
                title: 'Export Records',
                subtitle: 'Download as PDF',
                onTap: () => Navigator.pushNamed(context, AppConstants.pdfViewRoute),
              ),
              _buildSettingsTile(
                icon: Icons.backup_outlined,
                title: 'Backup & Sync',
                subtitle: 'Cloud backup settings',
                onTap: () => _showSnackBar(context, 'Cloud backup coming soon!'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSection(
            'Support',
            [
              _buildSettingsTile(
                icon: Icons.help_outline_rounded,
                title: 'Help Center',
                subtitle: 'FAQs and support',
                onTap: () => _showSnackBar(context, 'Help center coming soon!'),
              ),
              _buildSettingsTile(
                icon: Icons.feedback_outlined,
                title: 'Send Feedback',
                subtitle: 'Help us improve',
                onTap: () => _showFeedbackSheet(context),
              ),
              _buildSettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'About',
                subtitle: 'Version 1.0.0',
                onTap: () => _showAboutDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'VaxGuard v1.0.0',
              style: const TextStyle(color: AppTheme.textTertiary, fontSize: 13),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.shadowSm,
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primarySurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (trailing == null && onTap != null)
              const Icon(Icons.chevron_right_rounded, color: AppTheme.textTertiary),
          ],
        ),
      ),
    );
  }

  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Language',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('English (US)'),
              trailing: const Icon(Icons.check_rounded, color: AppTheme.primary),
              onTap: () {
                setState(() => _selectedLanguage = 'English (US)');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Spanish'),
              onTap: () {
                setState(() => _selectedLanguage = 'Spanish');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('French'),
              onTap: () {
                setState(() => _selectedLanguage = 'French');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showStorageSheet(BuildContext context) {
    final db = DatabaseService.instance;
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Storage',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.vaccines_rounded),
              title: const Text('Vaccine Records'),
              trailing: Text('${db.totalVaccines}'),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _confirmClearData(context);
              },
              icon: const Icon(Icons.delete_outline, color: AppTheme.danger),
              label: const Text('Clear All Data', style: TextStyle(color: AppTheme.danger)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.danger),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text('This will permanently delete all your data. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await DatabaseService.instance.deleteAllRecords();
              Navigator.pop(context);
              _showSnackBar(context, 'All data cleared!');
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Send Feedback',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            const TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tell us what you think...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showSnackBar(context, 'Thank you for your feedback!');
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [Text('🛡️ '), Text('VaxGuard')],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('Your Health Companion'),
            Text('Track vaccines, assess risks, and find healthcare near you.'),
            SizedBox(height: 16),
            Text('© 2024 VaxGuard'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}