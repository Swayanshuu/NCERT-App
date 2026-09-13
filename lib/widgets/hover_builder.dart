import 'package:flutter/material.dart';

class HoverBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, bool isHovered) builder;
  final VoidCallback? onTap;
  final String? tooltip;
  final MouseCursor cursor;
  final double hoverScale;

  const HoverBuilder({
    super.key,
    required this.builder,
    this.onTap,
    this.tooltip,
    this.cursor = SystemMouseCursors.click,
    this.hoverScale = 1.02,
  });

  @override
  State<HoverBuilder> createState() => _HoverBuilderState();
}

class _HoverBuilderState extends State<HoverBuilder> {
  bool _isHovered = false;

  void _onEnter(PointerEvent details) {
    if (!_isHovered) {
      setState(() => _isHovered = true);
    }
  }

  void _onExit(PointerEvent details) {
    if (_isHovered) {
      setState(() => _isHovered = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = MouseRegion(
      cursor: widget.onTap != null ? widget.cursor : MouseCursor.defer,
      onEnter: _onEnter,
      onExit: _onExit,
      child: AnimatedScale(
        scale: _isHovered ? widget.hoverScale : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: GestureDetector(
          onTap: widget.onTap,
          child: widget.builder(context, _isHovered),
        ),
      ),
    );

    if (widget.tooltip != null && widget.tooltip!.isNotEmpty) {
      content = Tooltip(
        message: widget.tooltip!,
        child: content,
      );
    }

    return content;
  }
}
