import 'dart:math' as math;
import 'package:flutter/material.dart';

enum ModernCardPattern {
  concentricArcs,
  dotsMatrix,
  cornerCurves,
  minimalMesh,
  waves,
  badgeGlow,
}

class ModernCardPainter extends CustomPainter {
  final Color accentColor;
  final ModernCardPattern pattern;
  final bool isDark;

  const ModernCardPainter({
    required this.accentColor,
    this.pattern = ModernCardPattern.cornerCurves,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (pattern) {
      case ModernCardPattern.cornerCurves:
        _paintCornerCurves(canvas, size);
        break;
      case ModernCardPattern.concentricArcs:
        _paintConcentricArcs(canvas, size);
        break;
      case ModernCardPattern.dotsMatrix:
        _paintDotsMatrix(canvas, size);
        break;
      case ModernCardPattern.minimalMesh:
        _paintMinimalMesh(canvas, size);
        break;
      case ModernCardPattern.waves:
        _paintWaves(canvas, size);
        break;
      case ModernCardPattern.badgeGlow:
        _paintBadgeGlow(canvas, size);
        break;
    }
  }

  void _paintCornerCurves(Canvas canvas, Size size) {
    // 1. Soft radial gradient wash in top right corner
    final topCorner = Offset(size.width, 0);
    final auraPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              accentColor.withValues(alpha: isDark ? 0.14 : 0.09),
              accentColor.withValues(alpha: 0.0),
            ],
            radius: 0.9,
          ).createShader(
            Rect.fromCircle(center: topCorner, radius: size.width * 0.7),
          );
    canvas.drawCircle(topCorner, size.width * 0.7, auraPaint);

    // 2. Elegant, clean thin bezier curves in the corner
    final strokePaint = Paint()
      ..color = accentColor.withValues(alpha: isDark ? 0.16 : 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path1 = Path();
    path1.moveTo(size.width * 0.65, 0);
    path1.quadraticBezierTo(
      size.width * 0.78,
      size.height * 0.35,
      size.width,
      size.height * 0.42,
    );
    canvas.drawPath(path1, strokePaint);

    final path2 = Path();
    path2.moveTo(size.width * 0.78, 0);
    path2.quadraticBezierTo(
      size.width * 0.88,
      size.height * 0.22,
      size.width,
      size.height * 0.28,
    );
    canvas.drawPath(
      path2,
      strokePaint..color = accentColor.withValues(alpha: isDark ? 0.10 : 0.07),
    );
  }

  void _paintConcentricArcs(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.92, size.height * 0.15);
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = accentColor.withValues(alpha: isDark ? 0.15 : 0.10);

    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, 18.0 * i, arcPaint);
    }

    // Small solid decorative dot at center
    final dotPaint = Paint()
      ..color = accentColor.withValues(alpha: isDark ? 0.35 : 0.25);
    canvas.drawCircle(center, 3.0, dotPaint);
  }

  void _paintDotsMatrix(Canvas canvas, Size size) {
    // 3x3 subtle grid of micro dots in top right
    final startX = size.width - 44.0;
    final startY = 14.0;
    const spacing = 10.0;

    final dotPaint = Paint()
      ..color = accentColor.withValues(alpha: isDark ? 0.22 : 0.15);

    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        canvas.drawCircle(
          Offset(startX + (col * spacing), startY + (row * spacing)),
          1.5,
          dotPaint,
        );
      }
    }
  }

  void _paintMinimalMesh(Canvas canvas, Size size) {
    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          accentColor.withValues(alpha: isDark ? 0.12 : 0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), auraPaint);

    final linePaint = Paint()
      ..color = accentColor.withValues(alpha: isDark ? 0.08 : 0.05)
      ..strokeWidth = 1.0;

    // Elegant clean diagonal lines
    canvas.drawLine(
      Offset(size.width * 0.5, 0),
      Offset(size.width, size.height * 0.6),
      linePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.65, 0),
      Offset(size.width, size.height * 0.45),
      linePaint,
    );
  }

  void _paintWaves(Canvas canvas, Size size) {
    // Flowing smooth wave curves
    final wavePaint = Paint()
      ..color = accentColor.withValues(alpha: isDark ? 0.14 : 0.09)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    final path = Path();
    path.moveTo(size.width * 0.4, size.height);
    path.cubicTo(
      size.width * 0.6,
      size.height * 0.5,
      size.width * 0.75,
      size.height * 0.9,
      size.width,
      size.height * 0.35,
    );
    canvas.drawPath(path, wavePaint);

    final path2 = Path();
    path2.moveTo(size.width * 0.55, size.height);
    path2.cubicTo(
      size.width * 0.72,
      size.height * 0.65,
      size.width * 0.85,
      size.height * 0.95,
      size.width,
      size.height * 0.55,
    );
    canvas.drawPath(
      path2,
      wavePaint..color = accentColor.withValues(alpha: isDark ? 0.08 : 0.05),
    );
  }

  void _paintBadgeGlow(Canvas canvas, Size size) {
    // Subtle circular radiating ambient glow for achievement/trophy cards
    final center = Offset(size.width * 0.5, size.height * 0.38);
    final glowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              accentColor.withValues(alpha: isDark ? 0.20 : 0.12),
              accentColor.withValues(alpha: 0.0),
            ],
          ).createShader(
            Rect.fromCircle(center: center, radius: size.width * 0.45),
          );
    canvas.drawCircle(center, size.width * 0.45, glowPaint);

    // Subtle starburst rays
    final rayPaint = Paint()
      ..color = accentColor.withValues(alpha: isDark ? 0.09 : 0.06)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const numRays = 8;
    const angleStep = (2 * math.pi) / numRays;
    final rayRadius = size.width * 0.35;
    for (int i = 0; i < numRays; i++) {
      final angle = i * angleStep;
      canvas.drawLine(
        Offset(
          center.dx + 18 * math.cos(angle),
          center.dy + 18 * math.sin(angle),
        ),
        Offset(
          center.dx + rayRadius * math.cos(angle),
          center.dy + rayRadius * math.sin(angle),
        ),
        rayPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ModernCardPainter oldDelegate) {
    return oldDelegate.accentColor != accentColor ||
        oldDelegate.pattern != pattern ||
        oldDelegate.isDark != isDark;
  }
}

/// Reusable clean Modern Card widget with custom painter background
class ModernCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color accentColor;
  final ModernCardPattern pattern;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final double borderRadius;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const ModernCard({
    super.key,
    required this.child,
    this.onTap,
    this.backgroundColor,
    this.accentColor = const Color(0xFF18181B),
    this.pattern = ModernCardPattern.cornerCurves,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.width,
    this.height,
    this.borderRadius = 20,
    this.border,
    this.boxShadow,
  });

  @override
  State<ModernCard> createState() => _ModernCardState();
}

class _ModernCardState extends State<ModernCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? const Color(0xFF1E1E24) : Colors.white;
    final defaultBorder = Border.all(
      color: isDark ? const Color(0xFF2E2E36) : const Color(0xFFF1F1F4),
      width: 1.2,
    );

    return Container(
      margin: widget.margin,
      width: widget.width,
      height: widget.height,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? defaultBg,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: widget.border ?? defaultBorder,
            boxShadow:
                widget.boxShadow ??
                [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                onTapDown: (_) =>
                    widget.onTap != null ? _animController.forward() : null,
                onTapUp: (_) =>
                    widget.onTap != null ? _animController.reverse() : null,
                onTapCancel: () =>
                    widget.onTap != null ? _animController.reverse() : null,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: ModernCardPainter(
                          accentColor: widget.accentColor,
                          pattern: widget.pattern,
                          isDark: isDark,
                        ),
                      ),
                    ),
                    Padding(padding: widget.padding, child: widget.child),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
