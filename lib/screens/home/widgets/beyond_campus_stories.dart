import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class BeyondCampusStories extends StatelessWidget {
  final bool isDark;

  const BeyondCampusStories({super.key, required this.isDark});

  void _showStoryModal(BuildContext context, String title, String body) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF16161A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                body,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  height: 1.5,
                  color: isDark ? const Color(0xFFA1A1AA) : const Color(0xFF4B5563),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'STORIES & UPDATES',
                style: GoogleFonts.roboto(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8,
                  color: isDark ? const Color(0xFFA1A1AA) : const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Beyond textbook',
                style: GoogleFonts.outfit(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Horizontal Story Cards
        SizedBox(
          height: 146,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              // Card 1: 'Visual mind maps & diagrams'
              _buildStoryCard(
                context,
                title: 'Visual mind maps\n& concept flows',
                pillLabel: 'In pictures',
                pillIcon: Icons.photo_camera_outlined,
                gradient: const [Color(0xFF0F172A), Color(0xFF1E1B4B)],
                borderColor: const Color(0xFF38BDF8).withValues(alpha: 0.3),
                hasElectricWaves: true,
                onTap: () => _showStoryModal(
                  context,
                  'Visual Mind Maps',
                  'Discover daily visual summaries, mind maps, and chapter concept flows carefully handcrafted to make your NCERT learning journey exciting and stress-free.',
                ),
              ),

              const SizedBox(width: 12),

              // Card 2: 'A note from the developer'
              _buildStoryCard(
                context,
                title: 'A note from\nthe developer',
                pillLabel: 'A quick read',
                gradient: const [Color(0xFF2C1E14), Color(0xFF1A120B)],
                borderColor: const Color(0xFFF97316).withValues(alpha: 0.3),
                isQuoteCard: true,
                onTap: () => _showStoryModal(
                  context,
                  'A Note from Swayanshu',
                  'Hey there! I built this app to give NCERT students the cleanest, fastest, and most aesthetic study companion. All books are verified and available offline. Keep reaching higher!',
                ),
              ),

              const SizedBox(width: 12),

              // Card 3: 'CBSE & NCERT Official Alerts'
              _buildStoryCard(
                context,
                title: 'CBSE & NCERT\nOfficial Alerts',
                pillLabel: 'News',
                pillIcon: Icons.newspaper_outlined,
                gradient: const [Color(0xFF1E293B), Color(0xFF0F172A)],
                borderColor: Colors.white.withValues(alpha: 0.12),
                hasPhotoPlaceholder: true,
                onTap: () => _showStoryModal(
                  context,
                  'NCERT Rationalized Curriculum',
                  'All textbooks in this app follow the latest rationalized syllabus. Chapter exercises and solutions are fully aligned with current CBSE standards.',
                ),
              ),

              const SizedBox(width: 12),

              // Card 4: 'High-yield formula & theorem sheets'
              _buildStoryCard(
                context,
                title: 'Formula sheets\n& exam hacks',
                pillLabel: 'Revision',
                pillIcon: Icons.auto_awesome,
                gradient: const [Color(0xFF064E3B), Color(0xFF022C22)],
                borderColor: const Color(0xFF34D399).withValues(alpha: 0.3),
                onTap: () => _showStoryModal(
                  context,
                  'Fast Revision Formula Sheets',
                  'Access high-yield formula sheets for Physics, Chemistry, and Mathematics before your exams.',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStoryCard(
    BuildContext context, {
    required String title,
    required String pillLabel,
    IconData? pillIcon,
    required List<Color> gradient,
    required Color borderColor,
    bool isQuoteCard = false,
    bool hasElectricWaves = false,
    bool hasPhotoPlaceholder = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        height: 146,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top: Quote icon or pill icon
            if (isQuoteCard)
              Text(
                '“',
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFFB923C),
                  height: 0.8,
                ),
              )
            else if (pillIcon != null)
              Icon(
                pillIcon,
                size: 16,
                color: Colors.white70,
              )
            else
              const SizedBox(height: 16),

            // Middle: Title
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.25,
                letterSpacing: -0.2,
              ),
            ),

            // Bottom: Subtitle pill
            Text(
              pillLabel,
              style: GoogleFonts.roboto(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: Colors.white60,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
