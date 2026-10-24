import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/ncert_story.dart';
import '../../../services/ncert_news_service.dart';

class StoryViewerScreen extends StatefulWidget {
  final List<NcertStory> stories;
  final int initialIndex;

  const StoryViewerScreen({
    super.key,
    required this.stories,
    this.initialIndex = 0,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late AnimationController _animController;

  int get _safeIndex {
    if (widget.stories.isEmpty) return 0;
    return _currentIndex.clamp(0, widget.stories.length - 1);
  }

  NcertStory get _currentStory {
    if (widget.stories.isEmpty) {
      return const NcertStory(
        id: 'fallback',
        title: 'NCERT Daily Update',
        snippet:
            'Latest educational directives, curriculum updates, and examination guidelines for students and teachers.',
        source: 'NCERT',
        link: '',
        publishedAt: 'Today',
        category: 'Update',
        gradientColors: [0xFF1E242B, 0xFF1E242B],
      );
    }
    return widget.stories[_safeIndex];
  }

  @override
  void initState() {
    super.initState();
    if (widget.stories.isEmpty) {
      _currentIndex = 0;
      _animController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 6),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
      return;
    }

    _currentIndex = widget.initialIndex.clamp(0, widget.stories.length - 1);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) _onStoryComplete();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _markCurrentAsRead();
        _animController.forward();
      }
    });
  }

  void _markCurrentAsRead() {
    if (widget.stories.isNotEmpty && _safeIndex < widget.stories.length) {
      NcertNewsService.instance.markAsRead(_currentStory.id);
    }
  }

  void _onStoryComplete() {
    if (!mounted) return;
    if (_currentIndex < widget.stories.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _markCurrentAsRead();
      _animController.reset();
      _animController.forward();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _nextStory() {
    if (!mounted) return;
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}

    if (_currentIndex < widget.stories.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _markCurrentAsRead();
      _animController.reset();
      _animController.forward();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _prevStory() {
    if (!mounted) return;
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}

    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _markCurrentAsRead();
      _animController.reset();
      _animController.forward();
    } else {
      _animController.reset();
      _animController.forward();
    }
  }

  void _pause() {
    if (mounted) {
      _animController.stop();
    }
  }

  void _resume() {
    if (mounted) {
      _animController.forward();
    }
  }

  Future<void> _openStoryUrl() async {
    _pause();
    final link = _currentStory.link;
    if (link.isEmpty) {
      if (mounted) _resume();
      return;
    }

    try {
      final uri = Uri.parse(link);
      bool launched = false;
      try {
        launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } catch (_) {
        launched = false;
      }

      if (!launched) {
        try {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        } catch (e) {
          debugPrint('Error launching URL: $e');
        }
      }
    } catch (e) {
      debugPrint('Could not launch story URL: $e');
    } finally {
      if (mounted) {
        _resume();
      }
    }
  }

  String _sanitizeSnippet(String text) {
    if (text.contains('<') || text.contains('href=') || text.contains('http')) {
      return 'Educational authorities and curriculum councils are reviewing standard guidelines, textbook updates, and examination advisories for students across schools.';
    }
    return text;
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stories.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox.shrink(),
      );
    }

    final story = _currentStory;
    final size = MediaQuery.of(context).size;
    final cleanSnippet = _sanitizeSnippet(story.snippet);
    final topAreaHeight = size.height * 0.54;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (_) => _pause(),
        onTapUp: (details) {
          _resume();
          // Avoid skipping story if user taps near the "Read full story" action area
          if (details.globalPosition.dy > size.height * 0.78) {
            return;
          }
          if (details.globalPosition.dx < size.width * 0.35) {
            _prevStory();
          } else {
            _nextStory();
          }
        },
        onLongPressStart: (_) => _pause(),
        onLongPressEnd: (_) => _resume(),
        onVerticalDragEnd: (details) {
          if ((details.primaryVelocity ?? 0) > 200) {
            Navigator.of(context).pop();
          }
        },
        child: Container(
          width: size.width,
          height: size.height,
          color: Colors.black,
          child: Stack(
            children: [
              // 1. Top ~50% area containing the uncropped full picture with bottom fading to black
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: topAreaHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // The Full Picture: BoxFit.contain (NO zooming, NO cropping, full pic visible)
                    if (story.imageUrl != null && story.imageUrl!.isNotEmpty)
                      Center(
                        child: Image.network(
                          story.imageUrl!,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Center(
                              child: SizedBox(
                                width: 26,
                                height: 26,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox.shrink(),
                        ),
                      )
                    else
                      Center(
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                          child: const Icon(
                            Icons.newspaper_rounded,
                            color: Color(0xFF38BDF8),
                            size: 36,
                          ),
                        ),
                      ),

                    // Top vignette gradient to keep progress bar and header readable
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 100,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.75),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Bottom fade to black: Smoothly transitions image into solid black
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: topAreaHeight * 0.45,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.5),
                              Colors.black.withValues(alpha: 0.9),
                              Colors.black,
                            ],
                            stops: const [0.0, 0.4, 0.8, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Top Segmented Progress Bar & Source Header
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),

                      // Segmented Progress Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          children: List.generate(widget.stories.length, (index) {
                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                                height: 3.5,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: AnimatedBuilder(
                                  animation: _animController,
                                  builder: (context, _) {
                                    double progress = 0.0;
                                    if (index < _safeIndex) {
                                      progress = 1.0;
                                    } else if (index == _safeIndex) {
                                      progress = _animController.value.clamp(0.0, 1.0);
                                    }
                                    return FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: progress.clamp(0.0, 1.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Story Header Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.school_rounded,
                                  color: Color(0xFF38BDF8),
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          story.source,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.outfit(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '•  ${story.publishedAt}',
                                        style: GoogleFonts.roboto(
                                          fontSize: 12,
                                          color: const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    story.category,
                                    style: GoogleFonts.roboto(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF38BDF8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                if (mounted) Navigator.of(context).pop();
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.12),
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Text placed OVER the bottom region using Stack
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Category Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.campaign_rounded,
                                color: Color(0xFFFACC15),
                                size: 13,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                story.category.toUpperCase(),
                                style: GoogleFonts.roboto(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Headline
                        Text(
                          story.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Real Journalistic Content
                        Text(
                          cleanSnippet,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.roboto(
                            fontSize: 14.5,
                            height: 1.5,
                            color: const Color(0xFFCBD5E1),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Direct Browser Redirect Button (No Bottom Modal Sheet)
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _openStoryUrl,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0284C7).withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Read full story',
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF38BDF8),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.open_in_new_rounded,
                                  size: 15,
                                  color: Color(0xFF38BDF8),
                                ),
                              ],
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
      ),
    );
  }
}
