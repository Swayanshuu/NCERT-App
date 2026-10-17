import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ncert_books_app/services/gamification_service.dart';
import 'package:ncert_books_app/theme/app_theme.dart';
import 'package:ncert_books_app/widgets/custom_snack_bar.dart';

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
  Timer? _countdownTimer;
  bool _isClaiming = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutBack));

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
        'Next study reward available in ${widget.gamification.timeUntilNextBonusFormatted}!',
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
        'Daily Streak Reward Claimed! +50 XP added to your profile!',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.gamification.isDarkMode;
    final canClaim = widget.gamification.canClaimDailyBonus;

    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Row(
        children: [
          // Icon Container
          GestureDetector(
            onTap: _handleClaim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: canClaim
                      ? (isDark ? const Color(0xFF2A2318) : const Color(0xFFFEF3C7))
                      : (isDark ? const Color(0xFF262A34) : const Color(0xFFF3F4F6)),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: canClaim
                        ? AppTheme.accentAmber.withValues(alpha: 0.5)
                        : (isDark ? const Color(0xFF383F4F) : const Color(0xFFE5E7EB)),
                  ),
                ),
                child: Center(
                  child: Icon(
                    canClaim
                        ? Icons.card_giftcard_rounded
                        : Icons.bolt_rounded,
                    color: canClaim
                        ? AppTheme.accentAmber
                        : (isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.lightTextSecondary),
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      canClaim ? 'Daily Study Bonus' : 'Claimed for Today',
                      style: GoogleFonts.roboto(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                    if (!canClaim)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.emeraldMint.withValues(alpha: isDark ? 0.20 : 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Done',
                          style: GoogleFonts.roboto(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.emeraldMint,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  canClaim
                      ? 'Tap to collect your daily +50 XP bonus'
                      : 'Next bonus in ${widget.gamification.timeUntilNextBonusFormatted}',
                  style: GoogleFonts.roboto(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          if (canClaim)
            GestureDetector(
              onTap: _handleClaim,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white : const Color(0xFF18181B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+50 XP',
                  style: GoogleFonts.roboto(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? const Color(0xFF18181B) : Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
