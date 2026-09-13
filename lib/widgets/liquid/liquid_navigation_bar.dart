import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'liquid_surface.dart';
import '../../theme/app_theme.dart';

class LiquidNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const LiquidNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class LiquidNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<LiquidNavItem> items;

  const LiquidNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
      child: LiquidSurface(
        height: 66,
        borderRadius: 33,
        blurSigma: 20,
        color: isDark
            ? AppTheme.darkSurface.withValues(alpha: 0.90)
            : Colors.white.withValues(alpha: 0.92),
        borderColor: isDark
            ? AppTheme.primaryTeal.withValues(alpha: 0.40)
            : AppTheme.primaryTeal.withValues(alpha: 0.60),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.50)
                : AppTheme.primaryTealDark.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = selectedIndex == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onDestinationSelected(index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryTeal.withValues(alpha: isDark ? 0.25 : 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                      border: isSelected
                          ? Border.all(
                              color: AppTheme.primaryTeal.withValues(alpha: 0.45),
                              width: 1,
                            )
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSelected ? item.selectedIcon : item.icon,
                          size: isSelected ? 22 : 20,
                          color: isSelected
                              ? AppTheme.primaryTeal
                              : (isDark
                                    ? AppTheme.darkTextMuted
                                    : AppTheme.lightTextMuted),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 10.5,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected
                                ? AppTheme.primaryTeal
                                : (isDark
                                      ? AppTheme.darkTextMuted
                                      : AppTheme.lightTextMuted),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
