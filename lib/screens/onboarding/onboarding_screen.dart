import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ncert_books_app/services/gamification_service.dart';
import 'package:ncert_books_app/theme/app_theme.dart';
import 'package:ncert_books_app/theme/app_responsive.dart';
import 'package:ncert_books_app/screens/home/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final GamificationService gamification;

  const OnboardingScreen({super.key, required this.gamification});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final TextEditingController _nameController;
  String _selectedAvatar = GamificationService.avatars.first;
  String _selectedClass = '10';

  final List<String> _classes = List.generate(12, (i) => '${i + 1}');

  static const List<Map<String, dynamic>> _companionData = [
    {
      'id': 'Smart Owl',
      'emoji': '🦉',
      'name': 'Smart Owl',
      'role': 'Wisdom & Focus',
      'accent': Color(0xFF3B82F6),
    },
    {
      'id': 'Clever Fox',
      'emoji': '🦊',
      'name': 'Clever Fox',
      'role': 'Quick Problem Solver',
      'accent': Color(0xFFF97316),
    },
    {
      'id': 'Space Cadet',
      'emoji': '🚀',
      'name': 'Space Cadet',
      'role': 'High Achiever',
      'accent': Color(0xFF8B5CF6),
    },
    {
      'id': 'Wise Panda',
      'emoji': '🐼',
      'name': 'Wise Panda',
      'role': 'Calm & Steady',
      'accent': Color(0xFF10B981),
    },
    {
      'id': 'Hero Bunny',
      'emoji': '🐰',
      'name': 'Hero Bunny',
      'role': 'Fast & Agile',
      'accent': Color(0xFFEC4899),
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedClass = widget.gamification.userClass.isNotEmpty
        ? widget.gamification.userClass
        : '10';
    _selectedAvatar = widget.gamification.currentAvatar.isNotEmpty
        ? widget.gamification.currentAvatar
        : GamificationService.avatars.first;
    _nameController = TextEditingController(
      text:
          widget.gamification.userName.isNotEmpty &&
              widget.gamification.userName != 'Student'
          ? widget.gamification.userName
          : 'Student',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _activeCompanion {
    return _companionData.firstWhere(
      (c) => c['id'] == _selectedAvatar,
      orElse: () => _companionData.first,
    );
  }

  void _finishOnboarding() {
    HapticFeedback.mediumImpact();
    final name = _nameController.text.trim().isEmpty
        ? 'Student'
        : _nameController.text.trim();

    widget.gamification.completeOnboarding(
      _selectedAvatar,
      _selectedClass,
      name,
    );

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => HomeScreen(gamification: widget.gamification),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = AppResponsive.isMobile(context);
    final activeCompanion = _activeCompanion;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.darkBackground
          : AppTheme.lightBackground,
      body: SafeArea(
        bottom: false,
        child: MaxContentConstraint(
          maxWidth: 680,
          child: Stack(
            children: [
              // Scrollable onboarding content
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top App Pill Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF181822)
                            : const Color(0xFFF1F1F6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF2C2C38)
                              : const Color(0xFFE5E7EB),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.asset(
                              'assets/logo.png',
                              width: 18,
                              height: 18,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'SWYNX • NCERT Books & News',
                            style: GoogleFonts.roboto(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: isDark
                                  ? const Color(0xFFD1D5DB)
                                  : const Color(0xFF4B5563),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Hero Title
                    Text(
                      'Turn Study Into\nSuperpowers.',
                      style: GoogleFonts.roboto(
                        fontSize: isMobile ? 32 : 38,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                        letterSpacing: -1.2,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      'Official NCERT textbooks, chapter solutions, offline vault, and daily streak rewards configured just for you.',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        height: 1.45,
                        color: isDark
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 1. Student Name Card
                    _buildNameCard(isDark, activeCompanion),
                    const SizedBox(height: 22),

                    // 2. Select Grade / Class
                    _buildClassSelector(isDark),
                    const SizedBox(height: 22),

                    // 3. Choose Study Companion
                    _buildCompanionSelector(isDark),
                    const SizedBox(height: 22),

                    // 4. Feature Value Propositions
                    _buildFeaturesList(isDark),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              // Pinned Bottom Action CTA with subtle gradient blur scrim
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    16,
                    20,
                    MediaQuery.of(context).padding.bottom > 0
                        ? MediaQuery.of(context).padding.bottom + 8
                        : 20,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        (isDark
                                ? const Color(0xFF0C0C0F)
                                : AppTheme.lightBackground)
                            .withValues(alpha: 0.0),
                        (isDark
                                ? const Color(0xFF0C0C0F)
                                : AppTheme.lightBackground)
                            .withValues(alpha: 0.92),
                        (isDark
                            ? const Color(0xFF0C0C0F)
                            : AppTheme.lightBackground),
                      ],
                      stops: const [0.0, 0.35, 1.0],
                    ),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 680),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: _finishOnboarding,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: double.infinity,
                              height: 54,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF18181B),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (isDark ? Colors.white : Colors.black)
                                            .withValues(alpha: 0.16),
                                    blurRadius: 18,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Start Learning Class $_selectedClass',
                                    style: GoogleFonts.roboto(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.2,
                                      color: isDark
                                          ? const Color(0xFF111827)
                                          : Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 19,
                                    color: isDark
                                        ? const Color(0xFF111827)
                                        : Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Free forever • Offline ready • 100% official curriculum',
                            style: GoogleFonts.roboto(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? const Color(0xFF6B7280)
                                  : const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
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

  // --- 1. STUDENT NAME CARD ---
  Widget _buildNameCard(bool isDark, Map<String, dynamic> activeCompanion) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF14141A) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF242430) : const Color(0xFFE5E7EB),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Dynamic Companion Avatar Monogram
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (activeCompanion['accent'] as Color).withValues(
                alpha: 0.16,
              ),
              border: Border.all(
                color: (activeCompanion['accent'] as Color).withValues(
                  alpha: 0.4,
                ),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                activeCompanion['emoji'] as String,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Name Input Field with Clean Label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR NAME / DISPLAY NAME',
                  style: GoogleFonts.roboto(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 3),
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter your name',
                    hintStyle: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFF4B5563)
                          : const Color(0xFF9CA3AF),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),

          // Edit icon
          Icon(
            Icons.edit_outlined,
            size: 18,
            color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
          ),
        ],
      ),
    );
  }

  // --- 2. CLASS SELECTOR GRID ---
  Widget _buildClassSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3B82F6),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Select Grade / Class',
                  style: GoogleFonts.roboto(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E202B)
                    : const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF2E3348)
                      : const Color(0xFFC7D2FE),
                  width: 0.8,
                ),
              ),
              child: Text(
                'Class $_selectedClass Selected',
                style: GoogleFonts.roboto(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6366F1),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Responsive grid of 12 classes (4 columns on mobile, 6 on tablet)
        LayoutBuilder(
          builder: (context, constraints) {
            final colCount = constraints.maxWidth > 500 ? 6 : 4;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _classes.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: colCount,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.55,
              ),
              itemBuilder: (context, index) {
                final cls = _classes[index];
                final isSelected = _selectedClass == cls;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedClass = cls);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? Colors.white : const Color(0xFF18181B))
                          : (isDark ? const Color(0xFF14141A) : Colors.white),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? (isDark ? Colors.white : const Color(0xFF18181B))
                            : (isDark
                                  ? const Color(0xFF22222C)
                                  : const Color(0xFFE5E7EB)),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: (isDark ? Colors.white : Colors.black)
                                    .withValues(alpha: 0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isSelected) ...[
                                Icon(
                                  Icons.check_rounded,
                                  size: 13,
                                  color: isDark
                                      ? const Color(0xFF18181B)
                                      : Colors.white,
                                ),
                                const SizedBox(width: 4),
                              ],
                              Text(
                                'Class $cls',
                                style: GoogleFonts.roboto(
                                  fontSize: 12.5,
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? (isDark
                                            ? const Color(0xFF18181B)
                                            : Colors.white)
                                      : (isDark
                                            ? const Color(0xFFD1D5DB)
                                            : const Color(0xFF374151)),
                                ),
                              ),
                            ],
                          ),
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
    );
  }

  // --- 3. COMPANION SELECTOR CAROUSEL ---
  Widget _buildCompanionSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Choose Study Companion',
              style: GoogleFonts.roboto(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF111827),
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Horizontal list of companions with real emojis, titles and traits
        SizedBox(
          height: 98,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _companionData.length,
            itemBuilder: (context, index) {
              final comp = _companionData[index];
              final isSelected = _selectedAvatar == comp['id'];
              final accentColor = comp['accent'] as Color;

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedAvatar = comp['id'] as String);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    width: 148,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark
                                ? const Color(0xFF1C1C26)
                                : const Color(0xFFF8FAFC))
                          : (isDark ? const Color(0xFF14141A) : Colors.white),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? accentColor
                            : (isDark
                                  ? const Color(0xFF22222C)
                                  : const Color(0xFFE5E7EB)),
                        width: isSelected ? 1.8 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: accentColor.withValues(alpha: 0.22),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: accentColor.withValues(alpha: 0.16),
                              ),
                              child: Center(
                                child: Text(
                                  comp['emoji'] as String,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                            if (isSelected)
                              Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: accentColor,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comp['name'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.roboto(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF111827),
                                letterSpacing: -0.2,
                              ),
                            ),
                            Text(
                              comp['role'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.roboto(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? const Color(0xFF9CA3AF)
                                    : const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- 4. VALUE PROPOSITIONS LIST ---
  Widget _buildFeaturesList(bool isDark) {
    const features = [
      {
        'icon': Icons.offline_bolt_rounded,
        'color': Color(0xFFF59E0B),
        'title': 'Offline Study Vault',
        'desc':
            'Download books once and read anywhere with zero internet usage.',
      },
      {
        'icon': Icons.local_fire_department_rounded,
        'color': Color(0xFFEF4444),
        'title': 'Daily Reading Streaks',
        'desc': 'Build powerful study habits and earn XP levels as you read.',
      },
      {
        'icon': Icons.auto_awesome_rounded,
        'color': Color(0xFF8B5CF6),
        'title': 'Official NCERT Syllabus',
        'desc':
            'Exact textbook chapters, solutions, and diagrams for Classes 1 to 12.',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF14141A) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF242430) : const Color(0xFFE5E7EB),
          width: 1.0,
        ),
      ),
      child: Column(
        children: features.asMap().entries.map((entry) {
          final idx = entry.key;
          final f = entry.value;
          final color = f['color'] as Color;
          final isLast = idx == features.length - 1;

          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.15),
                  ),
                  child: Icon(f['icon'] as IconData, color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        f['title'] as String,
                        style: GoogleFonts.roboto(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF111827),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        f['desc'] as String,
                        style: GoogleFonts.roboto(
                          fontSize: 11.5,
                          height: 1.35,
                          color: isDark
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
