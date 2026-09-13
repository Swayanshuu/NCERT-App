import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Palette - Refined Emerald & Indigo
  static const Color primaryTeal = Color(0xFF0D9488);
  static const Color primaryTealDark = Color(0xFF0F766E);

  static const Color primaryIndigo = Color(0xFF4F46E5);
  static const Color primaryIndigoDark = Color(0xFF4338CA);

  // Vibrant Child-Friendly Palette
  static const Color skyCyan = Color(0xFF0284C7);
  static const Color emeraldMint = Color(0xFF10B981);
  static const Color sunshineGold = Color(0xFFF59E0B);
  static const Color energyOrange = Color(0xFFF97316);
  static const Color royalPurple = Color(0xFF8B5CF6);
  static const Color coralPink = Color(0xFFEC4899);

  // Subject Worlds Semantic Colors
  static const Color subjectMathColor = Color(0xFF0EA5E9);
  static const Color subjectScienceColor = Color(0xFF10B981);
  static const Color subjectEnglishColor = Color(0xFFF97316);
  static const Color subjectSocialColor = Color(0xFFF59E0B);
  static const Color subjectHindiColor = Color(0xFF8B5CF6);
  static const Color subjectSanskritColor = Color(0xFFEC4899);

  // Accent & Status Colors
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentAmberDark = Color(0xFFD97706);

  static const Color accentOrange = Color(0xFFEA580C);
  static const Color accentRose = Color(0xFFF43F5E);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentCyan = Color(0xFF06B6D4);

  // Light Theme Surfaces & Text
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightBorderHighlight = Color(0xFFCBD5E1);

  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Dark Theme Surfaces & Text
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkSurfaceElevated = Color(0xFF334155);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkBorderHighlight = Color(0xFF475569);

  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextMuted = Color(0xFF64748B);

  // Legacy compatibility getters for existing color calls
  static Color get duoGreen => primaryTeal;
  static Color get duoGreenShadow => primaryTealDark;
  static Color get duoCyan => primaryIndigo;
  static Color get duoCyanShadow => primaryIndigoDark;
  static Color get duoYellow => accentAmber;
  static Color get duoYellowShadow => accentAmberDark;
  static Color get duoOrange => accentOrange;
  static Color get duoOrangeShadow => const Color(0xFFC2410C);
  static Color get duoRed => accentRose;
  static Color get duoRedShadow => const Color(0xFFE11D48);
  static Color get duoPurple => accentPurple;
  static Color get duoPurpleShadow => const Color(0xFF7C3AED);

  static ThemeData lightThemeData() {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(ThemeData.light().textTheme);
    final headingFont = GoogleFonts.outfitTextTheme(ThemeData.light().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: primaryTeal,
        secondary: primaryIndigo,
        tertiary: accentAmber,
        surface: lightSurface,
        onSurface: lightTextPrimary,
        outline: lightBorder,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: headingFont.displayLarge?.copyWith(color: lightTextPrimary, fontWeight: FontWeight.bold),
        displayMedium: headingFont.displayMedium?.copyWith(color: lightTextPrimary, fontWeight: FontWeight.bold),
        displaySmall: headingFont.displaySmall?.copyWith(color: lightTextPrimary, fontWeight: FontWeight.bold),
        headlineLarge: headingFont.headlineLarge?.copyWith(color: lightTextPrimary, fontWeight: FontWeight.bold),
        headlineMedium: headingFont.headlineMedium?.copyWith(color: lightTextPrimary, fontWeight: FontWeight.bold),
        headlineSmall: headingFont.headlineSmall?.copyWith(color: lightTextPrimary, fontWeight: FontWeight.w700),
        titleLarge: headingFont.titleLarge?.copyWith(color: lightTextPrimary, fontWeight: FontWeight.w700),
        titleMedium: baseTextTheme.titleMedium?.copyWith(color: lightTextPrimary, fontWeight: FontWeight.w600),
        titleSmall: baseTextTheme.titleSmall?.copyWith(color: lightTextSecondary, fontWeight: FontWeight.w600),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: lightTextPrimary),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: lightTextSecondary),
        bodySmall: baseTextTheme.bodySmall?.copyWith(color: lightTextMuted),
        labelLarge: headingFont.labelLarge?.copyWith(color: lightTextPrimary, fontWeight: FontWeight.bold),
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: lightBorder, width: 1.5),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: lightTextPrimary),
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: lightTextPrimary,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: lightBorder, width: 1.5),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData darkThemeData() {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme);
    final headingFont = GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryTeal,
        secondary: primaryIndigo,
        tertiary: accentAmber,
        surface: darkSurface,
        onSurface: darkTextPrimary,
        outline: darkBorder,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: headingFont.displayLarge?.copyWith(color: darkTextPrimary, fontWeight: FontWeight.bold),
        displayMedium: headingFont.displayMedium?.copyWith(color: darkTextPrimary, fontWeight: FontWeight.bold),
        displaySmall: headingFont.displaySmall?.copyWith(color: darkTextPrimary, fontWeight: FontWeight.bold),
        headlineLarge: headingFont.headlineLarge?.copyWith(color: darkTextPrimary, fontWeight: FontWeight.bold),
        headlineMedium: headingFont.headlineMedium?.copyWith(color: darkTextPrimary, fontWeight: FontWeight.bold),
        headlineSmall: headingFont.headlineSmall?.copyWith(color: darkTextPrimary, fontWeight: FontWeight.w700),
        titleLarge: headingFont.titleLarge?.copyWith(color: darkTextPrimary, fontWeight: FontWeight.w700),
        titleMedium: baseTextTheme.titleMedium?.copyWith(color: darkTextPrimary, fontWeight: FontWeight.w600),
        titleSmall: baseTextTheme.titleSmall?.copyWith(color: darkTextSecondary, fontWeight: FontWeight.w600),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: darkTextPrimary),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: darkTextSecondary),
        bodySmall: baseTextTheme.bodySmall?.copyWith(color: darkTextMuted),
        labelLarge: headingFont.labelLarge?.copyWith(color: darkTextPrimary, fontWeight: FontWeight.bold),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: darkBorder, width: 1.5),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: darkTextPrimary),
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: darkBorder, width: 1.5),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  static Color getSubjectColor(String subject) {
    final s = subject.toLowerCase();
    if (s.contains('math')) return primaryTeal;
    if (s.contains('sci') || s.contains('evs')) return primaryIndigo;
    if (s.contains('eng')) return accentOrange;
    if (s.contains('hin')) return accentRose;
    if (s.contains('soc') || s.contains('his') || s.contains('geo')) return accentPurple;
    return accentCyan;
  }

  static Color getSubjectShadow(String subject) {
    final s = subject.toLowerCase();
    if (s.contains('math')) return primaryTealDark;
    if (s.contains('sci') || s.contains('evs')) return primaryIndigoDark;
    if (s.contains('eng')) return const Color(0xFFC2410C);
    if (s.contains('hin')) return const Color(0xFFE11D48);
    if (s.contains('soc') || s.contains('his') || s.contains('geo')) return const Color(0xFF7C3AED);
    return const Color(0xFF0891B2);
  }

  static IconData getSubjectIcon(String subject) {
    final s = subject.toLowerCase();
    if (s.contains('math')) return Icons.calculate_rounded;
    if (s.contains('sci') || s.contains('evs')) return Icons.science_rounded;
    if (s.contains('eng')) return Icons.auto_stories_rounded;
    if (s.contains('hin')) return Icons.translate_rounded;
    if (s.contains('soc') || s.contains('his') || s.contains('geo')) return Icons.public_rounded;
    return Icons.menu_book_rounded;
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
      };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    );
  }
}
