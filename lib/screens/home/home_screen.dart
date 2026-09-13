import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncert_books_app/models/ncert_book.dart';
import 'package:ncert_books_app/services/ncert_repository.dart';
import 'package:ncert_books_app/services/gamification_service.dart';
import 'package:ncert_books_app/theme/app_theme.dart';
import 'package:ncert_books_app/theme/app_responsive.dart';
import 'package:ncert_books_app/widgets/ad_banner_widget.dart';
import 'package:ncert_books_app/widgets/app_background.dart';
import 'package:ncert_books_app/widgets/confetti_overlay.dart';
import 'package:ncert_books_app/widgets/hover_builder.dart';
import 'package:ncert_books_app/widgets/glass/glass_surface.dart';
import 'package:ncert_books_app/widgets/glass/glass_navigation_bar.dart';
import 'package:ncert_books_app/widgets/glass/glass_search_bar.dart';
import 'package:ncert_books_app/screens/home/bloc/home_bloc.dart';
import 'package:ncert_books_app/screens/home/widgets/hero_player_card.dart';
import 'package:ncert_books_app/screens/home/widgets/daily_mission_card.dart';
import 'package:ncert_books_app/screens/home/widgets/reward_chest_widget.dart';
import 'package:ncert_books_app/screens/books/widgets/book_card.dart';
import 'package:ncert_books_app/screens/books/downloads_screen.dart';
import 'package:ncert_books_app/screens/progress/progress_screen.dart';
import 'package:ncert_books_app/screens/profile/profile_screen.dart';
import 'package:ncert_books_app/screens/books/book_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final GamificationService gamification;

  const HomeScreen({super.key, required this.gamification});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NcertRepository _repository = NcertRepository();
  final TextEditingController _searchController = TextEditingController();
  int _currentTabIndex = 0;
  String _selectedClass = '10';
  String _searchQuery = '';
  String _selectedFilterSubject = 'All';

  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _selectedClass = widget.gamification.userClass;
    widget.gamification.addListener(_onStateChanged);
    _initData();
  }

  @override
  void dispose() {
    widget.gamification.removeListener(_onStateChanged);
    _confettiController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    if (_currentTabIndex == index) return;
    context.read<HomeBloc>().add(HomeTabChanged(index));
    setState(() {
      _currentTabIndex = index;
    });
  }

  void _onStateChanged() {
    if (mounted) {
      if (_selectedClass != widget.gamification.userClass) {
        _selectedClass = widget.gamification.userClass;
        _updateBooks();
      }
      setState(() {});
    }
  }

  Future<void> _initData() async {
    await _repository.loadCatalog();
    if (mounted) setState(() {});
  }

  void _updateBooks() {
    // Books loaded based on selected class
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
            color: isDark
                ? AppTheme.darkBackground.withValues(alpha: 0.95)
                : AppTheme.lightBackground.withValues(alpha: 0.95),
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
                          color: isDark
                              ? AppTheme.darkTextPrimary
                              : AppTheme.lightTextPrimary,
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
                                _updateBooks();
                              });
                              Navigator.pop(ctx);
                            },
                            builder: (context, isHovered) => Container(
                              decoration: BoxDecoration(
                                color: isSel
                                    ? AppTheme.primaryTeal
                                    : (isDark
                                        ? AppTheme.darkSurface
                                        : Colors.white),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSel
                                      ? AppTheme.primaryTeal
                                      : (isDark
                                          ? AppTheme.darkBorder
                                          : AppTheme.lightBorder),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Class $cls',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    color: isSel
                                        ? Colors.white
                                        : (isDark
                                            ? Colors.white
                                            : AppTheme.lightTextPrimary),
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

  String _getSubjectEmoji(String subject) {
    final s = subject.toLowerCase();
    if (s.contains('math')) return '📐';
    if (s.contains('sci') || s.contains('evs')) return '🔬';
    if (s.contains('eng')) return '📖';
    if (s.contains('hin')) return '🪶';
    if (s.contains('soc') || s.contains('his') || s.contains('geo') || s.contains('pol')) return '🌍';
    if (s.contains('san')) return '🕉';
    return '📚';
  }

  Widget _buildHomeContent(BuildContext context) {
    final isDark = widget.gamification.isDarkMode;

    // Dynamic real subjects from repository for active class
    final realSubjects = _repository.getSubjectsForClass(_selectedClass);

    final subjectWorlds = realSubjects.map((subject) {
      final books = _repository.getBooks(_selectedClass, subject);
      return {
        'title': subject,
        'emoji': _getSubjectEmoji(subject),
        'icon': AppTheme.getSubjectIcon(subject),
        'color': AppTheme.getSubjectColor(subject),
        'count': books.length,
        'progress': 0.5,
      };
    }).toList();

    final filterTabs = [
      {'title': 'All', 'emoji': '🌟', 'color': AppTheme.skyCyan},
      ...subjectWorlds.map((s) => {
        'title': s['title'] as String,
        'emoji': s['emoji'] as String,
        'color': s['color'] as Color,
      }),
    ];

    // Calculate books to display in Home tab
    List<NcertBook> booksToDisplay = [];
    if (_searchQuery.isNotEmpty) {
      booksToDisplay = _repository.searchBooks(_searchQuery);
    } else if (_selectedFilterSubject != 'All') {
      booksToDisplay = _repository.getBooks(_selectedClass, _selectedFilterSubject);
    } else {
      final List<NcertBook> all = [];
      for (final s in realSubjects) {
        all.addAll(_repository.getBooks(_selectedClass, s));
      }
      booksToDisplay = all;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = AppResponsive.getGridColumnCount(
          context,
          availableWidth: constraints.maxWidth,
        );

        return RefreshIndicator(
          color: AppTheme.primaryTeal,
          onRefresh: () async {
            await _repository.loadCatalog();
            if (mounted) setState(() {});
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 0. Mobile Top Bar with Quick Class Switcher
              if (!AppResponsive.isDesktop(context))
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                'assets/logo.png',
                                width: 28,
                                height: 28,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'NCERT Books',
                                  style: GoogleFonts.outfit(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                                  ),
                                ),
                                Text(
                                  'v1.0.0',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Mobile Switch Class Button
                        HoverBuilder(
                          onTap: _showClassPickerModal,
                          builder: (context, isHovered) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppTheme.primaryTeal, AppTheme.skyCyan],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryTeal.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.school_rounded, color: Colors.white, size: 14),
                                const SizedBox(width: 5),
                                Text(
                                  'Class $_selectedClass',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                const Icon(Icons.unfold_more_rounded, color: Colors.white, size: 15),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // 1. Greeting Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 8),
                  child: HeroPlayerCard(
                    gamification: widget.gamification,
                    onAvatarTap: () {
                      setState(() => _currentTabIndex = 3);
                    },
                    onClassTap: _showClassPickerModal,
                  ),
                ),
              ),

              // 2. Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: GlassSearchBar(
                    controller: _searchController,
                    isDark: isDark,
                    hintText: 'Search Class $_selectedClass books, subjects, chapters...',
                    onChanged: (query) {
                      setState(() {
                        _searchQuery = query;
                      });
                    },
                    onClear: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                  ),
                ),
              ),

              // 3. Subject Filter Tabs Bar
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 14, bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Class $_selectedClass Subjects 🌈',
                            style: GoogleFonts.outfit(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                            ),
                          ),
                          if (_selectedFilterSubject != 'All' || _searchQuery.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedFilterSubject = 'All';
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                              child: Text(
                                'Show All',
                                style: GoogleFonts.outfit(
                                  color: AppTheme.skyCyan,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filterTabs.length,
                        itemBuilder: (context, index) {
                          final tab = filterTabs[index];
                          final title = tab['title'] as String;
                          final emoji = tab['emoji'] as String;
                          final color = tab['color'] as Color;
                          final isSelected = _selectedFilterSubject == title;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedFilterSubject = title;
                                  });
                                  widget.gamification.recordSubjectExplored(title);
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? color
                                        : color.withValues(alpha: isDark ? 0.15 : 0.08),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? color
                                          : color.withValues(alpha: 0.35),
                                      width: isSelected ? 1.8 : 1.0,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: color.withValues(alpha: 0.35),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            )
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(emoji, style: const TextStyle(fontSize: 14)),
                                      const SizedBox(width: 6),
                                      Text(
                                        title,
                                        style: GoogleFonts.outfit(
                                          fontSize: 12,
                                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                          color: isSelected ? Colors.white : color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              // 4. Banner Ad
              const SliverToBoxAdapter(
                child: AdBannerWidget(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  showSectionLabel: true,
                ),
              ),

              // 7. NCERT Books Catalog Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 12),
                  child: Text(
                    _searchQuery.isNotEmpty
                        ? 'Search Results (${booksToDisplay.length})'
                        : (_selectedFilterSubject == 'All'
                            ? 'All Class $_selectedClass NCERT Books (${booksToDisplay.length})'
                            : '$_selectedFilterSubject Books (${booksToDisplay.length})'),
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                    ),
                  ),
                ),
              ),

              // 8. NCERT Books Grid
              if (booksToDisplay.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'No books found',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 95),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.70,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final book = booksToDisplay[index];
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
                            if (mounted) setState(() {});
                          },
                        );
                      },
                      childCount: booksToDisplay.length,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRightDesktopUtilityPanel() {
    return Container(
      width: 320,
      margin: const EdgeInsets.only(top: 16, bottom: 16, right: 16),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            RewardChestWidget(
              gamification: widget.gamification,
              onChestOpened: () => _confettiController.play(),
            ),
            const SizedBox(height: 16),
            DailyMissionCard(
              gamification: widget.gamification,
              onMissionCompleted: () => _confettiController.play(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktopLayout = AppResponsive.isDesktop(context);
    final isDark = widget.gamification.isDarkMode;

    return ConfettiOverlay(
      controller: _confettiController,
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        body: AppBackground(
          child: SafeArea(
            bottom: false,
            child: isDesktopLayout
                ? Row(
                    children: [
                      // Desktop Rail Sidebar Drawer
                      Container(
                        width: 230,
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.darkSurface.withValues(alpha: 0.90)
                              : Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: isDark
                                ? AppTheme.darkBorder
                                : AppTheme.lightBorder,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            // 1. App Branding Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    'assets/logo.png',
                                    width: 38,
                                    height: 38,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'NCERT Books',
                                      style: GoogleFonts.outfit(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? AppTheme.darkTextPrimary
                                            : AppTheme.lightTextPrimary,
                                      ),
                                    ),
                                    Text(
                                      'v1.0.0',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? AppTheme.darkTextMuted
                                            : AppTheme.lightTextMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Divider(
                              color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                              indent: 16,
                              endIndent: 16,
                            ),
                            const SizedBox(height: 8),

                            // 2. Navigation Items
                            _buildDesktopRailItem(
                              0,
                              Icons.home_rounded,
                              'Home',
                            ),
                            _buildDesktopRailItem(
                              1,
                              Icons.library_books_rounded,
                              'Library',
                            ),
                            _buildDesktopRailItem(
                              2,
                              Icons.emoji_events_rounded,
                              'Progress',
                            ),
                            _buildDesktopRailItem(
                              3,
                              Icons.person_rounded,
                              'Profile',
                            ),

                            const Spacer(),

                            // 3. Active Class Switcher Card
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              child: HoverBuilder(
                                onTap: _showClassPickerModal,
                                builder: (context, isHovered) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryTeal.withValues(alpha: isDark ? 0.15 : 0.08),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppTheme.primaryTeal.withValues(alpha: 0.35),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.school_rounded, color: AppTheme.primaryTeal, size: 18),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Class $_selectedClass',
                                            style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryTeal,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'Switch',
                                          style: GoogleFonts.outfit(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // 4. Quick Student Profile Mini Card
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppTheme.darkSurface.withValues(alpha: 0.6)
                                      : Colors.white.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      widget.gamification.currentAvatar.split(' ').first,
                                      style: const TextStyle(fontSize: 22),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.gamification.userName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                                            ),
                                          ),
                                          Text(
                                            'Lvl ${widget.gamification.level} • 🔥 ${widget.gamification.streak}d',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.accentAmber,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // 5. Theme Switcher Button Card
                            Padding(
                              padding: const EdgeInsets.only(left: 14, right: 14, top: 6, bottom: 16),
                              child: HoverBuilder(
                                onTap: () {
                                  widget.gamification.toggleTheme();
                                },
                                builder: (context, isHovered) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : Colors.black.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                                            color: isDark ? AppTheme.accentPurple : AppTheme.accentAmber,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            isDark ? 'Dark Mode' : 'Light Mode',
                                            style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                              color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Toggle Switch Animation Pill
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        width: 36,
                                        height: 20,
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          color: isDark ? AppTheme.accentPurple : AppTheme.accentAmber,
                                        ),
                                        child: AnimatedAlign(
                                          duration: const Duration(milliseconds: 200),
                                          alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
                                          child: Container(
                                            width: 16,
                                            height: 16,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Main Content Area (Constrained Max Width)
                      Expanded(
                        child: MaxContentConstraint(
                          child: IndexedStack(
                            index: _currentTabIndex,
                            children: [
                              _buildHomeContent(context),
                              DownloadsScreen(gamification: widget.gamification),
                              ProgressScreen(gamification: widget.gamification),
                              ProfileScreen(gamification: widget.gamification),
                            ],
                          ),
                        ),
                      ),

                      // Right Contextual Utility Panel
                      if (_currentTabIndex == 0)
                        _buildRightDesktopUtilityPanel(),
                    ],
                  )
                : IndexedStack(
                    index: _currentTabIndex,
                    children: [
                      _buildHomeContent(context),
                      DownloadsScreen(gamification: widget.gamification),
                      ProgressScreen(gamification: widget.gamification),
                      ProfileScreen(gamification: widget.gamification),
                    ],
                  ),
          ),
        ),
        bottomNavigationBar: isDesktopLayout
            ? null
            : SafeArea(
                top: false,
                child: GlassNavigationBar(
                  selectedIndex: _currentTabIndex,
                  onDestinationSelected: _onTabSelected,
                  items: const [
                    GlassNavItem(
                      icon: Icons.home_outlined,
                      selectedIcon: Icons.home_rounded,
                      label: 'Home',
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
    );
  }

  Widget _buildDesktopRailItem(int index, IconData icon, String label) {
    final isSelected = _currentTabIndex == index;
    final isDark = widget.gamification.isDarkMode;

    return HoverBuilder(
      onTap: () => _onTabSelected(index),
      builder: (context, isHovered) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            tileColor: isSelected
                ? AppTheme.primaryTeal.withValues(alpha: 0.20)
                : (isHovered
                      ? AppTheme.primaryTeal.withValues(alpha: 0.08)
                      : Colors.transparent),
            leading: Icon(
              icon,
              color: isSelected
                  ? AppTheme.primaryTeal
                  : (isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted),
            ),
            title: Text(
              label,
              style: GoogleFonts.outfit(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? AppTheme.primaryTeal
                    : (isDark
                          ? AppTheme.darkTextPrimary
                          : AppTheme.lightTextPrimary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
