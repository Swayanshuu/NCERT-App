import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:ncert_books_app/models/ncert_book.dart';
import 'package:ncert_books_app/services/gamification_service.dart';
import 'package:ncert_books_app/services/ncert_repository.dart';
import 'package:ncert_books_app/services/pdf_cache_service.dart';
import 'package:ncert_books_app/theme/app_theme.dart';
import 'package:ncert_books_app/theme/app_responsive.dart';
import 'package:ncert_books_app/widgets/custom_snack_bar.dart';
import 'package:ncert_books_app/widgets/glass/glass_card.dart';
import 'package:ncert_books_app/widgets/glass/glass_surface.dart';
import 'package:ncert_books_app/widgets/glass/glass_button.dart';
import 'package:ncert_books_app/widgets/glass/glass_segmented_control.dart';
import 'package:ncert_books_app/screens/reader/pdf_viewer_screen.dart';
import 'package:ncert_books_app/screens/books/book_detail_screen.dart';

class DownloadsScreen extends StatefulWidget {
  final GamificationService gamification;

  const DownloadsScreen({super.key, required this.gamification});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  int _selectedSegmentIndex = 0;
  List<Map<String, dynamic>> _cachedBooks = [];
  Map<String, dynamic>? _selectedDesktopBook;
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
          setState(() {
            _selectedSegmentIndex = _tabController.index;
          });
        }
      }
    });
    widget.gamification.addListener(_onStateChanged);
    _loadCachedBooks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    widget.gamification.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadCachedBooks() async {
    setState(() => _isLoading = true);
    final cached = await PdfCacheService().getAllCachedBooksInfo();
    final storageStr = await PdfCacheService().getTotalStorageSizeString();
    if (mounted) {
      setState(() {
        _cachedBooks = cached;
        _totalStorageString = storageStr;
        if (cached.isNotEmpty) {
          _selectedDesktopBook = cached.first;
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _clearBookCache(String bookCode, String bookTitle) async {
    await PdfCacheService().deleteCachedBook(bookCode);
    await _loadCachedBooks();
    if (mounted) {
      CustomSnackBar.showSuccess(context, 'Cleared $bookTitle from offline vault 🗑️');
    }
  }

  void _openOfflinePdfFile(File pdfFile, String bookTitle, String chapterTitle, NcertBook? book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfViewerScreen(
          pdfFile: pdfFile, // Direct local file: ZERO remote API calls needed!
          bookTitle: bookTitle,
          chapterTitle: chapterTitle,
          book: book,
        ),
      ),
    );
  }

  List<NcertBook> _getFavoriteBooksList() {
    final repo = NcertRepository();
    final List<NcertBook> favorites = [];
    for (final cls in repo.getAvailableClasses()) {
      for (final subj in repo.getSubjectsForClass(cls)) {
        for (final book in repo.getBooks(cls, subj)) {
          if (widget.gamification.isFavorite(book.code) && !favorites.any((b) => b.code == book.code)) {
            favorites.add(book);
          }
        }
      }
    }
    return favorites;
  }

  String _getChapterTitleFromFileName(String filePath) {
    final clean = filePath.split(RegExp(r'[/\\]')).last.toLowerCase();
    if (clean.contains('ps')) return 'Preliminary Pages';
    final match = RegExp(r'(\d+)').firstMatch(clean);
    if (match != null) {
      final numStr = match.group(1)!;
      final chNum = int.tryParse(numStr.length > 2 ? numStr.substring(numStr.length - 2) : numStr) ?? 1;
      return 'Chapter $chNum';
    }
    return 'Chapter 1';
  }

  void _showChapterExplorerModal(String bookTitle, List<File> files, NcertBook? book) {
    final isDark = widget.gamification.isDarkMode;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          margin: const EdgeInsets.all(16),
          child: GlassSurface(
            borderRadius: 28,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bookTitle,
                            style: GoogleFonts.outfit(fontSize: 19, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${files.length} Offline Chapter PDFs • Local Disk Cache',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.primaryTeal),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: files.length,
                    itemBuilder: (ctx, idx) {
                      final f = files[idx];
                      final chTitle = _getChapterTitleFromFileName(f.path);
                      final fName = f.path.split(RegExp(r'[/\\]')).last;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: GlassCard(
                          borderRadius: 16,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          onTap: () {
                            Navigator.pop(ctx);
                            _openOfflinePdfFile(f, bookTitle, chTitle, book);
                          },
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryTeal.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.picture_as_pdf_rounded, color: AppTheme.primaryTeal, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      chTitle,
                                      style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '$fName • Offline Ready (0 Network Calls)',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.play_circle_fill_rounded, color: AppTheme.primaryTeal, size: 22),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
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
    final isDesktop = AppResponsive.isDesktop(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: MaxContentConstraint(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title with Expanded text to fix overflow bug
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Library & Vault 📚',
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                            ),
                          ),
                          Text(
                            'Offline PDF downloads, favorites & bookmarks • $_totalStorageString',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryTeal),
                      onPressed: _loadCachedBooks,
                      tooltip: 'Sync Local Vault',
                    ),
                  ],
                ),
              ),

              // 3-Segment Control Bar (Downloaded, Favorites, Bookmarks)
              GlassSegmentedControl(
                selectedIndex: _selectedSegmentIndex,
                onSegmentSelected: (index) {
                  setState(() {
                    _selectedSegmentIndex = index;
                  });
                  _tabController.animateTo(index);
                },
                segments: [
                  GlassSegmentItem(
                    label: 'Downloaded',
                    icon: Icons.offline_pin_rounded,
                    badgeText: _cachedBooks.isNotEmpty ? '${_cachedBooks.length}' : null,
                  ),
                  GlassSegmentItem(
                    label: 'Favorites',
                    icon: Icons.favorite_rounded,
                    badgeText: favoriteBooks.isNotEmpty ? '${favoriteBooks.length}' : null,
                  ),
                  GlassSegmentItem(
                    label: 'Bookmarks',
                    icon: Icons.bookmark_rounded,
                    badgeText: bookmarks.isNotEmpty ? '${bookmarks.length}' : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // Tab 0: Downloaded Books (Guaranteed Offline PDF reading without API calls)
                    _isLoading
                        ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal))
                        : _cachedBooks.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.cloud_download_rounded, size: 54, color: AppTheme.primaryTeal),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No Offline Downloads Yet',
                                      style: GoogleFonts.outfit(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Downloaded books appear here and open 100% offline from local disk',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : isDesktop
                                ? Row(
                                    children: [
                                      // Left Book List
                                      SizedBox(
                                        width: 360,
                                        child: ListView.builder(
                                          padding: const EdgeInsets.only(left: 20, right: 10, bottom: 90),
                                          itemCount: _cachedBooks.length,
                                          itemBuilder: (context, idx) {
                                            final item = _cachedBooks[idx];
                                            final isSel = _selectedDesktopBook?['code'] == item['code'];
                                            final files = item['files'] as List<File>;
                                            return Container(
                                              margin: const EdgeInsets.only(bottom: 10),
                                              child: GlassCard(
                                                borderRadius: 18,
                                                borderColor: isSel ? AppTheme.primaryTeal : null,
                                                onTap: () {
                                                  setState(() => _selectedDesktopBook = item);
                                                },
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.offline_pin_rounded,
                                                      color: isSel ? AppTheme.primaryTeal : Colors.grey,
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            item['title'] as String,
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                                                          ),
                                                          Text(
                                                            '${files.length} Offline PDFs',
                                                            style: GoogleFonts.plusJakartaSans(
                                                              fontSize: 11,
                                                              color: AppTheme.primaryTeal,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),

                                      // Right Detail Pane
                                      Expanded(
                                        child: _selectedDesktopBook == null
                                            ? const SizedBox.shrink()
                                            : Padding(
                                                padding: const EdgeInsets.only(right: 20, bottom: 90),
                                                child: GlassCard(
                                                  borderRadius: 24,
                                                  padding: const EdgeInsets.all(24),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        _selectedDesktopBook!['title'] as String,
                                                        style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        'Offline Local Storage • Instant Reading (0 Network Calls)',
                                                        style: GoogleFonts.plusJakartaSans(color: AppTheme.primaryTeal),
                                                      ),
                                                      const SizedBox(height: 16),
                                                      Text(
                                                        'Downloaded Chapter Files (${(_selectedDesktopBook!['files'] as List).length}):',
                                                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
                                                      ),
                                                      const SizedBox(height: 10),
                                                      Expanded(
                                                        child: ListView.builder(
                                                          itemCount: (_selectedDesktopBook!['files'] as List<File>).length,
                                                          itemBuilder: (ctx, fIdx) {
                                                            final f = (_selectedDesktopBook!['files'] as List<File>)[fIdx];
                                                            final chTitle = _getChapterTitleFromFileName(f.path);
                                                            final fName = f.path.split(RegExp(r'[/\\]')).last;
                                                            return Container(
                                                              margin: const EdgeInsets.only(bottom: 8),
                                                              child: ListTile(
                                                                tileColor: isDark
                                                                    ? AppTheme.darkSurface.withValues(alpha: 0.6)
                                                                    : Colors.grey.shade100,
                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                                                leading: const Icon(Icons.picture_as_pdf_rounded, color: AppTheme.primaryTeal),
                                                                title: Text(
                                                                  chTitle,
                                                                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
                                                                ),
                                                                subtitle: Text(
                                                                  '$fName • Local Disk Cache',
                                                                  style: GoogleFonts.plusJakartaSans(fontSize: 10.5),
                                                                ),
                                                                trailing: const Icon(Icons.play_circle_fill_rounded, color: AppTheme.primaryTeal),
                                                                onTap: () {
                                                                  _openOfflinePdfFile(
                                                                    f,
                                                                    _selectedDesktopBook!['title'] as String,
                                                                    chTitle,
                                                                    _selectedDesktopBook!['book'] as NcertBook?,
                                                                  );
                                                                },
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      const SizedBox(height: 12),
                                                      GlassButton(
                                                        label: 'Clear Offline Vault Files',
                                                        icon: Icons.delete_outline_rounded,
                                                        variant: GlassButtonVariant.ghost,
                                                        onPressed: () => _clearBookCache(
                                                          _selectedDesktopBook!['code'] as String,
                                                          _selectedDesktopBook!['title'] as String,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ],
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 90),
                                    itemCount: _cachedBooks.length,
                                    itemBuilder: (context, idx) {
                                      final item = _cachedBooks[idx];
                                      final code = item['code'] as String;
                                      final title = item['title'] as String;
                                      final files = item['files'] as List<File>;
                                      final book = item['book'] as NcertBook?;

                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        child: GlassCard(
                                          borderRadius: 20,
                                          padding: const EdgeInsets.all(16),
                                          onTap: () => _showChapterExplorerModal(title, files, book),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 46,
                                                height: 46,
                                                decoration: BoxDecoration(
                                                  color: AppTheme.primaryTeal.withValues(alpha: 0.18),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.offline_pin_rounded,
                                                  color: AppTheme.primaryTeal,
                                                  size: 24,
                                                ),
                                              ),
                                              const SizedBox(width: 14),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      title,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: GoogleFonts.outfit(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 3),
                                                    Text(
                                                      '${files.length} Offline Files • Tap to select chapter',
                                                      style: GoogleFonts.plusJakartaSans(
                                                        fontSize: 12,
                                                        color: AppTheme.primaryTeal,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Icon(
                                                Icons.chevron_right_rounded,
                                                color: AppTheme.primaryTeal,
                                                size: 24,
                                              ),
                                              const SizedBox(width: 4),
                                              IconButton(
                                                icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.accentRose),
                                                onPressed: () => _clearBookCache(code, title),
                                                tooltip: 'Delete downloaded book',
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                    // Tab 1: Favorite Books Section
                    favoriteBooks.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.favorite_border_rounded, size: 54, color: AppTheme.accentRose),
                                const SizedBox(height: 12),
                                Text(
                                  'No Favorite Books Yet',
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tap the heart icon ❤️ on any book to add it to your favorites',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 90),
                            itemCount: favoriteBooks.length,
                            itemBuilder: (context, idx) {
                              final book = favoriteBooks[idx];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: GlassCard(
                                  borderRadius: 20,
                                  padding: const EdgeInsets.all(16),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BookDetailScreen(
                                          book: book,
                                          gamification: widget.gamification,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: AppTheme.accentRose.withValues(alpha: 0.18),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.favorite_rounded,
                                          color: AppTheme.accentRose,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              book.text,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.outfit(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Class ${book.className} • ${book.subject.toUpperCase()}',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 12,
                                                color: AppTheme.accentRose,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.favorite_rounded, color: AppTheme.accentRose),
                                        onPressed: () {
                                          widget.gamification.toggleFavorite(book.code);
                                          CustomSnackBar.showInfo(context, 'Removed from favorites');
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                    // Tab 2: Saved Bookmarks
                    bookmarks.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.bookmark_border_rounded, size: 54, color: AppTheme.accentAmber),
                                const SizedBox(height: 12),
                                Text(
                                  'No Saved Bookmarks',
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tap star/bookmark inside PDF viewer to save pages',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 90),
                            itemCount: bookmarks.length,
                            itemBuilder: (context, idx) {
                              final b = bookmarks[idx];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: GlassCard(
                                  borderRadius: 20,
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: AppTheme.accentAmber.withValues(alpha: 0.18),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.star_rounded,
                                          color: AppTheme.accentAmber,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              b.bookTitle,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.outfit(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${b.chapterTitle} • Page ${b.pageNumber}',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 12,
                                                color: AppTheme.accentAmber,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close_rounded, size: 20, color: AppTheme.accentRose),
                                        onPressed: () {
                                          widget.gamification.removeBookmark(b.id);
                                          CustomSnackBar.showInfo(context, 'Bookmark removed');
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
