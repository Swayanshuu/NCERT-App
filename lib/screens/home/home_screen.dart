import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ncert_books_app/models/ncert_book.dart';
import 'package:ncert_books_app/services/gamification_service.dart';
import 'package:ncert_books_app/services/ncert_repository.dart';
import 'package:ncert_books_app/theme/app_theme.dart';
import 'package:ncert_books_app/theme/app_responsive.dart';
import 'package:ncert_books_app/widgets/app_background.dart';
import 'package:ncert_books_app/widgets/ad_banner_widget.dart';
import 'package:ncert_books_app/widgets/confetti_overlay.dart';
import 'package:ncert_books_app/widgets/glass/glass_search_bar.dart';
import 'package:ncert_books_app/widgets/glass/glass_navigation_bar.dart';
import 'package:ncert_books_app/screens/home/widgets/hero_player_card.dart';
import 'package:ncert_books_app/screens/home/widgets/home_header.dart';
import 'package:ncert_books_app/screens/home/widgets/class_picker_modal.dart';
import 'package:ncert_books_app/screens/home/widgets/subject_filter_bar.dart';
import 'package:ncert_books_app/screens/home/widgets/home_books_grid.dart';
import 'package:ncert_books_app/screens/explore/explore_screen.dart';
import 'package:ncert_books_app/screens/explore/widgets/subject_card.dart';
import 'package:ncert_books_app/screens/books/downloads_screen.dart';
import 'package:ncert_books_app/screens/progress/progress_screen.dart';
import 'package:ncert_books_app/screens/profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final GamificationService gamification;

  const HomeScreen({super.key, required this.gamification});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NcertRepository _repository = NcertRepository();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _homeScrollController = ScrollController();
  final GlobalKey<DownloadsScreenState> _downloadsKey = GlobalKey<DownloadsScreenState>();
  late ConfettiController _confettiController;

  int _currentTabIndex = 0;
  String _selectedClass = '10';
  String _selectedFilterSubject = 'All';
  String _searchQuery = '';
  Set<int> _homeAdRowIndices = {};

  int _homeCurrentPage = 1;
  static const int _homePageSize = 8;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _selectedClass = widget.gamification.userClass;
    widget.gamification.addListener(_onStateChange);
    _homeScrollController.addListener(_onHomeScroll);
    _initCatalog();
  }

  Future<void> _initCatalog() async {
    if (!_repository.isLoaded) {
      await _repository.loadCatalog();
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    widget.gamification.removeListener(_onStateChange);
    _homeScrollController.removeListener(_onHomeScroll);
    _homeScrollController.dispose();
    _searchController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  void _onHomeScroll() {
    if (!_homeScrollController.hasClients || _isLoadingMore) return;
    final maxScroll = _homeScrollController.position.maxScrollExtent;
    final currentScroll = _homeScrollController.position.pixels;

    if (currentScroll >= maxScroll - 350) {
      final realSubjects = _repository.getSubjectsForClass(_selectedClass);
      int totalBooks = 0;
      if (_searchQuery.isNotEmpty) {
        totalBooks = _repository.searchBooks(_searchQuery).length;
      } else if (_selectedFilterSubject != 'All') {
        totalBooks = _repository
            .getBooks(_selectedClass, _selectedFilterSubject)
            .length;
      } else {
        for (final s in realSubjects) {
          totalBooks += _repository.getBooks(_selectedClass, s).length;
        }
      }

      if (_homeCurrentPage * _homePageSize < totalBooks) {
        setState(() {
          _isLoadingMore = true;
          _homeCurrentPage++;
        });
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) setState(() => _isLoadingMore = false);
        });
      }
    }
  }

  void _randomizeHomeAdPositions(int totalRows) {
    if (totalRows <= 1) {
      _homeAdRowIndices = {0};
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
    _homeAdRowIndices = positions;
  }

  void _showClassPicker() {
    final classes = _repository.getAvailableClasses();
    ClassPickerModal.show(
      context: context,
      selectedClass: _selectedClass,
      availableClasses: classes,
      isDark: widget.gamification.isDarkMode,
      onClassSelected: (cls) {
        widget.gamification.setUserClass(cls);
        setState(() {
          _selectedClass = cls;
          _homeCurrentPage = 1;
          _selectedFilterSubject = 'All';
          _homeAdRowIndices.clear();
        });
      },
    );
  }

  List<NcertBook> _computeBooksToDisplay(List<String> realSubjects) {
    if (_searchQuery.isNotEmpty) {
      return _repository.searchBooks(_searchQuery);
    }
    if (_selectedFilterSubject != 'All') {
      return _repository.getBooks(_selectedClass, _selectedFilterSubject);
    }
    final List<NcertBook> all = [];
    for (final s in realSubjects) {
      all.addAll(_repository.getBooks(_selectedClass, s));
    }
    return all;
  }

  List<Widget> _buildHomeSubjectRowsWithAds(
    int columns,
    bool isDark,
    List<String> subjects,
  ) {
    final List<Widget> slivers = [];
    final subjectRows = <List<String>>[];
    for (int i = 0; i < subjects.length; i += columns) {
      final end = (i + columns > subjects.length) ? subjects.length : i + columns;
      subjectRows.add(subjects.sublist(i, end));
    }

    if (_homeAdRowIndices.isEmpty && subjectRows.isNotEmpty) {
      _randomizeHomeAdPositions(subjectRows.length);
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
                              _selectedFilterSubject = row[c];
                              _homeCurrentPage = 1;
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
      if (_homeAdRowIndices.contains(rowIndex)) {
        slivers.add(
          SliverToBoxAdapter(
            key: ValueKey('home_subj_ad_${rowIndex}_$_selectedClass'),
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

  Widget _buildHomeContent(BuildContext context) {
    final isDark = widget.gamification.isDarkMode;
    final realSubjects = _repository.getSubjectsForClass(_selectedClass);
    final booksToDisplay = _computeBooksToDisplay(realSubjects);

    final filterTabs = [
      {
        'title': 'All',
        'icon': Icons.grid_view_rounded,
        'color': isDark ? Colors.white : const Color(0xFF18181B),
      },
      ...realSubjects.map(
        (subj) => {
          'title': subj,
          'icon': AppTheme.getSubjectIcon(subj),
          'color': AppTheme.getSubjectColor(subj),
        },
      ),
    ];

    return RefreshIndicator(
      color: Colors.white,
      backgroundColor: const Color(0xFF1E1E1E),
      onRefresh: () async {
        await _repository.loadCatalog();
        if (mounted) setState(() {});
      },
      child: CustomScrollView(
        controller: _homeScrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Top Header with SWYNX Shimmer Branding
          SliverToBoxAdapter(
            child: HomeHeader(
              isDark: isDark,
              onProfileTap: () => setState(() => _currentTabIndex = 4),
            ),
          ),

          // 2. Student Hero Banner Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 10,
                bottom: 8,
              ),
              child: HeroPlayerCard(
                gamification: widget.gamification,
                onAvatarTap: () => setState(() => _currentTabIndex = 4),
                onClassTap: _showClassPicker,
              ),
            ),
          ),

          // 3. Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: GlassSearchBar(
                controller: _searchController,
                isDark: isDark,
                hintText:
                    'Search Class $_selectedClass books, subjects, chapters...',
                onChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                    _homeCurrentPage = 1;
                  });
                },
                onClear: () {
                  setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                    _homeCurrentPage = 1;
                  });
                },
              ),
            ),
          ),

          // 4. Subject Filter Bar (horizontal chips with static colors)
          SliverToBoxAdapter(
            child: SubjectFilterBar(
              selectedClass: _selectedClass,
              selectedSubject: _selectedFilterSubject,
              hasActiveFilter:
                  _selectedFilterSubject != 'All' || _searchQuery.isNotEmpty,
              filterTabs: filterTabs,
              isDark: isDark,
              onSubjectSelected: (subj) {
                setState(() {
                  _selectedFilterSubject = subj;
                  _homeCurrentPage = 1;
                });
                widget.gamification.recordSubjectExplored(subj);
              },
              onClearFilter: () {
                setState(() {
                  _selectedFilterSubject = 'All';
                  _searchController.clear();
                  _searchQuery = '';
                  _homeCurrentPage = 1;
                });
              },
            ),
          ),

          // 5. Subject Cards Grid (2 cards in a row with ads randomly between rows)
          if (_selectedFilterSubject == 'All' && _searchQuery.isEmpty) ...[
            ..._buildHomeSubjectRowsWithAds(
              AppResponsive.getGridColumnCount(
                context,
                availableWidth: MediaQuery.of(context).size.width,
              ),
              isDark,
              realSubjects,
            ),
          ],

          // 6. Section Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 14,
                bottom: 12,
              ),
              child: Text(
                _searchQuery.isNotEmpty
                    ? 'Search Results (${booksToDisplay.length})'
                    : (_selectedFilterSubject == 'All'
                          ? 'Class $_selectedClass Textbooks (${booksToDisplay.length})'
                          : '$_selectedFilterSubject Textbooks (${booksToDisplay.length})'),
                style: GoogleFonts.roboto(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),

          // 7. Books Grid
          HomeBooksGrid(
            booksToDisplay: booksToDisplay,
            currentPage: _homeCurrentPage,
            pageSize: _homePageSize,
            isDark: isDark,
            gamification: widget.gamification,
            onStateChanged: () {
              if (mounted) setState(() {});
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConfettiOverlay(
      controller: _confettiController,
      child: AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            top: true,
            bottom: false,
            child: MaxContentConstraint(
              child: IndexedStack(
                index: _currentTabIndex,
                children: [
                  _buildHomeContent(context),
                  ExploreScreen(gamification: widget.gamification),
                  DownloadsScreen(
                    key: _downloadsKey,
                    gamification: widget.gamification,
                  ),
                  ProgressScreen(gamification: widget.gamification),
                  ProfileScreen(gamification: widget.gamification),
                ],
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: GlassNavigationBar(
              selectedIndex: _currentTabIndex,
              onDestinationSelected: (index) {
                setState(() => _currentTabIndex = index);
                if (index == 2) {
                  _downloadsKey.currentState?.reload();
                }
              },
              items: const [
                GlassNavItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: 'Home',
                ),
                GlassNavItem(
                  icon: Icons.explore_outlined,
                  selectedIcon: Icons.explore_rounded,
                  label: 'Explore',
                ),
                GlassNavItem(
                  icon: Icons.library_books_outlined,
                  selectedIcon: Icons.library_books_rounded,
                  label: 'Library',
                ),
                GlassNavItem(
                  icon: Icons.emoji_events_outlined,
                  selectedIcon: Icons.emoji_events_rounded,
                  label: 'Progress',
                ),
                GlassNavItem(
                  icon: Icons.person_outline_rounded,
                  selectedIcon: Icons.person_rounded,
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
