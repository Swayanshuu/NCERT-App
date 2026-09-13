import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ncert_books_app/services/gamification_service.dart';
import 'package:ncert_books_app/theme/app_theme.dart';
import 'package:ncert_books_app/widgets/custom_snack_bar.dart';
import 'package:ncert_books_app/widgets/glass/glass_card.dart';

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
                  color: AppTheme.skyCyan.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.gps_fixed_rounded, color: AppTheme.skyCyan, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "TODAY'S MISSIONS",
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.emeraldMint.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$completedCount / $totalCount DONE',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.emeraldMint,
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
              minHeight: 6,
              backgroundColor: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.emeraldMint),
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
                          'Mission Completed! (+$xp XP earned)',
                        );
                      } else {
                        final questId = quest['id'] as String;
                        if (questId == 'daily_explore') {
                          widget.gamification.recordSubjectExplored('All');
                          CustomSnackBar.showReward(
                            context,
                            'Explored Subject Worlds! +40 XP earned!',
                          );
                          if (widget.onMissionCompleted != null) {
                            widget.onMissionCompleted!();
                          }
                        } else {
                          CustomSnackBar.showInfo(context, hint);
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDone
                            ? AppTheme.emeraldMint.withValues(alpha: isDark ? 0.12 : 0.08)
                            : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03)),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDone
                              ? AppTheme.emeraldMint.withValues(alpha: 0.3)
                              : (isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                            color: isDone ? AppTheme.emeraldMint : (isDark ? Colors.white38 : const Color(0xFF94A3B8)),
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: isDone ? FontWeight.w600 : FontWeight.w500,
                                color: isDone
                                    ? (isDark ? Colors.white70 : const Color(0xFF334155))
                                    : (isDark ? Colors.white : const Color(0xFF0F172A)),
                                decoration: isDone ? TextDecoration.lineThrough : null,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDone
                                  ? AppTheme.emeraldMint.withValues(alpha: 0.15)
                                  : AppTheme.sunshineGold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '+$xp XP',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isDone ? AppTheme.emeraldMint : AppTheme.sunshineGold,
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
    );
  }
}
