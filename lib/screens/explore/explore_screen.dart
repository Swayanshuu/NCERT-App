import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncert_books_app/models/ncert_book.dart';
import 'package:ncert_books_app/services/gamification_service.dart';
import 'package:ncert_books_app/services/ncert_repository.dart';
import 'package:ncert_books_app/theme/app_theme.dart';
import 'package:ncert_books_app/theme/app_responsive.dart';
import 'package:ncert_books_app/widgets/ad_banner_widget.dart';
import 'package:ncert_books_app/widgets/glass/glass_search_bar.dart';
import 'package:ncert_books_app/widgets/glass/glass_surface.dart';
import 'package:ncert_books_app/widgets/glass/glass_skeleton.dart';
import 'package:ncert_books_app/widgets/hover_builder.dart';
import 'package:ncert_books_app/screens/explore/bloc/explore_bloc.dart';
import 'package:ncert_books_app/screens/explore/widgets/subject_card.dart';
import 'package:ncert_books_app/screens/books/widgets/book_card.dart';
import 'package:ncert_books_app/screens/books/book_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  final GamificationService gamification;

  const ExploreScreen({super.key, required this.gamification});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> with AutomaticKeepAliveClientMixin {
  final NcertRepository _repository = NcertRepository();
  final TextEditingController _searchController = TextEditingController();

  String _selectedClass = '10';
  String _selectedSubject = 'All';
  String _searchQuery = '';

  List<String> _availableSubjects = [];
  List<NcertBook> _booksToDisplay = [];
  bool _isLoading = false;

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

  void _showClassPickerModal() {
    final availableClasses = _repository.getAvailableClasses();
    final isDark = widget.gamification.isDarkMode;
    final mediaQuery = MediaQuery.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: mediaQuery.size.height * 0.85,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: GlassSurface(
            borderRadius: 32,
            padding: const EdgeInsets.all(24),
            color: isDark ? AppTheme.darkBackground.withValues(alpha: 0.95) : AppTheme.lightBackground.withValues(alpha: 0.95),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Class',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 500 ? 4 : 3;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: crossAxisCount == 4 ? 2.8 : 2.2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: availableClasses.length,
                        itemBuilder: (context, idx) {
                          final cls = availableClasses[idx];
                          final isSel = _selectedClass == cls;
                          return HoverBuilder(
                            onTap: () {
                              widget.gamification.setUserClass(cls);
                              setState(() {
                                _selectedClass = cls;
                                _updateContent();
                              });
                              Navigator.pop(ctx);
                            },
                            builder: (context, isHovered) => Container(
                              decoration: BoxDecoration(
                                color: isSel ? AppTheme.primaryTeal : (isDark ? AppTheme.darkSurface : Colors.white),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSel ? AppTheme.primaryTeal : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Class $cls',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    color: isSel ? Colors.white : (isDark ? Colors.white : AppTheme.lightTextPrimary),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<ExploreBloc, ExploreState>(
      builder: (context, state) {
        final isDark = widget.gamification.isDarkMode;
        return Scaffold(
          backgroundColor: Colors.transparent,
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
                      padding: const EdgeInsets.all(20),
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
                                    'Explore & Search 🧭',
                                    style: GoogleFonts.outfit(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Browse NCERT subjects, books & chapters',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                                    ),
                                  ),
                                ],
                              ),
                              HoverBuilder(
                                onTap: _showClassPickerModal,
                                builder: (context, isHovered) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryTeal,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Class $_selectedClass',
                                        style: GoogleFonts.outfit(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const Icon(Icons.arrow_drop_down, color: Colors.white, size: 18),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Glass Search Bar
                          GlassSearchBar(
                            controller: _searchController,
                            isDark: isDark,
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
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        child: Text(
                          'Subjects for Class $_selectedClass',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 1.3,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final subj = _availableSubjects[index];
                            final books = _repository.getBooks(_selectedClass, subj);
                            return SubjectCard(
                              subjectName: subj,
                              bookCount: books.length,
                              isDark: isDark,
                              onTap: () {
                                setState(() {
                                  _selectedSubject = _selectedSubject == subj ? 'All' : subj;
                                  _updateContent();
                                });
                                widget.gamification.recordSubjectExplored(subj);
                              },
                            );
                          },
                          childCount: _availableSubjects.length,
                        ),
                      ),
                    ),
                  ],

                  // Books Catalog Section Title
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'Search Results (${_booksToDisplay.length})'
                                : (_selectedSubject == 'All' ? 'All Books' : '$_selectedSubject Books'),
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                            ),
                          ),
                          if (_selectedSubject != 'All' && _searchQuery.isEmpty)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedSubject = 'All';
                                  _updateContent();
                                });
                              },
                              child: Text(
                                'Show All',
                                style: GoogleFonts.outfit(color: AppTheme.primaryTeal, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Books Grid / Skeleton
                  if (_isLoading)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GlassSkeletonGrid(itemCount: 6, crossAxisCount: columns),
                      ),
                    )
                  else if (_booksToDisplay.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'No books found',
                          style: GoogleFonts.outfit(fontSize: 16, color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 90),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.70,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
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
                                setState(() {});
                              },
                            );
                          },
                          childCount: _booksToDisplay.length,
                        ),
                      ),
                    ),

                  // AdBanner Placement
                  const SliverToBoxAdapter(
                    child: AdBannerWidget(),
                  ),
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
