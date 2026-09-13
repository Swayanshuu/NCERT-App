import 'package:flutter/material.dart';

class ReaderBackgroundPainter extends CustomPainter {
  final String paperMode; // 'day', 'sepia', 'night'

  ReaderBackgroundPainter({required this.paperMode});

  @override
  void paint(Canvas canvas, Size size) {
    Color bg;
    Color accent;

    switch (paperMode) {
      case 'sepia':
        bg = const Color(0xFFFBF0D9);
        accent = const Color(0xFF8C6D46).withValues(alpha: 0.12);
        break;
      case 'night':
        bg = const Color(0xFF0F172A);
        accent = Colors.white.withValues(alpha: 0.06);
        break;
      case 'day':
      default:
        bg = const Color(0xFFF8FAFC);
        accent = const Color(0xFF0F172A).withValues(alpha: 0.05);
        break;
    }

    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = bg);

    final linePaint = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Corner decorative lines
    canvas.drawLine(const Offset(16, 24), const Offset(48, 24), linePaint);
    canvas.drawLine(const Offset(24, 16), const Offset(24, 48), linePaint);

    canvas.drawLine(Offset(size.width - 48, 24), Offset(size.width - 16, 24), linePaint);
    canvas.drawLine(Offset(size.width - 24, 16), Offset(size.width - 24, 48), linePaint);
  }

  @override
  bool shouldRepaint(covariant ReaderBackgroundPainter oldDelegate) => oldDelegate.paperMode != paperMode;
}
