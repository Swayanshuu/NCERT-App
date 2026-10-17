import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncert_books_app/services/gamification_service.dart';
import 'package:ncert_books_app/theme/app_theme.dart';
import 'package:ncert_books_app/theme/app_responsive.dart';
import 'package:ncert_books_app/widgets/custom_snack_bar.dart';
import 'package:ncert_books_app/screens/progress/bloc/progress_bloc.dart';
import 'package:ncert_books_app/screens/progress/widgets/hero_level_card.dart';
import 'package:ncert_books_app/screens/progress/widgets/quest_tile.dart';
import 'package:ncert_books_app/screens/progress/widgets/achievement_badge_card.dart';

class ProgressScreen extends StatefulWidget {
  final GamificationService gamification;

  const ProgressScreen({super.key, required this.gamification});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with AutomaticKeepAliveClientMixin {
  late ConfettiController _confettiController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    widget.gamification.addListener(_onStateChange);
  }

  @override
  void dispose() {
    widget.gamification.removeListener(_onStateChange);
    _confettiController.dispose();
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  void _claimDailyChest() {
    final success = widget.gamification.claimDailyBonus();
    if (success) {
      _confettiController.stop();
      _confettiController.play();
      CustomSnackBar.showReward(
        context,
        'Daily Reward Claimed! +50 XP added!',
      );
    } else {
      CustomSnackBar.showInfo(
        context,
        'Next chest available in ${widget.gamification.hoursUntilNextBonus} hours',
      );
    }
  }

  IconData _getBadgeIcon(String badge) {
    switch (badge) {
      case 'Book Explorer':
        return Icons.explore_rounded;
      case 'Super Reader':
        return Icons.auto_stories_rounded;
      case 'Master Mind':
        return Icons.psychology_rounded;
      case 'Streak Champ':
        return Icons.local_fire_department_rounded;
      case 'Book Collector':
        return Icons.collections_bookmark_rounded;
      default:
        return Icons.military_tech_rounded;
    }
  }

  Color _getBadgeColor(String badge) {
    switch (badge) {
      case 'Book Explorer':
        return const Color(0xFF38BDF8);
      case 'Super Reader':
        return const Color(0xFF34D399);
      case 'Master Mind':
        return const Color(0xFFA78BFA);
      case 'Streak Champ':
        return const Color(0xFFF97316);
      case 'Book Collector':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFFEAB308);
    }
  }

  String _getBadgeDescription(String badge) {
    switch (badge) {
      case 'Book Explorer':
        return 'Discovered first NCERT book';
      case 'Super Reader':
        return 'Earned 100+ XP in reading';
      case 'Master Mind':
        return 'Reached master tier with 300+ XP';
      case 'Streak Champ':
        return 'Maintained a 3-day active streak';
      case 'Book Collector':
        return 'Bookmarked 5 or more books';
      default:
        return 'Achievement unlocked';
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = widget.gamification.isDarkMode;
    final isTablet = AppResponsive.isTablet(context);
    final quests = widget.gamification.dailyQuests;
    final badges = widget.gamification.unlockedBadges;

    return BlocBuilder<ProgressBloc, ProgressState>(
      builder: (context, state) {
        return MaxContentConstraint(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: 90,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Title
                Text(
                  'Learning Journey',
                  style: GoogleFonts.roboto(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppTheme.darkTextPrimary
                        : AppTheme.lightTextPrimary,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Track XP, streaks, level titles & trophies',
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    color: isDark
                        ? AppTheme.darkTextMuted
                        : AppTheme.lightTextMuted,
                  ),
                ),
                const SizedBox(height: 20),

                // 1. Hero Level & Streak Card
                HeroLevelCard(
                  level: widget.gamification.level,
                  xp: widget.gamification.xp,
                  levelTitle: widget.gamification.levelTitle,
                  levelProgressXp: widget.gamification.levelProgressXp,
                  streak: widget.gamification.streak,
                  canClaimDailyBonus: widget.gamification.canClaimDailyBonus,
                  hoursUntilNextBonus: widget.gamification.hoursUntilNextBonus,
                  onClaimBonus: _claimDailyChest,
                ),
                const SizedBox(height: 24),

                // 2. Daily Missions Section
                Text(
                  'Daily Missions',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppTheme.darkTextPrimary
                        : AppTheme.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  children: quests.map((q) {
                    final isComp = q['isCompleted'] as bool? ?? false;
                    final rawIcon = q['icon'];
                    final title = q['title'] as String? ?? 'Mission';
                    final desc = q['desc'] as String? ?? '';
                    final xp = q['xp'] as int? ?? 10;

                    return QuestTile(
                      title: title,
                      description: desc,
                      xp: xp,
                      isCompleted: isComp,
                      icon: rawIcon is IconData ? rawIcon : Icons.stars_rounded,
                      iconColor: isComp
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF59E0B),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // 3. Trophies & Badges Section
                Text(
                  'Trophies & Badges',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppTheme.darkTextPrimary
                        : AppTheme.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isTablet ? 2 : 1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    mainAxisExtent: 72,
                  ),
                  itemCount: badges.length,
                  itemBuilder: (context, idx) {
                    final badge = badges[idx];
                    return AchievementBadgeCard(
                      title: badge,
                      description: _getBadgeDescription(badge),
                      icon: _getBadgeIcon(badge),
                      iconColor: _getBadgeColor(badge),
                      isUnlocked: true,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
