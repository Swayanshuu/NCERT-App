import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/ncert_story.dart';
import '../../../services/ncert_news_service.dart';
import '../../../widgets/app_shimmer.dart';
import 'story_viewer_screen.dart';

class BeyondCampusStories extends StatefulWidget {
  final bool isDark;

  const BeyondCampusStories({super.key, required this.isDark});

  @override
  State<BeyondCampusStories> createState() => _BeyondCampusStoriesState();
}

class _BeyondCampusStoriesState extends State<BeyondCampusStories> {
  @override
  void initState() {
    super.initState();
    NcertNewsService.instance.init();
    NcertNewsService.instance.fetchLiveNews();
  }

  void _openStoryViewer(List<NcertStory> stories, int initialIndex) {
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        transitionDuration: const Duration(milliseconds: 260),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: StoryViewerScreen(
              stories: stories,
              initialIndex: initialIndex,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return AnimatedBuilder(
      animation: NcertNewsService.instance,
      builder: (context, _) {
        final newsService = NcertNewsService.instance;
        final stories = newsService.stories;
        final isLoading = newsService.isLoading && stories.isEmpty;
        final unreadCount = newsService.unreadCount;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      'Daily Student Briefs',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        letterSpacing: -0.5,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                  ),

                  // Clean Static Header Badge (No blurry neon)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E242B)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          unreadCount > 0 ? '$unreadCount NEW' : 'LIVE',
                          style: GoogleFonts.roboto(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: isDark
                                ? const Color(0xFFCBD5E1)
                                : const Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Horizontal Stories Reel
            if (isLoading)
              const AppShimmerStoryReel()
            else if (stories.isEmpty)
              const SizedBox.shrink()
            else
              SizedBox(
                height: 136,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: stories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final story = stories[index];
                    final cardColor = isDark
                        ? const Color(0xFF1E2228)
                        : const Color(0xFFF8FAFC);

                    final isUnread = !story.isRead;

                    return GestureDetector(
                      onTap: () => _openStoryViewer(stories, index),
                      child: Container(
                        width: 172,
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(14),
                          // No borders and no blurry neon effects
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Tag & Crisp Solid Unread Dot
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : Colors.black.withValues(alpha: 0.06),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    story.category.toUpperCase(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.roboto(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.6,
                                      color: isDark
                                          ? const Color(0xFF93C5FD)
                                          : const Color(0xFF2563EB),
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                if (isUnread)
                                  Container(
                                    width: 5,
                                    height: 5,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF38BDF8),
                                    ),
                                  ),
                              ],
                            ),

                            const Spacer(),

                            // Headline: clean, professional, readable
                            Text(
                              story.title,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                            ),

                            const SizedBox(height: 7),

                            // Source & Time
                            Text(
                              '${story.source} • ${story.publishedAt}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.roboto(
                                fontSize: 10,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
