import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/gamification_service.dart';
import '../theme/app_theme.dart';
import '../screens/notices/notices_screen.dart';
import '../screens/profile/widgets/avatar_selector_modal.dart';
import '../screens/profile/settings_screen.dart';
import '../services/pdf_cache_service.dart';
import '../widgets/custom_snack_bar.dart';

class AppDrawer extends StatelessWidget {
  final GamificationService gamification;
  final VoidCallback? onOpenDownloads;
  final VoidCallback? onOpenProgress;
  final VoidCallback? onOpenNotices;

  const AppDrawer({
    super.key,
    required this.gamification,
    this.onOpenDownloads,
    this.onOpenProgress,
    this.onOpenNotices,
  });

  void _showEditNameDialog(BuildContext context) {
    final isDark = gamification.isDarkMode;
    final controller = TextEditingController(text: gamification.userName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
        ),
        title: Text(
          'Edit Student Name',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: isDark
                ? AppTheme.darkTextPrimary
                : AppTheme.lightTextPrimary,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter student name',
            hintStyle: GoogleFonts.roboto(
              color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
            ),
            filled: true,
            fillColor: isDark
                ? AppTheme.darkSurfaceElevated
                : AppTheme.lightSurfaceElevated,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
              ),
            ),
          ),
          style: GoogleFonts.roboto(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppTheme.darkTextPrimary
                : AppTheme.lightTextPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.roboto(
                color: isDark
                    ? AppTheme.darkTextSecondary
                    : AppTheme.lightTextSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                gamification.setUserName(newName);
              }
              Navigator.pop(ctx);
              CustomSnackBar.showSuccess(
                context,
                'Name updated to ${gamification.userName}',
              );
            },
            child: Text(
              'Save',
              style: GoogleFonts.roboto(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = gamification.isDarkMode;
    final drawerBg = isDark
        ? AppTheme.darkBackground
        : AppTheme.lightBackground;
    final cardBg = isDark
        ? AppTheme.darkSurfaceElevated
        : AppTheme.lightSurface;
    final textPrimary = isDark
        ? AppTheme.darkTextPrimary
        : AppTheme.lightTextPrimary;
    final textMuted = isDark
        ? AppTheme.darkTextSecondary
        : AppTheme.lightTextSecondary;
    final borderCol = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;

    return Drawer(
      backgroundColor: drawerBg,
      elevation: 0,
      width: MediaQuery.of(context).size.width * 0.84,
      child: SafeArea(
        child: Column(
          children: [
            // Top Bar with Close button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 16, 6),
              child: Row(
                children: [
                  Text(
                    'Student Profile',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded, color: textMuted, size: 22),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. User Profile Header Card (Reference Style)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: borderCol),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Avatar with tap to change
                              GestureDetector(
                                onTap: () => AvatarSelectorModal.show(
                                  context,
                                  gamification,
                                ),
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 58,
                                      height: 58,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AvatarHelper.getColor(
                                          gamification.currentAvatar,
                                        ).withValues(alpha: 0.12),
                                        border: Border.all(
                                          color: AvatarHelper.getColor(
                                            gamification.currentAvatar,
                                          ).withValues(alpha: 0.4),
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          AvatarHelper.getIcon(
                                            gamification.currentAvatar,
                                          ),
                                          color: AvatarHelper.getColor(
                                            gamification.currentAvatar,
                                          ),
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF0284C7),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.edit_rounded,
                                          size: 11,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Name & Class
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            gamification.userName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.outfit(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                              color: textPrimary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        GestureDetector(
                                          onTap: () =>
                                              _showEditNameDialog(context),
                                          child: Icon(
                                            Icons.edit_outlined,
                                            size: 15,
                                            color: textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 7,
                                            vertical: 2.5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFF0284C7,
                                            ).withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            'Class ${gamification.userClass}',
                                            style: GoogleFonts.roboto(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF0284C7),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Level ${gamification.level}',
                                          style: GoogleFonts.roboto(
                                            fontSize: 11,
                                            color: textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 2. Learning Stats Metrics (XP, Streak, Favorites)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderCol),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            label: 'XP Points',
                            value: '${gamification.xp}',
                            icon: Icons.bolt_rounded,
                            iconColor: const Color(0xFFF59E0B),
                            textPrimary: textPrimary,
                            textMuted: textMuted,
                          ),
                          Container(width: 1, height: 32, color: borderCol),
                          _buildStatItem(
                            label: 'Streak',
                            value: '${gamification.streak}d',
                            icon: Icons.local_fire_department_rounded,
                            iconColor: const Color(0xFFEF4444),
                            textPrimary: textPrimary,
                            textMuted: textMuted,
                          ),
                          Container(width: 1, height: 32, color: borderCol),
                          _buildStatItem(
                            label: 'Saved',
                            value: '${gamification.favoriteBookCodes.length}',
                            icon: Icons.bookmark_rounded,
                            iconColor: const Color(0xFF0284C7),
                            textPrimary: textPrimary,
                            textMuted: textMuted,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Section: Official Updates
                    Text(
                      'UPDATES & DISCOVERY',
                      style: GoogleFonts.roboto(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: textMuted,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Official NCERT Notices Item
                    _buildNavTile(
                      icon: Icons.campaign_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      title: 'Official NCERT Notices',
                      subtitle: 'Live circulars, press releases & PDFs',
                      badge: 'LIVE',
                      badgeColor: const Color(0xFF0284C7),
                      isDark: isDark,
                      borderCol: borderCol,
                      textPrimary: textPrimary,
                      textMuted: textMuted,
                      onTap: () {
                        Navigator.of(context).pop();
                        if (onOpenNotices != null) {
                          onOpenNotices!();
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  NoticesScreen(gamification: gamification),
                            ),
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 8),

                    // Downloads / Library Item
                    _buildNavTile(
                      icon: Icons.library_books_rounded,
                      iconColor: const Color(0xFF0284C7),
                      title: 'My Downloaded Books',
                      subtitle: 'Read NCERT PDFs offline anytime',
                      badge: null,
                      badgeColor: null,
                      isDark: isDark,
                      borderCol: borderCol,
                      textPrimary: textPrimary,
                      textMuted: textMuted,
                      onTap: () {
                        Navigator.of(context).pop();
                        onOpenDownloads?.call();
                      },
                    ),

                    const SizedBox(height: 8),

                    // Progress & Study Goals
                    _buildNavTile(
                      icon: Icons.emoji_events_rounded,
                      iconColor: const Color(0xFF10B981),
                      title: 'Study Goals & Progress',
                      subtitle: 'Learning streaks & achievements',
                      badge: null,
                      badgeColor: null,
                      isDark: isDark,
                      borderCol: borderCol,
                      textPrimary: textPrimary,
                      textMuted: textMuted,
                      onTap: () {
                        Navigator.of(context).pop();
                        onOpenProgress?.call();
                      },
                    ),

                    const SizedBox(height: 18),

                    // Section: Preferences
                    Text(
                      'PREFERENCES',
                      style: GoogleFonts.roboto(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: textMuted,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Dark Mode Toggle
                    _buildNavTile(
                      icon: Icons.settings_rounded,
                      iconColor: const Color(0xFF0284C7),
                      title: 'Settings & Class',
                      subtitle: 'Manage class, profile & storage',
                      badge: null,
                      badgeColor: null,
                      isDark: isDark,
                      borderCol: borderCol,
                      textPrimary: textPrimary,
                      textMuted: textMuted,
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                SettingsScreen(gamification: gamification),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 8),

                    _buildNavTile(
                      icon: Icons.cleaning_services_rounded,
                      iconColor: const Color(0xFF10B981),
                      title: 'Clear PDF Cache',
                      subtitle: 'Free up local offline storage',
                      badge: null,
                      badgeColor: null,
                      isDark: isDark,
                      borderCol: borderCol,
                      textPrimary: textPrimary,
                      textMuted: textMuted,
                      onTap: () async {
                        await PdfCacheService().clearAllCache();
                        if (context.mounted) {
                          CustomSnackBar.showSuccess(
                            context,
                            'PDF cache cleared successfully',
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 20),

                    // Official NCERT Portal external link
                    InkWell(
                      onTap: () async {
                        final uri = Uri.parse('https://ncert.nic.in');
                        try {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        } catch (_) {}
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1A1D24)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.public_rounded,
                              size: 18,
                              color: Color(0xFF0284C7),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Visit Official NCERT Portal',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.open_in_new_rounded,
                              size: 14,
                              color: textMuted,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Version Info
                    Center(
                      child: Text(
                        'NCERT Books & News • v1.2.0\nEducational Resource App',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          fontSize: 11,
                          color: textMuted.withValues(alpha: 0.6),
                          height: 1.4,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: 'Powered by ',
                          style: GoogleFonts.roboto(
                            fontSize: 11,
                            color: Colors.white,
                          ),
                          children: [
                            TextSpan(
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // nav to swynx.dev website
                                  launchUrl(
                                    Uri.parse('https://swynx.dev'),
                                    mode: LaunchMode.externalApplication,
                                  );
                                },
                              text: 'SWYNX',
                              style: GoogleFonts.roboto(
                                color: const Color.fromARGB(255, 0, 81, 255),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color textPrimary,
    required Color textMuted,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.roboto(fontSize: 10.5, color: textMuted),
        ),
      ],
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String? badge,
    required Color? badgeColor,
    required bool isDark,
    required Color borderCol,
    required Color textPrimary,
    required Color textMuted,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? AppTheme.darkSurfaceElevated
              : AppTheme.lightSurfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderCol),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withValues(alpha: 0.15),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: (badgeColor ?? const Color(0xFF0284C7))
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge,
                            style: GoogleFonts.roboto(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: badgeColor ?? const Color(0xFF0284C7),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.roboto(fontSize: 11, color: textMuted),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
