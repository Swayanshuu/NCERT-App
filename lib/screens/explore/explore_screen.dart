import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ncert_books_app/models/ncert_book.dart';
import 'package:ncert_books_app/services/gamification_service.dart';
import 'package:ncert_books_app/services/ncert_repository.dart';
import 'package:ncert_books_app/theme/app_theme.dart';
import 'package:ncert_books_app/theme/app_responsive.dart';
import 'package:ncert_books_app/widgets/glass/glass_search_bar.dart';
import 'package:ncert_books_app/screens/books/widgets/book_card.dart';
import 'package:ncert_books_app/screens/books/book_detail_screen.dart';

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

  String _searchQuery = '';
  String _selectedClass = 'All';
  String _selectedSubject = 'All';

  List<NcertBook> _searchResults = [];
  bool _isLoading = true;

  final int _pageSize = 12;
  int _currentPage = 1;

  final List<String> _popularSubjects = [
    'All',
    'Mathematics',
    'Science',
    'Physics',
    'Chemistry',
    'Biology',
    'Social Science',
    'History',
    'Geography',
    'English',
    'Hindi',
    'Sanskrit',
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initCatalog();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasActiveFilterOrQuery =>
      _searchQuery.trim().isNotEmpty ||
      _selectedClass != 'All' ||
      _selectedSubject != 'All';

  Future<void> _initCatalog() async {
    if (!_repository.isLoaded) {
      await _repository.loadCatalog();
    }
    _runSearch();
    if (mounted) setState(() => _isLoading = false);
  }

  void _runSearch() {
    if (!_hasActiveFilterOrQuery) {
      _searchResults = [];
    } else {
      _searchResults = _repository.searchCatalog(
        query: _searchQuery,
        className: _selectedClass,
        subjectName: _selectedSubject,
      );
    }
    _currentPage = 1;
  }

  int get _displayedCount => _searchResults.isEmpty
      ? 0
      : (_currentPage * _pageSize > _searchResults.length
          ? _searchResults.length
          : _currentPage * _pageSize);

  bool get _hasMore => _displayedCount < _searchResults.length;

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedClass = 'All';
      _selectedSubject = 'All';
      _runSearch();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = widget.gamification.isDarkMode;
    final availableClasses = ['All', ..._repository.getAvailableClasses()];

    return Scaffold(
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
                  // 1. Search Header Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 12,
                        bottom: 6,
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
                                    'Search Library',
                                    style: GoogleFonts.roboto(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? Colors.white : const Color(0xFF111827),
                                      letterSpacing: -0.6,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Find any NCERT subject or chapter across all classes',
                                    style: GoogleFonts.roboto(
                                      fontSize: 12.5,
                                      color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                              if (_searchQuery.isNotEmpty ||
                                  _selectedClass != 'All' ||
                                  _selectedSubject != 'All')
                                GestureDetector(
                                  onTap: _resetFilters,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF24242C)
                                          : const Color(0xFFF1F1F4),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Reset',
                                      style: GoogleFonts.roboto(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Search Bar
                          GlassSearchBar(
                            controller: _searchController,
                            isDark: isDark,
                            hintText: 'Search textbooks (e.g. Physics, Science, Math)...',
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val;
                                _runSearch();
                              });
                            },
                            onClear: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                                _runSearch();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. Class Filter Horizontal Chips
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: SizedBox(
                        height: 36,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: availableClasses.length,
                          itemBuilder: (context, index) {
                            final cls = availableClasses[index];
                            final isSel = _selectedClass == cls;
                            final isUserClass = cls == widget.gamification.userClass;

                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedClass = cls;
                                    _runSearch();
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 13,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSel
                                        ? (isDark ? Colors.white : const Color(0xFF18181B))
                                        : (isDark ? const Color(0xFF18181E) : Colors.white),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSel
                                          ? (isDark ? Colors.white : const Color(0xFF18181B))
                                          : (isDark ? const Color(0xFF262630) : const Color(0xFFE5E7EB)),
                                      width: isSel ? 1.4 : 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        cls == 'All' ? 'All Classes' : 'Class $cls',
                                        style: GoogleFonts.roboto(
                                          fontSize: 12,
                                          fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                                          color: isSel
                                              ? (isDark ? const Color(0xFF18181B) : Colors.white)
                                              : (isDark ? const Color(0xFFD1D5DB) : const Color(0xFF374151)),
                                        ),
                                      ),
                                      if (isUserClass && cls != 'All') ...[
                                        const SizedBox(width: 4),
                                        Container(
                                          width: 5,
                                          height: 5,
                                          decoration: BoxDecoration(
                                            color: isSel
                                                ? (isDark ? const Color(0xFF18181B) : Colors.white)
                                                : const Color(0xFF3B82F6),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // 3. Subject Quick Filter Chips
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SizedBox(
                        height: 34,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _popularSubjects.length,
                          itemBuilder: (context, index) {
                            final subj = _popularSubjects[index];
                            final isSel = _selectedSubject == subj;
                            final subjColor = subj == 'All'
                                ? (isDark ? Colors.white : const Color(0xFF18181B))
                                : AppTheme.getSubjectColor(subj);

                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedSubject = subj;
                                    _runSearch();
                                  });
                                  if (subj != 'All') {
                                    widget.gamification.recordSubjectExplored(subj);
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSel
                                        ? (isDark ? const Color(0xFF22222E) : const Color(0xFFEFF6FF))
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSel
                                          ? subjColor
                                          : (isDark ? const Color(0xFF22222C) : const Color(0xFFE5E7EB)),
                                      width: isSel ? 1.2 : 0.8,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (subj != 'All') ...[
                                        Icon(
                                          AppTheme.getSubjectIcon(subj),
                                          size: 13,
                                          color: subjColor,
                                        ),
                                        const SizedBox(width: 5),
                                      ],
                                      Text(
                                        subj,
                                        style: GoogleFonts.roboto(
                                          fontSize: 11.5,
                                          fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                                          color: isSel
                                              ? (isDark ? Colors.white : const Color(0xFF111827))
                                              : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // 4. Initial Discovery Landing (when no query or filter active)
                  if (!_hasActiveFilterOrQuery)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
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
                                      alpha: isDark ? 0.2 : 0.04,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF38BDF8)
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: const Color(0xFF38BDF8)
                                                .withValues(alpha: 0.35),
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.manage_search_rounded,
                                          color: Color(0xFF38BDF8),
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'GLOBAL NCERT SEARCH',
                                        style: GoogleFonts.roboto(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.4,
                                          color: isDark
                                              ? const Color(0xFFA1A1AA)
                                              : const Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    'Search any textbook across all classes',
                                    style: GoogleFonts.roboto(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.3,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Type a book title, subject, or chapter keyword above — or select a Class and Subject filter to view textbooks.',
                                    style: GoogleFonts.roboto(
                                      fontSize: 12.5,
                                      height: 1.4,
                                      color: isDark
                                          ? const Color(0xFF71717A)
                                          : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'POPULAR SEARCHES',
                              style: GoogleFonts.roboto(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                                color: isDark
                                    ? const Color(0xFFA1A1AA)
                                    : const Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildSuggestionChip(
                                  'Class 10 Mathematics',
                                  className: '10',
                                  subject: 'Mathematics',
                                ),
                                _buildSuggestionChip(
                                  'Class 10 Science',
                                  className: '10',
                                  subject: 'Science',
                                ),
                                _buildSuggestionChip(
                                  'Class 12 Physics',
                                  className: '12',
                                  query: 'Physics',
                                ),
                                _buildSuggestionChip(
                                  'Class 11 Chemistry',
                                  className: '11',
                                  query: 'Chemistry',
                                ),
                                _buildSuggestionChip(
                                  'Class 9 Social Science',
                                  className: '9',
                                  subject: 'Social Science',
                                ),
                                _buildSuggestionChip(
                                  'Class 12 Biology',
                                  className: '12',
                                  query: 'Biology',
                                ),
                                _buildSuggestionChip(
                                  'Class 8 History',
                                  className: '8',
                                  query: 'History',
                                ),
                                _buildSuggestionChip(
                                  'Class 10 English',
                                  className: '10',
                                  subject: 'English',
                                ),
                              ],
                            ),
                            const SizedBox(height: 120),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    // 4. Results Header Bar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 4,
                          bottom: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'Search Results (${_searchResults.length})'
                                  : '${_selectedClass == 'All' ? 'All Classes' : 'Class $_selectedClass'}${_selectedSubject == 'All' ? '' : ' • $_selectedSubject'} (${_searchResults.length})',
                              style: GoogleFonts.roboto(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF111827),
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              'Showing $_displayedCount of ${_searchResults.length}',
                              style: GoogleFonts.roboto(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? const Color(0xFF777777)
                                    : const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // 5. Books Grid or Empty State
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
                  else if (_searchResults.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1C1C24) : const Color(0xFFF1F1F4),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.search_off_rounded,
                                  size: 32,
                                  color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No matching textbooks found',
                                style: GoogleFonts.roboto(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : const Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Try searching with another subject, book title, or select "All Classes".',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.roboto(
                                  fontSize: 12.5,
                                  color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 18),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark ? Colors.white : const Color(0xFF18181B),
                                  foregroundColor: isDark ? const Color(0xFF181818) : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                ),
                                onPressed: _resetFilters,
                                child: Text(
                                  'Clear Search Filters',
                                  style: GoogleFonts.roboto(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else ...[
                    // Books Grid
                    SliverPadding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 20,
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
                            final book = _searchResults[index];
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
                          },
                          childCount: _displayedCount,
                        ),
                      ),
                    ),

                    // Pagination Load More Controls
                    if (_hasMore)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            bottom: 110,
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
                                      'Load More (${_searchResults.length - _displayedCount} remaining)',
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
                    else if (_searchResults.length > _pageSize)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 110),
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
                                'All ${_searchResults.length} textbooks loaded',
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
                      const SliverToBoxAdapter(child: SizedBox(height: 110)),
                  ],
                ],
              ],
            );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(
    String label, {
    String? className,
    String? subject,
    String? query,
  }) {
    final isDark = widget.gamification.isDarkMode;
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          if (className != null) _selectedClass = className;
          if (subject != null) _selectedSubject = subject;
          if (query != null) {
            _searchQuery = query;
            _searchController.text = query;
          }
          _runSearch();
        });
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E24) : const Color(0xFFF1F1F4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF282832) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_rounded,
              size: 13,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
