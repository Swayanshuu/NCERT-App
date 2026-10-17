import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ncert_books_app/services/gamification_service.dart';
import 'package:ncert_books_app/theme/app_theme.dart';
import 'package:ncert_books_app/widgets/custom_snack_bar.dart';

import 'package:ncert_books_app/widgets/painters/modern_card_painter.dart';

class DailyMissionCard extends StatefulWidget {
  final GamificationService gamification;
  final VoidCallback? onMissionCompleted;

  const DailyMissionCard({
    super.key,
    required this.gamification,
    this.onMissionCompleted,
  });

  @override
  State<DailyMissionCard> createState() => _DailyMissionCardState();
}

class _DailyMissionCardState extends State<DailyMissionCard> {
  @override
  void initState() {
    super.initState();
    widget.gamification.addListener(_onGamificationStateChanged);
  }

  @override
  void dispose() {
    widget.gamification.removeListener(_onGamificationStateChanged);
    super.dispose();
  }

  void _onGamificationStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.gamification.isDarkMode;
    final quests = widget.gamification.dailyQuests;
    final completedCount = quests.where((q) => q['isCompleted'] == true).length;
    final totalCount = quests.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D24) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF282D39) : const Color(0xFFE5E7EB),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: ModernCardPainter(
                  accentColor: AppTheme.emeraldMint,
                  pattern: ModernCardPattern.dotsMatrix,
                  isDark: isDark,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF262A34)
                              : const Color(0xFFF3F4F6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.flag_outlined,
                          color: Color(0xFF2563EB),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Today's Goals",
                          style: GoogleFonts.roboto(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF111827),
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF262A34)
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$completedCount of $totalCount completed',
                          style: GoogleFonts.roboto(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF4B5563),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 5,
                      backgroundColor: isDark
                          ? const Color(0xFF262A34)
                          : const Color(0xFFE5E7EB),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.emeraldMint,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Column(
                    children: quests.map((quest) {
                      final isDone = quest['isCompleted'] == true;
                      final title = quest['title'] as String;
                      final xp = quest['xp'] as int;
                      final hint = quest['actionHint'] as String;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              if (isDone) {
                                CustomSnackBar.showSuccess(
                                  context,
                                  'Goal Achieved! (+$xp XP earned)',
                                );
                              } else {
                                final questId = quest['id'] as String;
                                if (questId == 'daily_explore') {
                                  widget.gamification.recordSubjectExplored(
                                    'All',
                                  );
                                  CustomSnackBar.showReward(
                                    context,
                                    'Explored subjects! +40 XP earned!',
                                  );
                                  if (widget.onMissionCompleted != null) {
                                    widget.onMissionCompleted!();
                                  }
                                } else {
                                  CustomSnackBar.showInfo(context, hint);
                                }
                              }
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isDone
                                    ? AppTheme.emeraldMint.withValues(
                                        alpha: isDark ? 0.12 : 0.08,
                                      )
                                    : (isDark
                                          ? const Color(0xFF222630)
                                          : const Color(0xFFF9FAFB)),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isDone
                                      ? AppTheme.emeraldMint.withValues(
                                          alpha: 0.3,
                                        )
                                      : (isDark
                                            ? const Color(0xFF2D3340)
                                            : const Color(0xFFEEF0F3)),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isDone
                                        ? Icons.check_circle_rounded
                                        : Icons.radio_button_unchecked_rounded,
                                    color: isDone
                                        ? AppTheme.emeraldMint
                                        : (isDark
                                              ? Colors.white38
                                              : const Color(0xFF9CA3AF)),
                                    size: 19,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: GoogleFonts.roboto(
                                        fontSize: 13,
                                        fontWeight: isDone
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: isDone
                                            ? (isDark
                                                  ? Colors.white60
                                                  : const Color(0xFF6B7280))
                                            : (isDark
                                                  ? Colors.white
                                                  : const Color(0xFF111827)),
                                        decoration: isDone
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF262A34)
                                          : const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '+$xp XP',
                                      style: GoogleFonts.roboto(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF2563EB),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
