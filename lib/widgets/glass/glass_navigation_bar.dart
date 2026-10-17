import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GlassNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final int? badgeCount;

  const GlassNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.badgeCount,
  });
}

class GlassNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<GlassNavItem> items;

  const GlassNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final count = items.length;
    final alignX = count > 1 ? -1.0 + (selectedIndex * (2.0 / (count - 1))) : 0.0;

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
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF181818).withValues(alpha: 0.95)
                  : Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(34),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF282828)
                    : const Color(0xFFE5E7EB),
                width: 1.0,
              ),
            ),
            child: Stack(
              children: [
                // Animated sliding active pill indicator
                AnimatedAlign(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment(alignX, 0.0),
                  child: FractionallySizedBox(
                    widthFactor: 1 / count,
                    heightFactor: 1.0,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF242424)
                            : const Color(0xFF18181B),
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                  ),
                ),
                // Navigation items
                Row(
                  children: List.generate(items.length, (index) {
                    final item = items[index];
                    final isSelected = selectedIndex == index;

                    final selectedTextColor = Colors.white;
                    final unselectedTextColor = isDark
                        ? const Color(0xFF777777)
                        : const Color(0xFF6B7280);

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => onDestinationSelected(index),
                        behavior: HitTestBehavior.opaque,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedScale(
                                scale: isSelected ? 1.08 : 1.0,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOutCubic,
                                child: Icon(
                                  isSelected ? item.selectedIcon : item.icon,
                                  color: isSelected ? selectedTextColor : unselectedTextColor,
                                  size: 21,
                                ),
                              ),
                              const SizedBox(height: 2),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  item.label,
                                  style: GoogleFonts.roboto(
                                    fontSize: 10.5,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? selectedTextColor : unselectedTextColor,
                                    letterSpacing: -0.2,
                                  ),
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
