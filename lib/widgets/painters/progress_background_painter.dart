import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ProgressBackgroundPainter extends CustomPainter {
  final bool isDark;

  ProgressBackgroundPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Base Gradient
    final rect = Offset.zero & size;
    final bgGradient = RadialGradient(
      center: Alignment.topCenter,
      radius: 1.2,
      colors: [
        AppTheme.accentAmber.withValues(alpha: isDark ? 0.15 : 0.10),
        AppTheme.primaryTeal.withValues(alpha: isDark ? 0.08 : 0.04),
        Colors.transparent,
      ],
    );
    canvas.drawRect(rect, Paint()..shader = bgGradient.createShader(rect));

    // 2. Constellation Lines and Star Nodes
    final nodeColor = isDark
        ? Colors.white.withValues(alpha: 0.18)
        : AppTheme.accentAmber.withValues(alpha: 0.35);

    final linePaint = Paint()
      ..color = nodeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final nodes = [
      Offset(size.width * 0.15, size.height * 0.18),
      Offset(size.width * 0.45, size.height * 0.28),
      Offset(size.width * 0.80, size.height * 0.15),
      Offset(size.width * 0.88, size.height * 0.45),
      Offset(size.width * 0.50, size.height * 0.58),
      Offset(size.width * 0.20, size.height * 0.72),
      Offset(size.width * 0.75, size.height * 0.82),
    ];

    final path = Path();
    path.moveTo(nodes[0].dx, nodes[0].dy);
    for (int i = 1; i < nodes.length; i++) {
      path.lineTo(nodes[i].dx, nodes[i].dy);
    }
    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()..color = isDark ? AppTheme.accentAmber : AppTheme.accentAmberDark;
    for (final node in nodes) {
      canvas.drawCircle(node, 4, dotPaint);
      canvas.drawCircle(node, 8, Paint()..color = dotPaint.color.withValues(alpha: 0.25)..style = PaintingStyle.stroke..strokeWidth = 1.5);
    }
  }

  @override
  bool shouldRepaint(covariant ProgressBackgroundPainter oldDelegate) => oldDelegate.isDark != isDark;
}
