import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ncert_books_app/models/ncert_book.dart';
import 'package:ncert_books_app/theme/app_theme.dart';

class DownloadedBookTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const DownloadedBookTile({
    super.key,
    required this.item,
    required this.isDark,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final book = item['book'] as NcertBook?;
    final title = book?.text ?? (item['code'] as String);
    final subject = book?.subject ?? 'General';
    final files = item['files'] as List<File>;
    final sizeStr = item['sizeString'] as String? ?? '';
    final subjectColor = AppTheme.getSubjectColor(subject);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: subjectColor.withValues(alpha: isDark ? 0.18 : 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.offline_pin_rounded,
                    color: subjectColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.roboto(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${files.length} Chapters • $sizeStr',
                        style: GoogleFonts.roboto(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 19,
                    color: Color(0xFFEF4444),
                  ),
                  onPressed: onDelete,
                  tooltip: 'Delete offline files',
                ),
                const SizedBox(width: 4),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF222222) : const Color(0xFFF1F1F4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 13,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
