import 'package:flutter/material.dart';
import 'liquid_surface.dart';
import '../../theme/app_theme.dart';

class LiquidCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Color? borderColor;
  final double blurSigma;

  const LiquidCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = 24.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.color,
    this.borderColor,
    this.blurSigma = 12.0,
  });

  @override
  State<LiquidCard> createState() => _LiquidCardState();
}

class _LiquidCardState extends State<LiquidCard> with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: (_) => widget.onTap != null ? _hoverController.forward() : null,
        onTapUp: (_) => widget.onTap != null ? _hoverController.reverse() : null,
        onTapCancel: () => widget.onTap != null ? _hoverController.reverse() : null,
        onTap: widget.onTap,
        child: LiquidSurface(
          borderRadius: widget.borderRadius,
          padding: widget.padding,
          margin: widget.margin,
          color: widget.color ??
              (isDark
                  ? AppTheme.darkSurface.withValues(alpha: 0.88)
                  : AppTheme.lightSurface.withValues(alpha: 0.92)),
          borderColor: widget.borderColor ??
              (isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : AppTheme.lightBorder),
          blurSigma: widget.blurSigma,
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.30)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
          child: widget.child,
        ),
      ),
    );
  }
}
