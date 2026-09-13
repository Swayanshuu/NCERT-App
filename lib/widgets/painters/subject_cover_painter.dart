import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class SubjectCoverArt extends StatelessWidget {
  final String subject;
  final double height;
  final double width;
  final bool isDark;

  const SubjectCoverArt({
    super.key,
    required this.subject,
    this.height = 70.0,
    this.width = double.infinity,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getSubjectColor(subject);
    final shadowColor = AppTheme.getSubjectShadow(subject);
    final icon = AppTheme.getSubjectIcon(subject);

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: isDark ? 0.70 : 0.95),
            shadowColor.withValues(alpha: isDark ? 0.90 : 1.0),
            Color.alphaBlend(color.withValues(alpha: 0.6), shadowColor),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: isDark ? 0.4 : 0.45),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Custom Painter Vector Canvas
            Positioned.fill(
              child: CustomPaint(
                painter: SubjectCoverPainter(
                  subject: subject,
                  primaryColor: color,
                  secondaryColor: shadowColor,
                  isDark: isDark,
                ),
              ),
            ),

            // Glossy 3D Reflection Highlight
            Positioned(
              top: -24,
              left: -24,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.18),
                ),
              ),
            ),

            // Bottom-Left Floating Subject Pill Badge
            Positioned(
              bottom: 6,
              left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      subject.toUpperCase(),
                      style: GoogleFonts.fredoka(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SubjectCoverPainter extends CustomPainter {
  final String subject;
  final Color primaryColor;
  final Color secondaryColor;
  final bool isDark;

  SubjectCoverPainter({
    required this.subject,
    required this.primaryColor,
    required this.secondaryColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Paint Right-Aligned Glowing Radial Orb
    final topRightCenter = Offset(size.width * 0.90, size.height * 0.30);
    final glowPaint1 = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.35),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: topRightCenter, radius: size.width * 0.45));
    canvas.drawCircle(topRightCenter, size.width * 0.45, glowPaint1);

    // 2. Right-Aligned Particle Dots
    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.35);
    canvas.drawCircle(Offset(size.width * 0.78, size.height * 0.20), 3.0, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.92, size.height * 0.75), 3.5, dotPaint);

    final s = subject.toLowerCase();

    if (s.contains('math')) {
      _paintMath(canvas, size);
    } else if (s.contains('sci') || s.contains('evs') || s.contains('phys') || s.contains('chem') || s.contains('bio')) {
      _paintScience(canvas, size);
    } else if (s.contains('eng') || s.contains('hin') || s.contains('san') || s.contains('urd')) {
      _paintLanguage(canvas, size);
    } else if (s.contains('soc') || s.contains('his') || s.contains('geo') || s.contains('civ') || s.contains('eco')) {
      _paintSocial(canvas, size);
    } else {
      _paintGeneric(canvas, size);
    }
  }

  void _paintMath(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Right-Aligned Geometry Circles
    canvas.drawCircle(Offset(size.width * 0.88, size.height * 0.45), 34, strokePaint);
    canvas.drawCircle(Offset(size.width * 0.88, size.height * 0.45), 20, strokePaint);

    // Right-Aligned Wave Line
    final wavePath = Path();
    wavePath.moveTo(size.width * 0.65, size.height * 0.65);
    for (double x = size.width * 0.65; x <= size.width; x += 4) {
      final y = size.height * 0.65 + math.sin(x * 0.08) * 12;
      wavePath.lineTo(x, y);
    }
    canvas.drawPath(wavePath, strokePaint);

    // Right-Aligned Symbols
    _drawSymbol(canvas, 'π', Offset(size.width * 0.82, size.height * 0.30), 18);
    _drawSymbol(canvas, '∑', Offset(size.width * 0.93, size.height * 0.70), 18);
    _drawSymbol(canvas, '+', Offset(size.width * 0.76, size.height * 0.75), 16);
  }

  void _paintScience(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.38)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final center = Offset(size.width * 0.86, size.height * 0.48);

    // Right-Aligned Atomic Orbital Loops
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 60, height: 24), strokePaint);

    canvas.rotate(math.pi / 3);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 60, height: 24), strokePaint);

    canvas.rotate(math.pi / 3);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 60, height: 24), strokePaint);
    canvas.restore();

    // Nucleus Core
    canvas.drawCircle(center, 6, Paint()..color = Colors.white.withValues(alpha: 0.85));

    // Molecule Nodes on Right
    final c1 = Offset(size.width * 0.72, size.height * 0.30);
    final c2 = Offset(size.width * 0.76, size.height * 0.75);
    canvas.drawLine(c1, c2, strokePaint..strokeWidth = 1.8);
    canvas.drawCircle(c1, 8, Paint()..color = Colors.white.withValues(alpha: 0.30));
    canvas.drawCircle(c2, 10, Paint()..color = Colors.white.withValues(alpha: 0.35));
  }

  void _paintLanguage(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
      ..style = PaintingStyle.fill;

    // Right-Aligned Open Book Contour
    final pagePath = Path();
    pagePath.moveTo(size.width * 0.72, size.height * 0.18);
    pagePath.quadraticBezierTo(size.width * 0.84, size.height * 0.08, size.width * 0.96, size.height * 0.18);
    pagePath.lineTo(size.width * 0.96, size.height * 0.82);
    pagePath.quadraticBezierTo(size.width * 0.84, size.height * 0.72, size.width * 0.72, size.height * 0.82);
    pagePath.close();

    canvas.drawPath(pagePath, fillPaint);
    canvas.drawPath(
      pagePath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    _drawSymbol(canvas, 'A', Offset(size.width * 0.80, size.height * 0.40), 16);
    _drawSymbol(canvas, 'अ', Offset(size.width * 0.90, size.height * 0.40), 15);
  }

  void _paintSocial(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Right-Aligned Globe Grid
    final globeCenter = Offset(size.width * 0.86, size.height * 0.48);
    final radius = size.height * 0.38;

    canvas.drawCircle(globeCenter, radius, strokePaint);
    canvas.drawOval(Rect.fromCenter(center: globeCenter, width: radius * 1.8, height: radius * 0.8), strokePaint);
    canvas.drawLine(Offset(globeCenter.dx - radius, globeCenter.dy), Offset(globeCenter.dx + radius, globeCenter.dy), strokePaint);

    // Compass Rose Star
    final starCenter = Offset(size.width * 0.74, size.height * 0.45);
    final starPath = Path();
    starPath.moveTo(starCenter.dx, starCenter.dy - 12);
    starPath.lineTo(starCenter.dx + 4, starCenter.dy - 4);
    starPath.lineTo(starCenter.dx + 12, starCenter.dy);
    starPath.lineTo(starCenter.dx + 4, starCenter.dy + 4);
    starPath.lineTo(starCenter.dx, starCenter.dy + 12);
    starPath.lineTo(starCenter.dx - 4, starCenter.dy + 4);
    starPath.lineTo(starCenter.dx - 12, starCenter.dy);
    starPath.lineTo(starCenter.dx - 4, starCenter.dy - 4);
    starPath.close();

    canvas.drawPath(starPath, Paint()..color = Colors.white.withValues(alpha: 0.35));
  }

  void _paintGeneric(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(Offset(size.width * 0.86, size.height * 0.4), 28, strokePaint);
  }

  void _drawSymbol(Canvas canvas, String symbol, Offset offset, double fontSize) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: symbol,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.75),
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.30),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(offset.dx - textPainter.width / 2, offset.dy - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant SubjectCoverPainter oldDelegate) {
    return oldDelegate.subject != subject ||
        oldDelegate.isDark != isDark ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor;
  }
}
