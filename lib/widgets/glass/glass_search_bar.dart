import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GlassSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final String hintText;
  final bool isDark;

  const GlassSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onClear,
    this.hintText = 'Search notes...',
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181818) : const Color(0xFFF1F1F4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF282828) : const Color(0xFFE5E7EB),
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: isDark ? const Color(0xFF777777) : const Color(0xFF6B7280),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: GoogleFonts.roboto(
                  color: isDark ? const Color(0xFF777777) : const Color(0xFF9CA3AF),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: GoogleFonts.roboto(
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : const Color(0xFF111827),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
                onChanged('');
                onClear?.call();
              },
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  Icons.close_rounded,
                  color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
