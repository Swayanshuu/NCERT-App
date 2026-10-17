import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncert_books_app/services/gamification_service.dart';
import 'package:ncert_books_app/theme/app_theme.dart';
import 'package:ncert_books_app/theme/app_responsive.dart';
import 'package:ncert_books_app/widgets/custom_snack_bar.dart';
import 'package:ncert_books_app/widgets/ad_banner_widget.dart';
import 'package:ncert_books_app/screens/profile/bloc/profile_bloc.dart';
import 'package:ncert_books_app/screens/profile/widgets/avatar_selector_modal.dart';
import 'package:ncert_books_app/screens/profile/widgets/profile_header_card.dart';
import 'package:ncert_books_app/screens/profile/widgets/profile_stats_bar.dart';
import 'package:ncert_books_app/screens/profile/widgets/profile_preferences_list.dart';

class ProfileScreen extends StatefulWidget {
  final GamificationService gamification;

  const ProfileScreen({super.key, required this.gamification});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
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
    final isDark = widget.gamification.isDarkMode;
    final controller = TextEditingController(
      text: widget.gamification.userName,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF181818) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isDark ? const Color(0xFF282828) : const Color(0xFFE5E7EB),
          ),
        ),
        title: Text(
          'Edit Student Name',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: GoogleFonts.roboto(
              color: isDark ? const Color(0xFF777777) : const Color(0xFF9CA3AF),
            ),
            filled: true,
            fillColor: isDark
                ? const Color(0xFF222222)
                : const Color(0xFFF3F4F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? const Color(0xFF333333)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? const Color(0xFF333333)
                    : const Color(0xFFE2E8F0),
              ),
            ),
          ),
          style: GoogleFonts.roboto(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.roboto(
                color: isDark ? const Color(0xFF777777) : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.white : const Color(0xFF18181B),
              foregroundColor: isDark ? const Color(0xFF181818) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                context.read<ProfileBloc>().add(ProfileNameUpdated(newName));
                widget.gamification.setUserName(newName);
              }
              Navigator.pop(ctx);
              CustomSnackBar.showSuccess(
                context,
                'Name updated to ${widget.gamification.userName}',
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
    super.build(context);
    final isDark = widget.gamification.isDarkMode;

    return MaxContentConstraint(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: 95,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile',
              style: GoogleFonts.roboto(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppTheme.darkTextPrimary
                    : AppTheme.lightTextPrimary,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Personal learning stats, streak & app settings',
              style: GoogleFonts.roboto(
                fontSize: 13,
                color: isDark
                    ? AppTheme.darkTextMuted
                    : AppTheme.lightTextMuted,
              ),
            ),
            const SizedBox(height: 18),

            ProfileHeaderCard(
              userName: widget.gamification.userName,
              userClass: widget.gamification.userClass,
              level: widget.gamification.level,
              currentAvatar: widget.gamification.currentAvatar,
              onTapAvatar: () =>
                  AvatarSelectorModal.show(context, widget.gamification),
              onTapEditName: _showEditNameDialog,
            ),
            const SizedBox(height: 14),

            ProfileStatsBar(
              xp: widget.gamification.xp,
              streak: widget.gamification.streak,
              favoritesCount: widget.gamification.favoriteBookCodes.length,
            ),
            const SizedBox(height: 18),

            ProfilePreferencesList(gamification: widget.gamification),
            const SizedBox(height: 20),

            const AdBannerWidget(),
          ],
        ),
      ),
    );
  }
}
