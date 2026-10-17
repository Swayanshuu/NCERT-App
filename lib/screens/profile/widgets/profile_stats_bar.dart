import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileStatsBar extends StatelessWidget {
  final int xp;
  final int streak;
  final int favoritesCount;

  const ProfileStatsBar({
    super.key,
    required this.xp,
    required this.streak,
    required this.favoritesCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final stats = [
      {
        'label': 'Total XP',
        'value': '$xp',
        'icon': Icons.stars_rounded,
        'iconColor': const Color(0xFFF59E0B),
      },
      {
        'label': 'Streak',
        'value': '${streak}d',
        'icon': Icons.local_fire_department_rounded,
        'iconColor': const Color(0xFFF97316),
      },
      {
        'label': 'Favorites',
        'value': '$favoritesCount',
        'icon': Icons.favorite_rounded,
        'iconColor': const Color(0xFFEF4444),
      },
    ];

    return Row(
      children: stats.map((s) {
        final icon = s['icon'] as IconData;
        final iconColor = s['iconColor'] as Color;
        final value = s['value'] as String;
        final label = s['label'] as String;

        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF181818) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF282828) : const Color(0xFFE5E7EB),
                width: 1.0,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: iconColor, size: 16),
                    const SizedBox(width: 4),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          value,
                          maxLines: 1,
                          style: GoogleFonts.roboto(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF111827),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.roboto(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? const Color(0xFF777777) : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
