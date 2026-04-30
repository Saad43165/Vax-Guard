import 'package:flutter/material.dart';
import '../../core/theme.dart';

class AppTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int maxLines;
  final int? maxLength;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final FocusNode? focusNode;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.border;
    final tertiaryColor = isDark ? AppTheme.darkTextTertiary : AppTheme.textTertiary;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: labelColor,
              ),
            ),
          ),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          maxLength: maxLength,
          enabled: enabled,
          onChanged: onChanged,
          onTap: onTap,
          readOnly: readOnly,
          focusNode: focusNode,
          style: TextStyle(fontSize: 15, color: cs.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: tertiaryColor,
              fontSize: 14,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: cs.onSurface.withValues(alpha: 0.7), size: 20)
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: enabled ? cs.surface : cs.surfaceContainerHighest,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: BorderSide(
                color: AppTheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: BorderSide(color: AppTheme.danger),
            ),
          ),
        ),
      ],
    );
  }
}

class AppSearchField extends StatelessWidget {
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const AppSearchField({
    super.key,
    this.hint = 'Search...',
    this.controller,
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.border;
    final tertiaryColor = isDark ? AppTheme.darkTextTertiary : AppTheme.textTertiary;
    final secondaryColor = isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary;
    
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: borderColor),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(fontSize: 15, color: cs.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: tertiaryColor,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: secondaryColor,
            size: 20,
          ),
          suffixIcon: controller?.text.isNotEmpty == true
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    controller?.clear();
                    onClear?.call();
                  },
                  color: secondaryColor,
                  iconSize: 20,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

class AppDropdownField<T> extends StatelessWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;

  const AppDropdownField({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.border;
    final tertiaryColor = isDark ? AppTheme.darkTextTertiary : AppTheme.textTertiary;
    final textColor = isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: labelColor,
              ),
            ),
          ),
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          validator: validator,
          hint: Text(
            hint ?? 'Select',
            style: TextStyle(color: tertiaryColor),
          ),
          style: TextStyle(
            fontSize: 15,
            color: textColor,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: cs.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: BorderSide(color: borderColor),
            ),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: labelColor,
          ),
        ),
      ],
    );
  }
}

class AppDateField extends StatelessWidget {
  final String? label;
  final String? hint;
  final DateTime? value;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime>? onChanged;
  final String? Function(DateTime?)? validator;

  const AppDateField({
    super.key,
    this.label,
    this.hint,
    this.value,
    this.firstDate,
    this.lastDate,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.border;
    final tertiaryColor = isDark ? AppTheme.darkTextTertiary : AppTheme.textTertiary;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: labelColor,
              ),
            ),
          ),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: firstDate ?? DateTime(2000),
              lastDate: lastDate ?? DateTime(2100),
            );
            if (date != null) {
              onChanged?.call(date);
            }
          },
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: labelColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  value != null
                      ? '${value!.day}/${value!.month}/${value!.year}'
                      : hint ?? 'Select date',
                  style: TextStyle(
                    fontSize: 15,
                    color: value != null
                        ? cs.onSurface
                        : tertiaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AppTimeField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TimeOfDay? value;
  final ValueChanged<TimeOfDay>? onChanged;

  const AppTimeField({
    super.key,
    this.label,
    this.hint,
    this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.border;
    final tertiaryColor = isDark ? AppTheme.darkTextTertiary : AppTheme.textTertiary;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: labelColor,
              ),
            ),
          ),
        GestureDetector(
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: value ?? TimeOfDay.now(),
            );
            if (time != null) {
              onChanged?.call(time);
            }
          },
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  color: labelColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  value != null
                      ? '${value!.hour}:${value!.minute.toString().padLeft(2, '0')}'
                      : hint ?? 'Select time',
                  style: TextStyle(
                    fontSize: 15,
                    color: value != null
                        ? cs.onSurface
                        : tertiaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}