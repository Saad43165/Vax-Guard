import 'package:flutter/material.dart';
import '../core/theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AnimatedCounter
// Smoothly counts from the previous value to the new value whenever [value]
// changes. Supports optional prefix/suffix text.
// ─────────────────────────────────────────────────────────────────────────────
class AnimatedCounter extends StatefulWidget {
  final int value;
  final TextStyle? style;
  final String? prefix;
  final String? suffix;
  final Duration duration;
  final Curve curve;

  const AnimatedCounter({
    Key? key,
    required this.value,
    this.style,
    this.prefix,
    this.suffix,
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.easeOutCubic,
  }) : super(key: key);

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _previousValue = widget.value;
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final currentValue = (_previousValue +
            (_animation.value * (widget.value - _previousValue)))
            .round();
        return Text(
          '${widget.prefix ?? ''}$currentValue${widget.suffix ?? ''}',
          style: widget.style,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AnimatedProgressBar
// Animates from old progress to new progress whenever [progress] changes.
// Supports gradient fill, rounded caps, and an optional label.
// ─────────────────────────────────────────────────────────────────────────────
class AnimatedProgressBar extends StatefulWidget {
  final double progress;        // 0.0 – 1.0
  final Color? backgroundColor;
  final Color? progressColor;
  final Gradient? progressGradient;
  final double height;
  final Duration duration;
  final Curve curve;
  final bool showLabel;
  final String? label;

  const AnimatedProgressBar({
    Key? key,
    required this.progress,
    this.backgroundColor,
    this.progressColor,
    this.progressGradient,
    this.height = 8,
    this.duration = const Duration(milliseconds: 1000),
    this.curve = Curves.easeInOut,
    this.showLabel = false,
    this.label,
  }) : super(key: key);

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.progress,
      ).animate(
        CurvedAnimation(parent: _controller, curve: widget.curve),
      );
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showLabel) ...[
          AnimatedBuilder(
            animation: _animation,
            builder: (_, __) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.label != null)
                  Text(
                    widget.label!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                Text(
                  '${(_animation.value.clamp(0.0, 1.0) * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
        ],
        AnimatedBuilder(
          animation: _animation,
          builder: (_, __) {
            final value = _animation.value.clamp(0.0, 1.0);
            return LayoutBuilder(
              builder: (context, constraints) {
                final fillWidth = constraints.maxWidth * value;
                return Container(
                  height: widget.height,
                  decoration: BoxDecoration(
                    color: widget.backgroundColor ?? AppTheme.border,
                    borderRadius: BorderRadius.circular(widget.height / 2),
                  ),
                  child: Stack(
                    children: [
                      AnimatedContainer(
                        duration: Duration.zero,
                        width: fillWidth,
                        decoration: BoxDecoration(
                          color: widget.progressGradient == null
                              ? (widget.progressColor ??
                              Theme.of(context).colorScheme.primary)
                              : null,
                          gradient: widget.progressGradient,
                          borderRadius:
                          BorderRadius.circular(widget.height / 2),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AnimatedStatCard
// A card with an animated counter and sub-label — ideal for dashboards.
// ─────────────────────────────────────────────────────────────────────────────
class AnimatedStatCard extends StatelessWidget {
  final String title;
  final int value;
  final String? prefix;
  final String? suffix;
  final IconData icon;
  final Color color;
  final String? changeLabel;    // e.g. "+12 this week"
  final bool changePositive;

  const AnimatedStatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.prefix,
    this.suffix,
    this.changeLabel,
    this.changePositive = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.shadowMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon + title row
          Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Animated number
          AnimatedCounter(
            value: value,
            prefix: prefix,
            suffix: suffix,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -0.8,
            ),
          ),

          // Change label
          if (changeLabel != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  changePositive
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  size: 13,
                  color: changePositive ? AppTheme.success : AppTheme.danger,
                ),
                const SizedBox(width: 4),
                Text(
                  changeLabel!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: changePositive ? AppTheme.success : AppTheme.danger,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AnimatedProgressRing
// Circular variant of a progress indicator with animated fill.
// ─────────────────────────────────────────────────────────────────────────────
class AnimatedProgressRing extends StatefulWidget {
  final double progress;        // 0.0 – 1.0
  final double size;
  final double strokeWidth;
  final Color? trackColor;
  final Color? progressColor;
  final Widget? child;
  final Duration duration;

  const AnimatedProgressRing({
    Key? key,
    required this.progress,
    this.size = 80,
    this.strokeWidth = 8,
    this.trackColor,
    this.progressColor,
    this.child,
    this.duration = const Duration(milliseconds: 1200),
  }) : super(key: key);

  @override
  State<AnimatedProgressRing> createState() => _AnimatedProgressRingState();
}

class _AnimatedProgressRingState extends State<AnimatedProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.progress,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => SizedBox(
        height: widget.size,
        width: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _RingPainter(
                progress: _animation.value.clamp(0.0, 1.0),
                strokeWidth: widget.strokeWidth,
                trackColor: widget.trackColor ?? AppTheme.border,
                progressColor: widget.progressColor ??
                    Theme.of(context).colorScheme.primary,
              ),
            ),
            if (widget.child != null) widget.child!,
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final Color progressColor;

  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -3.14159 / 2,              // start at 12 o'clock
        2 * 3.14159 * progress,    // sweep angle
        false,
        Paint()
          ..color = progressColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
          oldDelegate.progressColor != progressColor;
}