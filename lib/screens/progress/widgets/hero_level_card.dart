import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ncert_books_app/theme/app_theme.dart';
import 'package:ncert_books_app/widgets/liquid/liquid_progress.dart';

class HeroLevelCard extends StatelessWidget {
  final int level;
  final int xp;
  final String levelTitle;
  final int levelProgressXp;
  final int streak;
  final bool canClaimDailyBonus;
  final int hoursUntilNextBonus;
  final VoidCallback onClaimBonus;

  const HeroLevelCard({
    super.key,
    required this.level,
    required this.xp,
    required this.levelTitle,
    required this.levelProgressXp,
    required this.streak,
    required this.canClaimDailyBonus,
    required this.hoursUntilNextBonus,
    required this.onClaimBonus,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final xpProgress = (levelProgressXp.clamp(0, 100)) / 100.0;

    return Column(
      children: [
        // Level & Progress Ring Box
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF181818) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark ? const Color(0xFF282828) : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            children: [
              LiquidProgressRing(
                progress: xpProgress,
                size: 78,
                strokeWidth: 8,
                color: AppTheme.accentAmber,
                centerChild: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Lvl $level',
                      style: GoogleFonts.roboto(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.accentAmber,
                      ),
                    ),
                    Text(
                      '$xp XP',
                      style: GoogleFonts.roboto(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF777777) : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      levelTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.roboto(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${100 - levelProgressXp} XP to Level ${level + 1}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: isDark ? const Color(0xFF777777) : const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 10),
                    LiquidProgressBar(
                      progress: xpProgress,
                      height: 6,
                      color: AppTheme.accentAmber,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Quick Stats: Streak & Daily Reward
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF181818) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? const Color(0xFF282828) : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF97316).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.local_fire_department_rounded,
                          color: Color(0xFFF97316),
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$streak Days',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.roboto(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF111827),
                            ),
                          ),
                          Text(
                            'Reading Streak',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.roboto(
                              fontSize: 11,
                              color: isDark ? const Color(0xFF777777) : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: onClaimBonus,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF181818) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark ? const Color(0xFF282828) : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.card_giftcard_rounded,
                            color: Color(0xFFF59E0B),
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              canClaimDailyBonus ? 'Claim Chest' : 'Claimed',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: canClaimDailyBonus
                                    ? AppTheme.accentAmber
                                    : (isDark ? const Color(0xFF999999) : const Color(0xFF6B7280)),
                              ),
                            ),
                            Text(
                              canClaimDailyBonus ? '+50 XP' : 'In ${hoursUntilNextBonus}h',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.roboto(
                                fontSize: 11,
                                color: isDark ? const Color(0xFF777777) : const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
