import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class MascotOwlCanvas extends StatelessWidget {
  final double size;

  const MascotOwlCanvas({super.key, this.size = 64.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: MascotOwlPainter(),
      ),
    );
  }
}

class MascotOwlPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Body Fill Gradient
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppTheme.primaryTeal, AppTheme.primaryTealDark],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius * 0.9, bodyPaint);

    // Cute Belly Oval
    final bellyPaint = Paint()..color = const Color(0xFFE2F7C2);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 0.25),
        width: radius * 1.1,
        height: radius * 0.9,
      ),
      bellyPaint,
    );

    // Big Eyes Glasses Frames
    final eyeRadius = radius * 0.28;
    final leftEyeCenter = Offset(center.dx - radius * 0.32, center.dy - radius * 0.12);
    final rightEyeCenter = Offset(center.dx + radius * 0.32, center.dy - radius * 0.12);

    // White Eye Balls
    final eyeWhitePaint = Paint()..color = Colors.white;
    canvas.drawCircle(leftEyeCenter, eyeRadius, eyeWhitePaint);
    canvas.drawCircle(rightEyeCenter, eyeRadius, eyeWhitePaint);

    // Black Pupils with White Sparkle
    final pupilPaint = Paint()..color = const Color(0xFF2B3D47);
    final pupilRadius = eyeRadius * 0.55;
    canvas.drawCircle(leftEyeCenter, pupilRadius, pupilPaint);
    canvas.drawCircle(rightEyeCenter, pupilRadius, pupilPaint);

    final sparklePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(leftEyeCenter.dx + 2, leftEyeCenter.dy - 2), 2.5, sparklePaint);
    canvas.drawCircle(Offset(rightEyeCenter.dx + 2, rightEyeCenter.dy - 2), 2.5, sparklePaint);

    // Glasses Frame Rings
    final glassesPaint = Paint()
      ..color = AppTheme.duoYellowShadow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawCircle(leftEyeCenter, eyeRadius + 1, glassesPaint);
    canvas.drawCircle(rightEyeCenter, eyeRadius + 1, glassesPaint);
    canvas.drawLine(
      Offset(leftEyeCenter.dx + eyeRadius, leftEyeCenter.dy),
      Offset(rightEyeCenter.dx - eyeRadius, rightEyeCenter.dy),
      glassesPaint..strokeWidth = 3.5,
    );

    // Orange Beak Triangle
    final beakPath = Path();
    beakPath.moveTo(center.dx - 6, center.dy + 6);
    beakPath.lineTo(center.dx + 6, center.dy + 6);
    beakPath.lineTo(center.dx, center.dy + 18);
    beakPath.close();

    canvas.drawPath(beakPath, Paint()..color = AppTheme.duoOrange);

    // Graduation Cap / Smart Hat on top
    final capPath = Path();
    capPath.moveTo(center.dx, center.dy - radius * 0.95);
    capPath.lineTo(center.dx + radius * 0.65, center.dy - radius * 0.70);
    capPath.lineTo(center.dx, center.dy - radius * 0.45);
    capPath.lineTo(center.dx - radius * 0.65, center.dy - radius * 0.70);
    capPath.close();

    canvas.drawPath(capPath, Paint()..color = const Color(0xFF1C2833));
    canvas.drawPath(capPath, Paint()..color = AppTheme.duoPurple.withValues(alpha: 0.8));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
