import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ncert_books_app/theme/app_theme.dart';
import 'package:ncert_books_app/widgets/glass/glass_card.dart';
import 'package:ncert_books_app/widgets/painters/gamification_painters.dart';

class LearningJourneyWidget extends StatelessWidget {
  final String bookTitle;
  final int currentChapter;
  final int totalChapters;
  final Function(int chapterIndex)? onChapterTap;

  const LearningJourneyWidget({
    super.key,
    required this.bookTitle,
    required this.currentChapter,
    required this.totalChapters,
    this.onChapterTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      borderRadius: 28,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.royalPurple.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.alt_route_rounded, color: AppTheme.royalPurple, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LEARNING JOURNEY',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      bookTitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : const Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: LearningJourneyPathPainter(
                      pathColor: AppTheme.royalPurple,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(3, (index) {
                    final chNum = index + 1;
                    final isCompleted = chNum < currentChapter;
                    final isCurrent = chNum == currentChapter;

                    Color nodeColor = Colors.grey.shade400;
                    IconData icon = Icons.lock_rounded;
                    String label = 'Locked';

                    if (isCompleted) {
                      nodeColor = AppTheme.emeraldMint;
                      icon = Icons.star_rounded;
                      label = 'Done';
                    } else if (isCurrent) {
                      nodeColor = AppTheme.sunshineGold;
                      icon = Icons.play_arrow_rounded;
                      label = 'Current';
                    }

                    return GestureDetector(
                      onTap: () => onChapterTap?.call(chNum),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: isCurrent ? 52 : 44,
                            height: isCurrent ? 52 : 44,
                            decoration: BoxDecoration(
                              color: nodeColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: nodeColor.withValues(alpha: 0.4),
                                  blurRadius: isCurrent ? 14 : 6,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white,
                                width: isCurrent ? 3 : 2,
                              ),
                            ),
                            child: Icon(
                              icon,
                              color: Colors.white,
                              size: isCurrent ? 26 : 20,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: nodeColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Ch $chNum • $label',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: nodeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
