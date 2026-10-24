import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ncert_books_app/services/gamification_service.dart';
import 'package:ncert_books_app/services/ncert_repository.dart';
import 'package:ncert_books_app/theme/app_responsive.dart';
import 'package:ncert_books_app/theme/app_theme.dart';
import 'package:ncert_books_app/widgets/app_background.dart';
import 'package:ncert_books_app/widgets/confetti_overlay.dart';
import 'package:ncert_books_app/widgets/glass/glass_navigation_bar.dart';
import 'package:ncert_books_app/screens/home/widgets/home_header.dart';
import 'package:ncert_books_app/screens/home/widgets/student_journal_hero_card.dart';
import 'package:ncert_books_app/screens/home/widgets/beyond_campus_stories.dart';
import 'package:ncert_books_app/screens/home/widgets/class_picker_modal.dart';
import 'package:ncert_books_app/screens/home/widgets/subject_bento_grid.dart';
import 'package:ncert_books_app/screens/books/subject_books_screen.dart';
import 'package:ncert_books_app/screens/explore/explore_screen.dart';
import 'package:ncert_books_app/screens/books/downloads_screen.dart';
import 'package:ncert_books_app/screens/progress/progress_screen.dart';
import 'package:ncert_books_app/screens/profile/profile_screen.dart';
import 'package:shimmer_text/shimmer_text.dart';

class HomeScreen extends StatefulWidget {
  final GamificationService gamification;

  const HomeScreen({super.key, required this.gamification});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NcertRepository _repository = NcertRepository();
  final ScrollController _homeScrollController = ScrollController();
  final GlobalKey<DownloadsScreenState> _downloadsKey =
      GlobalKey<DownloadsScreenState>();
  late ConfettiController _confettiController;

  int _currentTabIndex = 0;
  String _selectedClass = '10';

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _selectedClass = widget.gamification.userClass;
    widget.gamification.addListener(_onStateChange);
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
    _homeScrollController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
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
        });
      },
    );
  }

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'morning';
    } else if (hour >= 12 && hour < 17) {
      return 'afternoon';
    } else {
      return 'evening';
    }
  }

  Widget _buildHomeContent(BuildContext context) {
    final isDark = widget.gamification.isDarkMode;
    final realSubjects = _repository.getSubjectsForClass(_selectedClass);
    final totalResources = realSubjects.fold<int>(
      0,
      (sum, s) => sum + _repository.getBooks(_selectedClass, s).length,
    );

    return RefreshIndicator(
      color: Colors.white,
      backgroundColor: AppTheme.darkBackground,
      onRefresh: () async {
        await _repository.loadCatalog();
        if (mounted) setState(() {});
      },
      child: CustomScrollView(
        controller: _homeScrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Top Header with brand 'alcademy.', ONLINE indicator, and hamburger menu
          SliverToBoxAdapter(
            child: HomeHeader(
              isDark: isDark,
              onProfileTap: () => setState(() => _currentTabIndex = 4),
            ),
          ),

          // 2. Greeting: 'Good evening, swayanshu.'
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 8,
                bottom: 12,
              ),
              child: Row(
                children: [
                  Text(
                    'Good ${_getTimeGreeting()}, ',
                    style: GoogleFonts.outfit(
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      color: isDark ? Colors.white : const Color(0xFF111827),
                    ),
                  ),
                  ShimmerText(
                    text: '${widget.gamification.userName}.',
                    textSize: 23,
                    textColor: isDark ? Colors.white : const Color(0xFF111827),
                    shiningColor: const Color.fromARGB(255, 102, 102, 102),
                    letterspacing: -0.4,
                    textFamily: GoogleFonts.outfit().fontFamily ?? '',
                  ),
                ],
              ),
            ),
          ),

          // 3. Hero Card: 'THE STUDENT JOURNAL' (Teal gradient, 24 OCT, Evening chill mode!, notebook graphic, resources count, Class pill)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
              child: StudentJournalHeroCard(
                totalResources: totalResources,
                selectedClass: _selectedClass,
                isDark: isDark,
                onPillTap: _showClassPicker,
              ),
            ),
          ),

          // 4. Section 1: 'STORIES & UPDATES: Beyond textbook' (Mind maps, Developer note, CBSE updates, Formulas)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: BeyondCampusStories(isDark: isDark),
            ),
          ),

          // 6. Section 3: 'THE STUDY SHELF: Your subjects' (Bento Grid of subjects with watermarks, icons, diagonal arrows, and 'Change class' button)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SubjectBentoGrid(
                selectedClass: _selectedClass,
                selectedSubject: '',
                subjects: realSubjects,
                isDark: isDark,
                gamification: widget.gamification,
                getBookCount: (subj) =>
                    _repository.getBooks(_selectedClass, subj).length,
                onChangeClassTap: _showClassPicker,
                onSubjectSelected: (subj) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SubjectBooksScreen(
                        className: _selectedClass,
                        subjectName: subj,
                        gamification: widget.gamification,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 7. Bottom spacer to comfortably clear floating glass navigation bar
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
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
          extendBody: true,
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
                  icon: Icons.search_outlined,
                  selectedIcon: Icons.search_rounded,
                  label: 'Search',
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
