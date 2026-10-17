import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:ncert_books_app/theme/app_theme.dart';

class SubjectChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const SubjectChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subjectColor = label == 'All' ? const Color(0xFF18181B) : AppTheme.getSubjectColor(label);

    final chipBg = isSelected
        ? (isDark ? Colors.white : const Color(0xFF18181B))
        : (isDark ? const Color(0xFF1E222A) : const Color(0xFFF3F4F6));

    final chipText = isSelected
        ? (isDark ? const Color(0xFF18181B) : Colors.white)
        : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF374151));

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: chipBg,
              borderRadius: BorderRadius.circular(20),
              border: isSelected
                  ? null
                  : Border.all(
                      color: isDark ? const Color(0xFF2E3544) : const Color(0xFFE5E7EB),
                      width: 1.0,
                    ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (label != 'All') ...[
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: isSelected ? chipText : subjectColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                AutoSizeText(
                  label,
                  maxLines: 1,
                  minFontSize: 10,
                  style: GoogleFonts.roboto(
                    color: chipText,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 12.5,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
