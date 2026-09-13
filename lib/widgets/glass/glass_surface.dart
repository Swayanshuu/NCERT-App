import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:oc_liquid_glass/oc_liquid_glass.dart';
import '../../theme/app_theme.dart';

class GlassSurface extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final double blurSigma;
  final List<BoxShadow>? boxShadow;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final VoidCallback? onTap;

  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius = 24.0,
    this.color,
    this.borderColor,
    this.borderWidth = 1.2,
    this.blurSigma = 18.0,
    this.boxShadow,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.alignment,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColor = color ??
        (isDark
            ? AppTheme.darkSurface.withValues(alpha: 0.82)
            : AppTheme.lightSurface.withValues(alpha: 0.88));

    final specularBorder = borderColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.16)
            : AppTheme.lightBorderHighlight.withValues(alpha: 0.80));

    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      alignment: alignment,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: specularBorder,
          width: borderWidth,
        ),
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.40)
                    : AppTheme.primaryTealDark.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 5),
              ),
            ],
      ),
      child: child,
    );

    if (blurSigma > 0) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: OCLiquidGlass(
            borderRadius: borderRadius,
            color: baseColor,
            child: content,
          ),
        ),
      );
    }

    if (onTap != null) {
      content = GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}
