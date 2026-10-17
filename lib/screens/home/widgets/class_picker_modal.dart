import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ncert_books_app/theme/app_theme.dart';
import 'package:ncert_books_app/widgets/hover_builder.dart';

class ClassPickerModal {
  static void show({
    required BuildContext context,
    required String selectedClass,
    required List<String> availableClasses,
    required bool isDark,
    required ValueChanged<String> onClassSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 540),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                width: 1.0,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 30,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(22),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Class',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                          letterSpacing: -0.3,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: isDark ? Colors.white70 : Colors.black87,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 420 ? 4 : 3;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 2.4,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: availableClasses.length,
                        itemBuilder: (context, idx) {
                          final cls = availableClasses[idx];
                          final isSel = selectedClass == cls;
                          return HoverBuilder(
                            onTap: () {
                              onClassSelected(cls);
                              Navigator.pop(ctx);
                            },
                            builder: (context, isHovered) => Container(
                              decoration: BoxDecoration(
                                color: isSel
                                    ? (isDark ? Colors.white : const Color(0xFF18181B))
                                    : (isDark ? const Color(0xFF222222) : const Color(0xFFF3F4F6)),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSel
                                      ? (isDark ? Colors.white : const Color(0xFF18181B))
                                      : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                                  width: 1.0,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Class $cls',
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: isSel
                                        ? (isDark ? const Color(0xFF18181B) : Colors.white)
                                        : (isDark ? Colors.white : const Color(0xFF111827)),
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
