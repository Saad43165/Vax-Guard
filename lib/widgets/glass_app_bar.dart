import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final bool centerTitle;

  const GlassAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.centerTitle = false,
  }) : assert(title != null || titleWidget != null, 'Either title or titleWidget must be provided');

  @override
  Widget build(BuildContext context) {
    // Less glassy, more professional solid feel with subtle blur
    final defaultBgColor = backgroundColor ?? AppTheme.surface(context);

    return Container(
      decoration: BoxDecoration(
        color: defaultBgColor,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.border(context),
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              if (leading != null)
                leading!
              else if (Navigator.canPop(context))
                _buildBackButton(context),
              if (leading != null || Navigator.canPop(context))
                const SizedBox(width: 16),
              Expanded(
                child: titleWidget ?? Text(
                  title!,
                  textAlign: centerTitle ? TextAlign.center : TextAlign.left,
                  style: GoogleFonts.outfit(
                    color: AppTheme.textPrimary(context),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (actions != null) ...actions!,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceVariant(context).withOpacity(0.5) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppTheme.border(context).withOpacity(0.5) : AppTheme.border(context).withOpacity(0.2),
          ),
          boxShadow: isDark ? [] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary(context), size: 20),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60.0);
}

class SliverGlassAppBar extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final bool pinned;
  final bool floating;
  final Widget? flexibleSpace;
  final double expandedHeight;

  const SliverGlassAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.pinned = true,
    this.floating = false,
    this.flexibleSpace,
    this.expandedHeight = 60.0,
  }) : assert(title != null || titleWidget != null || flexibleSpace != null, 'Provide title, titleWidget, or flexibleSpace');

  @override
  Widget build(BuildContext context) {
    final defaultBgColor = backgroundColor ?? AppTheme.surface(context);

    return SliverAppBar(
      pinned: true,
      floating: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      backgroundColor: defaultBgColor,
      title: Container(
        height: kToolbarHeight,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppTheme.border(context),
              width: 1.0,
            ),
          ),
        ),
        child: Row(
          children: [
            if (leading != null)
              leading!
            else if (Navigator.canPop(context))
              _buildBackButton(context),
            if (leading != null || Navigator.canPop(context))
              const SizedBox(width: 16),
            if (titleWidget != null || title != null)
              Expanded(
                child: titleWidget ?? Text(
                  title!,
                  style: GoogleFonts.outfit(
                    color: AppTheme.textPrimary(context),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            if (actions != null) ...actions!,
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceVariant(context).withOpacity(0.5) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppTheme.border(context).withOpacity(0.5) : AppTheme.border(context).withOpacity(0.2),
          ),
          boxShadow: isDark ? [] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary(context), size: 20),
      ),
    );
  }
}
