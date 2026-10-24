import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ncert_books_app/services/gamification_service.dart';
import 'package:ncert_books_app/services/ncert_repository.dart';
import 'package:ncert_books_app/services/pdf_cache_service.dart';
import 'package:ncert_books_app/theme/app_theme.dart';
import 'package:ncert_books_app/theme/app_responsive.dart';
import 'package:ncert_books_app/widgets/ad_banner_widget.dart';
import 'package:ncert_books_app/widgets/custom_snack_bar.dart';
import 'package:ncert_books_app/screens/profile/widgets/avatar_selector_modal.dart';

class SettingsScreen extends StatefulWidget {
  final GamificationService gamification;

  const SettingsScreen({super.key, required this.gamification});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameController;
  List<String> _availableClasses = List.generate(12, (i) => '${i + 1}');
  String _totalStorageSize = '0 MB';
  bool _isSavingName = false;

  @override
  void initState() {
    super.initState();
    final name = widget.gamification.userName;
    _nameController = TextEditingController(text: name.isEmpty ? 'Student' : name);
    widget.gamification.addListener(_onGamificationChanged);
    _loadData();
  }

  @override
  void dispose() {
    widget.gamification.removeListener(_onGamificationChanged);
    _nameController.dispose();
    super.dispose();
  }

  void _onGamificationChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadData() async {
    try {
      await NcertRepository().loadCatalog();
      final classes = NcertRepository().getAvailableClasses();
      final sizeStr = await PdfCacheService().getTotalStorageSizeString();
      if (mounted) {
        setState(() {
          if (classes.isNotEmpty) {
            _availableClasses = classes;
          }
          _totalStorageSize = sizeStr;
        });
      }
    } catch (_) {}
  }

  void _saveName() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    widget.gamification.setUserName(name);
    setState(() => _isSavingName = true);
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        setState(() => _isSavingName = false);
        CustomSnackBar.showSuccess(context, 'Name updated to "$name"');
      }
    });
  }

  Future<void> _clearCache() async {
    final isDark = widget.gamification.isDarkMode;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF181818) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isDark ? const Color(0xFF282828) : const Color(0xFFE5E7EB),
          ),
        ),
        title: Row(
          children: [
            const Icon(Icons.delete_outline_rounded, color: AppTheme.accentRose, size: 24),
            const SizedBox(width: 8),
            Text(
              'Clear Offline Storage?',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: isDark ? Colors.white : const Color(0xFF111827),
              ),
            ),
          ],
        ),
        content: Text(
          'This will delete all offline downloaded books ($_totalStorageSize). You can re-download them anytime.',
          style: GoogleFonts.roboto(
            fontSize: 13.5,
            height: 1.4,
            color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF4B5563),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.roboto(
                color: isDark ? const Color(0xFF777777) : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentRose,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Clear All',
              style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final books = await PdfCacheService().getDownloadedBooksList();
      for (final b in books) {
        await PdfCacheService().deleteCachedBook(b.code);
      }
      await _loadData();
      if (mounted) {
        CustomSnackBar.showSuccess(context, 'Offline storage cleared successfully');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.gamification.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings & Profile',
          style: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: MaxContentConstraint(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // 1. Edit Name Section
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF181818) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF282828) : const Color(0xFFE5E7EB),
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF38BDF8),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Student Name',
                        style: GoogleFonts.roboto(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF222222) : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB),
                              width: 1.0,
                            ),
                          ),
                          child: TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter student name...',
                              hintStyle: GoogleFonts.roboto(
                                color: isDark ? const Color(0xFF777777) : const Color(0xFF9CA3AF),
                                fontSize: 14,
                              ),
                            ),
                            style: GoogleFonts.roboto(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : const Color(0xFF111827),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _saveName,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white : const Color(0xFF18181B),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            _isSavingName ? '...' : 'Save',
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                              color: isDark ? const Color(0xFF181818) : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 2. Change Class Section
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF181818) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF282828) : const Color(0xFFE5E7EB),
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF59E0B),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Selected Class',
                        style: GoogleFonts.roboto(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Current: Class ${widget.gamification.userClass}',
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF777777) : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableClasses.map((cls) {
                      final isSel = widget.gamification.userClass == cls;
                      return GestureDetector(
                        onTap: () {
                          widget.gamification.setUserClass(cls);
                          setState(() {});
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel
                                ? (isDark ? Colors.white : const Color(0xFF18181B))
                                : (isDark ? const Color(0xFF222222) : const Color(0xFFF3F4F6)),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSel
                                  ? (isDark ? Colors.white : const Color(0xFF18181B))
                                  : (isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB)),
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            'Class $cls',
                            style: GoogleFonts.roboto(
                              fontSize: 12.5,
                              fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                              color: isSel
                                  ? (isDark ? const Color(0xFF181818) : Colors.white)
                                  : (isDark ? Colors.white : const Color(0xFF111827)),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 3. Companion Avatar Section
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF181818) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF282828) : const Color(0xFFE5E7EB),
                  width: 1.0,
                ),
              ),
              child: Column(
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
                        'Study Companion Avatar',
                        style: GoogleFonts.roboto(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: GamificationService.avatars.map((avatar) {
                      final isSel = widget.gamification.currentAvatar == avatar;
                      final icon = AvatarHelper.getIcon(avatar);
                      final iconColor = AvatarHelper.getColor(avatar);

                      return GestureDetector(
                        onTap: () => widget.gamification.setAvatar(avatar),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel
                                ? (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE5E7EB))
                                : (isDark ? const Color(0xFF222222) : const Color(0xFFF3F4F6)),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSel
                                  ? iconColor
                                  : (isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB)),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(icon, size: 16, color: iconColor),
                              const SizedBox(width: 6),
                              Text(
                                avatar,
                                style: GoogleFonts.roboto(
                                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                  fontSize: 12.5,
                                  color: isDark ? Colors.white : const Color(0xFF111827),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 4. Offline Storage Section
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF181818) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF282828) : const Color(0xFFE5E7EB),
                  width: 1.0,
                ),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF222222) : const Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.storage_rounded, color: AppTheme.accentRose, size: 20),
                ),
                title: Text(
                  'Offline Storage',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                ),
                subtitle: Text(
                  '$_totalStorageSize used for offline books',
                  style: GoogleFonts.roboto(
                    fontSize: 11.5,
                    color: isDark ? const Color(0xFF777777) : const Color(0xFF6B7280),
                  ),
                ),
                trailing: GestureDetector(
                  onTap: _clearCache,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppTheme.accentRose.withValues(alpha: isDark ? 0.25 : 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Clear',
                      style: GoogleFonts.roboto(
                        color: AppTheme.accentRose,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const AdBannerWidget(),
          ],
        ),
      ),
    );
  }
}
