import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';

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
      {'icon': Icons.folder_outlined, 'label': 'Vault'},
      {'icon': Icons.bookmark_border_rounded, 'label': 'Favs'},
      {'icon': Icons.person_outline_rounded, 'label': 'Profile'},
    ];

    final double alignX = -1.0 + (selectedIndex * (2.0 / (items.length - 1)));

    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      height: 68,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF181A20).withValues(alpha: 0.90)
                  : Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(34),
              border: Border.all(
                color: isDark ? const Color(0xFF282D39) : const Color(0xFFE5E7EB),
                width: 1.0,
              ),
            ),
            child: Stack(
              children: [
                // Animated sliding indicator
                AnimatedAlign(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment(alignX, 0.0),
                  child: FractionallySizedBox(
                    widthFactor: 1.0 / items.length,
                    heightFactor: 1.0,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : const Color(0xFF18181B),
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                  ),
                ),

                // Tab items
                Row(
                  children: List.generate(items.length, (index) {
                    final isSelected = selectedIndex == index;
                    final item = items[index];
                    final selectedColor = Colors.white;
                    final unselectedColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => onDestinationSelected(index),
                        behavior: HitTestBehavior.opaque,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                item['icon'] as IconData,
                                color: isSelected ? selectedColor : unselectedColor,
                                size: 20,
                              ),
                              const SizedBox(height: 2),
                              AutoSizeText(
                                item['label'] as String,
                                maxLines: 1,
                                minFontSize: 8,
                                style: GoogleFonts.roboto(
                                  fontSize: 10.5,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? selectedColor : unselectedColor,
                                  letterSpacing: -0.2,
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
    );
  }
}
