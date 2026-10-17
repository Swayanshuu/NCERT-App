import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ncert_books_app/theme/app_theme.dart';

class SubjectCard extends StatelessWidget {
  final String subjectName;
  final int bookCount;
  final bool isDark;
  final VoidCallback onTap;

  const SubjectCard({
    super.key,
    required this.subjectName,
    required this.bookCount,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icon = AppTheme.getSubjectIcon(subjectName);
    final subjectColor = AppTheme.getSubjectColor(subjectName);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.05),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF181818) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF282828) : const Color(0xFFE5E7EB),
              width: 1.0,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: subjectColor.withValues(alpha: isDark ? 0.18 : 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: subjectColor,
                      size: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF222222) : const Color(0xFFF1F1F4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? const Color(0xFF282828) : const Color(0xFFE5E7EB),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      '$bookCount Books',
                      style: GoogleFonts.roboto(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF777777) : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          subjectName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: isDark ? Colors.white : const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'NCERT Textbooks',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.roboto(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: isDark ? const Color(0xFF777777) : const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF222222) : const Color(0xFFF1F1F4),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? const Color(0xFF282828) : const Color(0xFFE5E7EB),
                        width: 0.8,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 11,
                      color: isDark ? Colors.white : const Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
