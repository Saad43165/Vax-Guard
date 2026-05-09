import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../utils/app_constants.dart';

class ActionGridCard extends StatelessWidget {
  final VoidCallback onRefresh;

  const ActionGridCard({
    super.key,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      ('Animal Bite', Icons.pets_rounded, AppConstants.animalBiteRoute, AppTheme.danger),
      ('Find Hospital', Icons.local_hospital_rounded, AppConstants.hospitalMapRoute, AppTheme.primary),
      ('Vaccines', Icons.vaccines_rounded, AppConstants.vaccineScheduleRoute, AppTheme.success),
      ('Medicines', Icons.medication_rounded, AppConstants.medicineReminderRoute, AppTheme.purple),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.9,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return _buildActionCard(
          context,
          icon: action.$2,
          label: action.$1,
          color: action.$4,
          onTap: () => Navigator.pushNamed(context, action.$3).then((_) => onRefresh()),
        );
      },
    );
  }

  Widget _buildActionCard(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color color,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}