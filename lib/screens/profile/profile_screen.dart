import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncert_books_app/services/gamification_service.dart';
import 'package:ncert_books_app/services/pdf_cache_service.dart';
import 'package:ncert_books_app/theme/app_theme.dart';
import 'package:ncert_books_app/theme/app_responsive.dart';
import 'package:ncert_books_app/widgets/custom_snack_bar.dart';
import 'package:ncert_books_app/widgets/ad_banner_widget.dart';
import 'package:ncert_books_app/widgets/glass/glass_card.dart';
import 'package:ncert_books_app/widgets/glass/glass_surface.dart';
import 'package:ncert_books_app/widgets/hover_builder.dart';
import 'package:ncert_books_app/screens/profile/bloc/profile_bloc.dart';

class ProfileScreen extends StatefulWidget {
  final GamificationService gamification;

  const ProfileScreen({super.key, required this.gamification});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    widget.gamification.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    widget.gamification.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  void _showEditNameDialog() {
    final controller = TextEditingController(text: widget.gamification.userName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Student Name', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter your name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ProfileBloc>().add(ProfileNameUpdated(controller.text));
              widget.gamification.setUserName(controller.text);
              Navigator.pop(ctx);
              CustomSnackBar.showSuccess(context, 'Name updated to ${widget.gamification.userName} ✨');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAvatarPickerModal() {
    final avatars = GamificationService.avatars;
    final isDark = widget.gamification.isDarkMode;
    final mediaQuery = MediaQuery.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: mediaQuery.size.height * 0.8,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: GlassSurface(
            borderRadius: 32,
            padding: const EdgeInsets.all(24),
            color: isDark ? AppTheme.darkBackground.withValues(alpha: 0.95) : AppTheme.lightBackground.withValues(alpha: 0.95),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Choose Avatar',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: avatars.length,
                    itemBuilder: (context, idx) {
                      final av = avatars[idx];
                      final isSel = widget.gamification.currentAvatar == av;
                      return HoverBuilder(
                        onTap: () {
                          context.read<ProfileBloc>().add(ProfileAvatarUpdated(av));
                          widget.gamification.setAvatar(av);
                          Navigator.pop(ctx);
                        },
                        builder: (context, isHovered) => Material(
                          color: Colors.transparent,
                          child: ListTile(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            tileColor: isSel ? AppTheme.primaryTeal.withValues(alpha: 0.2) : null,
                            leading: Text(av.split(' ').first, style: const TextStyle(fontSize: 26)),
                            title: Text(av, style: GoogleFonts.outfit(fontWeight: isSel ? FontWeight.bold : FontWeight.w500)),
                            trailing: isSel ? const Icon(Icons.check_circle_rounded, color: AppTheme.primaryTeal) : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final isDark = widget.gamification.isDarkMode;
    return GlassCard(
      borderRadius: 28,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          HoverBuilder(
            onTap: _showAvatarPickerModal,
            tooltip: 'Change Avatar',
            builder: (context, isHovered) => Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withValues(alpha: 0.20),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primaryTeal,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  widget.gamification.currentAvatar.split(' ').first,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.gamification.userName,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.primaryTeal),
                      onPressed: _showEditNameDialog,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Class ${widget.gamification.userClass} Student • Level ${widget.gamification.level}',
                    style: GoogleFonts.outfit(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final isDark = widget.gamification.isDarkMode;
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            borderRadius: 20,
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Text('⭐ ${widget.gamification.xp}', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Total XP', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GlassCard(
            borderRadius: 20,
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Text('🔥 ${widget.gamification.streak}d', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Streak', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GlassCard(
            borderRadius: 20,
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Text('❤️ ${widget.gamification.favoriteBookCodes.length}', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Favorites', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesList() {
    final isDark = widget.gamification.isDarkMode;

    return GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            SwitchListTile(
              value: widget.gamification.isDarkMode,
              onChanged: (val) => widget.gamification.toggleTheme(),
              secondary: Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: AppTheme.accentAmber,
              ),
              title: Text('Dark Theme', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
              subtitle: Text('Toggle dark slate liquid interface', style: GoogleFonts.plusJakartaSans(fontSize: 12)),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.cleaning_services_rounded, color: AppTheme.accentRose),
              title: Text('Clear PDF Cache', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
              subtitle: Text('Free up local storage space', style: GoogleFonts.plusJakartaSans(fontSize: 12)),
              onTap: () async {
                await PdfCacheService().clearAllCache();
                if (mounted) {
                  CustomSnackBar.showSuccess(context, 'PDF cache cleared successfully! 🧹');
                }
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded, color: AppTheme.primaryTeal),
              title: Text('App Version', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
              subtitle: Text('NCERT Fun Books & Reader v1.0.0 (Build 1)', style: GoogleFonts.plusJakartaSans(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = widget.gamification.isDarkMode;
    final isDesktop = AppResponsive.isDesktop(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: MaxContentConstraint(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student Profile 👤',
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                  ),
                ),
                Text(
                  'Manage preferences, stats & account settings',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                  ),
                ),
                const SizedBox(height: 20),

                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            _buildProfileHeader(),
                            const SizedBox(height: 16),
                            _buildStatsCards(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 6,
                        child: _buildPreferencesList(),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildProfileHeader(),
                      const SizedBox(height: 16),
                      _buildStatsCards(),
                      const SizedBox(height: 20),
                      _buildPreferencesList(),
                    ],
                  ),

                const SizedBox(height: 20),
                const AdBannerWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
