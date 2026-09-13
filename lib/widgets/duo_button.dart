import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oc_liquid_glass/oc_liquid_glass.dart';

class DuoButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final Color color;
  final Color shadowColor;
  final VoidCallback? onPressed;
  final bool fullWidth;

  const DuoButton({
    super.key,
    required this.text,
    this.icon,
    this.color = const Color(0xFF58CC02),
    this.shadowColor = const Color(0xFF46A302),
    this.onPressed,
    this.fullWidth = false,
  });

  @override
  State<DuoButton> createState() => _DuoButtonState();
}

class _DuoButtonState extends State<DuoButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.onPressed == null ? Colors.grey : widget.color;
    final shadowColor = widget.onPressed == null ? Colors.grey.shade700 : widget.shadowColor;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: OCLiquidGlass(
        borderRadius: 16,
        color: baseColor.withValues(alpha: 0.82),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 60),
          width: widget.fullWidth ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          margin: EdgeInsets.only(top: _isPressed ? 4 : 0, bottom: _isPressed ? 0 : 4),
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: shadowColor.withValues(alpha: 0.8),
              width: 2,
            ),
            boxShadow: _isPressed
                ? null
                : [
                    BoxShadow(
                      color: shadowColor.withValues(alpha: 0.5),
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.text.toUpperCase(),
                    style: GoogleFonts.fredoka(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
