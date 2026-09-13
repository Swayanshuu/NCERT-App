import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ncert_books_app/theme/app_theme.dart';
import 'package:ncert_books_app/widgets/painters/gamification_painters.dart';
import 'package:ncert_books_app/widgets/hover_builder.dart';

class AchievementBadgeCard extends StatelessWidget {
  final String title;
  final String description;
  final String emoji;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const AchievementBadgeCard({
    super.key,
    required this.title,
    required this.description,
    required this.emoji,
    required this.isUnlocked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final badgeColor = isUnlocked ? AppTheme.sunshineGold : Colors.grey;

    return HoverBuilder(
      onTap: onTap,
      builder: (context, isHovered) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: isUnlocked
                ? [
                    AppTheme.sunshineGold.withValues(alpha: isDark ? 0.25 : 0.15),
                    AppTheme.energyOrange.withValues(alpha: isDark ? 0.15 : 0.08),
                  ]
                : [
                    isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                    isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.01),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: isUnlocked
                ? AppTheme.sunshineGold.withValues(alpha: isHovered ? 0.8 : 0.5)
                : (isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
            width: isUnlocked ? 1.8 : 1.0,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: AppTheme.sunshineGold.withValues(alpha: isHovered ? 0.3 : 0.12),
                    blurRadius: isHovered ? 14 : 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            if (isUnlocked)
              Positioned.fill(
                child: CustomPaint(
                  painter: StarburstPainter(color: AppTheme.sunshineGold),
                ),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? AppTheme.sunshineGold.withValues(alpha: 0.2)
                        : (isDark ? Colors.white10 : Colors.black12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: badgeColor.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      isUnlocked ? emoji : '🔒',
                      style: TextStyle(fontSize: isUnlocked ? 26 : 20),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked
                        ? (isDark ? Colors.white : const Color(0xFF0F172A))
                        : (isDark ? Colors.white38 : const Color(0xFF94A3B8)),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: isUnlocked
                        ? (isDark ? Colors.white70 : const Color(0xFF64748B))
                        : (isDark ? Colors.white24 : const Color(0xFFCBD5E1)),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
