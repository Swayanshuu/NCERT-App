import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'dart:io';
import 'package:ncert_books_app/models/ncert_book.dart';
import 'package:ncert_books_app/theme/app_theme.dart';
import 'package:ncert_books_app/theme/app_responsive.dart';
import 'package:ncert_books_app/services/pdf_cache_service.dart';
import 'package:ncert_books_app/services/gamification_service.dart';
import 'package:ncert_books_app/widgets/ad_banner_widget.dart';
import 'package:ncert_books_app/widgets/confetti_overlay.dart';
import 'package:ncert_books_app/widgets/custom_snack_bar.dart';
import 'package:ncert_books_app/screens/reader/pdf_viewer_screen.dart';

class BookDetailScreen extends StatefulWidget {
  final NcertBook book;
  final GamificationService gamification;

  const BookDetailScreen({
    super.key,
    required this.book,
    required this.gamification,
  });

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  bool _isCached = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String _downloadStatus = '';
  List<File> _cachedFiles = [];
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    widget.gamification.addListener(_onStateChanged);
    widget.gamification.recordSubjectExplored(widget.book.subject);
    _isCached = PdfCacheService().isBookCachedSync(widget.book.code);
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _checkStatus();
  }

  @override
  void dispose() {
    widget.gamification.removeListener(_onStateChanged);
    _confettiController.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _checkStatus() async {
    final cached = await PdfCacheService().isBookCached(widget.book.code);
    List<File> files = [];
    if (cached) {
      files = await PdfCacheService().getCachedPdfFiles(widget.book.code);
    }
    if (mounted) {
      setState(() {
        _isCached = cached;
        _cachedFiles = files;
      });
    }
  }

  Future<void> _startDownload() async {
    if (_isCached) {
      CustomSnackBar.showInfo(context, 'This book is already saved offline in your vault.');
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _downloadStatus = 'Initializing...';
    });

    try {
      final files = await PdfCacheService().downloadAndCacheBook(
        widget.book,
        onProgress: (p, s) {
          if (mounted) {
            setState(() {
              _downloadProgress = p;
              _downloadStatus = s;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _isDownloading = false;
          _isCached = true;
          _cachedFiles = files;
        });
        _confettiController.play();
        CustomSnackBar.showSuccess(context, 'Book downloaded for offline access');
        widget.gamification.addXp(50, 'Downloaded Book Offline');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDownloading = false);
        CustomSnackBar.showError(context, 'Failed to download book. Please check connection.');
      }
    }
  }

  void _openChapter(int chNum) {
    widget.gamification.recordReadingSession();
    final chNumStr = chNum.toString().padLeft(2, '0');
    final chapterTitle = 'Chapter $chNum';

    File? cachedFile;
    if (_cachedFiles.isNotEmpty) {
      for (final f in _cachedFiles) {
        if (f.path.contains('${widget.book.code}$chNumStr.pdf')) {
          cachedFile = f;
          break;
        }
      }
      cachedFile ??= _cachedFiles.first;
    }

    final pdfUrl = 'https://ncert.nic.in/textbook/pdf/${widget.book.code}$chNumStr.pdf';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfViewerScreen(
          pdfFile: cachedFile,
          pdfUrl: cachedFile == null ? pdfUrl : null,
          bookTitle: widget.book.text,
          chapterTitle: chapterTitle,
          book: widget.book,
        ),
      ),
    );
  }

  Widget _buildChapterItem(int chNum) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openChapter(chNum),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF181818),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFF282828),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                // Chapter Index Circle
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFF222222),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$chNum',
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chapter $chNum',
                        style: GoogleFonts.roboto(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'NCERT Official Textbook Chapter',
                        style: GoogleFonts.roboto(
                          fontSize: 11.5,
                          color: const Color(0xFF777777),
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow icon
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFF222222),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: Color(0xFF777777),
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

  @override
  Widget build(BuildContext context) {
    final isFav = widget.gamification.isFavorite(widget.book.code);

    // Build chapter list
    List<Widget> chapterListWidgets = [];
    for (int i = 1; i <= widget.book.maxChapterNumber; i++) {
      chapterListWidgets.add(_buildChapterItem(i));

      if (i % 4 == 0 && i != widget.book.maxChapterNumber) {
        chapterListWidgets.add(
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: AdBannerWidget(
              margin: EdgeInsets.zero,
              showSectionLabel: true,
            ),
          ),
        );
      }
    }

    return ConfettiOverlay(
      controller: _confettiController,
      child: Scaffold(
        backgroundColor: const Color(0xFF101010),
        body: SafeArea(
          child: MaxContentConstraint(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top App Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back Arrow
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF181818),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF282828),
                                width: 1.0,
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        // Center Category Dropdown Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xFF181818),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF282828),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.folder_outlined,
                                size: 14,
                                color: Color(0xFF777777),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Class ${widget.book.className} • ${widget.book.subject}',
                                style: GoogleFonts.roboto(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Favorite Heart Button
                        GestureDetector(
                          onTap: () {
                            widget.gamification.toggleFavorite(widget.book.code);
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF181818),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF282828),
                                width: 1.0,
                              ),
                            ),
                            child: Icon(
                              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              size: 18,
                              color: isFav ? AppTheme.accentRose : const Color(0xFF777777),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Hero Book Info Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 14, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.book.text,
                          style: GoogleFonts.roboto(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),

                        Text(
                          'Class ${widget.book.className} • ${widget.book.maxChapterNumber} Chapters • NCERT Official Edition',
                          style: GoogleFonts.roboto(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF777777),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Download & Offline Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF181818),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF282828),
                              width: 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF222222),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _isCached ? Icons.offline_pin_rounded : Icons.cloud_download_outlined,
                                      color: _isCached ? AppTheme.emeraldMint : Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _isCached
                                              ? 'Downloaded & Offline Ready'
                                              : (_isDownloading ? _downloadStatus : 'Download Entire Book'),
                                          style: GoogleFonts.roboto(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          _isCached
                                              ? 'All ${widget.book.maxChapterNumber} chapters stored on device'
                                              : (_isDownloading
                                                    ? '${(_downloadProgress * 100).toInt()}% completed'
                                                    : 'Save all chapters for instant offline reading'),
                                          style: GoogleFonts.roboto(
                                            fontSize: 11.5,
                                            color: const Color(0xFF777777),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!_isCached && !_isDownloading)
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: const Color(0xFF101010),
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      onPressed: _startDownload,
                                      child: Text(
                                        'Download',
                                        style: GoogleFonts.roboto(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              if (_isDownloading) ...[
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: _downloadProgress,
                                    minHeight: 5,
                                    backgroundColor: const Color(0xFF282828),
                                    color: const Color(0xFF38BDF8),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        Text(
                          'Chapters (${widget.book.maxChapterNumber})',
                          style: GoogleFonts.roboto(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),

                // Chapter List Items
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(chapterListWidgets),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 40),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
