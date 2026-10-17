import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ncert_books_app/models/ncert_book.dart';
import 'package:ncert_books_app/theme/app_theme.dart';
import 'package:ncert_books_app/screens/reader/pdf_viewer_screen.dart';

class ChapterExplorerModal {
  static String getChapterTitleFromFileName(String filePath) {
    final clean = filePath.split(RegExp(r'[/\\]')).last.toLowerCase();
    if (clean.contains('ps')) return 'Preliminary Pages';
    final match = RegExp(r'(\d+)').firstMatch(clean);
    if (match != null) {
      final numStr = match.group(1)!;
      final chNum = int.tryParse(numStr.length > 2 ? numStr.substring(numStr.length - 2) : numStr) ?? 1;
      return 'Chapter $chNum';
    }
    return 'Chapter 1';
  }

  static void show({
    required BuildContext context,
    required String bookTitle,
    required List<File> files,
    required NcertBook? book,
    required bool isDark,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
              maxWidth: 540,
            ),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                width: 1.0,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bookTitle,
                            style: GoogleFonts.roboto(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${files.length} Offline Chapter PDFs • Local Storage',
                            style: GoogleFonts.roboto(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF222222) : const Color(0xFFF4F4F5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(
                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                  height: 1,
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: files.length,
                    itemBuilder: (ctx, idx) {
                      final f = files[idx];
                      final chTitle = getChapterTitleFromFileName(f.path);
                      final fName = f.path.split(RegExp(r'[/\\]')).last;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.pop(ctx);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PdfViewerScreen(
                                    pdfFile: f,
                                    bookTitle: bookTitle,
                                    chapterTitle: chTitle,
                                    book: book,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF202020) : const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.18 : 0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.picture_as_pdf_rounded,
                                      color: Color(0xFF10B981),
                                      size: 17,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          chTitle,
                                          style: GoogleFonts.roboto(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w700,
                                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                                          ),
                                        ),
                                        Text(
                                          '$fName • Offline Ready',
                                          style: GoogleFonts.roboto(
                                            fontSize: 11,
                                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF282828) : const Color(0xFF18181B),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ],
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
        ),
      ),
    );
  }
}
