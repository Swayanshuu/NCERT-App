import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncert_books_app/services/gamification_service.dart';
import 'package:ncert_books_app/theme/app_theme.dart';
import 'package:ncert_books_app/theme/app_responsive.dart';
import 'package:ncert_books_app/widgets/confetti_overlay.dart';
import 'package:ncert_books_app/widgets/custom_snack_bar.dart';
import 'package:ncert_books_app/widgets/glass/glass_card.dart';
import 'package:ncert_books_app/widgets/liquid/liquid_progress.dart';
import 'package:ncert_books_app/widgets/painters/progress_background_painter.dart';
import 'package:ncert_books_app/screens/progress/bloc/progress_bloc.dart';

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
        '🎉 Daily Reward Claimed! +50 XP added!',
      );
    } else {
      CustomSnackBar.showInfo(
        context,
        '⌛ Next chest available in ${widget.gamification.hoursUntilNextBonus} hours!',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<ProgressBloc, ProgressState>(
      builder: (context, state) {
        final isDark = widget.gamification.isDarkMode;
        final isDesktop = AppResponsive.isDesktop(context);
        final xpProgress = (widget.gamification.levelProgressXp) / 100.0;
        final quests = widget.gamification.dailyQuests;

        return ConfettiOverlay(
          controller: _confettiController,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                CustomPaint(
                  size: Size.infinite,
                  painter: ProgressBackgroundPainter(isDark: isDark),
                ),
                SafeArea(
                  child: MaxContentConstraint(
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
                            'Learning Journey 🏆',
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppTheme.darkTextPrimary
                                  : AppTheme.lightTextPrimary,
                            ),
                          ),
                          Text(
                            'Track XP, streaks, level titles & trophies',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: isDark
                                  ? AppTheme.darkTextMuted
                                  : AppTheme.lightTextMuted,
                            ),
                          ),
                          const SizedBox(height: 20),

                          if (isDesktop)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Desktop Left Column
                                Expanded(
                                  flex: 5,
                                  child: Column(
                                    children: [
                                      // Hero Level Card
                                      GlassCard(
                                        borderRadius: 28,
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                LiquidProgressRing(
                                                  progress: xpProgress,
                                                  size: 84,
                                                  strokeWidth: 9,
                                                  color: AppTheme.accentAmber,
                                                  centerChild: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        'Lvl ${widget.gamification.level}',
                                                        style:
                                                            GoogleFonts.outfit(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: AppTheme
                                                                  .accentAmber,
                                                            ),
                                                      ),
                                                      Text(
                                                        '${widget.gamification.xp} XP',
                                                        style: GoogleFonts.plusJakartaSans(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: isDark
                                                              ? AppTheme
                                                                    .darkTextMuted
                                                              : AppTheme
                                                                    .lightTextMuted,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 18),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        widget
                                                            .gamification
                                                            .levelTitle,
                                                        style: GoogleFonts.outfit(
                                                          fontSize: 19,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: isDark
                                                              ? AppTheme
                                                                    .darkTextPrimary
                                                              : AppTheme
                                                                    .lightTextPrimary,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        '${100 - widget.gamification.levelProgressXp} XP to Level ${widget.gamification.level + 1}',
                                                        style: GoogleFonts.plusJakartaSans(
                                                          fontSize: 12,
                                                          color: isDark
                                                              ? AppTheme
                                                                    .darkTextMuted
                                                              : AppTheme
                                                                    .lightTextMuted,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      LiquidProgressBar(
                                                        progress: xpProgress,
                                                        height: 8,
                                                        color: AppTheme
                                                            .accentAmber,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: GlassCard(
                                              borderRadius: 24,
                                              padding: const EdgeInsets.all(16),
                                              child: Column(
                                                children: [
                                                  const Text(
                                                    '🔥',
                                                    style: TextStyle(
                                                      fontSize: 32,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    '${widget.gamification.streak} Days',
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          AppTheme.accentOrange,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Reading Streak',
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 11.5,
                                                      color: isDark
                                                          ? AppTheme
                                                                .darkTextMuted
                                                          : AppTheme
                                                                .lightTextMuted,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: GlassCard(
                                              borderRadius: 24,
                                              padding: const EdgeInsets.all(16),
                                              onTap: _claimDailyChest,
                                              child: Column(
                                                children: [
                                                  const Text(
                                                    '🎁',
                                                    style: TextStyle(
                                                      fontSize: 32,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    widget
                                                            .gamification
                                                            .canClaimDailyBonus
                                                        ? 'Claim Chest!'
                                                        : 'Claimed',
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          widget
                                                              .gamification
                                                              .canClaimDailyBonus
                                                          ? AppTheme.accentAmber
                                                          : AppTheme
                                                                .primaryTeal,
                                                    ),
                                                  ),
                                                  Text(
                                                    widget
                                                            .gamification
                                                            .canClaimDailyBonus
                                                        ? '+50 Free XP'
                                                        : 'Next in ${widget.gamification.hoursUntilNextBonus}h',
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 11.5,
                                                      color: isDark
                                                          ? AppTheme
                                                                .darkTextMuted
                                                          : AppTheme
                                                                .lightTextMuted,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20),

                                // Desktop Right Column
                                Expanded(
                                  flex: 6,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Daily Missions 🎯',
                                        style: GoogleFonts.outfit(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? AppTheme.darkTextPrimary
                                              : AppTheme.lightTextPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Column(
                                        children: quests.map((q) {
                                          final isComp =
                                              q['isCompleted'] as bool;
                                          final rawIcon = q['icon'];
                                          final title = q['title'] as String;
                                          final desc = q['desc'] as String;
                                          final xp = q['xp'] as int;

                                          return Container(
                                            margin: const EdgeInsets.only(
                                              bottom: 10,
                                            ),
                                            child: GlassCard(
                                              borderRadius: 20,
                                              padding: const EdgeInsets.all(14),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 44,
                                                    height: 44,
                                                    decoration: BoxDecoration(
                                                      color: isComp
                                                          ? AppTheme.primaryTeal
                                                                .withValues(
                                                                  alpha: 0.20,
                                                                )
                                                          : AppTheme.accentAmber
                                                                .withValues(
                                                                  alpha: 0.15,
                                                                ),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Center(
                                                      child: rawIcon is IconData
                                                          ? Icon(
                                                              rawIcon,
                                                              size: 22,
                                                              color: isComp
                                                                  ? AppTheme
                                                                        .primaryTeal
                                                                  : AppTheme
                                                                        .accentAmber,
                                                            )
                                                          : Text(
                                                              rawIcon?.toString() ??
                                                                  '🌟',
                                                              style:
                                                                  const TextStyle(
                                                                    fontSize:
                                                                        22,
                                                                  ),
                                                            ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 14),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          title,
                                                          style: GoogleFonts.outfit(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: isDark
                                                                ? AppTheme
                                                                      .darkTextPrimary
                                                                : AppTheme
                                                                      .lightTextPrimary,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 2,
                                                        ),
                                                        Text(
                                                          desc,
                                                          style: GoogleFonts.plusJakartaSans(
                                                            fontSize: 11.5,
                                                            color: isDark
                                                                ? AppTheme
                                                                      .darkTextMuted
                                                                : AppTheme
                                                                      .lightTextMuted,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 6,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: isComp
                                                          ? AppTheme.primaryTeal
                                                          : AppTheme
                                                                .accentAmber,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      isComp
                                                          ? 'DONE ✅'
                                                          : '+$xp XP',
                                                      style: GoogleFonts.outfit(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 1. Hero Level & XP Progress Card
                                GlassCard(
                                  borderRadius: 28,
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          LiquidProgressRing(
                                            progress: xpProgress,
                                            size: 84,
                                            strokeWidth: 9,
                                            color: AppTheme.accentAmber,
                                            centerChild: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Lvl ${widget.gamification.level}',
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppTheme.accentAmber,
                                                  ),
                                                ),
                                                Text(
                                                  '${widget.gamification.xp} XP',
                                                  style:
                                                      GoogleFonts.plusJakartaSans(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: isDark
                                                            ? AppTheme
                                                                  .darkTextMuted
                                                            : AppTheme
                                                                  .lightTextMuted,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 18),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  widget
                                                      .gamification
                                                      .levelTitle,
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.bold,
                                                    color: isDark
                                                        ? AppTheme
                                                              .darkTextPrimary
                                                        : AppTheme
                                                              .lightTextPrimary,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${100 - widget.gamification.levelProgressXp} XP to Level ${widget.gamification.level + 1}',
                                                  style:
                                                      GoogleFonts.plusJakartaSans(
                                                        fontSize: 12,
                                                        color: isDark
                                                            ? AppTheme
                                                                  .darkTextMuted
                                                            : AppTheme
                                                                  .lightTextMuted,
                                                      ),
                                                ),
                                                const SizedBox(height: 10),
                                                LiquidProgressBar(
                                                  progress: xpProgress,
                                                  height: 8,
                                                  color: AppTheme.accentAmber,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // 2. Streak & Daily Chest Row
                                Row(
                                  children: [
                                    Expanded(
                                      child: GlassCard(
                                        borderRadius: 24,
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          children: [
                                            const Text(
                                              '🔥',
                                              style: TextStyle(fontSize: 32),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              '${widget.gamification.streak} Days',
                                              style: GoogleFonts.outfit(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.accentOrange,
                                              ),
                                            ),
                                            Text(
                                              'Reading Streak',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                    fontSize: 11.5,
                                                    color: isDark
                                                        ? AppTheme.darkTextMuted
                                                        : AppTheme
                                                              .lightTextMuted,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: GlassCard(
                                        borderRadius: 24,
                                        padding: const EdgeInsets.all(16),
                                        onTap: _claimDailyChest,
                                        child: Column(
                                          children: [
                                            const Text(
                                              '🎁',
                                              style: TextStyle(fontSize: 32),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              widget
                                                      .gamification
                                                      .canClaimDailyBonus
                                                  ? 'Claim Chest!'
                                                  : 'Claimed',
                                              style: GoogleFonts.outfit(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    widget
                                                        .gamification
                                                        .canClaimDailyBonus
                                                    ? AppTheme.accentAmber
                                                    : AppTheme.primaryTeal,
                                              ),
                                            ),
                                            Text(
                                              widget
                                                      .gamification
                                                      .canClaimDailyBonus
                                                  ? '+50 Free XP'
                                                  : 'Next in ${widget.gamification.hoursUntilNextBonus}h',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                    fontSize: 11.5,
                                                    color: isDark
                                                        ? AppTheme.darkTextMuted
                                                        : AppTheme
                                                              .lightTextMuted,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // 3. Daily Quests Section
                                Text(
                                  'Daily Missions 🎯',
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppTheme.darkTextPrimary
                                        : AppTheme.lightTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Column(
                                  children: quests.map((q) {
                                    final isComp = q['isCompleted'] as bool;
                                    final rawIcon = q['icon'];
                                    final title = q['title'] as String;
                                    final desc = q['desc'] as String;
                                    final xp = q['xp'] as int;

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: GlassCard(
                                        borderRadius: 20,
                                        padding: const EdgeInsets.all(14),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 44,
                                              height: 44,
                                              decoration: BoxDecoration(
                                                color: isComp
                                                    ? AppTheme.primaryTeal
                                                          .withValues(
                                                            alpha: 0.20,
                                                          )
                                                    : AppTheme.accentAmber
                                                          .withValues(
                                                            alpha: 0.15,
                                                          ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: rawIcon is IconData
                                                    ? Icon(
                                                        rawIcon,
                                                        size: 22,
                                                        color: isComp
                                                            ? AppTheme
                                                                  .primaryTeal
                                                            : AppTheme
                                                                  .accentAmber,
                                                      )
                                                    : Text(
                                                        rawIcon?.toString() ??
                                                            '🌟',
                                                        style: const TextStyle(
                                                          fontSize: 22,
                                                        ),
                                                      ),
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    title,
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: isDark
                                                          ? AppTheme
                                                                .darkTextPrimary
                                                          : AppTheme
                                                                .lightTextPrimary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    desc,
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 11.5,
                                                      color: isDark
                                                          ? AppTheme
                                                                .darkTextMuted
                                                          : AppTheme
                                                                .lightTextMuted,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: isComp
                                                    ? AppTheme.primaryTeal
                                                    : AppTheme.accentAmber,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                isComp ? 'DONE ✅' : '+$xp XP',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          const SizedBox(height: 20),

                          // 4. Badges & Achievements
                          Text(
                            'Trophies & Badges 🎖️',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppTheme.darkTextPrimary
                                  : AppTheme.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isDesktop ? 4 : 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 1.6,
                                ),
                            itemCount:
                                widget.gamification.unlockedBadges.length,
                            itemBuilder: (context, idx) {
                              final badge =
                                  widget.gamification.unlockedBadges[idx];
                              return GlassCard(
                                borderRadius: 20,
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      badge.split(' ').last,
                                      style: const TextStyle(fontSize: 28),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      badge
                                          .replaceAll(badge.split(' ').last, '')
                                          .trim(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? AppTheme.darkTextPrimary
                                            : AppTheme.lightTextPrimary,
                                      ),
                                    ),
                                    Text(
                                      'Unlocked Badge',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10.5,
                                        color: AppTheme.primaryTeal,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
