import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/gamification_service.dart';
import '../theme/app_theme.dart';

class ResponsiveBreakpoints {
  static const double mobile = 600.0;
  static const double tablet = 850.0;
  static const double desktop = 1100.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobile &&
      MediaQuery.of(context).size.width < tablet;
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tablet;

  static int getGridColumnCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 1;
    if (width < 900) return 2;
    if (width < 1300) return 3;
    if (width < 1600) return 4;
    return 5;
  }

  static double getMaxContentWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1400) return 1320;
    if (width > 1100) return 1080;
    return double.infinity;
  }
}

class DesktopSidebarNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final GamificationService gamification;
  final ValueChanged<String>? onClassChanged;

  const DesktopSidebarNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.gamification,
    this.onClassChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = gamification.isDarkMode;

    return Container(
      width: 230,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.darkSurface.withValues(alpha: 0.90)
            : Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/logo.png',
              width: 42,
              height: 42,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'NCERT Books',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
            ),
          ),
          Text(
            'v1.0.0',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
            ),
          ),
          const SizedBox(height: 24),
          _buildRailItem(0, Icons.home_rounded, 'Home'),
          _buildRailItem(1, Icons.explore_rounded, 'Explore'),
          _buildRailItem(2, Icons.library_books_rounded, 'Library'),
          _buildRailItem(3, Icons.emoji_events_rounded, 'Progress'),
          _buildRailItem(4, Icons.person_rounded, 'Profile'),
        ],
      ),
    );
  }

  Widget _buildRailItem(int index, IconData icon, String label) {
    final isSelected = selectedIndex == index;
    final isDark = gamification.isDarkMode;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          tileColor: isSelected ? AppTheme.primaryTeal.withValues(alpha: 0.20) : Colors.transparent,
          leading: Icon(
            icon,
            color: isSelected ? AppTheme.primaryTeal : (isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted),
          ),
          title: Text(
            label,
            style: GoogleFonts.outfit(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? AppTheme.primaryTeal : (isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary),
            ),
          ),
          onTap: () => onDestinationSelected(index),
        ),
      ),
    );
  }
}
