import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GlassToolbar extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final VoidCallback onDownload;
  final bool isDownloaded;
  final bool isDownloading;

  const GlassToolbar({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.onDownload,
    this.isDownloaded = false,
    this.isDownloading = false,
  });

  @override
  Widget build(BuildContext context) {
    const buttonBg = Color(0xFF181818);
    const borderColor = Color(0xFF282828);

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          // 1. Circular Back Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onBack,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: buttonBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 1.0),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  size: 19,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // 2. Center Pill Title Card
          Expanded(
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: buttonBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor, width: 1.0),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$title ',
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.2,
                            ),
                          ),
                          TextSpan(
                            text: '• $subtitle',
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF777777),
                              letterSpacing: -0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),

          // 3. Download to App Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onDownload,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: buttonBg,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDownloaded
                        ? const Color(0xFF10B981).withValues(alpha: 0.5)
                        : borderColor,
                    width: 1.0,
                  ),
                ),
                child: Center(
                  child: isDownloading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          isDownloaded
                              ? Icons.check_rounded
                              : Icons.download_rounded,
                          size: isDownloaded ? 18 : 20,
                          color: isDownloaded
                              ? const Color(0xFF10B981)
                              : Colors.white,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
