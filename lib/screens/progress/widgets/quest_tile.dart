import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuestTile extends StatelessWidget {
  final String title;
  final String description;
  final int xp;
  final bool isCompleted;
  final IconData icon;
  final Color iconColor;

  const QuestTile({
    super.key,
    required this.title,
    required this.description,
    required this.xp,
    required this.isCompleted,
    this.icon = Icons.stars_rounded,
    this.iconColor = const Color(0xFFF59E0B),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFF10B981).withValues(alpha: 0.15)
                  : iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                isCompleted ? Icons.check_circle_rounded : icon,
                size: 20,
                color: isCompleted ? const Color(0xFF10B981) : iconColor,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  maxLines: 2,
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFF10B981)
                  : (isDark ? const Color(0xFF222222) : const Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isCompleted ? 'Done' : '+$xp XP',
              style: GoogleFonts.roboto(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isCompleted
                    ? Colors.white
                    : (isDark ? const Color(0xFFCCCCCC) : const Color(0xFF374151)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
