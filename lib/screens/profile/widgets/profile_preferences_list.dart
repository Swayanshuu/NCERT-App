import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ncert_books_app/services/gamification_service.dart';
import 'package:ncert_books_app/services/pdf_cache_service.dart';
import 'package:ncert_books_app/theme/app_theme.dart';
import 'package:ncert_books_app/widgets/custom_snack_bar.dart';
import 'package:ncert_books_app/screens/profile/settings_screen.dart';

class ProfilePreferencesList extends StatelessWidget {
  final GamificationService gamification;

  const ProfilePreferencesList({super.key, required this.gamification});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF282828),
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.settings_outlined, color: Color(0xFF10B981)),
            title: Text(
              'Settings & Storage',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w700,
                fontSize: 14.5,
                color: Colors.white,
              ),
            ),
            subtitle: Text(
              'Manage class, downloads & storage',
              style: GoogleFonts.roboto(
                fontSize: 12,
                color: const Color(0xFF777777),
              ),
            ),
            trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF777777)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(gamification: gamification),
                ),
              );
            },
          ),
          const Divider(
            color: Color(0xFF282828),
            height: 1,
          ),
          ListTile(
            leading: const Icon(Icons.cleaning_services_rounded, color: AppTheme.accentRose),
            title: Text(
              'Clear PDF Cache',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w700,
                fontSize: 14.5,
                color: Colors.white,
              ),
            ),
            subtitle: Text(
              'Free up offline local storage',
              style: GoogleFonts.roboto(
                fontSize: 12,
                color: const Color(0xFF777777),
              ),
            ),
            onTap: () async {
              await PdfCacheService().clearAllCache();
              if (context.mounted) {
                CustomSnackBar.showSuccess(context, 'PDF cache cleared successfully');
              }
            },
          ),
          const Divider(
            color: Color(0xFF282828),
            height: 1,
          ),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded, color: Color(0xFF6B7280)),
            title: Text(
              'App Version',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w700,
                fontSize: 14.5,
                color: Colors.white,
              ),
            ),
            subtitle: Text(
              'NCERT Books & Solutions v1.0.0',
              style: GoogleFonts.roboto(
                fontSize: 12,
                color: const Color(0xFF777777),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
