import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncert_books_app/models/ncert_book.dart';
import 'package:ncert_books_app/services/gamification_service.dart';
import 'package:ncert_books_app/services/ncert_repository.dart';
import 'package:ncert_books_app/theme/app_responsive.dart';
import 'package:ncert_books_app/widgets/glass/glass_search_bar.dart';
import 'package:ncert_books_app/screens/explore/bloc/explore_bloc.dart';
import 'package:ncert_books_app/screens/explore/widgets/subject_card.dart';
import 'package:ncert_books_app/screens/books/widgets/book_card.dart';
import 'package:ncert_books_app/screens/books/book_detail_screen.dart';
import 'package:ncert_books_app/screens/home/widgets/class_picker_modal.dart';
import 'package:ncert_books_app/widgets/ad_banner_widget.dart';

class ExploreScreen extends StatefulWidget {
  final GamificationService gamification;

  const ExploreScreen({super.key, required this.gamification});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with AutomaticKeepAliveClientMixin {
  final NcertRepository _repository = NcertRepository();
  final TextEditingController _searchController = TextEditingController();

  String _selectedClass = '10';
  String _selectedSubject = 'All';
  String _searchQuery = '';

  List<String> _availableSubjects = [];
  List<NcertBook> _booksToDisplay = [];
  bool _isLoading = false;

  final int _pageSize = 8;
  int _currentPage = 1;

  int get _displayedItemCount => _booksToDisplay.isEmpty
      ? 0
      : (_currentPage * _pageSize > _booksToDisplay.length
            ? _booksToDisplay.length
            : _currentPage * _pageSize);

  bool get _hasMore => _displayedItemCount < _booksToDisplay.length;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _selectedClass = widget.gamification.userClass;
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _repository.loadCatalog();
    _updateContent();
    if (mounted) setState(() => _isLoading = false);
  }

  void _updateContent() {
    _currentPage = 1;
    _selectedClass = widget.gamification.userClass;
    _availableSubjects = _repository.getSubjectsForClass(_selectedClass);

    if (_searchQuery.isNotEmpty) {
      _booksToDisplay = _repository.searchBooks(_searchQuery);
    } else if (_selectedSubject == 'All') {
      final List<NcertBook> all = [];
      for (final s in _availableSubjects) {
        all.addAll(_repository.getBooks(_selectedClass, s));
      }
      _booksToDisplay = all;
    } else {
      _booksToDisplay = _repository.getBooks(_selectedClass, _selectedSubject);
    }
  }

  Set<int> _adRowIndices = {};

  void _randomizeAdPositions(int totalRows) {
    if (totalRows <= 1) {
      _adRowIndices = {0};
      return;
    }
    final Set<int> positions = {};
    final rng = math.Random((_selectedClass.hashCode ^ (DateTime.now().minute ~/ 5)));
    final count = totalRows >= 4 ? 2 : 1;
    final available = List<int>.generate(totalRows - 1, (i) => i);
    available.shuffle(rng);
    for (int i = 0; i < count && i < available.length; i++) {
      positions.add(available[i]);
    }
    if (positions.isEmpty && totalRows > 1) {
      positions.add(0);
    }
    _adRowIndices = positions;
  }

  void _openClassPicker() {
    final availableClasses = _repository.getAvailableClasses();
    final isDark = widget.gamification.isDarkMode;

    ClassPickerModal.show(
      context: context,
      selectedClass: _selectedClass,
      availableClasses: availableClasses,
      isDark: isDark,
      onClassSelected: (cls) {
        widget.gamification.setUserClass(cls);
        setState(() {
          _selectedClass = cls;
          _adRowIndices.clear();
          _updateContent();
        });
      },
    );
  }

  List<Widget> _buildSubjectRowsWithAds(int columns, bool isDark) {
    final List<Widget> slivers = [];
    final subjectRows = <List<String>>[];
    for (int i = 0; i < _availableSubjects.length; i += columns) {
      final end = (i + columns > _availableSubjects.length)
          ? _availableSubjects.length
          : i + columns;
      subjectRows.add(_availableSubjects.sublist(i, end));
    }

    if (_adRowIndices.isEmpty && subjectRows.isNotEmpty) {
      _randomizeAdPositions(subjectRows.length);
    }

    for (int rowIndex = 0; rowIndex < subjectRows.length; rowIndex++) {
      final row = subjectRows[rowIndex];

      // 1. Add Subject Row of cards (2 cards in one row on mobile)
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int c = 0; c < columns; c++)
                  if (c < row.length)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: c == 0 ? 0 : 6,
                          right: c == columns - 1 ? 0 : 6,
                        ),
                        child: SubjectCard(
                          subjectName: row[c],
                          bookCount: _repository.getBooks(_selectedClass, row[c]).length,
                          isDark: isDark,
                          onTap: () {
                            setState(() {
                              _selectedSubject = _selectedSubject == row[c] ? 'All' : row[c];
                              _updateContent();
                            });
                            widget.gamification.recordSubjectExplored(row[c]);
                          },
                        ),
                      ),
                    )
                  else
                    const Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      );

      // 2. Between rows, insert AdBannerWidget at random positions
      if (_adRowIndices.contains(rowIndex)) {
        slivers.add(
          SliverToBoxAdapter(
            key: ValueKey('explore_subj_ad_${rowIndex}_$_selectedClass'),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: AdBannerWidget(
                margin: EdgeInsets.zero,
                showSectionLabel: true,
              ),
            ),
          ),
        );
      }
    }

    return slivers;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = widget.gamification.isDarkMode;

    return BlocBuilder<ExploreBloc, ExploreState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF101010) : Colors.transparent,
          body: SafeArea(
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
                      // Search & Class Picker Header Bar
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: 12,
                            bottom: 8,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Explore Library',
                                        style: GoogleFonts.roboto(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w800,
                                          color: isDark ? Colors.white : const Color(0xFF111827),
                                          letterSpacing: -0.6,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Browse all subjects and official NCERT titles',
                                        style: GoogleFonts.roboto(
                                          fontSize: 13,
                                          color: isDark ? const Color(0xFF777777) : const Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: _openClassPicker,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF181818) : const Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isDark ? const Color(0xFF282828) : const Color(0xFFE5E7EB),
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            'Class $_selectedClass',
                                            style: GoogleFonts.roboto(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                              color: isDark ? Colors.white : const Color(0xFF111827),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            size: 16,
                                            color: isDark ? const Color(0xFF777777) : const Color(0xFF6B7280),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Clean Pill Search Bar
                              GlassSearchBar(
                                controller: _searchController,
                                isDark: isDark,
                                hintText: 'Search subjects, textbooks, chapters...',
                                onChanged: (val) {
                                  setState(() {
                                    _searchQuery = val;
                                    _updateContent();
                                  });
                                },
                                onClear: () {
                                  setState(() {
                                    _searchQuery = '';
                                    _updateContent();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Subject Cards Grid (when not searching)
                      if (_searchQuery.isEmpty) ...[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                              top: 10,
                              bottom: 4,
                            ),
                            child: Text(
                              'Subjects for Class $_selectedClass',
                              style: GoogleFonts.roboto(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : const Color(0xFF111827),
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                        ),
                        ..._buildSubjectRowsWithAds(columns, isDark),
                      ],

                      // Books Results Header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: 12,
                            bottom: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'Search Results (${_booksToDisplay.length})'
                                    : (_selectedSubject == 'All'
                                          ? 'All Textbooks (${_booksToDisplay.length})'
                                          : '$_selectedSubject Books (${_booksToDisplay.length})'),
                                style: GoogleFonts.roboto(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : const Color(0xFF111827),
                                  letterSpacing: -0.3,
                                ),
                              ),
                              if (_selectedSubject != 'All')
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedSubject = 'All';
                                      _updateContent();
                                    });
                                  },
                                  child: Text(
                                    'Show all',
                                    style: GoogleFonts.roboto(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF38BDF8),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      // Books Grid
                      if (_isLoading)
                        const SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(40),
                              child: CircularProgressIndicator(
                                color: Color(0xFF38BDF8),
                              ),
                            ),
                          ),
                        )
                      else if (_booksToDisplay.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Center(
                              child: Text(
                                'No books found',
                                style: GoogleFonts.roboto(
                                  fontSize: 15,
                                  color: isDark ? const Color(0xFF777777) : const Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          ),
                        )
                      else ...[
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
                              childAspectRatio: 0.88,
                            ),
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final book = _booksToDisplay[index];
                              return BookCard(
                                book: book,
                                gamification: widget.gamification,
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BookDetailScreen(
                                        book: book,
                                        gamification: widget.gamification,
                                      ),
                                    ),
                                  );
                                  if (mounted) setState(() {});
                                },
                              );
                            }, childCount: _displayedItemCount),
                          ),
                        ),

                        // Pagination Load More Controls
                        if (_hasMore)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 20,
                                right: 20,
                                bottom: 95,
                              ),
                              child: Center(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(22),
                                  onTap: () {
                                    setState(() {
                                      _currentPage++;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 13,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF181818) : Colors.white,
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(
                                        color: isDark ? const Color(0xFF282828) : const Color(0xFFE5E7EB),
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: isDark ? Colors.white : const Color(0xFF111827),
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Load More (${_booksToDisplay.length - _displayedItemCount} remaining)',
                                          style: GoogleFonts.roboto(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: isDark ? Colors.white : const Color(0xFF111827),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        else if (_booksToDisplay.length > _pageSize)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 95),
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF181818) : const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isDark ? const Color(0xFF282828) : const Color(0xFFE5E7EB),
                                    ),
                                  ),
                                  child: Text(
                                    'All ${_booksToDisplay.length} textbooks loaded',
                                    style: GoogleFonts.roboto(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? const Color(0xFF777777) : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          const SliverToBoxAdapter(child: SizedBox(height: 95)),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
