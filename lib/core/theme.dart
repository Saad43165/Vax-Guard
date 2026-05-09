import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_notifier.dart';

class AppTheme {
  AppTheme._();

  static bool get isDark => ThemeNotifier.instance.isDark;

  // ─── Premium Brand Palette (static const — safe in const widgets) ─────────
  static const Color primary        = Color(0xFF00D2FF); // Neon cyan
  static const Color primaryLight   = Color(0xFF3A86FF); // Bright Blue
  static const Color secondary      = Color(0xFFFF007A); // Neon Pink
  static const Color secondaryLight = Color(0xFFFF52A2);
  static const Color success        = Color(0xFF00E676); // Neon Green
  static const Color successLight   = Color(0xFFB9F6CA);
  static const Color warning        = Color(0xFFFFC400); // Neon Yellow
  static const Color warningLight   = Color(0xFFFFE57F);
  static const Color danger         = Color(0xFFFF1744); // Neon Red
  static const Color dangerLight    = Color(0xFFFF8A80);
  static const Color purple         = Color(0xFF8A2BE2); // Deep Purple
  static const Color purpleLight    = Color(0xFFD1C4E9);
  static const Color borderFocus    = Color(0xFF00D2FF);

  // ─── Theme-sensitive colors (Dynamic getters using context for reactivity) ──
  static Color background(BuildContext context) => Theme.of(context).scaffoldBackgroundColor;
  static Color surface(BuildContext context) => Theme.of(context).colorScheme.surface;
  static Color surfaceVariant(BuildContext context) => Theme.of(context).colorScheme.surfaceContainerHighest;
  static Color border(BuildContext context) => isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1);
  static Color textPrimary(BuildContext context) => Theme.of(context).colorScheme.onSurface;
  static Color textSecondary(BuildContext context) => isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  static Color textTertiary(BuildContext context) => isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
  static Color textInverse(BuildContext context) => Theme.of(context).colorScheme.surface;

  // Keep old getters for legacy compatibility but mark as deprecated or redirected
  static Color get primarySurface => isDark ? const Color(0xFF1E293B) : const Color(0xFFE0F2FE);
  static Color get backgroundStatic => isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
  static Color get surfaceStatic => isDark ? const Color(0xFF1E293B) : Colors.white;
  static Color get surfaceVariantStatic => isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
  static Color get borderStatic => isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1);
  static Color get textPrimaryStatic => isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
  static Color get textSecondaryStatic => isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

  // ─── Risk levels ─────────────────────────────────────────────────────────
  static const Color riskLow      = success;
  static const Color riskMedium   = warning;
  static const Color riskHigh     = Color(0xFFFF6D00);
  static const Color riskCritical = danger;

  // ─── Gradients (Premium) ──────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF3A86FF), Color(0xFF00D2FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient deepBlueGradient = LinearGradient(
    colors: [Color(0xFF090E17), Color(0xFF131B2B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient getHealthGradient(BuildContext context) {
    return isDark 
      ? deepBlueGradient 
      : LinearGradient(
          colors: [primary.withOpacity(0.05), primary.withOpacity(0.15)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
  }

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF00BFA5), Color(0xFF00E676)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFFF1744), Color(0xFFFF5252)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF8A2BE2), Color(0xFFB388FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFFF8008), Color(0xFFFFC837)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFFFD600)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premiumDarkGradient = LinearGradient(
    colors: [Color(0xFF141E30), Color(0xFF243B55)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Shadows ─────────────────────────────────────────────────────────────
  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: Colors.black.withOpacity(0.4),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];

  static List<BoxShadow> get shadowPrimary => [
    BoxShadow(
      color: primary.withOpacity(0.4),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  // ─── Radius ───────────────────────────────────────────────────────────────
  static const double radiusSm  = 8;
  static const double radiusMd  = 12;
  static const double radiusLg  = 16;
  static const double radiusXl  = 20;
  static const double radius2xl = 24;

  // ─── Spacing ─────────────────────────────────────────────────────────────
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;

  // ─── Theme ───────────────────────────────────────────────────────────────
  static ThemeData lightTheme() => _buildTheme(Brightness.light);
  static ThemeData darkTheme() => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDarkTheme = brightness == Brightness.dark;
    final bg = isDarkTheme ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final surf = isDarkTheme ? const Color(0xFF1E293B) : Colors.white;
    final txtPrimary = isDarkTheme ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final brdr = isDarkTheme ? const Color(0xFF475569) : const Color(0xFFCBD5E1);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryLight,
      brightness: brightness,
      primary: primary,
      onPrimary: Colors.black,
      secondary: secondary,
      onSecondary: Colors.white,
      error: danger,
      surface: surf,
      onSurface: txtPrimary,
      surfaceContainerHighest: isDarkTheme ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,

      // ── App Bar ─────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: surf,
        foregroundColor: txtPrimary,
        elevation: 0,
        scrolledUnderElevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        centerTitle: false,
        systemOverlayStyle: isDarkTheme ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: txtPrimary,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: txtPrimary, size: 24),
      ),

      // ── Text ────────────────────────────────────────────────────────────
      textTheme: _buildDarkTextTheme(),

      // ── Buttons ─────────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black, // Dark text on bright neon
          elevation: 0,
          shadowColor: primary.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ).copyWith(
          elevation: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) return 2;
            if (states.contains(WidgetState.hovered)) return 8;
            return 0;
          }),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: txtPrimary,
          side: BorderSide(color: brdr),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Cards ───────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: surf,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius2xl),
          side: BorderSide(color: brdr.withOpacity(0.5)),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Inputs ──────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDarkTheme ? const Color(0xFF1E293B) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusXl),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusXl),
          borderSide: BorderSide(color: brdr.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusXl),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusXl),
          borderSide: BorderSide(color: danger.withOpacity(0.5), width: 2),
        ),
        labelStyle: GoogleFonts.outfit(color: isDarkTheme ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 15, fontWeight: FontWeight.w500),
        hintStyle: GoogleFonts.outfit(color: isDarkTheme ? const Color(0xFF475569) : const Color(0xFF94A3B8), fontSize: 15),
        errorStyle: GoogleFonts.outfit(color: danger, fontSize: 13, fontWeight: FontWeight.w600),
      ),

      // ── Bottom Nav ──────────────────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surf,
        selectedItemColor: primary,
        unselectedItemColor: isDarkTheme ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
        selectedLabelStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // ── Bottom Sheet ────────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surf,
        modalBackgroundColor: surf,
        elevation: 24,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radius2xl)),
        ),
      ),

      // ── FAB ─────────────────────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.black,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
        ),
      ),

      // ── Divider ─────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(color: brdr.withOpacity(0.5), thickness: 1, space: 1),

      // ── Dialog ──────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: surf,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius2xl),
          side: BorderSide(color: brdr.withOpacity(0.3)),
        ),
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: txtPrimary,
          letterSpacing: -0.5,
        ),
        contentTextStyle: GoogleFonts.outfit(
          fontSize: 15,
          color: isDarkTheme ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          height: 1.6,
        ),
      ),

      // ── Snackbar ───────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDarkTheme ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        contentTextStyle: GoogleFonts.outfit(color: txtPrimary, fontSize: 15, height: 1.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: BorderSide(color: brdr.withOpacity(0.5)),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 8,
      ),

      // ── Switch ─────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.black;
          return isDarkTheme ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return isDarkTheme ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
        }),
      ),

      // ── Checkbox ───────────────────────────────────────────────────────
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.black),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        side: BorderSide(color: brdr.withOpacity(0.8), width: 2),
      ),

      // ── Progress ──────────────────────────────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: isDarkTheme ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
      ),

      // ── List Tile ─────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        tileColor: Colors.transparent,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: txtPrimary,
        ),
        subtitleTextStyle: GoogleFonts.outfit(fontSize: 14, color: isDarkTheme ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
        iconColor: isDarkTheme ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
      ),
    );
  }

  static TextTheme _buildDarkTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.w800, color: textPrimaryStatic, letterSpacing: -1.0, height: 1.1),
      displayMedium: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w800, color: textPrimaryStatic, letterSpacing: -0.8, height: 1.2),
      displaySmall: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, color: textPrimaryStatic, letterSpacing: -0.5, height: 1.2),
      headlineLarge: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w700, color: textPrimaryStatic, letterSpacing: -0.4),
      headlineMedium: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: textPrimaryStatic, letterSpacing: -0.3),
      headlineSmall: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimaryStatic, letterSpacing: -0.2),
      titleLarge: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimaryStatic, letterSpacing: -0.1),
      titleMedium: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500, color: textPrimaryStatic),
      titleSmall: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w500, color: textPrimaryStatic),
      bodyLarge: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w400, color: textPrimaryStatic, height: 1.6),
      bodyMedium: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w400, color: textSecondaryStatic, height: 1.6),
      bodySmall: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w400, color: textSecondaryStatic, height: 1.5),
      labelLarge: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: textPrimaryStatic, letterSpacing: 0.5),
      labelMedium: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: textSecondaryStatic, letterSpacing: 0.5),
      labelSmall: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8), letterSpacing: 0.5),
    );
  }

  // ─── Helper Utilities ─────────────────────────────────────────────────────
  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'done':
      case 'success':
      case 'low': return success;
      case 'pending':
      case 'warning':
      case 'moderate': return warning;
      case 'overdue':
      case 'critical':
      case 'high':
      case 'high_risk':
      case 'error':   return danger;
      default:        return textSecondaryStatic;
    }
  }

  static Color statusSurface(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'done':
      case 'success': return success.withOpacity(0.15);
      case 'pending':
      case 'warning': return warning.withOpacity(0.15);
      case 'overdue':
      case 'critical':
      case 'error':   return danger.withOpacity(0.15);
      default:        return surfaceVariantStatic;
    }
  }
}