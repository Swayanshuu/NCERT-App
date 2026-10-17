import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ncert_books_app/theme/app_theme.dart';

class SubjectFilterBar extends StatelessWidget {
  final String selectedClass;
  final String selectedSubject;
  final bool hasActiveFilter;
  final List<Map<String, dynamic>> filterTabs;
  final bool isDark;
  final ValueChanged<String> onSubjectSelected;
  final VoidCallback onClearFilter;

  const SubjectFilterBar({
    super.key,
    required this.selectedClass,
    required this.selectedSubject,
    required this.hasActiveFilter,
    required this.filterTabs,
    required this.isDark,
    required this.onSubjectSelected,
    required this.onClearFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Class $selectedClass Subjects',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.roboto(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              if (hasActiveFilter)
                GestureDetector(
                  onTap: onClearFilter,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      'Clear filter',
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: const Color(0xFF777777),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 52,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            itemCount: filterTabs.length,
            itemBuilder: (context, index) {
              final tab = filterTabs[index];
              final title = tab['title'] as String;
              final icon = tab['icon'] as IconData;
              final color = tab['color'] as Color;
              final isSelected = selectedSubject == title;

              final chipBg = isSelected
                  ? (isDark ? Colors.white : const Color(0xFF18181B))
                  : (isDark ? AppTheme.darkCard : const Color(0xFFF1F1F4));
              final chipText = isSelected
                  ? (isDark ? Colors.black : Colors.white)
                  : (isDark ? AppTheme.darkTextSecondary : const Color(0xFF374151));

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onSubjectSelected(title),
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: chipBg,
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected
                              ? null
                              : Border.all(
                                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                                  width: 1.0,
                                ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              icon,
                              size: 15,
                              color: isSelected ? chipText : color,
                            ),
                            const SizedBox(width: 7),
                            Text(
                              title,
                              maxLines: 1,
                              style: GoogleFonts.roboto(
                                fontSize: 12.5,
                                height: 1.15,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: chipText,
                                letterSpacing: -0.1,
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
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
