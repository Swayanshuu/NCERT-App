import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Clean, Scandinavian & Minimalist Design System for "NCERT Books & News"
/// Featuring modern pastel card surfaces, high-contrast typography, and tactile UI tokens.
class AppTheme {
  // ==========================================
  // 1. Core Primary & Semantic Colors
  // ==========================================
  /// Deep Charcoal Black used for active filter chips, buttons, and high-contrast badges (from Reference UI)
  static const Color primaryDark = Color(0xFF18181B);
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryTeal = Color(0xFF0D9488);
  static const Color primaryTealDark = Color(0xFF0F766E);
  static const Color primaryIndigo = Color(0xFF4F46E5);
  static const Color primaryIndigoDark = Color(0xFF4338CA);

  // ==========================================
  // 2. Pastel Palette System (Direct Reference)
  // Soft, cheerful pastel card tones with matching dark-mode deep tints
  // ==========================================
  // Butter Yellow
  static const Color pastelYellowLight = Color(0xFFFEF3C7);
  static const Color pastelYellowDark = Color(0xFF262015);
  static const Color pastelYellowBorder = Color(0xFFFDE68A);
  static const Color pastelYellowAccent = Color(0xFFD97706);

  // Rose Blossom Pink
  static const Color pastelPinkLight = Color(0xFFFCE7F3);
  static const Color pastelPinkDark = Color(0xFF2A1722);
  static const Color pastelPinkBorder = Color(0xFFFBCFE8);
  static const Color pastelPinkAccent = Color(0xFFE11D48);

  // Ice Sky Cyan
  static const Color pastelCyanLight = Color(0xFFE0F2FE);
  static const Color pastelCyanDark = Color(0xFF13222E);
  static const Color pastelCyanBorder = Color(0xFFBAE6FD);
  static const Color pastelCyanAccent = Color(0xFF0284C7);

  // Fresh Mint Green
  static const Color pastelMintLight = Color(0xFFDCFCE7);
  static const Color pastelMintDark = Color(0xFF14261C);
  static const Color pastelMintBorder = Color(0xFFBBF7D0);
  static const Color pastelMintAccent = Color(0xFF059669);

  // Lavender Purple
  static const Color pastelPurpleLight = Color(0xFFF3E8FF);
  static const Color pastelPurpleDark = Color(0xFF221731);
  static const Color pastelPurpleBorder = Color(0xFFE9D5FF);
  static const Color pastelPurpleAccent = Color(0xFF7C3AED);

  // Warm Peach Orange
  static const Color pastelOrangeLight = Color(0xFFFFEDD5);
  static const Color pastelOrangeDark = Color(0xFF281C14);
  static const Color pastelOrangeBorder = Color(0xFFFED7AA);
  static const Color pastelOrangeAccent = Color(0xFFEA580C);

  // ==========================================
  // 3. Modern Semantic Subject Accents
  // ==========================================
  static const Color subjectMathColor = Color(0xFF0284C7);
  static const Color subjectScienceColor = Color(0xFF059669);
  static const Color subjectEnglishColor = Color(0xFFD97706);
  static const Color subjectSocialColor = Color(0xFF7C3AED);
  static const Color subjectHindiColor = Color(0xFFDB2777);
  static const Color subjectSanskritColor = Color(0xFF4F46E5);

  // ==========================================
  // 4. Accent & Status Tokens
  // ==========================================
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentAmberDark = Color(0xFFD97706);
  static const Color accentOrange = Color(0xFFEA580C);
  static const Color accentRose = Color(0xFFF43F5E);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color emeraldMint = Color(0xFF10B981);
  static const Color skyCyan = Color(0xFF0284C7);
  static const Color sunshineGold = Color(0xFFF59E0B);
  static const Color energyOrange = Color(0xFFF97316);
  static const Color royalPurple = Color(0xFF8B5CF6);
  static const Color coralPink = Color(0xFFEC4899);

  // ==========================================
  // 5. Neutrals: Light Mode (Crisp & Breathable)
  // ==========================================
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(
    0xFFF3F4F6,
  ); // Soft pill inputs & search
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightBorderHighlight = Color(0xFFD1D5DB);
  static const Color lightBorderSubtle = Color(0xFFF1F1F4);

  static const Color lightTextPrimary = Color(
    0xFF18181B,
  ); // High-contrast Charcoal
  static const Color lightTextSecondary = Color(0xFF52525B);
  static const Color lightTextMuted = Color(0xFF9CA3AF);

  // ==========================================
  // 6. Neutrals: Dark Mode (Exact Threads by Meta)
  // ==========================================
  static const Color darkBackground = Color.fromARGB(
    255,
    24,
    24,
    24,
  ); // Custom Grey Background
  static const Color darkSurface = Color(
    0xFF181818,
  ); // Threads Card / Post Surface
  static const Color darkCard = Color(0xFF181818);
  static const Color darkSurfaceElevated = Color(
    0xFF222222,
  ); // Threads Input / Pill
  static const Color darkBorder = Color(
    0xFF282828,
  ); // Threads Subtle Hairline Border
  static const Color darkSurfaceSubtle = Color(0xFF141414);
  static const Color accentTeal = Color(0xFFFFFFFF);
  static const Color darkBorderHighlight = Color(0xFF383838);
  static const Color darkBorderSubtle = Color(0xFF202020);

  static const Color darkTextPrimary = Color(0xFFFFFFFF); // Pure Crisp White
  static const Color darkTextSecondary = Color(
    0xFF777777,
  ); // Signature Threads Neutral Grey
  static const Color darkTextMuted = Color(0xFF555555); // Muted Meta Grey

  // Compatibility getter aliases
  static Color get duoGreen => emeraldMint;
  static Color get duoGreenShadow => const Color(0xFF059669);
  static Color get duoCyan => skyCyan;
  static Color get duoCyanShadow => const Color(0xFF0284C7);
  static Color get duoYellow => accentAmber;
  static Color get duoYellowShadow => accentAmberDark;
  static Color get duoOrange => accentOrange;
  static Color get duoOrangeShadow => const Color(0xFFC2410C);
  static Color get duoRed => accentRose;
  static Color get duoRedShadow => const Color(0xFFE11D48);
  static Color get duoPurple => accentPurple;
  static Color get duoPurpleShadow => const Color(0xFF7C3AED);

  // ==========================================
  // 7. Light ThemeData
  // ==========================================
  static ThemeData lightThemeData() {
    final baseTextTheme = GoogleFonts.robotoTextTheme(
      ThemeData.light().textTheme,
    );
    final headingFont = GoogleFonts.robotoTextTheme(
      ThemeData.light().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: primaryDark,
        secondary: primaryBlue,
        tertiary: accentAmber,
        surface: lightSurface,
        onSurface: lightTextPrimary,
        outline: lightBorder,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: headingFont.displayLarge?.copyWith(
          color: lightTextPrimary,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.0,
        ),
        displayMedium: headingFont.displayMedium?.copyWith(
          color: lightTextPrimary,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
        ),
        displaySmall: headingFont.displaySmall?.copyWith(
          color: lightTextPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        headlineLarge: headingFont.headlineLarge?.copyWith(
          color: lightTextPrimary,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.6,
        ),
        headlineMedium: headingFont.headlineMedium?.copyWith(
          color: lightTextPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        headlineSmall: headingFont.headlineSmall?.copyWith(
          color: lightTextPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleLarge: headingFont.titleLarge?.copyWith(
          color: lightTextPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: lightTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: baseTextTheme.titleSmall?.copyWith(
          color: lightTextSecondary,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: lightTextPrimary,
          fontSize: 15,
          height: 1.5,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: lightTextSecondary,
          fontSize: 13.5,
          height: 1.45,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          color: lightTextMuted,
          fontSize: 12,
        ),
        labelLarge: headingFont.labelLarge?.copyWith(
          color: lightTextPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: lightBorder, width: 1.0),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: lightTextPrimary),
        titleTextStyle: GoogleFonts.roboto(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: lightTextPrimary,
          letterSpacing: -0.3,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: lightSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: lightBorder, width: 1.0),
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

  // ==========================================
  // 8. Dark ThemeData
  // ==========================================
  static ThemeData darkThemeData() {
    final baseTextTheme = GoogleFonts.robotoTextTheme(
      ThemeData.dark().textTheme,
    );
    final headingFont = GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: Colors.white,
        secondary: primaryBlue,
        tertiary: accentAmber,
        surface: darkSurface,
        onSurface: darkTextPrimary,
        outline: darkBorder,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: headingFont.displayLarge?.copyWith(
          color: darkTextPrimary,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.0,
        ),
        displayMedium: headingFont.displayMedium?.copyWith(
          color: darkTextPrimary,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
        ),
        displaySmall: headingFont.displaySmall?.copyWith(
          color: darkTextPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        headlineLarge: headingFont.headlineLarge?.copyWith(
          color: darkTextPrimary,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.6,
        ),
        headlineMedium: headingFont.headlineMedium?.copyWith(
          color: darkTextPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        headlineSmall: headingFont.headlineSmall?.copyWith(
          color: darkTextPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleLarge: headingFont.titleLarge?.copyWith(
          color: darkTextPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: darkTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: baseTextTheme.titleSmall?.copyWith(
          color: darkTextSecondary,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: darkTextPrimary,
          fontSize: 15,
          height: 1.5,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: darkTextSecondary,
          fontSize: 13.5,
          height: 1.45,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          color: darkTextMuted,
          fontSize: 12,
        ),
        labelLarge: headingFont.labelLarge?.copyWith(
          color: darkTextPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: darkBorder, width: 1.0),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: darkTextPrimary),
        titleTextStyle: GoogleFonts.roboto(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: darkTextPrimary,
          letterSpacing: -0.3,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: darkBorder, width: 1.0),
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

  // ==========================================
  // 9. Semantic Subject Helpers
  // ==========================================
  /// Returns semantic accent dot & highlight color for each subject
  static Color getSubjectColor(String subject) {
    final s = subject.toLowerCase();
    if (s.contains('math')) return subjectMathColor;
    if (s.contains('sci') ||
        s.contains('evs') ||
        s.contains('phys') ||
        s.contains('chem') ||
        s.contains('bio')) {
      return subjectScienceColor;
    }
    if (s.contains('eng')) return subjectEnglishColor;
    if (s.contains('soc') ||
        s.contains('his') ||
        s.contains('geo') ||
        s.contains('pol') ||
        s.contains('civ')) {
      return subjectSocialColor;
    }
    if (s.contains('hin') || s.contains('sansk') || s.contains('urdu')) {
      return subjectHindiColor;
    }
    return primaryBlue;
  }

  /// Returns subtle card container color based on subject (Threads darkCard in dark mode)
  static Color getSubjectPastelBg(String subject, bool isDark) {
    if (isDark) return darkCard;
    final s = subject.toLowerCase();
    if (s.contains('math')) return pastelCyanLight;
    if (s.contains('sci') ||
        s.contains('evs') ||
        s.contains('phys') ||
        s.contains('chem') ||
        s.contains('bio')) {
      return pastelMintLight;
    }
    if (s.contains('eng')) return pastelYellowLight;
    if (s.contains('soc') ||
        s.contains('his') ||
        s.contains('geo') ||
        s.contains('pol') ||
        s.contains('civ')) {
      return pastelPurpleLight;
    }
    if (s.contains('hin') || s.contains('sansk') || s.contains('urdu')) {
      return pastelPinkLight;
    }
    return const Color(0xFFF1F5F9);
  }

  /// Returns delicate subtle border matching the subject card
  static Color getSubjectBorder(String subject, bool isDark) {
    if (isDark) return darkBorder;
    final s = subject.toLowerCase();
    if (s.contains('math')) return pastelCyanBorder;
    if (s.contains('sci') ||
        s.contains('evs') ||
        s.contains('phys') ||
        s.contains('chem') ||
        s.contains('bio')) {
      return pastelMintBorder;
    }
    if (s.contains('eng')) return pastelYellowBorder;
    if (s.contains('soc') ||
        s.contains('his') ||
        s.contains('geo') ||
        s.contains('pol') ||
        s.contains('civ')) {
      return pastelPurpleBorder;
    }
    if (s.contains('hin') || s.contains('sansk') || s.contains('urdu')) {
      return pastelPinkBorder;
    }
    return lightBorder;
  }

  /// Returns staggered card background for index-based lists
  static Color getStaggeredPastelBg(int index, bool isDark) {
    if (isDark) return darkCard;
    const lightPastels = [
      pastelYellowLight,
      pastelPinkLight,
      pastelCyanLight,
      pastelMintLight,
      pastelPurpleLight,
      pastelOrangeLight,
    ];
    return lightPastels[index % lightPastels.length];
  }

  /// Returns staggered accent color for index-based lists
  static Color getStaggeredAccent(int index) {
    const accents = [
      pastelYellowAccent,
      pastelPinkAccent,
      pastelCyanAccent,
      pastelMintAccent,
      pastelPurpleAccent,
      pastelOrangeAccent,
    ];
    return accents[index % accents.length];
  }

  static Color getSubjectShadow(String subject) {
    final color = getSubjectColor(subject);
    return color.withValues(alpha: 0.18);
  }

  static IconData getSubjectIcon(String subject) {
    final s = subject.toLowerCase();
    if (s.contains('math')) return Icons.calculate_rounded;
    if (s.contains('sci') ||
        s.contains('evs') ||
        s.contains('phys') ||
        s.contains('chem') ||
        s.contains('bio')) {
      return Icons.science_rounded;
    }
    if (s.contains('eng')) return Icons.auto_stories_rounded;
    if (s.contains('hin') || s.contains('sansk') || s.contains('urdu')) {
      return Icons.translate_rounded;
    }
    if (s.contains('soc') ||
        s.contains('his') ||
        s.contains('geo') ||
        s.contains('pol') ||
        s.contains('civ')) {
      return Icons.public_rounded;
    }
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
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }
}
