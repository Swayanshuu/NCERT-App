import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AchievementBadgeCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const AchievementBadgeCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.isUnlocked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF181818) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? const Color(0xFF282828) : const Color(0xFFE5E7EB),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? iconColor.withValues(alpha: isDark ? 0.15 : 0.12)
                    : (isDark ? const Color(0xFF222222) : const Color(0xFFF1F5F9)),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isUnlocked
                      ? iconColor.withValues(alpha: 0.3)
                      : (isDark ? const Color(0xFF333333) : const Color(0xFFE2E8F0)),
                  width: 1.0,
                ),
              ),
              child: Center(
                child: Icon(
                  isUnlocked ? icon : Icons.lock_outline_rounded,
                  size: 22,
                  color: isUnlocked
                      ? iconColor
                      : (isDark ? const Color(0xFF666666) : const Color(0xFF94A3B8)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.roboto(
                      fontSize: 11.5,
                      color: isDark ? const Color(0xFF777777) : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? (isDark ? const Color(0xFF222222) : const Color(0xFFF3F4F6))
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isUnlocked ? 'Unlocked' : 'Locked',
                style: GoogleFonts.roboto(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isUnlocked
                      ? (isDark ? const Color(0xFFCCCCCC) : const Color(0xFF374151))
                      : (isDark ? const Color(0xFF555555) : const Color(0xFF9CA3AF)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
