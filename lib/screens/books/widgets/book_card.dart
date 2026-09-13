import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:ncert_books_app/models/ncert_book.dart';
import 'package:ncert_books_app/services/gamification_service.dart';
import 'package:ncert_books_app/theme/app_theme.dart';
import 'package:ncert_books_app/widgets/liquid/liquid_card.dart';
import 'package:ncert_books_app/widgets/painters/subject_background_painter.dart';

class BookCard extends StatelessWidget {
  final NcertBook book;
  final GamificationService gamification;
  final VoidCallback onTap;

  const BookCard({
    super.key,
    required this.book,
    required this.gamification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = gamification.isDarkMode;
    final isFav = gamification.isFavorite(book.code);
    final subjectColor = AppTheme.getSubjectColor(book.subject);
    final subjectIcon = AppTheme.getSubjectIcon(book.subject);

    return LiquidCard(
      onTap: onTap,
      borderRadius: 24,
      padding: EdgeInsets.zero,
      blurSigma: 16,
      borderColor: isDark
          ? Colors.white.withValues(alpha: 0.14)
          : AppTheme.lightBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Cover Graphic Section
          Expanded(
            flex: 50,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: SubjectBackgroundPainter(
                      subject: book.subject,
                      isDark: isDark,
                    ),
                  ),
                ),

                // Class Pill Top Left
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.60)
                          : Colors.white.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: subjectColor.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Class ${book.className}',
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: subjectColor,
                      ),
                    ),
                  ),
                ),

                // Favorite Heart Top Right
                Positioned(
                  top: 2,
                  right: 2,
                  child: IconButton(
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(5),
                    icon: Icon(
                      isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFav ? AppTheme.accentRose : (isDark ? Colors.white70 : Colors.black45),
                      size: 19,
                    ),
                    onPressed: () {
                      gamification.toggleFavorite(book.code);
                    },
                  ),
                ),

                // Center Big Subject Icon
                Center(
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: subjectColor.withValues(alpha: 0.22),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: subjectColor.withValues(alpha: 0.60),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      subjectIcon,
                      color: subjectColor,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Book Info Section
          Expanded(
            flex: 50,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: subjectColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                book.subject.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  color: subjectColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),

                        // Book Title
                        Flexible(
                          child: AutoSizeText(
                            book.text,
                            maxLines: 2,
                            minFontSize: 9,
                            maxFontSize: 13,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                              height: 1.15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Footer Row: Chapters & Action Arrow
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.collections_bookmark_rounded,
                            size: 12,
                            color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${book.maxChapterNumber} Chapters',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: subjectColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 13,
                          color: subjectColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
