import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ncert_books_app/screens/profile/widgets/avatar_selector_modal.dart';

class ProfileHeaderCard extends StatelessWidget {
  final String userName;
  final String userClass;
  final int level;
  final String currentAvatar;
  final VoidCallback onTapAvatar;
  final VoidCallback onTapEditName;

  const ProfileHeaderCard({
    super.key,
    required this.userName,
    required this.userClass,
    required this.level,
    required this.currentAvatar,
    required this.onTapAvatar,
    required this.onTapEditName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final icon = AvatarHelper.getIcon(currentAvatar);
    final iconColor = AvatarHelper.getColor(currentAvatar);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181818) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF282828) : const Color(0xFFE5E7EB),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onTapAvatar,
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: iconColor.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Icon(icon, color: iconColor, size: 28),
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
                    Flexible(
                      child: Text(
                        userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      onPressed: onTapEditName,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF222222) : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Class $userClass • Level $level',
                    style: GoogleFonts.roboto(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF4B5563),
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
}
