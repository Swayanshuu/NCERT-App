import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/ncert_notice.dart';
import '../../services/gamification_service.dart';
import '../../services/ncert_notices_service.dart';

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
  bool _isSearchOpen = false;

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
      debugPrint('Could not open notice PDF: $e');
    }
  }

  List<NcertNotice> _filterNotices(List<NcertNotice> all) {
    return all.where((n) {
      final matchesCat =
          _selectedCategory == 'All' || n.category == _selectedCategory;
      final matchesQuery = _searchQuery.isEmpty ||
          n.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          n.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.gamification.isDarkMode;
    final noticesService = NcertNoticesService.instance;

    final bgColor = isDark ? const Color(0xFF0F1116) : const Color(0xFFF8FAFC);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final circularBtnBg = isDark ? const Color(0xFF1E222A) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: noticesService,
          builder: (context, _) {
            final allNotices = noticesService.notices;
            final filtered = _filterNotices(allNotices);
            final isLoading = noticesService.isLoading && allNotices.isEmpty;

            return RefreshIndicator(
              color: const Color(0xFF0284C7),
              backgroundColor: isDark ? const Color(0xFF1E222A) : Colors.white,
              onRefresh: () => noticesService.fetchLiveNotices(force: true),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // 1. Top Bar: Circular Back Button, Title, Circular Action Buttons
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 14,
                        bottom: 16,
                      ),
                      child: Row(
                        children: [
                          // Circular Back Button
                          InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            borderRadius: BorderRadius.circular(22),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: circularBtnBg,
                              ),
                              child: Icon(
                                Icons.arrow_back_rounded,
                                color: textPrimary,
                                size: 20,
                              ),
                            ),
                          ),
                          const Spacer(),

                          // Circular Search Toggle Button
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isSearchOpen = !_isSearchOpen;
                                if (!_isSearchOpen) {
                                  _searchQuery = '';
                                  _searchController.clear();
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(22),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: circularBtnBg,
                              ),
                              child: Icon(
                                _isSearchOpen
                                    ? Icons.close_rounded
                                    : Icons.search_rounded,
                                color: textPrimary,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Circular Refresh Button
                          InkWell(
                            onTap: () =>
                                noticesService.fetchLiveNotices(force: true),
                            borderRadius: BorderRadius.circular(22),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: circularBtnBg,
                              ),
                              child: noticesService.isLoading
                                  ? Center(
                                      child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: textPrimary,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.refresh_rounded,
                                      color: textPrimary,
                                      size: 20,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. Screen Headline & Subtitle (Clean & Bold Modern Sans)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'NCERT Notices',
                                style: GoogleFonts.outfit(
                                  fontSize: 27,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.6,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3.5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'LIVE',
                                  style: GoogleFonts.roboto(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    color: const Color(0xFF0284C7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Official circulars, press releases & curriculum guidelines from ncert.nic.in',
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                              color: textMuted,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 3. Search Bar (if toggled open)
                  if (_isSearchOpen)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E222A)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF2B313E)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            onChanged: (val) =>
                                setState(() => _searchQuery = val.trim()),
                            style: GoogleFonts.roboto(
                              fontSize: 14.5,
                              color: textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search notices by keyword or subject...',
                              hintStyle: GoogleFonts.roboto(
                                fontSize: 14,
                                color: textMuted,
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: textMuted,
                                size: 20,
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

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // 4. Capsule Filter Chips
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 38,
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
                            onTap: () => setState(() => _selectedCategory = cat),
                            borderRadius: BorderRadius.circular(24),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark ? Colors.white : const Color(0xFF0F172A))
                                    : (isDark
                                        ? const Color(0xFF1E222A)
                                        : const Color(0xFFE2E8F0)),
                                borderRadius: BorderRadius.circular(24),
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
                                        ? (isDark ? const Color(0xFF0F172A) : Colors.white)
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

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // 5. Notices List
                  if (isLoading)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 40,
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              const CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Color(0xFF0284C7),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Loading latest NCERT notices...',
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 40,
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.find_in_page_rounded,
                                size: 48,
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
                                'Try clearing your search query or selecting "All"',
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
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final notice = filtered[index];
                            final isFirst = index == 0 && _searchQuery.isEmpty;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _buildNoticeCard(
                                context: context,
                                notice: notice,
                                isDark: isDark,
                                isFeatured: isFirst,
                              ),
                            );
                          },
                          childCount: filtered.length,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNoticeCard({
    required BuildContext context,
    required NcertNotice notice,
    required bool isDark,
    required bool isFeatured,
  }) {
    // Top featured card uses high-contrast light styling (McDonald's card style from reference)
    final cardBg = isFeatured
        ? const Color(0xFFF1F5F9) // High-contrast clean off-white card
        : (isDark ? const Color(0xFF1A1D24) : Colors.white);

    final cardBorder = isFeatured
        ? Border.all(color: const Color(0xFFE2E8F0), width: 1.2)
        : Border.all(
            color: isDark ? const Color(0xFF282C37) : const Color(0xFFE2E8F0),
            width: 1,
          );

    final titleColor = isFeatured
        ? const Color(0xFF0F172A)
        : (isDark ? Colors.white : const Color(0xFF0F172A));

    final iconBg = isFeatured
        ? const Color(0xFF0284C7).withValues(alpha: 0.15)
        : (isDark
            ? const Color(0xFF0284C7).withValues(alpha: 0.18)
            : const Color(0xFF0284C7).withValues(alpha: 0.12));

    return InkWell(
      onTap: () => _openNoticePdf(notice.pdfUrl),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(22),
          border: cardBorder,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Category Icon/Tag & Right Metadata Pill
            Row(
              children: [
                // Category Icon
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconBg,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.description_rounded,
                      color: Color(0xFF0284C7),
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 9),

                // Category Tag
                Text(
                  notice.category.toUpperCase(),
                  style: GoogleFonts.roboto(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: const Color(0xFF0284C7),
                  ),
                ),

                const Spacer(),

                // Right Metadata Pill (NEW or Date)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3.5,
                  ),
                  decoration: BoxDecoration(
                    color: isFeatured
                        ? const Color(0xFFE2E8F0)
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: notice.isNew
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        notice.date,
                        style: GoogleFonts.roboto(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: isFeatured
                              ? const Color(0xFF334155)
                              : (isDark
                                  ? const Color(0xFFCBD5E1)
                                  : const Color(0xFF475569)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Headline
            Text(
              notice.title,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                height: 1.3,
                color: titleColor,
              ),
            ),

            const SizedBox(height: 14),

            // Bottom Sub-Pills Row (Inspired by reference UI 'In-store & Online', '✓ Activated')
            Row(
              children: [
                // Pill 1: Document Format
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: isFeatured
                        ? const Color(0xFFE2EBF0)
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.picture_as_pdf_rounded,
                        size: 13,
                        color: isFeatured
                            ? const Color(0xFF475569)
                            : (isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B)),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Official Document',
                        style: GoogleFonts.roboto(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: isFeatured
                              ? const Color(0xFF334155)
                              : (isDark
                                  ? const Color(0xFFCBD5E1)
                                  : const Color(0xFF475569)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Pill 2: Direct Action Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View Notice',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0284C7),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.open_in_new_rounded,
                        size: 12,
                        color: Color(0xFF0284C7),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
