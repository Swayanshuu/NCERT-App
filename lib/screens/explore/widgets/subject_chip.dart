import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:oc_liquid_glass/oc_liquid_glass.dart';
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

  IconData _getSubjectIcon(String name) {
    final s = name.toLowerCase();
    if (s == 'all') return Icons.auto_awesome_rounded;
    if (s.contains('math')) return Icons.calculate_rounded;
    if (s.contains('scien') || s.contains('phys') || s.contains('chem') || s.contains('bio')) return Icons.science_rounded;
    if (s.contains('hist') || s.contains('geo') || s.contains('civic') || s.contains('polit') || s.contains('soci') || s.contains('econ')) return Icons.public_rounded;
    if (s.contains('eng')) return Icons.menu_book_rounded;
    if (s.contains('hind') || s.contains('sansk') || s.contains('urdu')) return Icons.translate_rounded;
    return Icons.auto_stories_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = label == 'All' ? AppTheme.duoGreen : AppTheme.getSubjectColor(label);
    final shadowColor = label == 'All' ? AppTheme.duoGreenShadow : AppTheme.getSubjectShadow(label);
    final iconData = _getSubjectIcon(label);

    final unselectedTextColor = isDark
        ? (baseColor == AppTheme.duoYellow ? const Color(0xFFFBBF24) : baseColor)
        : (baseColor == AppTheme.duoYellow ? const Color(0xFFD97706) : baseColor);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: OCLiquidGlass(
            height: 38,
            borderRadius: 22,
            color: isSelected
                ? baseColor.withValues(alpha: 0.95)
                : baseColor.withValues(alpha: isDark ? 0.16 : 0.10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          baseColor,
                          shadowColor,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : null,
                border: Border.all(
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: shadowColor.withValues(alpha: 0.40),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    iconData,
                    size: 16,
                    color: isSelected ? Colors.white : unselectedTextColor,
                  ),
                  const SizedBox(width: 6),
                  AutoSizeText(
                    label.toUpperCase(),
                    maxLines: 1,
                    minFontSize: 9,
                    style: GoogleFonts.fredoka(
                      color: isSelected ? Colors.white : unselectedTextColor,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 12.5,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
