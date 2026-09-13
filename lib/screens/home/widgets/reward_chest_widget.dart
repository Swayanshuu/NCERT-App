import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ncert_books_app/services/gamification_service.dart';
import 'package:ncert_books_app/theme/app_theme.dart';
import 'package:ncert_books_app/widgets/custom_snack_bar.dart';
import 'package:ncert_books_app/widgets/glass/glass_card.dart';

class RewardChestWidget extends StatefulWidget {
  final GamificationService gamification;
  final VoidCallback? onChestOpened;

  const RewardChestWidget({
    super.key,
    required this.gamification,
    this.onChestOpened,
  });

  @override
  State<RewardChestWidget> createState() => _RewardChestWidgetState();
}

class _RewardChestWidgetState extends State<RewardChestWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _rotateAnim;
  late Animation<double> _particleYAnim;
  late Animation<double> _particleOpacityAnim;

  Timer? _countdownTimer;
  bool _isClaiming = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 0.90), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.90, end: 1.15), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutBack));

    _rotateAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.15), weight: 15),
      TweenSequenceItem(tween: Tween(begin: -0.15, end: 0.15), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.15, end: -0.08), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -0.08, end: 0.0), weight: 35),
    ]).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));

    _particleYAnim = Tween<double>(begin: 0.0, end: -42.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _particleOpacityAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_animController);

    _countdownTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _handleClaim() {
    if (_isClaiming) return;

    final canClaim = widget.gamification.canClaimDailyBonus;
    if (!canClaim) {
      CustomSnackBar.showInfo(
        context,
        'Next daily bonus available in ${widget.gamification.timeUntilNextBonusFormatted}!',
      );
      return;
    }

    setState(() => _isClaiming = true);
    _animController.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() => _isClaiming = false);
      }
    });

    final success = widget.gamification.claimDailyBonus();
    if (success) {
      widget.onChestOpened?.call();
      CustomSnackBar.showReward(
        context,
        'Daily Bonus Claimed! +50 XP added to your total!',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.gamification.isDarkMode;
    final canClaim = widget.gamification.canClaimDailyBonus;

    return GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _handleClaim,
                child: AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnim.value,
                      child: Transform.rotate(
                        angle: _rotateAnim.value,
                        child: Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: canClaim
                                  ? [AppTheme.sunshineGold, AppTheme.energyOrange]
                                  : [
                                      isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                                      isDark ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: (canClaim ? AppTheme.sunshineGold : Colors.black)
                                    .withValues(alpha: canClaim ? 0.45 : 0.15),
                                blurRadius: canClaim ? 14 : 6,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              canClaim ? '🎁' : '🔓',
                              style: const TextStyle(fontSize: 30),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          canClaim ? 'DAILY MYSTERY CHEST' : 'CLAIMED TODAY',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: canClaim
                                ? (isDark ? Colors.white : AppTheme.lightTextPrimary)
                                : AppTheme.emeraldMint,
                          ),
                        ),
                        if (!canClaim)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.emeraldMint.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppTheme.emeraldMint.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              'Done',
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.emeraldMint,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      canClaim
                          ? 'Tap the chest to claim your daily bonus XP!'
                          : 'Next bonus available in ${widget.gamification.timeUntilNextBonusFormatted}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: canClaim ? FontWeight.w500 : FontWeight.w600,
                        color: canClaim
                            ? (isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted)
                            : (isDark ? AppTheme.accentAmber : AppTheme.energyOrange),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    if (canClaim)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _handleClaim,
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppTheme.sunshineGold, AppTheme.energyOrange],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.energyOrange.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              'CLAIM +50 XP',
                              style: GoogleFonts.outfit(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.timer_outlined, size: 13, color: AppTheme.accentAmber),
                            const SizedBox(width: 4),
                            Text(
                              'Next in ${widget.gamification.timeUntilNextBonusFormatted}',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              if (_animController.value == 0.0) return const SizedBox.shrink();

              return Positioned(
                left: 10,
                top: _particleYAnim.value,
                child: Opacity(
                  opacity: _particleOpacityAnim.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.sunshineGold,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.sunshineGold.withValues(alpha: 0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '+50 XP!',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
