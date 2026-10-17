import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer_text/shimmer_text.dart';
import 'package:ncert_books_app/theme/app_theme.dart';

class HomeHeader extends StatelessWidget {
  final bool isDark;
  final VoidCallback onProfileTap;

  const HomeHeader({
    super.key,
    required this.isDark,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/logo.png',
              width: 30,
              height: 30,
              fit: BoxFit.cover,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ShimmerText(
                textFamily:
                    GoogleFonts.allura(
                      fontWeight: FontWeight.bold,
                    ).fontFamily ??
                    'Allura',
                text: 'SWYNX',
                textSize: 22,
                textColor: Colors.white,
                shiningColor: const Color(0xFF777777),
                letterspacing: 2.0,
                duration: const Duration(seconds: 2),
              ),
              const SizedBox(height: 1),
              Text(
                'NCERT Books & Solutions',
                style: GoogleFonts.roboto(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppTheme.darkTextSecondary
                      : AppTheme.lightTextSecondary,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: onProfileTap,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? const Color(0xFF242424)
                    : const Color(0xFFF1F1F4),
                border: Border.all(
                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                  width: 1.0,
                ),
              ),
              child: Icon(
                Icons.person_rounded,
                size: 19,
                color: isDark ? Colors.white : AppTheme.lightTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
