import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/vaccine_record.dart';
import 'package:intl/intl.dart';

class VaccineCard extends StatelessWidget {
  final VaccineRecord record;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onMarkComplete;

  const VaccineCard({
    Key? key,
    required this.record,
    this.onTap,
    this.onDelete,
    this.onMarkComplete,
  }) : super(key: key);

@override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppTheme.darkSurface : AppTheme.surface;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.border;
    final tertiaryColor = isDark ? AppTheme.darkTextTertiary : AppTheme.textTertiary;
    final secondaryColor = isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary;
    final primaryTextColor = isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary;
    final surfaceVariantColor = isDark ? AppTheme.darkSurfaceVariant : AppTheme.surfaceVariant;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: borderColor),
          boxShadow: AppTheme.shadowMd,
        ),
child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildBody(context, tertiaryColor: tertiaryColor, primaryTextColor: primaryTextColor, secondaryColor: secondaryColor),
            if (onMarkComplete != null || onDelete != null) _buildActions(context),
          ],
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final gradient =
    record.isCompleted ? AppTheme.successGradient : AppTheme.primaryGradient;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusLg),
        ),
      ),
      child: Row(
        children: [
          // Icon badge
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: const Center(
              child: Text('💉', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),

          // Vaccine name + dose
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.vaccineName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (record.doseNumber != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    record.doseNumber!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.80),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Status pill
          _buildStatusBadge(),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final isCompleted = record.isCompleted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.30), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompleted ? Icons.check_circle_rounded : Icons.schedule_rounded,
            color: Colors.white,
            size: 11,
          ),
          const SizedBox(width: 4),
          Text(
            isCompleted ? 'Done' : 'Pending',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Body ─────────────────────────────────────────────────────────────────
  Widget _buildBody(BuildContext context, {required Color tertiaryColor, required Color primaryTextColor, required Color secondaryColor}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.border;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _infoRow(
            icon: Icons.calendar_today_rounded,
            label: 'Vaccination Date',
            value: DateFormat('MMMM d, yyyy').format(record.vaccinationDate),
            iconColor: AppTheme.primary,
            tertiaryColor: tertiaryColor,
            primaryTextColor: primaryTextColor,
          ),
          _divider(borderColor: borderColor),
          _infoRow(
            icon: Icons.tag_rounded,
            label: 'Lot Number',
            value: record.lotNumber,
            iconColor: AppTheme.secondary,
            tertiaryColor: tertiaryColor,
            primaryTextColor: primaryTextColor,
          ),
          if (record.clinicName != null && record.clinicName!.isNotEmpty) ...[
            _divider(borderColor: borderColor),
            _infoRow(
              icon: Icons.local_hospital_rounded,
              label: 'Clinic',
              value: record.clinicName!,
              iconColor: AppTheme.purple,
              tertiaryColor: tertiaryColor,
              primaryTextColor: primaryTextColor,
            ),
          ],
          if (record.administeredBy != null &&
              record.administeredBy!.isNotEmpty) ...[
            _divider(borderColor: borderColor),
            _infoRow(
              icon: Icons.person_rounded,
              label: 'Administered By',
              value: record.administeredBy!,
              iconColor: secondaryColor,
              tertiaryColor: tertiaryColor,
              primaryTextColor: primaryTextColor,
            ),
          ],
          if (record.nextDoseDate != null) ...[
            _divider(borderColor: borderColor),
            _infoRow(
              icon: Icons.notifications_active_rounded,
              label: 'Next Dose',
              value: DateFormat('MMMM d, yyyy').format(record.nextDoseDate!),
              iconColor: AppTheme.warning,
              valueColor: AppTheme.warning,
              highlighted: true,
              tertiaryColor: tertiaryColor,
              primaryTextColor: primaryTextColor,
            ),
          ],
          if (record.notes != null && record.notes!.isNotEmpty) ...[
            _divider(borderColor: borderColor),
            _infoRow(
              icon: Icons.notes_rounded,
              label: 'Notes',
              value: record.notes!,
              iconColor: tertiaryColor,
              tertiaryColor: tertiaryColor,
              primaryTextColor: primaryTextColor,
            ),
          ],
        ],
      ),
    );
  }

Widget _divider({required Color borderColor}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Divider(height: 1, color: borderColor),
  );

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    Color? valueColor,
    bool highlighted = false,
    required Color tertiaryColor,
    required Color primaryTextColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 28,
          width: 28,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.10),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: tertiaryColor,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: highlighted ? FontWeight.w600 : FontWeight.w500,
                  color: valueColor ?? primaryTextColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

// ─── Actions ──────────────────────────────────────────────────────────────
  Widget _buildActions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.border;
    final surfaceVariantColor = isDark ? AppTheme.darkSurfaceVariant : AppTheme.surfaceVariant;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: surfaceVariantColor,
        border: Border(top: BorderSide(color: borderColor)),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppTheme.radiusLg),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (onMarkComplete != null && !record.isCompleted)
            _actionButton(
              icon: Icons.check_circle_outline_rounded,
              label: 'Mark Complete',
              color: AppTheme.success,
              onPressed: onMarkComplete!,
            ),
          if (onMarkComplete != null &&
              !record.isCompleted &&
              onDelete != null)
            const SizedBox(width: 8),
          if (onDelete != null)
            _actionButton(
              icon: Icons.delete_outline_rounded,
              label: 'Delete',
              color: AppTheme.danger,
              onPressed: onDelete!,
            ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}