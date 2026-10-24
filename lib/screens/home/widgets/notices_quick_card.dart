import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/gamification_service.dart';
import '../../../services/ncert_notices_service.dart';
import '../../notices/notices_screen.dart';

class NoticesQuickCard extends StatelessWidget {
  final bool isDark;
  final GamificationService gamification;

  const NoticesQuickCard({
    super.key,
    required this.isDark,
    required this.gamification,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: NcertNoticesService.instance,
      builder: (context, _) {
        final noticesService = NcertNoticesService.instance;
        final latestNotice = noticesService.notices.isNotEmpty
            ? noticesService.notices.first
            : null;

        const cardBg = Color.fromARGB(
          255,
          255,
          123,
          0,
        ); // High-contrast clean off-white
        const textTitle = Color(0xFF0F172A);
        const textSubtitle = Color(0xFF475569);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      NoticesScreen(gamification: gamification),
                ),
              );
            },
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(210, 255, 255, 255),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notice header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Badge icon
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(
                            0xFF0284C7,
                          ).withValues(alpha: 0.15),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.campaign_rounded,
                            color: Color(0xFF0284C7),
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 11),

                      // Title & subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    'NCERT Official Notices',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.outfit(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: textTitle,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  size: 18,
                                  color: Color(0xFF0F172A),
                                ),
                              ],
                            ),
                            const SizedBox(height: 1),
                            Text(
                              latestNotice != null
                                  ? latestNotice.title
                                  : 'Live circulars, curriculum & exam releases',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.roboto(
                                fontSize: 11.5,
                                color: textSubtitle,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Source badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5.5,
                              height: 5.5,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFF59E0B),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'ncert.nic.in',
                              style: GoogleFonts.roboto(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Tags
                  Row(
                    children: [
                      // Sub-pill 1: Format
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4.5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2EBF0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.picture_as_pdf_rounded,
                              size: 13,
                              color: Color(0xFF475569),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Official Circulars & PDFs',
                              style: GoogleFonts.roboto(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Sub-pill 2: Action badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4.5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF0284C7,
                          ).withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.open_in_new_rounded,
                              size: 12,
                              color: Color(0xFF0284C7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'View All',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0284C7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
