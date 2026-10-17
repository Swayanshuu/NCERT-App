import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modern clean button replacement for the old Duolingo-style 3D button.
/// Features smooth tactile micro-interaction, clean geometry, and modern typography.
class DuoButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final Color color;
  final Color? textColor;
  final Color shadowColor;
  final VoidCallback? onPressed;
  final bool fullWidth;
  final double borderRadius;
  final EdgeInsets padding;
  final bool isSecondary;

  const DuoButton({
    super.key,
    required this.text,
    this.icon,
    this.color = const Color(0xFF18181B), // Modern charcoal / black as default
    this.textColor,
    this.shadowColor = Colors.transparent,
    this.onPressed,
    this.fullWidth = false,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    this.isSecondary = false,
  });

  @override
  State<DuoButton> createState() => _DuoButtonState();
}

class _DuoButtonState extends State<DuoButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = widget.onPressed != null;

    final effectiveColor = !isEnabled
        ? (isDark ? const Color(0xFF282D39) : const Color(0xFFE5E7EB))
        : (widget.isSecondary
            ? (isDark ? const Color(0xFF1A1D24) : const Color(0xFFF3F4F6))
            : widget.color);

    final effectiveTextColor = !isEnabled
        ? (isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF))
        : (widget.textColor ??
            (widget.isSecondary
                ? (isDark ? Colors.white : const Color(0xFF111827))
                : (effectiveColor.computeLuminance() > 0.55 ? const Color(0xFF111827) : Colors.white)));

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled
          ? (_) {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.fullWidth ? double.infinity : null,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: effectiveColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: widget.isSecondary
                ? Border.all(
                    color: isDark ? const Color(0xFF282D39) : const Color(0xFFE5E7EB),
                    width: 1.0,
                  )
                : null,
            boxShadow: isEnabled && !widget.isSecondary
                ? [
                    BoxShadow(
                      color: effectiveColor.withValues(alpha: 0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  color: effectiveTextColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  widget.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.roboto(
                    color: effectiveTextColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                    letterSpacing: -0.2,
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
