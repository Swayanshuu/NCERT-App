import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ncert_books_app/models/ncert_book.dart';
import 'package:ncert_books_app/services/gamification_service.dart';
import 'package:ncert_books_app/services/ncert_repository.dart';
import 'package:ncert_books_app/services/pdf_cache_service.dart';
import 'package:ncert_books_app/theme/app_theme.dart';
import 'package:ncert_books_app/theme/app_responsive.dart';
import 'package:ncert_books_app/widgets/custom_snack_bar.dart';
import 'package:ncert_books_app/screens/books/widgets/downloaded_book_tile.dart';
import 'package:ncert_books_app/screens/books/widgets/chapter_explorer_modal.dart';
import 'package:ncert_books_app/screens/books/widgets/book_card.dart';
import 'package:ncert_books_app/screens/books/book_detail_screen.dart';
import 'package:ncert_books_app/screens/reader/pdf_viewer_screen.dart';

class DownloadsScreen extends StatefulWidget {
  final GamificationService gamification;

  const DownloadsScreen({super.key, required this.gamification});

  @override
  State<DownloadsScreen> createState() => DownloadsScreenState();
}

class DownloadsScreenState extends State<DownloadsScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  int _selectedSegmentIndex = 0;
  List<Map<String, dynamic>> _cachedBooks = [];
  bool _isLoading = true;
  String _totalStorageString = '0 KB';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging || _tabController.index != _selectedSegmentIndex) {
        if (mounted) {
          setState(() => _selectedSegmentIndex = _tabController.index);
        }
      }
    });
    widget.gamification.addListener(_onStateChanged);
    PdfCacheService().addListener(_onCacheChanged);
    _initAndLoad();
  }

  Future<void> _initAndLoad() async {
    if (!NcertRepository().isLoaded) {
      await NcertRepository().loadCatalog();
    }
    await _loadCachedBooks(showLoading: true);
  }

  void reload() {
    _loadCachedBooks(showLoading: false);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    widget.gamification.removeListener(_onStateChanged);
    PdfCacheService().removeListener(_onCacheChanged);
    super.dispose();
  }

  void _onCacheChanged() {
    if (mounted) {
      _loadCachedBooks(showLoading: false);
      setState(() {});
    }
  }

  void _onStateChanged() {
    if (mounted) {
      _loadCachedBooks(showLoading: false);
      setState(() {});
    }
  }

  Future<void> _loadCachedBooks({bool showLoading = false}) async {
    if (showLoading && _cachedBooks.isEmpty) {
      setState(() => _isLoading = true);
    }
    final cached = await PdfCacheService().getAllCachedBooksInfo();
    final storageStr = await PdfCacheService().getTotalStorageSizeString();
    if (mounted) {
      setState(() {
        _cachedBooks = cached;
        _totalStorageString = storageStr;
        _isLoading = false;
      });
    }
  }

  Future<void> _clearBookCache(String bookCode, String bookTitle) async {
    await PdfCacheService().deleteCachedBook(bookCode);
    await _loadCachedBooks();
    if (mounted) {
      CustomSnackBar.showSuccess(context, 'Cleared $bookTitle from offline vault');
    }
  }

  List<NcertBook> _getFavoriteBooksList() {
    final repo = NcertRepository();
    final favCodes = widget.gamification.favoriteBookCodes;
    final List<NcertBook> favorites = [];
    for (final code in favCodes) {
      final book = repo.findBookByCode(code);
      if (book != null && !favorites.any((b) => b.code == book.code)) {
        favorites.add(book);
      }
    }
    if (favorites.isEmpty && favCodes.isNotEmpty) {
      for (final cls in repo.getAvailableClasses()) {
        for (final subj in repo.getSubjectsForClass(cls)) {
          for (final book in repo.getBooks(cls, subj)) {
            if (widget.gamification.isFavorite(book.code) && !favorites.any((b) => b.code == book.code)) {
              favorites.add(book);
            }
          }
        }
      }
    }
    return favorites;
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF222222) : const Color(0xFFF1F1F4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 26,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 12.5,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillTab({
    required int index,
    required String title,
    required int count,
    required Color dotColor,
    required bool isDark,
  }) {
    final isSel = _selectedSegmentIndex == index;
    final bg = isSel
        ? (isDark ? Colors.white : const Color(0xFF18181B))
        : (isDark ? AppTheme.darkCard : const Color(0xFFF1F1F4));
    final textCol = isSel
        ? (isDark ? Colors.black : Colors.white)
        : (isDark ? AppTheme.darkTextSecondary : const Color(0xFF374151));

    return GestureDetector(
      onTap: () {
        _tabController.animateTo(index);
        setState(() => _selectedSegmentIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: isSel
              ? null
              : Border.all(
                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                  width: 1.0,
                ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: isSel ? textCol : dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$title ($count)',
              style: GoogleFonts.roboto(
                fontSize: 12.5,
                fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                color: textCol,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = widget.gamification.isDarkMode;
    final bookmarks = widget.gamification.bookmarks;
    final favoriteBooks = _getFavoriteBooksList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Title
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Library & Vault',
                      style: GoogleFonts.roboto(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Offline downloads, favorites & bookmarks • $_totalStorageString',
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.refresh_rounded,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                  size: 20,
                ),
                onPressed: _loadCachedBooks,
                tooltip: 'Sync Local Vault',
              ),
            ],
          ),
        ),

        // Pill Filter Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildPillTab(
                  index: 0,
                  title: 'Downloaded',
                  count: _cachedBooks.length,
                  dotColor: const Color(0xFF10B981),
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _buildPillTab(
                  index: 1,
                  title: 'Favorites',
                  count: favoriteBooks.length,
                  dotColor: const Color(0xFFEF4444),
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _buildPillTab(
                  index: 2,
                  title: 'Bookmarks',
                  count: bookmarks.length,
                  dotColor: const Color(0xFFF59E0B),
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // Tab 0: Downloaded Books
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : _cachedBooks.isEmpty
                      ? _buildEmptyState(
                          icon: Icons.cloud_download_outlined,
                          title: 'No Offline Downloads Yet',
                          subtitle: 'Downloaded books will appear here and open 100% offline from local disk.',
                          isDark: isDark,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 90),
                          itemCount: _cachedBooks.length,
                          itemBuilder: (context, idx) {
                            final item = _cachedBooks[idx];
                            final book = item['book'] as NcertBook?;
                            final files = item['files'] as List<File>;
                            final title = book?.text ?? (item['code'] as String);
                            return DownloadedBookTile(
                              item: item,
                              isDark: isDark,
                              onTap: () {
                                ChapterExplorerModal.show(
                                  context: context,
                                  bookTitle: title,
                                  files: files,
                                  book: book,
                                  isDark: isDark,
                                );
                              },
                              onDelete: () => _clearBookCache(item['code'] as String, title),
                            );
                          },
                        ),

              // Tab 1: Favorite Books
              favoriteBooks.isEmpty
                  ? _buildEmptyState(
                      icon: Icons.favorite_border_rounded,
                      title: 'No Favorites Saved',
                      subtitle: 'Tap the heart icon on any textbook to pin it to your favorites.',
                      isDark: isDark,
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = AppResponsive.getGridColumnCount(
                          context,
                          availableWidth: constraints.maxWidth,
                        );
                        return GridView.builder(
                          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 90),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: columns == 2 ? 0.88 : 0.95,
                          ),
                          itemCount: favoriteBooks.length,
                          itemBuilder: (context, idx) {
                            final book = favoriteBooks[idx];
                            return BookCard(
                              book: book,
                              gamification: widget.gamification,
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BookDetailScreen(
                                      book: book,
                                      gamification: widget.gamification,
                                    ),
                                  ),
                                );
                                if (mounted) {
                                  _loadCachedBooks(showLoading: false);
                                  setState(() {});
                                }
                              },
                            );
                          },
                        );
                      },
                    ),

              // Tab 2: Bookmarks
              bookmarks.isEmpty
                  ? _buildEmptyState(
                      icon: Icons.bookmark_border_rounded,
                      title: 'No Page Bookmarks',
                      subtitle: 'Bookmarks created while reading will appear here for 1-tap jump back.',
                      isDark: isDark,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 90),
                      itemCount: bookmarks.length,
                      itemBuilder: (context, idx) {
                        final bm = bookmarks[idx];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PdfViewerScreen(
                                      bookTitle: bm.bookTitle,
                                      chapterTitle: bm.chapterTitle,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isDark ? AppTheme.darkCard : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                                    width: 1.0,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.18 : 0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.bookmark_rounded,
                                        color: Color(0xFFF59E0B),
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            bm.bookTitle,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.roboto(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                                            ),
                                          ),
                                          Text(
                                            '${bm.chapterTitle} • Page ${bm.pageNumber}',
                                            style: GoogleFonts.roboto(
                                              fontSize: 11.5,
                                              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close_rounded, size: 16),
                                      onPressed: () {
                                        widget.gamification.toggleBookmark(bm);
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
