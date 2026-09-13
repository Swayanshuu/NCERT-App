import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ncert_books_app/services/gamification_service.dart';
import 'package:ncert_books_app/theme/app_theme.dart';
import 'package:ncert_books_app/theme/app_responsive.dart';
import 'package:ncert_books_app/widgets/glass/glass_card.dart';
import 'package:ncert_books_app/widgets/glass/glass_button.dart';
import 'package:ncert_books_app/widgets/hover_builder.dart';
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
      _nameController.text,
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
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Welcome to NCERT Reader 📚',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Setup your profile to personalize your learning journey',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                  ),
                ),
                const SizedBox(height: 32),

                // 1. Name Input
                Text('Your Name', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                GlassCard(
                  borderRadius: 18,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter student name',
                      border: InputBorder.none,
                    ),
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Class Picker Chips
                Text('Select Class', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 2.2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _classes.length,
                  itemBuilder: (ctx, idx) {
                    final cls = _classes[idx];
                    final isSel = _selectedClass == cls;
                    return HoverBuilder(
                      onTap: () => setState(() => _selectedClass = cls),
                      builder: (context, isHovered) => Container(
                        decoration: BoxDecoration(
                          color: isSel ? AppTheme.primaryTeal : (isDark ? AppTheme.darkSurface : Colors.white),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSel ? AppTheme.primaryTeal : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Class $cls',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: isSel ? Colors.white : (isDark ? Colors.white : AppTheme.lightTextPrimary),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // 3. Avatar Picker
                Text('Choose Avatar', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: GamificationService.avatars.length,
                    itemBuilder: (ctx, idx) {
                      final av = GamificationService.avatars[idx];
                      final isSel = _selectedAvatar == av;
                      return HoverBuilder(
                        onTap: () => setState(() => _selectedAvatar = av),
                        builder: (context, isHovered) => Container(
                          width: 64,
                          height: 64,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: isSel ? AppTheme.primaryTeal.withValues(alpha: 0.2) : (isDark ? AppTheme.darkSurface : Colors.white),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSel ? AppTheme.primaryTeal : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                              width: isSel ? 2.5 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(av.split(' ').first, style: const TextStyle(fontSize: 28)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 40),

                // 4. Start Button
                GlassButton(
                  label: 'Start Learning 🚀',
                  height: 54,
                  borderRadius: 20,
                  onPressed: _finishOnboarding,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
