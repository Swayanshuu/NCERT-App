import 'package:flutter/material.dart';
import 'glass_surface.dart';
import '../hover_builder.dart';
import '../../theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Color? borderColor;
  final double blurSigma;
  final String? tooltip;

  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = 24.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.color,
    this.borderColor,
    this.blurSigma = 16.0,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return HoverBuilder(
      onTap: onTap,
      tooltip: tooltip,
      hoverScale: 1.02,
      builder: (context, isHovered) {
        final hoverColor = color ??
            (isDark
                ? (isHovered
                    ? AppTheme.darkSurface.withValues(alpha: 0.92)
                    : AppTheme.darkSurface.withValues(alpha: 0.82))
                : (isHovered
                    ? Colors.white.withValues(alpha: 0.96)
                    : AppTheme.lightSurface.withValues(alpha: 0.88)));

        final hoverBorder = borderColor ??
            (isDark
                ? (isHovered
                    ? AppTheme.primaryTeal.withValues(alpha: 0.60)
                    : Colors.white.withValues(alpha: 0.16))
                : (isHovered
                    ? AppTheme.primaryTeal.withValues(alpha: 0.70)
                    : AppTheme.lightBorder));

        return GlassSurface(
          borderRadius: borderRadius,
          padding: padding,
          margin: margin,
          color: hoverColor,
          borderColor: hoverBorder,
          blurSigma: blurSigma,
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? (isHovered
                      ? AppTheme.primaryTealDark.withValues(alpha: 0.35)
                      : Colors.black.withValues(alpha: 0.35))
                  : (isHovered
                      ? AppTheme.primaryTealDark.withValues(alpha: 0.15)
                      : Colors.black.withValues(alpha: 0.05)),
              blurRadius: isHovered ? 22 : 16,
              offset: isHovered ? const Offset(0, 6) : const Offset(0, 4),
            ),
          ],
          child: child,
        );
      },
    );
  }
}
