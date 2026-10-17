import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ncert_books_app/theme/app_theme.dart';
import 'package:ncert_books_app/widgets/hover_builder.dart';

class SubjectWorldCard extends StatelessWidget {
  final String title;
  final String iconEmoji;
  final IconData fallbackIcon;
  final Color themeColor;
  final int bookCount;
  final double progress;
  final VoidCallback onTap;

  const SubjectWorldCard({
    super.key,
    required this.title,
    required this.iconEmoji,
    required this.fallbackIcon,
    required this.themeColor,
    required this.bookCount,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return HoverBuilder(
      onTap: onTap,
      builder: (context, isHovered) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: isDark ? 0.20 : 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                fallbackIcon,
                color: themeColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: GoogleFonts.roboto(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: GoogleFonts.roboto(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 3,
                      backgroundColor: isDark ? const Color(0xFF242424) : const Color(0xFFE5E7EB),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? Colors.white : const Color(0xFF18181B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF222222) : const Color(0xFFF1F1F4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                  width: 0.8,
                ),
              ),
              child: Text(
                '$bookCount Books',
                style: GoogleFonts.roboto(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

