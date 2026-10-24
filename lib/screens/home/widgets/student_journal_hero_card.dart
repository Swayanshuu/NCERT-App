import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';

/// Exact student journal card matching the user's reference design:
/// - Smooth live auto-changing ambient color gradient (no border)
/// - Big bold editorial headline on left: "Study flow / every day"
/// - Poetic subtitle featuring Class & Total Resources
/// - Suspended vertical threads hanging from the top with glowing beads
/// - Slightly tilted frosted glass pill tags (including date, class switcher, and electric blue textbook count)
class StudentJournalHeroCard extends StatefulWidget {
  final int totalResources;
  final String selectedClass;
  final bool isDark;
  final VoidCallback? onPillTap;

  const StudentJournalHeroCard({
    super.key,
    required this.totalResources,
    required this.selectedClass,
    required this.isDark,
    this.onPillTap,
  });

  @override
  State<StudentJournalHeroCard> createState() => _StudentJournalHeroCardState();
}

class _StudentJournalHeroCardState extends State<StudentJournalHeroCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  // 4 curated dark mode palettes cycling continuously
  static const List<List<Color>> _darkPalettes = [
    // 1. Midnight Indigo & Violet (Exact reference palette)
    [
      Color(0xFF070814),
      Color(0xFF0C0E22),
      Color(0xFF151438),
      Color(0xFF22174C),
    ],
    // 2. Oceanic Deep Navy & Sapphire
    [
      Color(0xFF040B16),
      Color(0xFF071528),
      Color(0xFF0D2544),
      Color(0xFF163B60),
    ],
    // 3. Velvet Midnight Teal & Dark Pine
    [
      Color(0xFF040E10),
      Color(0xFF081C20),
      Color(0xFF0E3036),
      Color(0xFF154448),
    ],
    // 4. Royal Midnight Plum & Obsidian
    [
      Color(0xFF0C0616),
      Color(0xFF160A26),
      Color(0xFF26103E),
      Color(0xFF351656),
    ],
  ];

  // 4 curated light mode palettes cycling continuously
  static const List<List<Color>> _lightPalettes = [
    // 1. Vibrant Ocean Cyan & Azure
    [
      Color(0xFF0284C7),
      Color(0xFF0369A1),
      Color(0xFF1E40AF),
      Color(0xFF312E81),
    ],
    // 2. Iris Purple & Deep Violet
    [
      Color(0xFF6366F1),
      Color(0xFF4F46E5),
      Color(0xFF4338CA),
      Color(0xFF3730A3),
    ],
    // 3. Emerald Seafoam & Deep Teal
    [
      Color(0xFF0D9488),
      Color(0xFF0F766E),
      Color(0xFF115E59),
      Color(0xFF134E4A),
    ],
    // 4. Sunset Coral & Warm Amber
    [
      Color(0xFFD97706),
      Color(0xFFEA580C),
      Color(0xFFC2410C),
      Color(0xFF9A3412),
    ],
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatDate() {
    final now = DateTime.now();
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return '${now.day} ${months[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final double progress = _animationController.value;
        final palettes = widget.isDark ? _darkPalettes : _lightPalettes;
        final int n = palettes.length;
        final double scaled = progress * n;
        final int index = scaled.floor() % n;
        final int nextIndex = (index + 1) % n;
        final double t = scaled - scaled.floor();

        // Smoothly interpolate the 4 gradient stops
        final Color c0 =
            Color.lerp(palettes[index][0], palettes[nextIndex][0], t)!;
        final Color c1 =
            Color.lerp(palettes[index][1], palettes[nextIndex][1], t)!;
        final Color c2 =
            Color.lerp(palettes[index][2], palettes[nextIndex][2], t)!;
        final Color c3 =
            Color.lerp(palettes[index][3], palettes[nextIndex][3], t)!;

        // Subtle lifelike pendulum sway for the hanging strings
        final double swayAngle = progress * 2 * math.pi;
        final double sway1 = math.sin(swayAngle * 2) * 0.015;
        final double sway2 = math.cos(swayAngle * 2) * 0.015;

        return Container(
          width: double.infinity,
          height: 220,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [c0, c1, c2, c3],
            ),
            borderRadius: BorderRadius.circular(24),
            // NO BORDER (removed as requested)
            boxShadow: [
              BoxShadow(
                color: c3.withValues(alpha: widget.isDark ? 0.35 : 0.22),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Subtle cosmic dust / star specks
                Positioned.fill(
                  child: CustomPaint(
                    painter: _StarrySpecksPainter(),
                  ),
                ),

                // Main content layout: Left Typography + Right Hanging Tags
                Row(
                  children: [
                    // Left Column: Editorial Headline & Subtitle
                    Expanded(
                      flex: 52,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          top: 22,
                          bottom: 20,
                          right: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AutoSizeText(
                              'Study flow\nevery day',
                              maxLines: 2,
                              minFontSize: 20,
                              style: GoogleFonts.outfit(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFEDE9FE),
                                letterSpacing: -0.6,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 10),
                            AutoSizeText(
                              'Exams arise every year. Revisions are inevitable, but with Class ${widget.selectedClass} & ${widget.totalResources} books, chaos isn\'t.',
                              maxLines: 3,
                              minFontSize: 9,
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF94A3B8),
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Right Column: Two vertical threads with hanging frosted badges
                    Expanded(
                      flex: 48,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Hanging Column 1 (Left of pair)
                          Positioned(
                            left: 10,
                            top: 0,
                            child: _HangingColumn(
                              topWireHeight: 18,
                              midWire1Height: 14,
                              midWire2Height: 16,
                              tag1: _HangingTag(
                                text: 'Today • ${_formatDate()}',
                                angle: -0.05 + sway1,
                              ),
                              tag2: _HangingTag(
                                text: '${widget.totalResources} Textbooks',
                                angle: 0.03 + sway1,
                                isHighlight: true, // Electric blue glowing pill
                              ),
                              tag3: _HangingTag(
                                text: 'Class ${widget.selectedClass} ▾',
                                angle: -0.04 + sway1,
                                onTap: widget.onPillTap,
                              ),
                            ),
                          ),

                          // Hanging Column 2 (Right of pair)
                          Positioned(
                            right: 14,
                            top: 0,
                            child: _HangingColumn(
                              topWireHeight: 38,
                              midWire1Height: 22,
                              tag1: _HangingTag(
                                text: 'NCERT Solutions',
                                angle: 0.06 + sway2,
                              ),
                              tag2: _HangingTag(
                                text: 'Daily focus on',
                                angle: -0.04 + sway2,
                              ),
                            ),
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
      },
    );
  }
}

/// A vertical hanging line with glowing beads and suspended frosted pill badges
class _HangingColumn extends StatelessWidget {
  final double topWireHeight;
  final double midWire1Height;
  final double? midWire2Height;
  final Widget tag1;
  final Widget tag2;
  final Widget? tag3;

  const _HangingColumn({
    required this.topWireHeight,
    required this.midWire1Height,
    this.midWire2Height,
    required this.tag1,
    required this.tag2,
    this.tag3,
  });

  @override
  Widget build(BuildContext context) {
    const wireColor = Color(0xFF818CF8);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Wire from top edge
        Container(
          width: 0.9,
          height: topWireHeight,
          color: wireColor.withValues(alpha: 0.40),
        ),
        // Glowing connector bead
        _buildGlowBead(),
        tag1,
        // Wire between tag 1 and tag 2
        Container(
          width: 0.9,
          height: midWire1Height,
          color: wireColor.withValues(alpha: 0.40),
        ),
        _buildGlowBead(),
        tag2,
        if (tag3 != null && midWire2Height != null) ...[
          Container(
            width: 0.9,
            height: midWire2Height!,
            color: wireColor.withValues(alpha: 0.40),
          ),
          _buildGlowBead(),
          tag3!,
        ],
      ],
    );
  }

  Widget _buildGlowBead() {
    return Container(
      width: 4.5,
      height: 4.5,
      margin: const EdgeInsets.symmetric(vertical: 0.5),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE9FE),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA78BFA).withValues(alpha: 0.85),
            blurRadius: 6,
            spreadRadius: 1.5,
          ),
        ],
      ),
    );
  }
}

/// Individual suspended tag pill (matching the frosted tags from the reference image)
class _HangingTag extends StatelessWidget {
  final String text;
  final double angle;
  final bool isHighlight;
  final VoidCallback? onTap;

  const _HangingTag({
    required this.text,
    this.angle = 0.0,
    this.isHighlight = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget tagContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5.5),
      decoration: BoxDecoration(
        color: isHighlight
            ? const Color(0xFF3B82F6)
            : const Color(0xFF141630).withValues(alpha: 0.88),
        gradient: isHighlight
            ? const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isHighlight
              ? const Color(0xFF93C5FD).withValues(alpha: 0.60)
              : const Color(0xFF6366F1).withValues(alpha: 0.38),
          width: 0.9,
        ),
        boxShadow: [
          BoxShadow(
            color: isHighlight
                ? const Color(0xFF3B82F6).withValues(alpha: 0.50)
                : Colors.black.withValues(alpha: 0.35),
            blurRadius: isHighlight ? 12 : 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: AutoSizeText(
        text,
        maxLines: 1,
        minFontSize: 8,
        style: GoogleFonts.roboto(
          fontSize: 10.5,
          fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.2,
        ),
      ),
    );

    if (onTap != null) {
      tagContent = GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap!();
        },
        behavior: HitTestBehavior.opaque,
        child: tagContent,
      );
    }

    return Transform.rotate(
      angle: angle,
      child: tagContent,
    );
  }
}

/// Subtle faint cosmic specks matching the background of the reference image
class _StarrySpecksPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.28);

    // Subtle star specks
    canvas.drawCircle(Offset(size.width * 0.12, size.height * 0.20), 1.0, paint);
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.65), 1.2, paint);
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.30), 0.8, paint);
    canvas.drawCircle(Offset(size.width * 0.62, size.height * 0.85), 1.0, paint);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.25), 1.2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
