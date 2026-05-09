import 'package:flutter/material.dart';
import '../core/theme.dart';

enum ButtonVariant {
  primary,
  secondary,
  outlined,
  ghost,
  danger,
  success,
  gradient,
}

enum ButtonSize { sm, md, lg }

class CustomButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool fullWidth;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.md,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.fullWidth = true,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _scaleController;
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  // ─── Size Tokens ──────────────────────────────────────────────────────────
  double get _height {
    switch (widget.size) {
      case ButtonSize.sm: return 38;
      case ButtonSize.md: return 50;
      case ButtonSize.lg: return 58;
    }
  }

  EdgeInsets get _padding {
    switch (widget.size) {
      case ButtonSize.sm: return const EdgeInsets.symmetric(horizontal: 16);
      case ButtonSize.md: return const EdgeInsets.symmetric(horizontal: 22);
      case ButtonSize.lg: return const EdgeInsets.symmetric(horizontal: 28);
    }
  }

  double get _fontSize {
    switch (widget.size) {
      case ButtonSize.sm: return 13;
      case ButtonSize.md: return 15;
      case ButtonSize.lg: return 17;
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case ButtonSize.sm: return 15;
      case ButtonSize.md: return 18;
      case ButtonSize.lg: return 20;
    }
  }

  // ─── Variant Config ───────────────────────────────────────────────────────
  _ButtonConfig _getConfig(BuildContext context) {
    final disabled = widget.onPressed == null && !widget.isLoading;
    switch (widget.variant) {
      case ButtonVariant.primary:
        return _ButtonConfig(
          bg: disabled ? AppTheme.textTertiary(context) : AppTheme.primary,
          fg: Colors.white,
          border: null,
          shadows: disabled ? [] : AppTheme.shadowPrimary,
        );
      case ButtonVariant.secondary:
        return _ButtonConfig(
          bg: AppTheme.primarySurface,
          fg: AppTheme.primary,
          border: null,
          shadows: [],
        );
      case ButtonVariant.outlined:
        return _ButtonConfig(
          bg: Colors.transparent,
          fg: AppTheme.primary,
          border: Border.all(color: AppTheme.primary, width: 1.5),
          shadows: [],
        );
      case ButtonVariant.ghost:
        return _ButtonConfig(
          bg: Colors.transparent,
          fg: AppTheme.primary,
          border: null,
          shadows: [],
        );
      case ButtonVariant.danger:
        return _ButtonConfig(
          bg: AppTheme.danger,
          fg: Colors.white,
          border: null,
          shadows: [
            BoxShadow(
              color: AppTheme.danger.withOpacity(0.30),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        );
      case ButtonVariant.success:
        return _ButtonConfig(
          bg: AppTheme.success,
          fg: Colors.white,
          border: null,
          shadows: [
            BoxShadow(
              color: AppTheme.success.withOpacity(0.30),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        );
      case ButtonVariant.gradient:
        return _ButtonConfig(
          bg: Colors.transparent,
          fg: Colors.white,
          border: null,
          shadows: AppTheme.shadowPrimary,
          gradient: AppTheme.primaryGradient,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cfg = _getConfig(context);
    final isDisabled = widget.onPressed == null && !widget.isLoading;

    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnim.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: isDisabled
            ? null
            : (_) => _scaleController.reverse(),
        onTapUp: isDisabled
            ? null
            : (_) {
          _scaleController.forward();
          widget.onPressed?.call();
        },
        onTapCancel: () => _scaleController.forward(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: _height,
          width: widget.fullWidth ? double.infinity : null,
          padding: widget.fullWidth ? EdgeInsets.zero : _padding,
          decoration: BoxDecoration(
            color: cfg.gradient == null ? cfg.bg : null,
            gradient: cfg.gradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: cfg.border,
            boxShadow: isDisabled ? [] : cfg.shadows,
          ),
          child: _buildContent(cfg.fg),
        ),
      ),
    );
  }

  Widget _buildContent(Color fg) {
    if (widget.isLoading) {
      return Center(
        child: SizedBox(
          height: _iconSize,
          width: _iconSize,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            valueColor: AlwaysStoppedAnimation<Color>(fg),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (widget.leadingIcon != null) ...[
          Icon(widget.leadingIcon, size: _iconSize, color: fg),
          const SizedBox(width: 8),
        ],
        Text(
          widget.label,
          style: TextStyle(
            fontSize: _fontSize,
            fontWeight: FontWeight.w600,
            color: fg,
            letterSpacing: -0.1,
          ),
        ),
        if (widget.trailingIcon != null) ...[
          const SizedBox(width: 8),
          Icon(widget.trailingIcon, size: _iconSize, color: fg),
        ],
      ],
    );
  }
}

class _ButtonConfig {
  final Color bg;
  final Color fg;
  final BoxBorder? border;
  final List<BoxShadow> shadows;
  final Gradient? gradient;

  const _ButtonConfig({
    required this.bg,
    required this.fg,
    required this.border,
    required this.shadows,
    this.gradient,
  });
}

// ─── Icon-only Button ─────────────────────────────────────────────────────
class CustomIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? background;
  final double size;
  final String? tooltip;

  const CustomIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.background,
    this.size = 40,
    this.tooltip,
  });

  @override
  State<CustomIconButton> createState() => _CustomIconButtonState();
}

class _CustomIconButtonState extends State<CustomIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      lowerBound: 0.88,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget btn = GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.forward();
        widget.onPressed?.call();
      },
      onTapCancel: () => _ctrl.forward(),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform.scale(scale: _ctrl.value, child: child),
        child: Container(
          height: widget.size,
          width: widget.size,
          decoration: BoxDecoration(
            color: widget.background ?? AppTheme.surfaceVariant(context),
            borderRadius: BorderRadius.circular(widget.size / 3),
            border: Border.all(color: AppTheme.border(context).withOpacity(0.5)),
          ),
          child: Icon(
            widget.icon,
            size: widget.size * 0.46,
            color: widget.color ?? AppTheme.textSecondary(context),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      btn = Tooltip(message: widget.tooltip!, child: btn);
    }
    return btn;
  }
}