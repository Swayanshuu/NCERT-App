import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:oc_liquid_glass/oc_liquid_glass.dart';
import 'package:ncert_books_app/services/gamification_service.dart';
import 'package:ncert_books_app/services/ncert_repository.dart';
import 'package:ncert_books_app/services/pdf_cache_service.dart';
import 'package:ncert_books_app/theme/app_theme.dart';
import 'package:ncert_books_app/widgets/duo_button.dart';
import 'package:ncert_books_app/widgets/ad_banner_widget.dart';
import 'package:ncert_books_app/widgets/app_background.dart';
import 'package:ncert_books_app/widgets/custom_snack_bar.dart';

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
    if (mounted) {
      setState(() {});
    }
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
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _isSavingName = false);
        CustomSnackBar.showSuccess(context, 'Name updated to "$name"!');
      }
    });
  }

  Future<void> _clearCache() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.delete_sweep_rounded, color: AppTheme.duoRed, size: 28),
            const SizedBox(width: 8),
            Text('Clear Offline Storage?', style: GoogleFonts.fredoka(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('This will delete all offline downloaded books ($_totalStorageSize). You can re-download them anytime.', style: GoogleFonts.fredoka(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.fredoka(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.duoRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Clear All', style: GoogleFonts.fredoka(color: Colors.white, fontWeight: FontWeight.bold)),
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
        CustomSnackBar.showError(context, 'Offline storage cleared successfully!');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.gamification.isDarkMode;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: AutoSizeText(
            'Settings & Profile ⚙️',
            maxLines: 1,
            minFontSize: 14,
            style: GoogleFonts.fredoka(fontWeight: FontWeight.bold),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. Edit Name Section
                OCLiquidGlass(
                  borderRadius: 22,
                  color: (isDark ? AppTheme.darkCard : AppTheme.lightCard).withValues(alpha: 0.85),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                        width: 1.8,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.badge_rounded, color: AppTheme.duoGreen, size: 24),
                            const SizedBox(width: 8),
                            AutoSizeText('Student Name', maxLines: 1, minFontSize: 12, style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OCLiquidGlass(
                                borderRadius: 16,
                                color: isDark ? Colors.black38.withValues(alpha: 0.5) : Colors.grey.withValues(alpha: 0.15),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppTheme.duoGreen, width: 1.5),
                                  ),
                                  child: TextField(
                                    controller: _nameController,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Enter your name...',
                                      hintStyle: GoogleFonts.fredoka(color: Colors.grey),
                                    ),
                                    style: GoogleFonts.fredoka(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            DuoButton(
                              text: _isSavingName ? '...' : 'SAVE',
                              color: AppTheme.duoGreen,
                              shadowColor: AppTheme.duoGreenShadow,
                              onPressed: _saveName,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Change Class Section
                OCLiquidGlass(
                  borderRadius: 22,
                  color: (isDark ? AppTheme.darkCard : AppTheme.lightCard).withValues(alpha: 0.85),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                        width: 1.8,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.school_rounded, color: AppTheme.duoCyan, size: 24),
                            const SizedBox(width: 8),
                            AutoSizeText('Change Selected Class', maxLines: 1, minFontSize: 12, style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('Current: Class ${widget.gamification.userClass}', style: GoogleFonts.fredoka(fontSize: 13, color: Colors.grey)),
                        const SizedBox(height: 14),
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
                              child: OCLiquidGlass(
                                borderRadius: 18,
                                color: isSel
                                    ? AppTheme.duoCyan.withValues(alpha: 0.95)
                                    : (isDark ? Colors.black26.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.7)),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    gradient: isSel
                                        ? LinearGradient(
                                            colors: [AppTheme.duoCyan, AppTheme.duoCyanShadow],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          )
                                        : null,
                                    border: Border.all(
                                      color: isSel
                                          ? Colors.white
                                          : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                                      width: 1.5,
                                    ),
                                    boxShadow: isSel
                                        ? [
                                            BoxShadow(
                                              color: AppTheme.duoCyanShadow.withValues(alpha: 0.40),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: AutoSizeText(
                                    'Class $cls',
                                    maxLines: 1,
                                    minFontSize: 10,
                                    style: GoogleFonts.fredoka(
                                      fontSize: 13,
                                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w600,
                                      color: isSel ? Colors.white : AppTheme.duoCyan,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Buddy Avatar Section
                OCLiquidGlass(
                  borderRadius: 22,
                  color: (isDark ? AppTheme.darkCard : AppTheme.lightCard).withValues(alpha: 0.85),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                        width: 1.8,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.face_rounded, color: AppTheme.duoYellow, size: 24),
                            const SizedBox(width: 8),
                            AutoSizeText('Select Avatar Companion', maxLines: 1, minFontSize: 12, style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: GamificationService.avatars.map((avatar) {
                            final isSel = widget.gamification.currentAvatar == avatar;
                            return GestureDetector(
                              onTap: () => widget.gamification.setAvatar(avatar),
                              child: OCLiquidGlass(
                                borderRadius: 16,
                                color: isSel
                                    ? AppTheme.duoYellow.withValues(alpha: 0.95)
                                    : (isDark ? Colors.black26.withValues(alpha: 0.4) : Colors.grey.withValues(alpha: 0.15)),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: isSel
                                        ? LinearGradient(
                                            colors: [AppTheme.duoYellow, AppTheme.duoYellowShadow],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          )
                                        : null,
                                    border: Border.all(
                                      color: isSel ? Colors.white : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                                      width: 1.5,
                                    ),
                                    boxShadow: isSel
                                        ? [
                                            BoxShadow(
                                              color: AppTheme.duoYellowShadow.withValues(alpha: 0.40),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: AutoSizeText(
                                    avatar,
                                    maxLines: 1,
                                    minFontSize: 10,
                                    style: GoogleFonts.fredoka(
                                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w600,
                                      fontSize: 13,
                                      color: isSel ? Colors.white : null,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Dark Theme & Storage Section
                OCLiquidGlass(
                  borderRadius: 22,
                  color: (isDark ? AppTheme.darkCard : AppTheme.lightCard).withValues(alpha: 0.85),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                        width: 1.8,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: AutoSizeText('Dark Mode Theme', maxLines: 1, minFontSize: 12, style: GoogleFonts.fredoka(fontWeight: FontWeight.bold)),
                            value: isDark,
                            activeTrackColor: AppTheme.duoYellow,
                            onChanged: (_) => widget.gamification.toggleTheme(),
                          ),
                          Divider(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder, height: 24, thickness: 1.5),
                          ListTile(
                            leading: Icon(Icons.storage_rounded, color: AppTheme.duoRed),
                            title: AutoSizeText('Offline Storage Used', maxLines: 1, minFontSize: 12, style: GoogleFonts.fredoka(fontWeight: FontWeight.bold)),
                            subtitle: AutoSizeText(_totalStorageSize, maxLines: 1, minFontSize: 10, style: GoogleFonts.fredoka(color: Colors.grey)),
                            trailing: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.duoRed,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _clearCache,
                              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 16),
                              label: AutoSizeText('Clear', maxLines: 1, minFontSize: 10, style: GoogleFonts.fredoka(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const AdBannerWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
