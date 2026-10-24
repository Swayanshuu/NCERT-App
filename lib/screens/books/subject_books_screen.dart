import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ncert_books_app/models/ncert_book.dart';
import 'package:ncert_books_app/screens/books/book_detail_screen.dart';
import 'package:ncert_books_app/screens/books/widgets/book_card.dart';
import 'package:ncert_books_app/services/gamification_service.dart';
import 'package:ncert_books_app/services/ncert_repository.dart';
import 'package:ncert_books_app/theme/app_responsive.dart';
import 'package:ncert_books_app/theme/app_theme.dart';
import 'package:ncert_books_app/widgets/app_background.dart';
import 'package:ncert_books_app/widgets/glass/glass_search_bar.dart';
import 'package:ncert_books_app/widgets/painters/bento_watermark_painter.dart';

class SubjectBooksScreen extends StatefulWidget {
  final String className;
  final String subjectName;
  final GamificationService gamification;

  const SubjectBooksScreen({
    super.key,
    required this.className,
    required this.subjectName,
    required this.gamification,
  });

  @override
  State<SubjectBooksScreen> createState() => _SubjectBooksScreenState();
}

class _SubjectBooksScreenState extends State<SubjectBooksScreen> {
  final NcertRepository _repository = NcertRepository();
  final TextEditingController _searchController = TextEditingController();

  List<NcertBook> _allSubjectBooks = [];
  List<NcertBook> _filteredBooks = [];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    if (!_repository.isLoaded) {
      await _repository.loadCatalog();
    }
    _allSubjectBooks = _repository.getBooks(widget.className, widget.subjectName);
    _filteredBooks = List.from(_allSubjectBooks);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _filterBooks(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      _searchQuery = query;
      if (q.isEmpty) {
        _filteredBooks = List.from(_allSubjectBooks);
      } else {
        _filteredBooks = _allSubjectBooks.where((book) {
          final matchesTitle = book.text.toLowerCase().contains(q);
          final matchesCode = book.code.toLowerCase().contains(q);
          return matchesTitle || matchesCode;
        }).toList();
      }
    });
  }

  BentoWatermarkType _getWatermarkType(String subject) {
    final s = subject.toLowerCase();
    if (s.contains('math')) return BentoWatermarkType.mathSymbols;
    if (s.contains('sci') || s.contains('phys') || s.contains('chem') || s.contains('bio')) {
      return BentoWatermarkType.atom;
    }
    if (s.contains('soc') || s.contains('his') || s.contains('geo')) {
      return BentoWatermarkType.globe;
    }
    if (s.contains('eng') || s.contains('hin') || s.contains('lang')) {
      return BentoWatermarkType.columns;
    }
    return BentoWatermarkType.book;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.gamification.isDarkMode;
    final subjectColor = AppTheme.getSubjectColor(widget.subjectName);
    final subjectIcon = AppTheme.getSubjectIcon(widget.subjectName);
    final watermarkType = _getWatermarkType(widget.subjectName);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          top: true,
          bottom: false,
          child: MaxContentConstraint(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = AppResponsive.getGridColumnCount(
                  context,
                  availableWidth: constraints.maxWidth,
                );

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // 1. App Bar Header with Back Button and Subject Banner
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 10,
                          bottom: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Back Button + Subject Pill
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      Navigator.of(context).pop();
                                    },
                                    borderRadius: BorderRadius.circular(14),
                                    child: Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF1E1E24)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: isDark
                                              ? Colors.white.withValues(alpha: 0.10)
                                              : const Color(0xFFE5E7EB),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.arrow_back_rounded,
                                        color: isDark ? Colors.white : Colors.black87,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: subjectColor.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: subjectColor.withValues(alpha: 0.35),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 7,
                                        height: 7,
                                        decoration: BoxDecoration(
                                          color: subjectColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Class ${widget.className}',
                                        style: GoogleFonts.roboto(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: subjectColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Subject Hero Card with Watermark
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF16161A)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : const Color(0xFFE5E7EB),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: isDark ? 0.25 : 0.04,
                                    ),
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: Stack(
                                  children: [
                                    // Subtle vector watermark
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: BentoWatermarkPainter(
                                          type: watermarkType,
                                          tintColor: subjectColor,
                                          opacity: isDark ? 0.09 : 0.06,
                                        ),
                                      ),
                                    ),

                                    // Banner content
                                    Row(
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: subjectColor.withValues(
                                              alpha: 0.15,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            border: Border.all(
                                              color: subjectColor.withValues(
                                                alpha: 0.40,
                                              ),
                                              width: 1.2,
                                            ),
                                          ),
                                          child: Icon(
                                            subjectIcon,
                                            color: subjectColor,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                widget.subjectName,
                                                style: GoogleFonts.roboto(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: -0.4,
                                                  color: isDark
                                                      ? Colors.white
                                                      : const Color(0xFF111827),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${_allSubjectBooks.length} NCERT Textbooks • Class ${widget.className}',
                                                style: GoogleFonts.roboto(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: isDark
                                                      ? const Color(0xFFA1A1AA)
                                                      : const Color(0xFF6B7280),
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

                            const SizedBox(height: 14),

                            // Search bar inside this subject only
                            GlassSearchBar(
                              controller: _searchController,
                              isDark: isDark,
                              hintText:
                                  'Search in ${widget.subjectName} (e.g. title, code)...',
                              onChanged: _filterBooks,
                              onClear: () => _filterBooks(''),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 2. Section divider & count
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 4,
                          bottom: 12,
                        ),
                        child: Row(
                          children: [
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'SEARCH IN ${widget.subjectName.toUpperCase()} (${_filteredBooks.length})'
                                  : 'ALL TEXTBOOKS (${_filteredBooks.length})',
                              style: GoogleFonts.roboto(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.8,
                                color: isDark
                                    ? const Color(0xFFA1A1AA)
                                    : const Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.10)
                                    : Colors.black.withValues(alpha: 0.10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 3. Books Grid or Empty State
                    if (_isLoading)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(50),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                        ),
                      )
                    else if (_filteredBooks.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 50,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF1E1E24)
                                        : const Color(0xFFF1F1F4),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.search_off_rounded,
                                    size: 30,
                                    color: isDark
                                        ? const Color(0xFF71717A)
                                        : const Color(0xFF9CA3AF),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'No textbooks matching "$_searchQuery"',
                                  style: GoogleFonts.roboto(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Try searching with a different term',
                                  style: GoogleFonts.roboto(
                                    fontSize: 12,
                                    color: isDark
                                        ? const Color(0xFF71717A)
                                        : const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          bottom: 100,
                        ),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 1.15,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final book = _filteredBooks[index];
                              return BookCard(
                                book: book,
                                gamification: widget.gamification,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => BookDetailScreen(
                                        book: book,
                                        gamification: widget.gamification,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            childCount: _filteredBooks.length,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
