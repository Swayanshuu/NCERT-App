import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncert_books_app/models/ncert_book.dart';
import 'package:ncert_books_app/services/gamification_service.dart';
import 'package:ncert_books_app/services/ncert_repository.dart';
import 'package:ncert_books_app/theme/app_theme.dart';
import 'package:ncert_books_app/theme/app_responsive.dart';
import 'package:ncert_books_app/screens/books/bloc/books_bloc.dart';
import 'package:ncert_books_app/screens/books/widgets/book_card.dart';
import 'package:ncert_books_app/screens/books/book_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final GamificationService gamification;

  const FavoritesScreen({super.key, required this.gamification});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final NcertRepository _repository = NcertRepository();
  List<NcertBook> _favoriteBooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    widget.gamification.addListener(_onStateChanged);
    _loadFavorites();
  }

  @override
  void dispose() {
    widget.gamification.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) {
      _loadFavorites();
    }
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    await _repository.loadCatalog();
    final favCodes = widget.gamification.favoriteBookCodes;
    final List<NcertBook> favs = [];

    for (final cls in _repository.getAvailableClasses()) {
      for (final subj in _repository.getSubjectsForClass(cls)) {
        for (final b in _repository.getBooks(cls, subj)) {
          if (favCodes.contains(b.code) && !favs.any((item) => item.code == b.code)) {
            favs.add(b);
          }
        }
      }
    }

    if (mounted) {
      setState(() {
        _favoriteBooks = favs;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.gamification.isDarkMode;

    return BlocBuilder<BooksBloc, BooksState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = AppResponsive.getGridColumnCount(
                  context,
                  availableWidth: constraints.maxWidth,
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Favorite Books ❤️',
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                        ),
                      ),
                      Text(
                        'Your saved collection of NCERT textbooks',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal))
                      : _favoriteBooks.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.favorite_border_rounded, size: 54, color: AppTheme.accentRose),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No Favorites Added Yet',
                                    style: GoogleFonts.outfit(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tap the heart icon on any book to add it here',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 90),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: 0.70,
                              ),
                              itemCount: _favoriteBooks.length,
                              itemBuilder: (context, idx) {
                                final book = _favoriteBooks[idx];
                                return BookCard(
                                  book: book,
                                  gamification: widget.gamification,
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BookDetailScreen(
                                          book: book,
                                          gamification: widget.gamification,
                                        ),
                                      ),
                                    );
                                    _loadFavorites();
                                  },
                                );
                              },
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  },
);
  }
}
