import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/ncert_notice.dart';
import '../../services/gamification_service.dart';
import '../../services/ncert_notices_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ad_banner_widget.dart';

class NoticesScreen extends StatefulWidget {
  final GamificationService gamification;

  const NoticesScreen({super.key, required this.gamification});

  @override
  State<NoticesScreen> createState() => _NoticesScreenState();
}

class _NoticesScreenState extends State<NoticesScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSearchOpen = false;

  int _currentPage = 0;
  static const int _pageSize = 12;

  final List<String> _categories = [
    'All',
    'Curriculum',
    'Press Release',
    'Examinations',
    'Conference',
  ];

  @override
  void initState() {
    super.initState();
    NcertNoticesService.instance.init();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openNoticePdf(String url) async {
    if (url.isEmpty) return;
    try {
      HapticFeedback.lightImpact();
      final uri = Uri.parse(url);
      bool launched = false;
      try {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        launched = false;
      }
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint('Could not open notice: $e');
    }
  }

  List<NcertNotice> _filterNotices(List<NcertNotice> all) {
    return all.where((n) {
      if (NcertNoticesService.isGenericOrInvalidTitle(n.title, n.pdfUrl)) {
        return false;
      }
      final matchesCat =
          _selectedCategory == 'All' || n.category == _selectedCategory;
      final matchesQuery = _searchQuery.isEmpty ||
          n.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          n.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesQuery;
    }).toList();
  }

  void _goToPage(int page) {
    HapticFeedback.lightImpact();
    setState(() {
      _currentPage = page;
    });
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  int _getAdPositionForPage(int page, int itemCount) {
    if (itemCount < 8) return -1;
    final rand = Random(page * 37 + _selectedCategory.hashCode);
    final maxPos = min(10, itemCount);
    const minPos = 8;
    if (maxPos < minPos) return minPos;
    return minPos + rand.nextInt(maxPos - minPos + 1);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.gamification.isDarkMode;
    final noticesService = NcertNoticesService.instance;

    final bgColor = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final textPrimary = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final textMuted = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;
    final borderCol = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final cardBg = isDark ? AppTheme.darkSurfaceElevated : AppTheme.lightSurfaceElevated;
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: noticesService,
          builder: (context, _) {
            final allNotices = noticesService.notices;
            final filtered = _filterNotices(allNotices);
            final isLoading = noticesService.isLoading && allNotices.isEmpty;

            final totalPages = (filtered.length / _pageSize).ceil().clamp(1, 999);
            final safePage = _currentPage.clamp(0, totalPages - 1);
            final startIndex = safePage * _pageSize;
            final pageItems = filtered.skip(startIndex).take(_pageSize).toList();

            return RefreshIndicator(
              color: const Color(0xFF38BDF8),
              backgroundColor:
                  isDark ? AppTheme.darkSurfaceElevated : Colors.white,
              onRefresh: () =>
                  noticesService.fetchLiveNotices(force: true),
              child: CustomScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      slivers: [
                        // App bar
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    if (canPop) ...[
                                      GestureDetector(
                                        onTap: () => Navigator.of(context).pop(),
                                        child: Container(
                                          width: 38,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: cardBg,
                                            border: Border.all(color: borderCol),
                                          ),
                                          child: Icon(
                                            Icons.arrow_back_rounded,
                                            size: 19,
                                            color: textPrimary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                    ],
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'Official Notices',
                                              style: GoogleFonts.outfit(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: -0.4,
                                                color: textPrimary,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 7,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF0284C7)
                                                    .withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                'NCERT',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w800,
                                                  color: const Color(0xFF38BDF8),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'ncert.nic.in live circulars & updates',
                                          style: GoogleFonts.roboto(
                                            fontSize: 11.5,
                                            color: textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isSearchOpen = !_isSearchOpen;
                                      if (!_isSearchOpen) {
                                        _searchQuery = '';
                                        _searchController.clear();
                                      }
                                    });
                                  },
                                  child: Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: cardBg,
                                      border: Border.all(color: borderCol),
                                    ),
                                    child: Icon(
                                      _isSearchOpen
                                          ? Icons.close_rounded
                                          : Icons.search_rounded,
                                      size: 18,
                                      color: textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Search input
                        if (_isSearchOpen)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: borderCol),
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  autofocus: true,
                                  onChanged: (val) {
                                    setState(() {
                                      _searchQuery = val.trim();
                                      _currentPage = 0;
                                    });
                                  },
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    color: textPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Search circulars by keyword...',
                                    hintStyle: GoogleFonts.roboto(
                                      fontSize: 13.5,
                                      color: textMuted,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search_rounded,
                                      color: textMuted,
                                      size: 19,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        const SliverToBoxAdapter(child: SizedBox(height: 10)),

                        // Category filter chips
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 36,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: _categories.length,
                              separatorBuilder: (_, _) => const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final cat = _categories[index];
                                final isSelected = _selectedCategory == cat;

                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedCategory = cat;
                                      _currentPage = 0;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? (isDark ? Colors.white : const Color(0xFF0F172A))
                                          : cardBg,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected ? Colors.transparent : borderCol,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        cat,
                                        style: GoogleFonts.roboto(
                                          fontSize: 12,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? (isDark
                                                  ? const Color(0xFF0F172A)
                                                  : Colors.white)
                                              : textMuted,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        const SliverToBoxAdapter(child: SizedBox(height: 14)),

                        // Notice list content
                        if (isLoading)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(50),
                              child: Center(
                                child: Column(
                                  children: [
                                    const CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Color(0xFF38BDF8),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      'Loading NCERT official notices...',
                                      style: GoogleFonts.roboto(
                                        fontSize: 13,
                                        color: textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else if (filtered.isEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(50),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.find_in_page_rounded,
                                      size: 44,
                                      color: textMuted.withValues(alpha: 0.5),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No notices found',
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Try clearing your search query',
                                      style: GoogleFonts.roboto(
                                        fontSize: 12.5,
                                        color: textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final notice = pageItems[index];
                                  final isFeaturedLatest = safePage == 0 &&
                                      index == 0 &&
                                      _searchQuery.isEmpty;

                                  final noticeWidget = isFeaturedLatest
                                      ? Column(
                                          children: [
                                            _buildFeaturedLatestNotice(
                                              context: context,
                                              notice: notice,
                                              isDark: isDark,
                                              textPrimary: textPrimary,
                                              textMuted: textMuted,
                                            ),
                                            const SizedBox(height: 8),
                                          ],
                                        )
                                      : _buildFlatNoticeTile(
                                          context: context,
                                          notice: notice,
                                          isDark: isDark,
                                          borderCol: borderCol,
                                          textPrimary: textPrimary,
                                          textMuted: textMuted,
                                        );

                                  final adPosition = _getAdPositionForPage(
                                    safePage,
                                    pageItems.length,
                                  );

                                  if ((index + 1) == adPosition) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        noticeWidget,
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8,
                                            bottom: 8,
                                          ),
                                          child: AdBannerWidget(
                                            key: ValueKey(
                                              'notice_ad_${safePage}_$index',
                                            ),
                                            showSectionLabel: false,
                                            margin: EdgeInsets.zero,
                                          ),
                                        ),
                                      ],
                                    );
                                  }

                                  return noticeWidget;
                                },
                                childCount: pageItems.length,
                              ),
                            ),
                          ),

                        // 2. Inline pagination at the end of the notice list
                        if (filtered.isNotEmpty && totalPages > 1)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                              child: _buildEndPaginationCard(
                                currentPage: safePage,
                                totalPages: totalPages,
                                totalItems: filtered.length,
                                isDark: isDark,
                                borderCol: borderCol,
                                textPrimary: textPrimary,
                                textMuted: textMuted,
                              ),
                            ),
                          ),

                        // Bottom navigation bar scroll clearance
                        SliverToBoxAdapter(
                          child: SizedBox(height: canPop ? 32 : 120),
                        ),
                      ],
                    ),
                  );
          },
        ),
      ),
    );
  }

  // 1. Featured latest notice with distinct highlighted background
  Widget _buildFeaturedLatestNotice({
    required BuildContext context,
    required NcertNotice notice,
    required bool isDark,
    required Color textPrimary,
    required Color textMuted,
  }) {
    final isPdf = notice.pdfUrl.toLowerCase().endsWith('.pdf');
    final featuredBg = isDark
        ? const Color(0xFF13222E)
        : const Color(0xFFE0F2FE);
    final featuredBorder = isDark
        ? const Color(0xFF0284C7).withValues(alpha: 0.35)
        : const Color(0xFFBAE6FD);

    return InkWell(
      onTap: () => _openNoticePdf(notice.pdfUrl),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: featuredBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: featuredBorder, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top tag
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.fiber_new_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'LATEST CIRCULAR',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  notice.date,
                  style: GoogleFonts.roboto(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: isDark ? const Color(0xFFBAE6FD) : const Color(0xFF0369A1),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.open_in_new_rounded,
                  size: 15,
                  color: Color(0xFF38BDF8),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Title
            Text(
              notice.title,
              style: GoogleFonts.outfit(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                color: textPrimary,
                height: 1.35,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Bottom format indicator
            Row(
              children: [
                Icon(
                  isPdf
                      ? Icons.picture_as_pdf_rounded
                      : Icons.language_rounded,
                  size: 14,
                  color: isPdf ? const Color(0xFFEF4444) : const Color(0xFF38BDF8),
                ),
                const SizedBox(width: 6),
                Text(
                  isPdf ? 'PDF Official Circular' : 'Official Portal Link',
                  style: GoogleFonts.roboto(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFBAE6FD) : const Color(0xFF0369A1),
                  ),
                ),
                const Spacer(),
                Text(
                  'Tap to view document →',
                  style: GoogleFonts.roboto(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF38BDF8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 2. Clean, flat, non-boxy notice list row
  Widget _buildFlatNoticeTile({
    required BuildContext context,
    required NcertNotice notice,
    required bool isDark,
    required Color borderCol,
    required Color textPrimary,
    required Color textMuted,
  }) {
    final isPdf = notice.pdfUrl.toLowerCase().endsWith('.pdf');

    return InkWell(
      onTap: () => _openNoticePdf(notice.pdfUrl),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: borderCol.withValues(alpha: 0.6),
              width: 0.8,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left icon in soft circle
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  isPdf
                      ? Icons.picture_as_pdf_rounded
                      : Icons.language_rounded,
                  size: 18,
                  color: isPdf
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF38BDF8),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        notice.category,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF38BDF8),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: textMuted,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        notice.date,
                        style: GoogleFonts.roboto(
                          fontSize: 11,
                          color: textMuted,
                        ),
                      ),
                      if (notice.isNew) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'NEW',
                            style: GoogleFonts.outfit(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    notice.title,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                      height: 1.35,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isPdf ? 'PDF Document • Tap to read' : 'Web Portal • Tap to open',
                    style: GoogleFonts.roboto(
                      fontSize: 11,
                      color: textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Trailing arrow
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: textMuted.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Clean inline pagination card at the end of notices list
  Widget _buildEndPaginationCard({
    required int currentPage,
    required int totalPages,
    required int totalItems,
    required bool isDark,
    required Color borderCol,
    required Color textPrimary,
    required Color textMuted,
  }) {
    final hasPrev = currentPage > 0;
    final hasNext = currentPage < totalPages - 1;
    final cardBg = isDark ? AppTheme.darkSurfaceElevated : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous Page
              InkWell(
                onTap: hasPrev ? () => _goToPage(currentPage - 1) : null,
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: hasPrev
                        ? (isDark ? const Color(0xFF282832) : const Color(0xFFF1F5F9))
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: hasPrev ? borderCol : borderCol.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back_rounded,
                        size: 16,
                        color: hasPrev ? textPrimary : textMuted.withValues(alpha: 0.3),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Prev',
                        style: GoogleFonts.outfit(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: hasPrev ? textPrimary : textMuted.withValues(alpha: 0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Page indicator info
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Page ${currentPage + 1} of $totalPages',
                    style: GoogleFonts.outfit(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$totalItems official circulars',
                    style: GoogleFonts.roboto(
                      fontSize: 11,
                      color: textMuted,
                    ),
                  ),
                ],
              ),

              // Next Page
              InkWell(
                onTap: hasNext ? () => _goToPage(currentPage + 1) : null,
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: hasNext ? const Color(0xFF0284C7) : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: hasNext ? Colors.transparent : borderCol.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Next',
                        style: GoogleFonts.outfit(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: hasNext ? Colors.white : textMuted.withValues(alpha: 0.3),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: hasNext ? Colors.white : textMuted.withValues(alpha: 0.3),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Direct Page jump chips
          if (totalPages > 1 && totalPages <= 7) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(totalPages, (index) {
                final isCurrent = index == currentPage;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () => _goToPage(index),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 32,
                      height: 30,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? const Color(0xFF0284C7)
                            : (isDark ? const Color(0xFF1F1F26) : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isCurrent ? Colors.transparent : borderCol,
                          width: 0.8,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                            color: isCurrent ? Colors.white : textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }
}
