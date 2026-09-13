import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'glass_surface.dart';
import '../../theme/app_theme.dart';

class GlassSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final String hintText;
  final bool isDark;

  const GlassSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onClear,
    this.hintText = 'Search NCERT books, subjects, chapters...',
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      height: 52,
      borderRadius: 26,
      blurSigma: 20,
      color: isDark
          ? AppTheme.darkSurface.withValues(alpha: 0.90)
          : Colors.white.withValues(alpha: 0.94),
      borderColor: isDark
          ? AppTheme.primaryTeal.withValues(alpha: 0.50)
          : AppTheme.primaryTeal.withValues(alpha: 0.70),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.40)
              : AppTheme.primaryTealDark.withValues(alpha: 0.12),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Icon(
              Icons.search_rounded,
              color: AppTheme.primaryTeal,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: GoogleFonts.plusJakartaSans(
                    color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                ),
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                ),
              ),
            ),
            if (controller.text.isNotEmpty)
              IconButton(
                icon: const Icon(
                  Icons.clear_rounded,
                  color: AppTheme.accentRose,
                  size: 20,
                ),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                  onClear?.call();
                },
              ),
          ],
        ),
      ),
    );
  }
}
