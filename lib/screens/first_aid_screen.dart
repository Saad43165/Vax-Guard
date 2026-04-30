import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/status_badge.dart';

class FirstAidScreen extends StatefulWidget {
  const FirstAidScreen({Key? key}) : super(key: key);

  @override
  State<FirstAidScreen> createState() => _FirstAidScreenState();
}

class _FirstAidScreenState extends State<FirstAidScreen>
    with SingleTickerProviderStateMixin {
  late Duration remainingTime;
  bool isTimerRunning = false;
  bool isCompleted = false;
  late AnimationController _animationController;
  final timerDuration = const Duration(minutes: 15);

  @override
  void initState() {
    super.initState();
    remainingTime = timerDuration;
    _animationController = AnimationController(
      duration: timerDuration,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (!isTimerRunning) {
      setState(() {
        isTimerRunning = true;
        isCompleted = false;
      });
      _tick();
    }
  }

  void _resetTimer() {
    setState(() {
      isTimerRunning = false;
      isCompleted = false;
      remainingTime = timerDuration;
    });
  }

  void _tick() {
    if (isTimerRunning && remainingTime.inSeconds > 0) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            remainingTime = Duration(seconds: remainingTime.inSeconds - 1);
          });
          _tick();
        }
      });
    } else if (remainingTime.inSeconds == 0 && isTimerRunning) {
      setState(() {
        isTimerRunning = false;
        isCompleted = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Wound washing complete! You\'re doing great.'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
        ),
      );
    }
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  double get _progress =>
      (timerDuration.inSeconds - remainingTime.inSeconds) /
          timerDuration.inSeconds;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('First Aid Guide')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWarningBanner(),
            const SizedBox(height: AppTheme.spacingLg),
            _buildTimerSection(),
            const SizedBox(height: AppTheme.spacingLg),
            _buildStepsSection(),
            const SizedBox(height: AppTheme.spacingLg),
            _buildActionButton(),
            const SizedBox(height: AppTheme.spacingMd),
          ],
        ),
      ),
    );
  }

  // ─── Warning Banner ────────────────────────────────────────────────────────
  Widget _buildWarningBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.warningLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.warning.withOpacity(0.40)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: AppTheme.warning.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.wash_rounded,
              color: AppTheme.warning,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wash Your Wound',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'This is the MOST IMPORTANT step. Wash with soap and clean water for at least 15 minutes.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Timer Section ─────────────────────────────────────────────────────────
  Widget _buildTimerSection() {
    final ringColor = isCompleted
        ? AppTheme.success
        : isTimerRunning
        ? AppTheme.primary
        : AppTheme.textTertiary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.shadowMd,
      ),
      child: Column(
        children: [
          // Ring + time display
          AnimatedProgressRing(
            progress: isCompleted ? 1.0 : _progress,
            size: 180,
            strokeWidth: 10,
            trackColor: AppTheme.border,
            progressColor: ringColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(remainingTime),
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: ringColor,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isCompleted
                      ? 'Complete!'
                      : isTimerRunning
                      ? 'Running…'
                      : 'Ready',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isCompleted ? AppTheme.success : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),

          // Progress bar label
          AnimatedProgressBar(
            progress: isCompleted ? 1.0 : _progress,
            progressColor: ringColor,
            backgroundColor: AppTheme.border,
            height: 6,
            showLabel: true,
            label: 'Washing progress',
          ),
        ],
      ),
    );
  }

  // ─── Steps Section ─────────────────────────────────────────────────────────
  Widget _buildStepsSection() {
    final steps = [
      _StepData(
        title: 'Use Clean Water',
        description: 'Rinse the wound with clean, running water.',
        icon: Icons.water_drop_rounded,
        color: AppTheme.secondary,
      ),
      _StepData(
        title: 'Apply Soap',
        description: 'Use mild soap — antibacterial if available.',
        icon: Icons.cleaning_services_rounded,
        color: AppTheme.primary,
      ),
      _StepData(
        title: 'Scrub Gently',
        description: 'Gently scrub the wound area for full coverage.',
        icon: Icons.touch_app_rounded,
        color: AppTheme.purple,
      ),
      _StepData(
        title: 'Rinse Again',
        description: 'Rinse thoroughly with clean water.',
        icon: Icons.refresh_rounded,
        color: AppTheme.secondary,
      ),
      _StepData(
        title: 'Pat Dry',
        description: 'Dry with a clean cloth or sterile gauze.',
        icon: Icons.dry_rounded,
        color: AppTheme.success,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step-by-Step Instructions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        ...steps.asMap().entries.map(
              (entry) => _buildStep(
            number: entry.key + 1,
            data: entry.value,
            isLast: entry.key == steps.length - 1,
          ),
        ),
      ],
    );
  }

  Widget _buildStep({
    required int number,
    required _StepData data,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Number + connector
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: data.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: data.color.withOpacity(0.25)),
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: TextStyle(
                    color: data.color,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 1.5,
                height: 32,
                color: AppTheme.border,
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),
        const SizedBox(width: 14),

        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Action Button ─────────────────────────────────────────────────────────
  Widget _buildActionButton() {
    if (isCompleted) {
      return _PrimaryButton(
        label: 'Reset Timer',
        icon: Icons.restart_alt_rounded,
        color: AppTheme.success,
        onPressed: _resetTimer,
      );
    }

    if (isTimerRunning) {
      return Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.border),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Timer running…',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return _PrimaryButton(
      label: 'Start 15-Minute Timer',
      icon: Icons.play_circle_filled_rounded,
      color: AppTheme.primary,
      onPressed: _startTimer,
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
class _StepData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _StepData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
        ),
      ),
    );
  }
}