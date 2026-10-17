import 'package:flutter/material.dart';
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
  final TextEditingController _nameController = TextEditingController(text: 'Student');
  String _selectedAvatar = GamificationService.avatars.first;
  String _selectedClass = '10';

  final List<String> _classes = List.generate(12, (i) => '${i + 1}');

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _finishOnboarding() {
    widget.gamification.completeOnboarding(
      _selectedAvatar,
      _selectedClass,
      _nameController.text.trim().isEmpty ? 'Student' : _nameController.text.trim(),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(gamification: widget.gamification),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      body: SafeArea(
        child: MaxContentConstraint(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Large Bold App Title (matching Screen 1 of screenshot)
                Text(
                  'NCERT Books and Solutions',
                  style: GoogleFonts.roboto(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                    letterSpacing: -0.8,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Start turning study into action with a smart, modern NCERT textbook & solution experience.',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    height: 1.45,
                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 20),

                // Black Circular Action Button (directly from Screen 1 in screenshot)
                Row(
                  children: [
                    GestureDetector(
                      onTap: _finishOnboarding,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white : const Color(0xFF18181B),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.18),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: isDark ? const Color(0xFF18181B) : Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'Tap to start reading',
                      style: GoogleFonts.roboto(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Stacked Pastel Cards (recreating the iconic cards from Screen 1 of screenshot!)

                // 1. Warm Butter Yellow Card: Student Name
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.pastelYellowDark : AppTheme.pastelYellowLight,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF59E0B),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Student Profile',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF111827),
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1F1B14) : Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            hintText: 'Enter your name',
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          style: GoogleFonts.roboto(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF111827),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 2. Soft Rose Pink Card: Class Picker
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.pastelPinkDark : AppTheme.pastelPinkLight,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEC4899),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Select Grade / Class',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF111827),
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 38,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _classes.length,
                          itemBuilder: (ctx, idx) {
                            final cls = _classes[idx];
                            final isSel = _selectedClass == cls;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedClass = cls),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSel
                                        ? (isDark ? Colors.white : const Color(0xFF18181B))
                                        : (isDark ? const Color(0xFF22161C) : Colors.white.withValues(alpha: 0.8)),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    'Class $cls',
                                    style: GoogleFonts.roboto(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color: isSel
                                          ? (isDark ? const Color(0xFF18181B) : Colors.white)
                                          : (isDark ? Colors.white : const Color(0xFF111827)),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 3. Soft Sky Cyan Card: Study Avatar
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.pastelCyanDark : AppTheme.pastelCyanLight,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFF0284C7),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Choose Study Companion',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF111827),
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 52,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: GamificationService.avatars.length,
                          itemBuilder: (ctx, idx) {
                            final av = GamificationService.avatars[idx];
                            final isSel = _selectedAvatar == av;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedAvatar = av),
                              child: Container(
                                width: 50,
                                height: 50,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? (isDark ? Colors.white : const Color(0xFF18181B))
                                      : (isDark ? const Color(0xFF14202B) : Colors.white.withValues(alpha: 0.8)),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    av.split(' ').first,
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 4. Soft Fresh Mint Card: Offline Books
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.pastelMintDark : AppTheme.pastelMintLight,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Offline Vault Ready',
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : const Color(0xFF111827),
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Download books once and read anytime with zero data usage.',
                              style: GoogleFonts.roboto(
                                fontSize: 11.5,
                                color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Bottom Primary Action Button
                GestureDetector(
                  onTap: _finishOnboarding,
                  child: Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white : const Color(0xFF18181B),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Start Reading Now',
                        style: GoogleFonts.roboto(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFF18181B) : Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
