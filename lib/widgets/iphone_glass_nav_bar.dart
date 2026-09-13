import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:oc_liquid_glass/oc_liquid_glass.dart';
import '../theme/app_theme.dart';

class IPhoneGlassNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool isDark;

  const IPhoneGlassNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.download_for_offline_rounded, 'label': 'Vault'},
      {'icon': Icons.bookmark_rounded, 'label': 'Favs'},
      {'icon': Icons.person_rounded, 'label': 'Profile'},
    ];

    final double alignX = -1.0 + (selectedIndex * (2.0 / (items.length - 1)));

    return Container(
      margin: const EdgeInsets.only(left: 18, right: 18, bottom: 18),
      height: 64,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: OCLiquidGlass(
            borderRadius: 28,
            color: isDark
                ? AppTheme.darkCard.withValues(alpha: 0.65)
                : Colors.white.withValues(alpha: 0.70),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                  width: 1.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Smooth Sliding Liquid Glass Indicator Pill
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment(alignX, 0.0),
                    child: FractionallySizedBox(
                      widthFactor: 1.0 / items.length,
                      heightFactor: 1.0,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeOutCubic,
                        decoration: BoxDecoration(
                          color: AppTheme.duoGreen.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.40),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.duoGreenShadow.withValues(alpha: 0.55),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Tab Buttons Layer
                  Row(
                    children: List.generate(items.length, (index) {
                      final isSelected = selectedIndex == index;
                      final item = items[index];

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => onDestinationSelected(index),
                          behavior: HitTestBehavior.opaque,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    item['icon'] as IconData,
                                    key: ValueKey('icon_${index}_$isSelected'),
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark ? Colors.white70 : const Color(0xFF334155)),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                AutoSizeText(
                                  item['label'] as String,
                                  maxLines: 1,
                                  minFontSize: 8,
                                  style: GoogleFonts.fredoka(
                                    fontSize: 10.5,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark ? Colors.white70 : const Color(0xFF334155)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
