import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomSnackBar {
  static OverlayEntry? _currentOverlay;
  static Timer? _overlayTimer;

  // Professional static surface & border matching Threads by Meta styling
  static const Color _surfaceColor = Color(0xFF1E1E1E);
  static const Color _staticBorderColor = Color(0xFF333333);
  static const Color _successIconColor = Color(0xFF10B981);
  static const Color _errorIconColor = Color(0xFFEF4444);
  static const Color _infoIconColor = Color(0xFF94A3B8);
  static const Color _rewardIconColor = Color(0xFFF59E0B);

  static void showSuccess(
    BuildContext context,
    String message, {
    IconData icon = Icons.check_circle_rounded,
  }) {
    _show(
      context: context,
      message: message,
      icon: icon,
      iconColor: _successIconColor,
    );
  }

  static void showError(
    BuildContext context,
    String message, {
    IconData icon = Icons.error_outline_rounded,
  }) {
    _show(
      context: context,
      message: message,
      icon: icon,
      iconColor: _errorIconColor,
    );
  }

  static void showInfo(
    BuildContext context,
    String message, {
    IconData icon = Icons.info_outline_rounded,
  }) {
    _show(
      context: context,
      message: message,
      icon: icon,
      iconColor: _infoIconColor,
    );
  }

  static void showReward(
    BuildContext context,
    String message, {
    IconData icon = Icons.stars_rounded,
  }) {
    _show(
      context: context,
      message: message,
      icon: icon,
      iconColor: _rewardIconColor,
    );
  }

  static void _show({
    required BuildContext context,
    required String message,
    required IconData icon,
    required Color iconColor,
  }) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 750 || (!kIsWeb && Platform.isWindows);

    if (isDesktop) {
      _showDesktopToast(
        context: context,
        message: message,
        icon: icon,
        iconColor: iconColor,
      );
    } else {
      _showMobileSnackBar(
        context: context,
        message: message,
        icon: icon,
        iconColor: iconColor,
      );
    }
  }

  static void _showDesktopToast({
    required BuildContext context,
    required String message,
    required IconData icon,
    required Color iconColor,
  }) {
    _overlayTimer?.cancel();
    _currentOverlay?.remove();
    _currentOverlay = null;

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (ctx) => Positioned(
        top: 24,
        right: 28,
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 380),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _staticBorderColor,
                width: 1.0,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: iconColor,
                  size: 16,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      height: 1.25,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    _overlayTimer?.cancel();
                    entry.remove();
                    if (_currentOverlay == entry) {
                      _currentOverlay = null;
                    }
                  },
                  child: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF777777),
                    size: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    _currentOverlay = entry;
    overlay.insert(entry);

    _overlayTimer = Timer(const Duration(milliseconds: 2400), () {
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
    required Color iconColor,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 24, left: 20, right: 20),
        duration: const Duration(milliseconds: 2200),
        content: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _staticBorderColor,
                width: 1.0,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: iconColor,
                  size: 16,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      height: 1.25,
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
