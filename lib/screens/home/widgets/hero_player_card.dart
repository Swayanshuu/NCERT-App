import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ncert_books_app/services/gamification_service.dart';
import 'package:ncert_books_app/theme/app_theme.dart';

class HeroPlayerCard extends StatelessWidget {
  final GamificationService gamification;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onClassTap;

  const HeroPlayerCard({
    super.key,
    required this.gamification,
    this.onAvatarTap,
    this.onClassTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = gamification.isDarkMode;
    final totalXp = gamification.xp;
    final xpProgress = (totalXp % 100) / 100.0;
    final streak = gamification.streak;
    final initialLetter = gamification.userName.isNotEmpty
        ? gamification.userName[0].toUpperCase()
        : 'S';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Clean circular monogram avatar (Threads style, no emojis)
                GestureDetector(
                  onTap: onAvatarTap,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? const Color(0xFF242424)
                          : const Color(0xFFF1F1F4),
                      border: Border.all(
                        color: isDark
                            ? AppTheme.darkBorder
                            : AppTheme.lightBorder,
                        width: 1.0,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        initialLetter,
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppTheme.darkTextPrimary
                              : AppTheme.lightTextPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Student Name & Active details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gamification.userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppTheme.darkTextPrimary
                              : AppTheme.lightTextPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Class ${gamification.userClass} • $streak day streak',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Right: Minimal Class Switcher Chip
                if (onClassTap != null)
                  GestureDetector(
                    onTap: onClassTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF222222)
                            : const Color(0xFFF1F1F4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppTheme.darkBorder
                              : AppTheme.lightBorder,
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Class ${gamification.userClass}',
                            style: GoogleFonts.roboto(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppTheme.darkTextPrimary
                                  : AppTheme.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 14,
                            color: isDark
                                ? AppTheme.darkTextSecondary
                                : AppTheme.lightTextSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Minimalist 3px progress indicator
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: xpProgress.clamp(0.0, 1.0),
                minHeight: 3,
                backgroundColor: isDark
                    ? const Color(0xFF242424)
                    : const Color(0xFFE5E7EB),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? Colors.white : const Color(0xFF18181B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
