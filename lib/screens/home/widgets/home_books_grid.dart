import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ncert_books_app/models/ncert_book.dart';
import 'package:ncert_books_app/services/gamification_service.dart';
import 'package:ncert_books_app/screens/books/widgets/book_card.dart';
import 'package:ncert_books_app/screens/books/book_detail_screen.dart';
import 'package:ncert_books_app/theme/app_responsive.dart';

class HomeBooksGrid extends StatelessWidget {
  final List<NcertBook> booksToDisplay;
  final int currentPage;
  final int pageSize;
  final bool isDark;
  final GamificationService gamification;
  final VoidCallback onStateChanged;

  const HomeBooksGrid({
    super.key,
    required this.booksToDisplay,
    required this.currentPage,
    required this.pageSize,
    required this.isDark,
    required this.gamification,
    required this.onStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (booksToDisplay.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 48,
                  color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                ),
                const SizedBox(height: 12),
                Text(
                  'No books found matching criteria',
                  style: GoogleFonts.roboto(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final maxCount = booksToDisplay.length;
    final displayedCount = (currentPage * pageSize).clamp(0, maxCount);
    final hasMore = displayedCount < maxCount;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = AppResponsive.getGridColumnCount(
          context,
          availableWidth: constraints.maxWidth,
        );

        return SliverMainAxisGroup(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 16,
              ),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: columns == 2 ? 0.88 : 0.95,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final book = booksToDisplay[index];
                    return BookCard(
                      book: book,
                      gamification: gamification,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookDetailScreen(
                              book: book,
                              gamification: gamification,
                            ),
                          ),
                        );
                        onStateChanged();
                      },
                    );
                  },
                  childCount: displayedCount,
                ),
              ),
            ),

            // Subtle loader when more items exist
            if (hasMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF777777),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
