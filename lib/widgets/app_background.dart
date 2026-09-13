import 'package:flutter/material.dart';
import 'package:oc_liquid_glass/oc_liquid_glass.dart';
import 'painters/app_background_painter.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF0F172A),
                  const Color(0xFF1E293B),
                  const Color(0xFF0F172A),
                ]
              : [
                  const Color(0xFFF8FAFC),
                  const Color(0xFFEEF2FF),
                  const Color(0xFFF1F5F9),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: RepaintBoundary(
        child: CustomPaint(
          painter: AppBackgroundPainter(isDark: isDark),
          child: OCLiquidGlassGroup(
            settings: OCLiquidGlassSettings(
              blendPx: 35.0,
              specAngle: 0.8,
              refractStrength: -0.150,
              distortFalloffPx: 40,
              blurRadiusPx: 20.0,
              specStrength: 1.2,
              specWidth: 1.5,
              specPower: 4,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
