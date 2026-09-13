import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'glass_surface.dart';
import '../hover_builder.dart';
import '../../theme/app_theme.dart';

enum GlassButtonVariant { primary, secondary, accent, ghost, glass }

class GlassButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final GlassButtonVariant variant;
  final double height;
  final double? width;
  final double borderRadius;
  final bool isLoading;
  final String? tooltip;

  const GlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = GlassButtonVariant.primary,
    this.height = 48.0,
    this.width,
    this.borderRadius = 20.0,
    this.isLoading = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final enabled = onPressed != null && !isLoading;

    Color bg;
    Color border;
    Color textColor;

    switch (variant) {
      case GlassButtonVariant.primary:
        bg = AppTheme.primaryTeal;
        border = Colors.white.withValues(alpha: 0.35);
        textColor = Colors.white;
        break;
      case GlassButtonVariant.secondary:
        bg = AppTheme.primaryIndigo;
        border = Colors.white.withValues(alpha: 0.35);
        textColor = Colors.white;
        break;
      case GlassButtonVariant.accent:
        bg = AppTheme.accentAmber;
        border = Colors.white.withValues(alpha: 0.35);
        textColor = Colors.white;
        break;
      case GlassButtonVariant.ghost:
        bg = isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.05);
        border = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
        textColor = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
        break;
      case GlassButtonVariant.glass:
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

    return HoverBuilder(
      onTap: enabled ? onPressed : null,
      tooltip: tooltip,
      hoverScale: 1.03,
      builder: (context, isHovered) {
        return GlassSurface(
          width: width,
          height: height,
          borderRadius: borderRadius,
          color: isHovered && enabled ? bg.withValues(alpha: 0.90) : bg,
          borderColor: isHovered && enabled ? Colors.white.withValues(alpha: 0.60) : border,
          blurSigma: variant == GlassButtonVariant.glass ? 16 : 0,
          boxShadow: [
            if (variant == GlassButtonVariant.primary)
              BoxShadow(
                color: AppTheme.primaryTealDark.withValues(alpha: isHovered ? 0.45 : 0.30),
                blurRadius: isHovered ? 14 : 10,
                offset: const Offset(0, 4),
              )
            else if (variant == GlassButtonVariant.secondary)
              BoxShadow(
                color: AppTheme.primaryIndigoDark.withValues(alpha: isHovered ? 0.45 : 0.30),
                blurRadius: isHovered ? 14 : 10,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.05),
                blurRadius: isHovered ? 10 : 6,
                offset: const Offset(0, 2),
              ),
          ],
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: textColor,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          color: textColor,
                          size: 19,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: GoogleFonts.outfit(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
