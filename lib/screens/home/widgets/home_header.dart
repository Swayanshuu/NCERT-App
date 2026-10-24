import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeHeader extends StatelessWidget {
  final bool isDark;
  final VoidCallback? onProfileTap;
  final VoidCallback? onMenuTap;
  final VoidCallback? onNoticesTap;
  final bool hasUnreadNotices;

  const HomeHeader({
    super.key,
    required this.isDark,
    this.onProfileTap,
    this.onMenuTap,
    this.onNoticesTap,
    this.hasUnreadNotices = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // NCERT brand title
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'NCERT',
                    style: GoogleFonts.outfit(
                      fontSize: 27,
                      color: isDark ? Colors.white : const Color(0xFF111827),
                    ),
                  ),
                  Text(
                    '.',
                    style: GoogleFonts.outfit(
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF38BDF8),
                    ),
                  ),
                ],
              ),
              Text(
                'Books & News',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  color: const Color.fromARGB(255, 142, 142, 142),
                ),
              ),
            ],
          ),

          // Menu button (opens drawer from left)
          GestureDetector(
            onTap: onMenuTap ?? onProfileTap,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 36,
              height: 36,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 22,
                      height: 2.2,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white : const Color(0xFF111827),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      width: 16,
                      height: 2.2,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white : const Color(0xFF111827),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
