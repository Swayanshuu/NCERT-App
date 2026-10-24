import 'dart:math' as math;
import 'package:flutter/material.dart';

enum BentoWatermarkType {
  book,
  atom,
  globe,
  columns,
  checklist,
  diploma,
  mathSymbols,
}

class BentoWatermarkPainter extends CustomPainter {
  final BentoWatermarkType type;
  final Color tintColor;
  final double opacity;

  const BentoWatermarkPainter({
    required this.type,
    required this.tintColor,
    this.opacity = 0.08,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final effectiveColor = tintColor.withValues(alpha: opacity.clamp(0.0, 1.0));
    final fillPaint = Paint()
      ..color = effectiveColor
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = effectiveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    switch (type) {
      case BentoWatermarkType.book:
        _paintTiltedBook(canvas, size, fillPaint, strokePaint);
        break;
      case BentoWatermarkType.columns:
        _paintColumns(canvas, size, fillPaint);
        break;
      case BentoWatermarkType.atom:
        _paintAtom(canvas, size, strokePaint, fillPaint);
        break;
      case BentoWatermarkType.globe:
        _paintGlobe(canvas, size, strokePaint);
        break;
      case BentoWatermarkType.checklist:
        _paintChecklist(canvas, size, strokePaint, fillPaint);
        break;
      case BentoWatermarkType.diploma:
        _paintDiploma(canvas, size, strokePaint, fillPaint);
        break;
      case BentoWatermarkType.mathSymbols:
        _paintMath(canvas, size, strokePaint, fillPaint);
        break;
    }
  }

  /// Paints a large, sleek tilted open book watermark matching the hero card in reference
  void _paintTiltedBook(
    Canvas canvas,
    Size size,
    Paint fillPaint,
    Paint strokePaint,
  ) {
    canvas.save();
    // Position on right-center with an energetic upward tilt (~ -16 deg)
    canvas.translate(size.width * 0.62, size.height * 0.44);
    canvas.rotate(-math.pi / 11);

    const double bookW = 100.0;
    const double bookH = 75.0;
    const double spineCurve = 9.0;

    // Left Page
    final leftPage = Path()
      ..moveTo(0, 0)
      ..cubicTo(-bookW * 0.4, -spineCurve, -bookW * 0.8, spineCurve * 0.5, -bookW, -spineCurve)
      ..lineTo(-bookW, bookH - spineCurve)
      ..cubicTo(-bookW * 0.8, bookH + spineCurve * 0.5, -bookW * 0.4, bookH - spineCurve, 0, bookH)
      ..close();

    // Right Page
    final rightPage = Path()
      ..moveTo(0, 0)
      ..cubicTo(bookW * 0.4, -spineCurve, bookW * 0.8, spineCurve * 0.5, bookW, -spineCurve)
      ..lineTo(bookW, bookH - spineCurve)
      ..cubicTo(bookW * 0.8, bookH + spineCurve * 0.5, bookW * 0.4, bookH - spineCurve, 0, bookH)
      ..close();

    canvas.drawPath(leftPage, fillPaint);
    canvas.drawPath(rightPage, fillPaint);

    // Subtle outline and spine line
    final thinStroke = Paint()
      ..color = strokePaint.color.withValues(alpha: (strokePaint.color.a * 1.5).clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    canvas.drawPath(leftPage, thinStroke);
    canvas.drawPath(rightPage, thinStroke);
    canvas.drawLine(const Offset(0, -2), const Offset(0, bookH + 2), thinStroke);

    canvas.restore();
  }

  /// Paints 3 vertical column bars matching the "Timetable" card in reference
  void _paintColumns(Canvas canvas, Size size, Paint fillPaint) {
    canvas.save();
    canvas.translate(size.width * 0.72, size.height * 0.20);

    const double colW = 18.0;
    const double colH = 68.0;
    const double gap = 9.0;
    const double radius = 6.0;

    for (int i = 0; i < 3; i++) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(i * (colW + gap), i == 1 ? -6 : 0, colW, colH),
        const Radius.circular(radius),
      );
      canvas.drawRRect(rect, fillPaint);
    }
    canvas.restore();
  }

  /// Paints atomic orbit ellipses for Science/Physics
  void _paintAtom(
    Canvas canvas,
    Size size,
    Paint strokePaint,
    Paint fillPaint,
  ) {
    canvas.save();
    final center = Offset(size.width * 0.82, size.height * 0.48);
    canvas.translate(center.dx, center.dy);

    // Center nucleus dot
    canvas.drawCircle(Offset.zero, 6.0, fillPaint);

    // 3 Orbiting ellipses
    for (double angle in [0.0, math.pi / 3, 2 * math.pi / 3]) {
      canvas.save();
      canvas.rotate(angle);
      final bounds = Rect.fromCenter(center: Offset.zero, width: 56, height: 22);
      canvas.drawOval(bounds, strokePaint);
      canvas.restore();
    }
    canvas.restore();
  }

  /// Paints latitude & longitude globe arcs for Social Science
  void _paintGlobe(Canvas canvas, Size size, Paint strokePaint) {
    canvas.save();
    final center = Offset(size.width * 0.80, size.height * 0.50);
    const radius = 28.0;

    // Outer circle
    canvas.drawCircle(center, radius, strokePaint);

    // Horizontal equator line
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      strokePaint,
    );

    // Vertical meridian ellipse
    final oval = Rect.fromCenter(center: center, width: radius * 1.1, height: radius * 2.0);
    canvas.drawOval(oval, strokePaint);
    canvas.restore();
  }

  /// Paints checklist document with checkmark for Practice / Biology / Attendance
  void _paintChecklist(
    Canvas canvas,
    Size size,
    Paint strokePaint,
    Paint fillPaint,
  ) {
    canvas.save();
    canvas.translate(size.width * 0.70, size.height * 0.28);

    const rectW = 34.0;
    const rectH = 46.0;
    final docRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, rectW, rectH),
      const Radius.circular(6),
    );
    canvas.drawRRect(docRect, fillPaint);
    canvas.drawRRect(docRect, strokePaint);

    // Checkmark
    final checkPath = Path()
      ..moveTo(8, 16)
      ..lineTo(14, 22)
      ..lineTo(26, 10);
    canvas.drawPath(checkPath, strokePaint..strokeWidth = 2.2);

    // Document lines
    canvas.drawLine(const Offset(8, 28), const Offset(26, 28), strokePaint..strokeWidth = 1.6);
    canvas.drawLine(const Offset(8, 36), const Offset(20, 36), strokePaint..strokeWidth = 1.6);
    canvas.restore();
  }

  /// Paints diploma scroll / calendar grid matching Fees / Calendar in reference
  void _paintDiploma(
    Canvas canvas,
    Size size,
    Paint strokePaint,
    Paint fillPaint,
  ) {
    canvas.save();
    canvas.translate(size.width * 0.68, size.height * 0.25);

    const double cardW = 38.0;
    const double cardH = 46.0;
    final rrect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, cardW, cardH),
      const Radius.circular(7),
    );
    canvas.drawRRect(rrect, fillPaint);
    canvas.drawRRect(rrect, strokePaint);

    // Calendar header bar
    final headerRect = RRect.fromRectAndCorners(
      const Rect.fromLTWH(0, 0, cardW, 12),
      topLeft: const Radius.circular(7),
      topRight: const Radius.circular(7),
    );
    canvas.drawRRect(
      headerRect,
      Paint()..color = strokePaint.color.withValues(alpha: 0.25),
    );

    // 4 mini calendar day grid dots/squares
    for (int r = 0; r < 2; r++) {
      for (int c = 0; c < 3; c++) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(7.0 + c * 9.0, 18.0 + r * 10.0, 6.0, 6.0),
            const Radius.circular(1.5),
          ),
          fillPaint,
        );
      }
    }
    canvas.restore();
  }

  /// Paints math symbols grid (+, -, ×, ÷)
  void _paintMath(
    Canvas canvas,
    Size size,
    Paint strokePaint,
    Paint fillPaint,
  ) {
    canvas.save();
    canvas.translate(size.width * 0.72, size.height * 0.30);

    const double box = 42.0;
    final boxRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, box, box),
      const Radius.circular(8),
    );
    canvas.drawRRect(boxRect, fillPaint);
    canvas.drawRRect(boxRect, strokePaint);

    // + symbol (top left)
    canvas.drawLine(const Offset(6, 12), const Offset(16, 12), strokePaint);
    canvas.drawLine(const Offset(11, 7), const Offset(11, 17), strokePaint);

    // - symbol (top right)
    canvas.drawLine(const Offset(24, 12), const Offset(34, 12), strokePaint);

    // × symbol (bottom left)
    canvas.drawLine(const Offset(7, 27), const Offset(15, 35), strokePaint);
    canvas.drawLine(const Offset(15, 27), const Offset(7, 35), strokePaint);

    // ÷ or = symbol (bottom right)
    canvas.drawLine(const Offset(24, 28), const Offset(34, 28), strokePaint);
    canvas.drawLine(const Offset(24, 34), const Offset(34, 34), strokePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant BentoWatermarkPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.tintColor != tintColor ||
        oldDelegate.opacity != opacity;
  }
}
