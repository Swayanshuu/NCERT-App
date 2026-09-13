import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../theme/app_theme.dart';

class CustomSnackBar {
  static OverlayEntry? _currentOverlay;
  static Timer? _overlayTimer;

  static void showSuccess(BuildContext context, String message, {IconData icon = Icons.check_circle_rounded}) {
    _show(
      context: context,
      message: message,
      icon: icon,
      accentColor: AppTheme.duoGreen,
    );
  }

  static void showError(BuildContext context, String message, {IconData icon = Icons.warning_amber_rounded}) {
    _show(
      context: context,
      message: message,
      icon: icon,
      accentColor: AppTheme.duoRed,
    );
  }

  static void showInfo(BuildContext context, String message, {IconData icon = Icons.info_rounded}) {
    _show(
      context: context,
      message: message,
      icon: icon,
      accentColor: AppTheme.duoCyan,
    );
  }

  static void showReward(BuildContext context, String message, {IconData icon = Icons.stars_rounded}) {
    _show(
      context: context,
      message: message,
      icon: icon,
      accentColor: AppTheme.duoYellow,
    );
  }

  static void _show({
    required BuildContext context,
    required String message,
    required IconData icon,
    required Color accentColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 750 || (!kIsWeb && Platform.isWindows);

    if (isDesktop) {
      _showTopRightDesktopToast(
        context: context,
        message: message,
        icon: icon,
        accentColor: accentColor,
        isDark: isDark,
      );
    } else {
      _showMobileSnackBar(
        context: context,
        message: message,
        icon: icon,
        accentColor: accentColor,
        isDark: isDark,
      );
    }
  }

  static void _showTopRightDesktopToast({
    required BuildContext context,
    required String message,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
  }) {
    _overlayTimer?.cancel();
    _currentOverlay?.remove();
    _currentOverlay = null;

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    final cardBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFFFFFFF);
    final textCol = isDark ? Colors.white : const Color(0xFF0F172A);

    entry = OverlayEntry(
      builder: (ctx) => Positioned(
        top: 24,
        right: 28,
        child: Material(
          color: Colors.transparent,
          child: SizedBox(
            width: 320,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: cardBg.withValues(alpha: isDark ? 0.90 : 0.95),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.80),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.50)
                            : accentColor.withValues(alpha: 0.20),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: isDark ? 0.22 : 0.14),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.40),
                            width: 1,
                          ),
                        ),
                        child: Icon(icon, color: accentColor, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AutoSizeText(
                          message,
                          maxLines: 2,
                          minFontSize: 11,
                          style: GoogleFonts.outfit(
                            color: textCol,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          _overlayTimer?.cancel();
                          entry.remove();
                          if (_currentOverlay == entry) {
                            _currentOverlay = null;
                          }
                        },
                        child: Icon(
                          Icons.close_rounded,
                          color: isDark ? Colors.white60 : Colors.grey.shade600,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    _currentOverlay = entry;
    overlay.insert(entry);

    _overlayTimer = Timer(const Duration(seconds: 3), () {
      if (_currentOverlay == entry) {
        entry.remove();
        _currentOverlay = null;
      }
    });
  }

  static void _showMobileSnackBar({
    required BuildContext context,
    required String message,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
  }) {
    final cardBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFFFFFFF);
    final textCol = isDark ? Colors.white : const Color(0xFF0F172A);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        duration: const Duration(seconds: 3),
        content: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: cardBg.withValues(alpha: isDark ? 0.90 : 0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.80),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.45)
                        : accentColor.withValues(alpha: 0.20),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: isDark ? 0.22 : 0.14),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.40),
                        width: 1,
                      ),
                    ),
                    child: Icon(icon, color: accentColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AutoSizeText(
                      message,
                      maxLines: 2,
                      minFontSize: 11,
                      style: GoogleFonts.outfit(
                        color: textCol,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
