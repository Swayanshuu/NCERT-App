import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oc_liquid_glass/oc_liquid_glass.dart';
import 'package:ncert_books_app/theme/app_theme.dart';
import 'package:ncert_books_app/services/gamification_service.dart';
import 'package:ncert_books_app/services/ncert_repository.dart';
import 'package:ncert_books_app/services/pdf_cache_service.dart';
import 'package:ncert_books_app/services/ad_service.dart';
import 'package:ncert_books_app/services/notification_service.dart';
import 'package:ncert_books_app/screens/home/home_screen.dart';
import 'package:ncert_books_app/screens/onboarding/onboarding_screen.dart';
import 'package:ncert_books_app/screens/home/bloc/home_bloc.dart';
import 'package:ncert_books_app/screens/explore/bloc/explore_bloc.dart';
import 'package:ncert_books_app/screens/books/bloc/books_bloc.dart';
import 'package:ncert_books_app/screens/reader/bloc/pdf_reader_bloc.dart';
import 'package:ncert_books_app/screens/progress/bloc/progress_bloc.dart';
import 'package:ncert_books_app/screens/profile/bloc/profile_bloc.dart';
import 'package:ncert_books_app/screens/onboarding/bloc/onboarding_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global exception safety nets to prevent app crash auto-closure
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exception}');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('PlatformDispatcher uncaught error: $error');
    return true; // Handled safely to prevent crash
  };

  final gamification = GamificationService();
  try {
    await gamification.init();
  } catch (e) {
    debugPrint('GamificationService init error: $e');
  }

  // Launch UI immediately so app opens smoothly
  runApp(NcertBooksApp(gamification: gamification));

  // Run non-critical background initializations post-launch
  _initServicesAsync(gamification);
}

Future<void> _initServicesAsync(GamificationService gamification) async {
  try {
    await PdfCacheService().syncMemoryCache();
  } catch (e) {
    debugPrint('PdfCacheService sync error: $e');
  }

  try {
    await AdService().init();
  } catch (e) {
    debugPrint('AdService init error: $e');
  }

  try {
    await NotificationService().init();
    await NotificationService().trackAppOpen(
      userName: gamification.userName,
      streakDays: gamification.streak,
      canClaimBonus: gamification.canClaimDailyBonus,
      hoursUntilBonus: gamification.hoursUntilNextBonus,
    );
  } catch (e) {
    debugPrint('NotificationService init error: $e');
  }
}

class NcertBooksApp extends StatefulWidget {
  final GamificationService gamification;

  const NcertBooksApp({super.key, required this.gamification});

  @override
  State<NcertBooksApp> createState() => _NcertBooksAppState();
}

class _NcertBooksAppState extends State<NcertBooksApp> {
  late final NcertRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = NcertRepository();
    OCLiquidGlassGroup.precacheShader();
    widget.gamification.addListener(_onThemeOrStateChange);
  }

  @override
  void dispose() {
    widget.gamification.removeListener(_onThemeOrStateChange);
    super.dispose();
  }

  void _onThemeOrStateChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>(
          create: (_) => HomeBloc(gamification: widget.gamification)..add(HomeLoadRequested()),
        ),
        BlocProvider<ExploreBloc>(
          create: (_) => ExploreBloc(repository: _repository, gamification: widget.gamification)..add(ExploreLoadRequested()),
        ),
        BlocProvider<BooksBloc>(
          create: (_) => BooksBloc(repository: _repository, gamification: widget.gamification)..add(BooksLoadRequested()),
        ),
        BlocProvider<PdfReaderBloc>(
          create: (_) => PdfReaderBloc(gamification: widget.gamification),
        ),
        BlocProvider<ProgressBloc>(
          create: (_) => ProgressBloc(gamification: widget.gamification)..add(ProgressLoadRequested()),
        ),
        BlocProvider<ProfileBloc>(
          create: (_) => ProfileBloc(gamification: widget.gamification)..add(ProfileLoadRequested()),
        ),
        BlocProvider<OnboardingBloc>(
          create: (_) => OnboardingBloc(gamification: widget.gamification),
        ),
      ],
      child: MaterialApp(
        title: 'NCERT Fun Books & Reader',
        debugShowCheckedModeBanner: false,
        scrollBehavior: const AppScrollBehavior(),
        themeMode: widget.gamification.isDarkMode
            ? ThemeMode.dark
            : ThemeMode.light,
        theme: AppTheme.lightThemeData(),
        darkTheme: AppTheme.darkThemeData(),
        home: widget.gamification.isOnboardingCompleted
            ? HomeScreen(gamification: widget.gamification)
            : OnboardingScreen(gamification: widget.gamification),
      ),
    );
  }
}
