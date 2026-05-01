import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme.dart';
import '../utils/app_constants.dart';
import '../widgets/layout/app_page_widgets.dart';

class EmergencyModeScreen extends StatelessWidget {
  const EmergencyModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Offline Emergency Mode'),
        centerTitle: false,
        backgroundColor: AppTheme.danger,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const AppPageHeader(
            title: 'Emergency Toolkit',
            subtitle:
                'Use this screen when internet is unstable and fast action is needed.',
            gradient: [Color(0xFFFF5B5B), Color(0xFFE63946)],
          ),
          const SizedBox(height: 10),
          const AppSectionCard(
            child: Text(
              'For life-threatening signs, call emergency services first.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),
          _tile(
            context,
            Icons.call_rounded,
            'Call Emergency',
            'Dial local emergency number immediately.',
            () async {
              final uri = Uri.parse('tel:911');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Unable to place call. Please dial 911 manually.')),
                );
              }
            },
          ),
          _tile(
            context,
            Icons.local_hospital_rounded,
            'Find Hospital',
            'Open nearest hospitals map.',
            () => Navigator.pushNamed(context, AppConstants.hospitalMapRoute),
          ),
          _tile(
            context,
            Icons.healing_rounded,
            'First Aid Steps',
            'Open first aid instructions.',
            () => Navigator.pushNamed(context, AppConstants.firstAidRoute),
          ),
          _tile(
            context,
            Icons.pets_rounded,
            'Animal Bite Guide',
            'Run rabies and wound urgency check.',
            () => Navigator.pushNamed(context, AppConstants.animalBiteRoute),
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppTheme.danger),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
