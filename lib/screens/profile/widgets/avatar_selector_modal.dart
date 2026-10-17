import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncert_books_app/services/gamification_service.dart';
import 'package:ncert_books_app/screens/profile/bloc/profile_bloc.dart';

class AvatarHelper {
  static IconData getIcon(String avatar) {
    if (avatar.contains('Owl')) return Icons.school_rounded;
    if (avatar.contains('Fox')) return Icons.psychology_rounded;
    if (avatar.contains('Space')) return Icons.rocket_launch_rounded;
    if (avatar.contains('Panda')) return Icons.eco_rounded;
    if (avatar.contains('Bunny')) return Icons.bolt_rounded;
    return Icons.person_rounded;
  }

  static Color getColor(String avatar) {
    if (avatar.contains('Owl')) return const Color(0xFF38BDF8);
    if (avatar.contains('Fox')) return const Color(0xFFF97316);
    if (avatar.contains('Space')) return const Color(0xFFA855F7);
    if (avatar.contains('Panda')) return const Color(0xFF10B981);
    if (avatar.contains('Bunny')) return const Color(0xFFF59E0B);
    return const Color(0xFF3B82F6);
  }
}

class AvatarSelectorModal extends StatelessWidget {
  final GamificationService gamification;

  const AvatarSelectorModal({super.key, required this.gamification});

  static void show(BuildContext context, GamificationService gamification) {
    final isDark = gamification.isDarkMode;
    final mediaQuery = MediaQuery.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: mediaQuery.size.height * 0.70,
            maxWidth: 600,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF181818) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? const Color(0xFF282828) : const Color(0xFFE5E7EB),
              width: 1.0,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: AvatarSelectorModal(gamification: gamification),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatars = GamificationService.avatars;
    final isDark = gamification.isDarkMode;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Choose Avatar',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF111827),
                letterSpacing: -0.3,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: avatars.length,
            itemBuilder: (context, idx) {
              final av = avatars[idx];
              final isSel = gamification.currentAvatar == av;
              final icon = AvatarHelper.getIcon(av);
              final iconColor = AvatarHelper.getColor(av);

              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: InkWell(
                  onTap: () {
                    context.read<ProfileBloc>().add(ProfileAvatarUpdated(av));
                    gamification.setAvatar(av);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSel
                          ? (isDark ? const Color(0xFF222222) : const Color(0xFFF3F4F6))
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSel
                            ? (isDark ? const Color(0xFF333333) : const Color(0xFFE2E8F0))
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(icon, color: iconColor, size: 22),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            av,
                            style: GoogleFonts.roboto(
                              fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 14.5,
                              color: isDark ? Colors.white : const Color(0xFF111827),
                            ),
                          ),
                        ),
                        if (isSel)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF38BDF8),
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
