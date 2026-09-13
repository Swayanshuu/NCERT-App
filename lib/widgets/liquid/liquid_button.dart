import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'liquid_surface.dart';
import '../../theme/app_theme.dart';

enum LiquidButtonVariant { primary, secondary, accent, ghost, glass }

class LiquidButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final LiquidButtonVariant variant;
  final double height;
  final double? width;
  final double borderRadius;
  final bool isLoading;

  const LiquidButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = LiquidButtonVariant.primary,
    this.height = 50.0,
    this.width,
    this.borderRadius = 20.0,
    this.isLoading = false,
  });

  @override
  State<LiquidButton> createState() => _LiquidButtonState();
}

class _LiquidButtonState extends State<LiquidButton> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _scaleController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _scaleController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      _scaleController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final enabled = widget.onPressed != null && !widget.isLoading;

    Color bg;
    Color border;
    Color textColor;

    switch (widget.variant) {
      case LiquidButtonVariant.primary:
        bg = AppTheme.primaryTeal;
        border = Colors.white.withValues(alpha: 0.35);
        textColor = Colors.white;
        break;
      case LiquidButtonVariant.secondary:
        bg = AppTheme.primaryIndigo;
        border = Colors.white.withValues(alpha: 0.35);
        textColor = Colors.white;
        break;
      case LiquidButtonVariant.accent:
        bg = AppTheme.accentAmber;
        border = Colors.white.withValues(alpha: 0.35);
        textColor = Colors.white;
        break;
      case LiquidButtonVariant.ghost:
        bg = isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.05);
        border = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
        textColor = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
        break;
      case LiquidButtonVariant.glass:
        bg = isDark
            ? AppTheme.darkSurface.withValues(alpha: 0.70)
            : Colors.white.withValues(alpha: 0.85);
        border = isDark
            ? AppTheme.primaryTeal.withValues(alpha: 0.50)
            : AppTheme.primaryTeal.withValues(alpha: 0.65);
        textColor = isDark ? Colors.white : AppTheme.lightTextPrimary;
        break;
    }

    if (!enabled) {
      bg = bg.withValues(alpha: 0.45);
      textColor = textColor.withValues(alpha: 0.50);
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: enabled ? widget.onPressed : null,
        child: LiquidSurface(
          width: widget.width,
          height: widget.height,
          borderRadius: widget.borderRadius,
          color: bg,
          borderColor: border,
          blurSigma: widget.variant == LiquidButtonVariant.glass ? 16 : 0,
          boxShadow: [
            if (widget.variant == LiquidButtonVariant.primary)
              BoxShadow(
                color: AppTheme.primaryTealDark.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            else if (widget.variant == LiquidButtonVariant.secondary)
              BoxShadow(
                color: AppTheme.primaryIndigoDark.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: textColor,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          color: textColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.label,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
