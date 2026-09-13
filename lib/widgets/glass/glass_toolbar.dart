import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'glass_surface.dart';
import '../../theme/app_theme.dart';

class GlassToolbar extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isBookmarked;
  final VoidCallback onBack;
  final VoidCallback onBookmarkToggle;
  final VoidCallback onPaletteTap;

  const GlassToolbar({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isBookmarked,
    required this.onBack,
    required this.onBookmarkToggle,
    required this.onPaletteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      height: 60,
      borderRadius: 24,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      blurSigma: 20,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: onBack,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.primaryTeal),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.star_rounded : Icons.star_border_rounded,
              color: isBookmarked ? AppTheme.accentAmber : null,
            ),
            onPressed: onBookmarkToggle,
          ),
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            onPressed: onPaletteTap,
          ),
        ],
      ),
    );
  }
}
