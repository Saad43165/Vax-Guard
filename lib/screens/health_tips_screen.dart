import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../utils/l10n_helper.dart';

class _HealthTip {
  final String category;
  final String titleKey;
  final String subtitleKey;
  final String whyKey;
  final String whyDescKey;
  final String goalKey;
  final String goalDescKey;
  final IconData icon;
  final Color color;
  final String emoji;

  const _HealthTip({
    required this.category,
    required this.titleKey,
    required this.subtitleKey,
    required this.whyKey,
    required this.whyDescKey,
    required this.goalKey,
    required this.goalDescKey,
    required this.icon,
    required this.color,
    required this.emoji,
  });
}

class HealthTipsScreen extends StatefulWidget {
  const HealthTipsScreen({super.key});

  @override
  State<HealthTipsScreen> createState() => _HealthTipsScreenState();
}

class _HealthTipsScreenState extends State<HealthTipsScreen> {
  final PageController _pageController = PageController();

  final List<_HealthTip> _allTips = [
    _HealthTip(
      category: 'HYDRATION',
      titleKey: 'hydration_title',
      subtitleKey: 'hydration_subtitle',
      whyKey: 'hydration_why',
      whyDescKey: 'hydration_why_desc',
      goalKey: 'hydration_goal',
      goalDescKey: 'hydration_goal_desc',
      icon: Icons.water_drop_rounded,
      color: const Color(0xFF0EA5E9),
      emoji: '💧',
    ),
    _HealthTip(
      category: 'NUTRITION',
      titleKey: 'nutrition_title',
      subtitleKey: 'nutrition_subtitle',
      whyKey: 'nutrition_why',
      whyDescKey: 'nutrition_why_desc',
      goalKey: 'nutrition_goal',
      goalDescKey: 'nutrition_goal_desc',
      icon: Icons.restaurant_rounded,
      color: const Color(0xFF10B981),
      emoji: '🥗',
    ),
    _HealthTip(
      category: 'REST',
      titleKey: 'sleep_title',
      subtitleKey: 'sleep_subtitle',
      whyKey: 'sleep_why',
      whyDescKey: 'sleep_why_desc',
      goalKey: 'sleep_goal',
      goalDescKey: 'sleep_goal_desc',
      icon: Icons.bedtime_rounded,
      color: const Color(0xFF8B5CF6),
      emoji: '😴',
    ),
    _HealthTip(
      category: 'ACTIVITY',
      titleKey: 'exercise_title',
      subtitleKey: 'exercise_subtitle',
      whyKey: 'exercise_why',
      whyDescKey: 'exercise_why_desc',
      goalKey: 'exercise_goal',
      goalDescKey: 'exercise_goal_desc',
      icon: Icons.fitness_center_rounded,
      color: const Color(0xFFF43F5E),
      emoji: '🏃',
    ),
    _HealthTip(
      category: 'HYGIENE',
      titleKey: 'hygiene_title',
      subtitleKey: 'hygiene_subtitle',
      whyKey: 'hygiene_why',
      whyDescKey: 'hygiene_why_desc',
      goalKey: 'hygiene_goal',
      goalDescKey: 'hygiene_goal_desc',
      icon: Icons.clean_hands_rounded,
      color: const Color(0xFF06B6D4),
      emoji: '🧼',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(L10n.s(context, 'health_tips'), style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: _allTips.length,
            itemBuilder: (context, index) {
              return _buildTipPage(_allTips[index]);
            },
          ),
          _buildNavigationIndicators(),
        ],
      ),
    );
  }

  Widget _buildTipPage(_HealthTip tip) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [tip.color.withOpacity(0.4), Colors.black],
              stops: const [0.0, 0.7],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 1),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                      boxShadow: [BoxShadow(color: tip.color.withOpacity(0.3), blurRadius: 40, spreadRadius: 10)],
                    ),
                    child: Text(tip.emoji, style: const TextStyle(fontSize: 64)),
                  ),
                ),
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(color: tip.color.withOpacity(0.3), borderRadius: BorderRadius.circular(10), border: Border.all(color: tip.color.withOpacity(0.5))),
                  child: Text(tip.category, style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 2.0)),
                ),
                const SizedBox(height: 16),
                Text(L10n.s(context, tip.titleKey), style: GoogleFonts.outfit(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900, height: 1.1, letterSpacing: -1.0)),
                const SizedBox(height: 8),
                Text(L10n.s(context, tip.subtitleKey), style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.7), fontSize: 18, fontWeight: FontWeight.w500)),
                const SizedBox(height: 40),
                
                // Section 1: Why it matters
                _buildInfoSection(L10n.s(context, tip.whyKey), L10n.s(context, tip.whyDescKey), Icons.info_outline_rounded, tip.color),
                const SizedBox(height: 24),
                
                // Section 2: Goal
                _buildInfoSection(L10n.s(context, tip.goalKey), L10n.s(context, tip.goalDescKey), Icons.track_changes_rounded, tip.color),
                
                const Spacer(flex: 2),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.keyboard_double_arrow_up_rounded, color: Colors.white.withOpacity(0.4), size: 32),
                      const SizedBox(height: 8),
                      Text(L10n.s(context, 'swipe_up_more').toUpperCase(), style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String title, String desc, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(title.toUpperCase(), style: GoogleFonts.outfit(color: color, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          ],
        ),
        const SizedBox(height: 8),
        Text(desc, style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.9), fontSize: 16, height: 1.5, fontWeight: FontWeight.w400)),
      ],
    );
  }

  Widget _buildNavigationIndicators() {
    return Positioned(
      right: 16,
      top: 0,
      bottom: 0,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_allTips.length, (index) {
            return AnimatedBuilder(
              animation: _pageController,
              builder: (context, child) {
                double selectedness = 0;
                if (_pageController.hasClients) {
                  try {
                    selectedness = (1 - (_pageController.page! - index).abs()).clamp(0, 1);
                  } catch (_) {}
                }
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  width: 4,
                  height: 12 + (24 * selectedness),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2 + (0.8 * selectedness)),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: selectedness > 0.5 ? [BoxShadow(color: Colors.white.withOpacity(0.3), blurRadius: 10)] : [],
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}