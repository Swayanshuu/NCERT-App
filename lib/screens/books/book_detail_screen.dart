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
import 'package:ncert_books_app/widgets/glass/glass_card.dart';
import 'package:ncert_books_app/widgets/glass/glass_button.dart';
import 'package:ncert_books_app/widgets/liquid/liquid_progress.dart';
import 'package:ncert_books_app/widgets/painters/subject_background_painter.dart';
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
      CustomSnackBar.showInfo(context, 'This book is already in your offline vault! ⚡');
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
          _isCached = files.isNotEmpty;
          _cachedFiles = files;
        });

        if (_isCached) {
          _confettiController.stop();
          _confettiController.play();
          CustomSnackBar.showSuccess(context, 'Full book saved for offline reading! 📦');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDownloading = false);
        CustomSnackBar.showError(context, 'Download failed. Please check internet connection.');
      }
    }
  }

  void _openChapter(int chapterIndex) {
    final chNumStr = chapterIndex.toString().padLeft(2, '0');
    final chapterTitle = 'Chapter $chapterIndex';

    File? cachedFile;
    if (_cachedFiles.isNotEmpty) {
      for (final f in _cachedFiles) {
        if (f.path.contains('${widget.book.code}$chNumStr') || f.path.contains(chNumStr)) {
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

  Widget _buildChapterItem(int chNum, bool isDark, Color subjectColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        onTap: () => _openChapter(chNum),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: subjectColor.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$chNum',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: subjectColor,
                    fontSize: 15,
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
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                    ),
                  ),
                  Text(
                    'NCERT Official Textbook Content',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.primaryTeal),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.gamification.isDarkMode;
    final isFav = widget.gamification.isFavorite(widget.book.code);
    final subjectColor = AppTheme.getSubjectColor(widget.book.subject);
    final isDesktop = AppResponsive.isDesktop(context);

    // Build chapter list with banner ads inserted every 3 chapters
    List<Widget> chapterListWidgets = [];
    for (int i = 1; i <= widget.book.maxChapterNumber; i++) {
      chapterListWidgets.add(_buildChapterItem(i, isDark, subjectColor));

      // Insert banner ad in between chapter cards after every 3 chapters
      if (i % 3 == 0 && i != widget.book.maxChapterNumber) {
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

    Widget chapterListView = ListView(
      shrinkWrap: true,
      physics: isDesktop ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
      children: chapterListWidgets,
    );

    return ConfettiOverlay(
      controller: _confettiController,
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
        body: MaxContentConstraint(
          child: isDesktop
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Desktop Left Column
                      SizedBox(
                        width: 380,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_rounded),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const SizedBox(height: 12),

                              // Book Cover Banner
                              ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: SizedBox(
                                  height: 220,
                                  width: double.infinity,
                                  child: Stack(
                                    children: [
                                      CustomPaint(
                                        size: Size.infinite,
                                        painter: SubjectBackgroundPainter(
                                          subject: widget.book.subject,
                                          isDark: isDark,
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 16,
                                        left: 16,
                                        right: 16,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: subjectColor,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                'Class ${widget.book.className} • ${widget.book.subject.toUpperCase()}',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              widget.book.text,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.outfit(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Download & Storage Card
                              GlassCard(
                                borderRadius: 24,
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          _isCached ? Icons.offline_pin_rounded : Icons.cloud_download_rounded,
                                          color: _isCached ? AppTheme.primaryTeal : AppTheme.accentAmber,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            _isCached ? 'Offline Vault Ready' : 'Download Book Offline',
                                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                            color: isFav ? AppTheme.accentRose : null,
                                          ),
                                          onPressed: () => widget.gamification.toggleFavorite(widget.book.code),
                                        ),
                                      ],
                                    ),
                                    if (_isDownloading) ...[
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              _downloadStatus,
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.primaryTeal,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryTeal.withValues(alpha: 0.18),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '${(_downloadProgress * 100).toInt()}%',
                                              style: GoogleFonts.outfit(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.primaryTeal,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      LiquidProgressBar(
                                        progress: _downloadProgress,
                                        height: 8,
                                      ),
                                    ] else if (!_isCached) ...[
                                      const SizedBox(height: 12),
                                      GlassButton(
                                        label: _isDownloading
                                            ? 'Downloading ${(_downloadProgress * 100).toInt()}%'
                                            : 'Download Book',
                                        isLoading: _isDownloading,
                                        onPressed: _startDownload,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),

                      // Desktop Right Column (Chapters)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chapters Catalog (${widget.book.maxChapterNumber}) 📖',
                              style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            Expanded(child: chapterListView),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Top Cover Header
                    SliverAppBar(
                      expandedHeight: 220,
                      pinned: true,
                      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
                      leading: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black54 : Colors.white70,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back_rounded),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      actions: [
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black54 : Colors.white70,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: isFav ? AppTheme.accentRose : (isDark ? Colors.white : Colors.black87),
                            ),
                          ),
                          onPressed: () {
                            widget.gamification.toggleFavorite(widget.book.code);
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          children: [
                            CustomPaint(
                              size: const Size(double.infinity, 260),
                              painter: SubjectBackgroundPainter(
                                subject: widget.book.subject,
                                isDark: isDark,
                              ),
                            ),
                            Positioned(
                              bottom: 16,
                              left: 20,
                              right: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: subjectColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Class ${widget.book.className} • ${widget.book.subject.toUpperCase()}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    widget.book.text,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.outfit(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Content Body
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Download Banner
                            GlassCard(
                              borderRadius: 24,
                              padding: const EdgeInsets.all(18),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: (_isCached
                                              ? AppTheme.emeraldMint
                                              : AppTheme.primaryTeal)
                                          .withValues(alpha: isDark ? 0.22 : 0.14),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: (_isCached
                                                ? AppTheme.emeraldMint
                                                : AppTheme.primaryTeal)
                                            .withValues(alpha: 0.40),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Icon(
                                      _isCached
                                          ? Icons.offline_pin_rounded
                                          : Icons.cloud_download_rounded,
                                      color: _isCached
                                          ? AppTheme.emeraldMint
                                          : AppTheme.primaryTeal,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _isCached
                                              ? 'Downloaded Offline ✓'
                                              : 'Online Stream Available',
                                          style: GoogleFonts.outfit(
                                            fontSize: 15.5,
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? AppTheme.darkTextPrimary
                                                : AppTheme.lightTextPrimary,
                                          ),
                                        ),
                                        Text(
                                          _isCached
                                              ? 'All ${widget.book.maxChapterNumber} chapters saved in local vault'
                                              : 'Tap to download all ${widget.book.maxChapterNumber} chapters offline',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            color: isDark
                                                ? AppTheme.darkTextMuted
                                                : AppTheme.lightTextMuted,
                                          ),
                                        ),
                                        if (_isDownloading) ...[
                                          const SizedBox(height: 8),
                                          LiquidProgressBar(
                                            progress: _downloadProgress,
                                            height: 6,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _downloadStatus,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primaryTeal,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  if (!_isCached)
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: _isDownloading ? null : _startDownload,
                                        borderRadius: BorderRadius.circular(16),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 10),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                AppTheme.primaryTeal,
                                                AppTheme.primaryTeal
                                                    .withValues(alpha: 0.85),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(16),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppTheme.primaryTeal
                                                    .withValues(alpha: 0.35),
                                                blurRadius: 10,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              _isDownloading
                                                  ? const SizedBox(
                                                      width: 16,
                                                      height: 16,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.white,
                                                      ),
                                                    )
                                                  : const Icon(
                                                      Icons
                                                          .download_for_offline_rounded,
                                                      color: Colors.white,
                                                      size: 18,
                                                    ),
                                              const SizedBox(width: 6),
                                              Text(
                                                _isDownloading
                                                    ? '${(_downloadProgress * 100).toInt()}%'
                                                    : 'Download',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.emeraldMint
                                            .withValues(alpha: isDark ? 0.20 : 0.12),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: AppTheme.emeraldMint
                                              .withValues(alpha: 0.40),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.offline_pin_rounded,
                                            color: AppTheme.emeraldMint,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            'Vault Ready',
                                            style: GoogleFonts.outfit(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.emeraldMint,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            Text(
                              'Book Chapters (${widget.book.maxChapterNumber}) 📖',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            chapterListView,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
