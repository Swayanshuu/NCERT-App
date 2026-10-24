import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ncert_books_app/services/gamification_service.dart';
import 'package:ncert_books_app/theme/app_theme.dart';
import 'package:ncert_books_app/widgets/painters/bento_watermark_painter.dart';

/// Bento Grid for NCERT subjects designed in the exact style of the reference image:
/// - Section header: `01 / STUDY ────────────────────────────────`
/// - Asymmetrical Bento Grid with high-contrast tall Hero card (light off-white background in dark mode)
/// - Stacked companion cards in matte dark finish with minimal outlined colored icon badges
/// - Wide panoramic card with watermark columns
/// - Bottom 50/50 cards with checklist & diploma/calendar watermarks
/// - Diagonal top-right arrow (↗) on every card
/// - Interactive filtering + haptic feedback + gamification tracking
class SubjectBentoGrid extends StatelessWidget {
  final String selectedClass;
  final String selectedSubject;
  final List<String> subjects;
  final bool isDark;
  final ValueChanged<String> onSubjectSelected;
  final GamificationService? gamification;
  final int Function(String subject)? getBookCount;

  final VoidCallback? onChangeClassTap;

  const SubjectBentoGrid({
    super.key,
    required this.selectedClass,
    required this.selectedSubject,
    required this.subjects,
    required this.isDark,
    required this.onSubjectSelected,
    this.gamification,
    this.getBookCount,
    this.onChangeClassTap,
  });

  @override
  Widget build(BuildContext context) {
    if (subjects.isEmpty) {
      return const SizedBox.shrink();
    }

    final realSubjects = subjects.where((s) => s != 'All').toList();
    if (realSubjects.isEmpty) return const SizedBox.shrink();

    // Subject assignments matching thematic roles
    final heroSubject = _findSubject(
      realSubjects,
      ['math', 'sci'],
      fallbackIndex: 0,
    );
    final remaining1 = realSubjects.where((s) => s != heroSubject).toList();

    final card2Subject = _findSubject(
      remaining1,
      ['sci', 'math', 'phys'],
      fallbackIndex: 0,
    );
    final remaining2 = remaining1.where((s) => s != card2Subject).toList();

    final card3Subject = _findSubject(
      remaining2,
      ['soc', 'his', 'geo', 'chem'],
      fallbackIndex: 0,
    );
    final remaining3 = remaining2.where((s) => s != card3Subject).toList();

    final card4Subject = _findSubject(
      remaining3,
      ['eng', 'hin', 'lang'],
      fallbackIndex: 0,
    );
    final remaining4 = remaining3.where((s) => s != card4Subject).toList();

    final card5Subject = _findSubject(
      remaining4,
      ['hin', 'evs', 'bio'],
      fallbackIndex: 0,
    );
    final remaining5 = remaining4.where((s) => s != card5Subject).toList();

    final card6Subject = _findSubject(
      remaining5,
      ['sansk', 'urdu', 'art', 'comp'],
      fallbackIndex: 0,
    );
    final extraSubjects = remaining5.where((s) => s != card6Subject).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Editorial Section Header matching 'THE STUDY SHELF: Your subjects'
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'THE STUDY SHELF',
                style: GoogleFonts.roboto(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8,
                  color: isDark ? const Color(0xFFA1A1AA) : const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your subjects',
                    style: GoogleFonts.outfit(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: isDark ? Colors.white : const Color(0xFF111827),
                    ),
                  ),
                  if (onChangeClassTap != null)
                    GestureDetector(
                      onTap: onChangeClassTap,
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.tune_rounded,
                            size: 15,
                            color: Color(0xFFFB923C),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Change class',
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFFB923C),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2. Bento Grid Layout
          LayoutBuilder(
            builder: (context, constraints) {
              final double totalWidth = constraints.maxWidth;
              const double gap = 12.0;

              // Top Section: Tall Left Hero + Two Stacked Right Cards
              final double leftColWidth = (totalWidth - gap) * 0.53;
              final double rightColWidth = totalWidth - gap - leftColWidth;
              const double topSectionHeight = 236.0;

              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tall Left Hero Card (Off-white contrast in dark mode)
                      SizedBox(
                        width: leftColWidth,
                        height: topSectionHeight,
                        child: _BentoHeroCard(
                          subject: heroSubject,
                          kicker: 'THE STUDY SHELF',
                          isSelected: selectedSubject == heroSubject,
                          isDark: isDark,
                          bookCount: getBookCount?.call(heroSubject),
                          onTap: () => _handleSelect(heroSubject),
                        ),
                      ),
                      const SizedBox(width: gap),

                      // Two Stacked Right Cards
                      SizedBox(
                        width: rightColWidth,
                        height: topSectionHeight,
                        child: Column(
                          children: [
                            // Card 2: Top-right (Coral/Orange Accent)
                            Expanded(
                              child: _BentoMiniCard(
                                subject: card2Subject,
                                isSelected: selectedSubject == card2Subject,
                                isDark: isDark,
                                accentColor: const Color(0xFFFB923C), // Coral
                                icon: Icons.calculate_outlined,
                                watermarkType: BentoWatermarkType.mathSymbols,
                                bookCount: getBookCount?.call(card2Subject),
                                onTap: () => _handleSelect(card2Subject),
                              ),
                            ),
                            const SizedBox(height: gap),

                            // Card 3: Bottom-right (Sky Blue Accent)
                            Expanded(
                              child: _BentoMiniCard(
                                subject: card3Subject,
                                isSelected: selectedSubject == card3Subject,
                                isDark: isDark,
                                accentColor: const Color(0xFF38BDF8), // Sky Blue
                                icon: Icons.poll_outlined,
                                watermarkType: BentoWatermarkType.globe,
                                bookCount: getBookCount?.call(card3Subject),
                                onTap: () => _handleSelect(card3Subject),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Middle Section: Wide Panoramic Card (Languages / Timetable style)
                  if (card4Subject.isNotEmpty) ...[
                    const SizedBox(height: gap),
                    SizedBox(
                      width: totalWidth,
                      height: 118,
                      child: _BentoWideCard(
                        subject: card4Subject,
                        kicker: 'YOUR WEEK, IN ONE PLACE',
                        subkicker: 'Literature & Language Foundations',
                        isSelected: selectedSubject == card4Subject,
                        isDark: isDark,
                        accentColor: const Color(0xFFC084FC), // Lavender / Purple
                        icon: Icons.view_column_outlined,
                        watermarkType: BentoWatermarkType.columns,
                        bookCount: getBookCount?.call(card4Subject),
                        onTap: () => _handleSelect(card4Subject),
                      ),
                    ),
                  ],

                  // Bottom Section: Two 50/50 Cards (Attendance & Fees style)
                  if (card5Subject.isNotEmpty) ...[
                    const SizedBox(height: gap),
                    Row(
                      children: [
                        // Card 5: Emerald / Cyan
                        Expanded(
                          child: SizedBox(
                            height: 122,
                            child: _BentoSplitCard(
                              subject: card5Subject,
                              isSelected: selectedSubject == card5Subject,
                              isDark: isDark,
                              accentColor: const Color(0xFF2DD4BF), // Teal
                              icon: Icons.fact_check_outlined,
                              watermarkType: BentoWatermarkType.checklist,
                              bookCount: getBookCount?.call(card5Subject),
                              onTap: () => _handleSelect(card5Subject),
                            ),
                          ),
                        ),

                        // Card 6: Warm Amber (if available)
                        if (card6Subject.isNotEmpty) ...[
                          const SizedBox(width: gap),
                          Expanded(
                            child: SizedBox(
                              height: 122,
                              child: _BentoSplitCard(
                                subject: card6Subject,
                                isSelected: selectedSubject == card6Subject,
                                isDark: isDark,
                                accentColor: const Color(0xFFFBBF24), // Amber
                                icon: Icons.receipt_long_outlined,
                                watermarkType: BentoWatermarkType.diploma,
                                bookCount: getBookCount?.call(card6Subject),
                                onTap: () => _handleSelect(card6Subject),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],

                  // Extra subjects cards (if class has 7+ subjects, showing all subjects)
                  if (extraSubjects.isNotEmpty)
                    _buildExtraSubjectsGrid(extraSubjects),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExtraSubjectsGrid(List<String> extras) {
    const double gap = 12.0;
    final List<Widget> items = [];
    final accentColors = [
      const Color(0xFFEC4899), // Pink
      const Color(0xFF8B5CF6), // Violet
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFF10B981), // Emerald
      const Color(0xFFF59E0B), // Amber
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF14B8A6), // Teal
      const Color(0xFFF97316), // Orange
    ];
    final watermarkTypes = [
      BentoWatermarkType.checklist,
      BentoWatermarkType.diploma,
      BentoWatermarkType.globe,
      BentoWatermarkType.mathSymbols,
      BentoWatermarkType.columns,
    ];

    for (int i = 0; i < extras.length; i += 2) {
      final subject1 = extras[i];
      final subject2 = (i + 1 < extras.length) ? extras[i + 1] : null;

      final color1 = accentColors[i % accentColors.length];
      final wm1 = watermarkTypes[i % watermarkTypes.length];

      if (subject2 != null) {
        final color2 = accentColors[(i + 1) % accentColors.length];
        final wm2 = watermarkTypes[(i + 1) % watermarkTypes.length];
        items.add(
          Padding(
            padding: const EdgeInsets.only(top: gap),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 122,
                    child: _BentoSplitCard(
                      subject: subject1,
                      isSelected: selectedSubject == subject1,
                      isDark: isDark,
                      accentColor: color1,
                      icon: AppTheme.getSubjectIcon(subject1),
                      watermarkType: wm1,
                      bookCount: getBookCount?.call(subject1),
                      onTap: () => _handleSelect(subject1),
                    ),
                  ),
                ),
                const SizedBox(width: gap),
                Expanded(
                  child: SizedBox(
                    height: 122,
                    child: _BentoSplitCard(
                      subject: subject2,
                      isSelected: selectedSubject == subject2,
                      isDark: isDark,
                      accentColor: color2,
                      icon: AppTheme.getSubjectIcon(subject2),
                      watermarkType: wm2,
                      bookCount: getBookCount?.call(subject2),
                      onTap: () => _handleSelect(subject2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        // Single remaining subject - render wide card
        items.add(
          Padding(
            padding: const EdgeInsets.only(top: gap),
            child: SizedBox(
              height: 118,
              child: _BentoWideCard(
                subject: subject1,
                kicker: 'ELECTIVE / LANGUAGE',
                subkicker: 'Curated curriculum & guides',
                isSelected: selectedSubject == subject1,
                isDark: isDark,
                accentColor: color1,
                icon: AppTheme.getSubjectIcon(subject1),
                watermarkType: wm1,
                bookCount: getBookCount?.call(subject1),
                onTap: () => _handleSelect(subject1),
              ),
            ),
          ),
        );
      }
    }

    return Column(children: items);
  }

  void _handleSelect(String subject) {
    HapticFeedback.lightImpact();
    gamification?.recordSubjectExplored(subject);
    onSubjectSelected(subject);
  }

  String _findSubject(
    List<String> pool,
    List<String> keywords, {
    required int fallbackIndex,
  }) {
    for (final kw in keywords) {
      for (final s in pool) {
        if (s.toLowerCase().contains(kw)) {
          return s;
        }
      }
    }
    if (pool.isNotEmpty && fallbackIndex < pool.length) {
      return pool[fallbackIndex];
    }
    return '';
  }
}

/// 1. TALL HERO CARD (Left)
/// Matches the high-contrast light/bone card in dark mode with open book watermark & dark type
class _BentoHeroCard extends StatefulWidget {
  final String subject;
  final String kicker;
  final bool isSelected;
  final bool isDark;
  final int? bookCount;
  final VoidCallback onTap;

  const _BentoHeroCard({
    required this.subject,
    required this.kicker,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
    this.bookCount,
  });

  @override
  State<_BentoHeroCard> createState() => _BentoHeroCardState();
}

class _BentoHeroCardState extends State<_BentoHeroCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // In dark mode: Light grey / bone off-white (`#E2E2E6`) creates the signature editorial punch
    // In light mode: Crisp off-white `#F5F5F7` or dark charcoal `#18181B`
    final Color bgColor = widget.isDark
        ? const Color(0xFFE2E2E6)
        : const Color(0xFF18181B);
    final Color primaryTextColor = widget.isDark
        ? const Color(0xFF111114)
        : Colors.white;
    final Color kickerColor = widget.isDark
        ? const Color(0xFF6B7280)
        : const Color(0xFFA1A1AA);
    final Color iconColor = widget.isDark
        ? const Color(0xFF1A1A1E)
        : Colors.white;
    final Color arrowColor = widget.isDark
        ? const Color(0xFF4B4B52)
        : Colors.white70;

    return AnimatedScale(
      scale: _isPressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (val) => setState(() => _isPressed = val),
          borderRadius: BorderRadius.circular(24),
          splashColor: Colors.black.withValues(alpha: 0.08),
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: widget.isSelected
                    ? (widget.isDark
                        ? const Color(0xFF000000)
                        : const Color(0xFF38BDF8))
                    : (widget.isDark
                        ? Colors.black.withValues(alpha: 0.06)
                        : Colors.white.withValues(alpha: 0.12)),
                width: widget.isSelected ? 2.4 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: widget.isDark ? 0.25 : 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
                if (widget.isSelected)
                  BoxShadow(
                    color: (widget.isDark ? Colors.black : Colors.white)
                        .withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Painted tilted open book watermark
                  CustomPaint(
                    painter: BentoWatermarkPainter(
                      type: BentoWatermarkType.book,
                      tintColor: widget.isDark
                          ? const Color(0xFF000000)
                          : const Color(0xFFFFFFFF),
                      opacity: widget.isDark ? 0.09 : 0.08,
                    ),
                  ),

                  // Card Content
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row: Minimal open book icon + Diagonal arrow ↗
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              Icons.auto_stories_outlined,
                              size: 26,
                              color: iconColor,
                            ),
                            Icon(
                              Icons.north_east_rounded,
                              size: 20,
                              color: arrowColor,
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Bottom typography
                        Text(
                          widget.kicker,
                          style: GoogleFonts.roboto(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: kickerColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subject,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.roboto(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            height: 1.15,
                            color: primaryTextColor,
                          ),
                        ),
                        if (widget.bookCount != null) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: widget.isDark
                                  ? Colors.black.withValues(alpha: 0.08)
                                  : Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${widget.bookCount} Books • NCERT',
                              style: GoogleFonts.roboto(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: widget.isDark
                                    ? const Color(0xFF4B4B52)
                                    : Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 2. STACKED MINI CARD (Top-Right & Middle-Right)
/// Matte dark finish, outlined colored squircle icon badge, diagonal arrow ↗, bold title
class _BentoMiniCard extends StatefulWidget {
  final String subject;
  final bool isSelected;
  final bool isDark;
  final Color accentColor;
  final IconData icon;
  final BentoWatermarkType watermarkType;
  final int? bookCount;
  final VoidCallback onTap;

  const _BentoMiniCard({
    required this.subject,
    required this.isSelected,
    required this.isDark,
    required this.accentColor,
    required this.icon,
    required this.watermarkType,
    required this.onTap,
    this.bookCount,
  });

  @override
  State<_BentoMiniCard> createState() => _BentoMiniCardState();
}

class _BentoMiniCardState extends State<_BentoMiniCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const Color cardBg = Color(0xFF16161A);

    return AnimatedScale(
      scale: _isPressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (val) => setState(() => _isPressed = val),
          borderRadius: BorderRadius.circular(22),
          child: Container(
            decoration: BoxDecoration(
              color: widget.isDark ? cardBg : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: widget.isSelected
                    ? widget.accentColor
                    : (widget.isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFFE5E7EB)),
                width: widget.isSelected ? 2.0 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
                if (widget.isSelected)
                  BoxShadow(
                    color: widget.accentColor.withValues(alpha: 0.25),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Subtle vector watermark
                  CustomPaint(
                    painter: BentoWatermarkPainter(
                      type: widget.watermarkType,
                      tintColor: widget.accentColor,
                      opacity: 0.07,
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Top row: Outlined Icon Badge + Diagonal arrow ↗
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _BentoIconBadge(
                              icon: widget.icon,
                              color: widget.accentColor,
                            ),
                            Icon(
                              Icons.north_east_rounded,
                              size: 16,
                              color: widget.isDark
                                  ? const Color(0xFF71717A)
                                  : const Color(0xFF9CA3AF),
                            ),
                          ],
                        ),

                        // Bottom Title
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.subject,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                                color: widget.isDark
                                    ? Colors.white
                                    : const Color(0xFF111827),
                              ),
                            ),
                            if (widget.bookCount != null)
                              Text(
                                '${widget.bookCount} Books',
                                style: GoogleFonts.roboto(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: widget.isDark
                                      ? const Color(0xFF71717A)
                                      : const Color(0xFF6B7280),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 3. PANORAMIC WIDE CARD (Languages / Timetable style)
/// Full-width card with purple squircle icon badge, columns watermark on right, kicker & bold title
class _BentoWideCard extends StatefulWidget {
  final String subject;
  final String kicker;
  final String subkicker;
  final bool isSelected;
  final bool isDark;
  final Color accentColor;
  final IconData icon;
  final BentoWatermarkType watermarkType;
  final int? bookCount;
  final VoidCallback onTap;

  const _BentoWideCard({
    required this.subject,
    required this.kicker,
    required this.subkicker,
    required this.isSelected,
    required this.isDark,
    required this.accentColor,
    required this.icon,
    required this.watermarkType,
    required this.onTap,
    this.bookCount,
  });

  @override
  State<_BentoWideCard> createState() => _BentoWideCardState();
}

class _BentoWideCardState extends State<_BentoWideCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const Color cardBg = Color(0xFF16161A);

    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (val) => setState(() => _isPressed = val),
          borderRadius: BorderRadius.circular(22),
          child: Container(
            decoration: BoxDecoration(
              color: widget.isDark ? cardBg : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: widget.isSelected
                    ? widget.accentColor
                    : (widget.isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFFE5E7EB)),
                width: widget.isSelected ? 2.0 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
                if (widget.isSelected)
                  BoxShadow(
                    color: widget.accentColor.withValues(alpha: 0.25),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Three vertical columns watermark painted on right
                  CustomPaint(
                    painter: BentoWatermarkPainter(
                      type: widget.watermarkType,
                      tintColor: widget.accentColor,
                      opacity: 0.10,
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row: Outlined Icon Badge + Diagonal arrow ↗
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _BentoIconBadge(
                              icon: widget.icon,
                              color: widget.accentColor,
                              size: 32,
                              iconSize: 18,
                            ),
                            Icon(
                              Icons.north_east_rounded,
                              size: 18,
                              color: widget.isDark
                                  ? const Color(0xFF71717A)
                                  : const Color(0xFF9CA3AF),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Kicker
                        Text(
                          widget.kicker,
                          style: GoogleFonts.roboto(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: widget.isDark
                                ? const Color(0xFFA1A1AA)
                                : const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 2),

                        // Title
                        Row(
                          children: [
                            Text(
                              widget.subject,
                              style: GoogleFonts.roboto(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.4,
                                color: widget.isDark
                                    ? Colors.white
                                    : const Color(0xFF111827),
                              ),
                            ),
                            if (widget.bookCount != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                '•  ${widget.bookCount} Books',
                                style: GoogleFonts.roboto(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: widget.isDark
                                      ? const Color(0xFF71717A)
                                      : const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 4. SPLIT 50/50 CARDS (Attendance & Fees style)
/// Side-by-side cards with colored squircle badges, watermarks, diagonal arrow ↗
class _BentoSplitCard extends StatefulWidget {
  final String subject;
  final bool isSelected;
  final bool isDark;
  final Color accentColor;
  final IconData icon;
  final BentoWatermarkType watermarkType;
  final int? bookCount;
  final VoidCallback onTap;

  const _BentoSplitCard({
    required this.subject,
    required this.isSelected,
    required this.isDark,
    required this.accentColor,
    required this.icon,
    required this.watermarkType,
    required this.onTap,
    this.bookCount,
  });

  @override
  State<_BentoSplitCard> createState() => _BentoSplitCardState();
}

class _BentoSplitCardState extends State<_BentoSplitCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const Color cardBg = Color(0xFF16161A);

    return AnimatedScale(
      scale: _isPressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (val) => setState(() => _isPressed = val),
          borderRadius: BorderRadius.circular(22),
          child: Container(
            decoration: BoxDecoration(
              color: widget.isDark ? cardBg : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: widget.isSelected
                    ? widget.accentColor
                    : (widget.isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFFE5E7EB)),
                width: widget.isSelected ? 2.0 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
                if (widget.isSelected)
                  BoxShadow(
                    color: widget.accentColor.withValues(alpha: 0.25),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Painted watermark
                  CustomPaint(
                    painter: BentoWatermarkPainter(
                      type: widget.watermarkType,
                      tintColor: widget.accentColor,
                      opacity: 0.07,
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Top row: Outlined Icon Badge + Diagonal arrow ↗
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _BentoIconBadge(
                              icon: widget.icon,
                              color: widget.accentColor,
                            ),
                            Icon(
                              Icons.north_east_rounded,
                              size: 16,
                              color: widget.isDark
                                  ? const Color(0xFF71717A)
                                  : const Color(0xFF9CA3AF),
                            ),
                          ],
                        ),

                        // Bottom Title
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.subject,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                                color: widget.isDark
                                    ? Colors.white
                                    : const Color(0xFF111827),
                              ),
                            ),
                            if (widget.bookCount != null)
                              Text(
                                '${widget.bookCount} Books',
                                style: GoogleFonts.roboto(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: widget.isDark
                                      ? const Color(0xFF71717A)
                                      : const Color(0xFF6B7280),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Minimal Outlined Icon Badge
/// Matches the outlined squircle icon containers from the reference screenshot
class _BentoIconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;

  const _BentoIconBadge({
    required this.icon,
    required this.color,
    this.size = 30,
    this.iconSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.40),
          width: 1.2,
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          size: iconSize,
          color: color,
        ),
      ),
    );
  }
}
