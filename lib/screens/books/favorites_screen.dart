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
      _loadFavorites(showLoading: false);
    }
  }

  Future<void> _loadFavorites({bool showLoading = true}) async {
    if (showLoading && _favoriteBooks.isEmpty) {
      setState(() => _isLoading = true);
    }
    if (!_repository.isLoaded) {
      await _repository.loadCatalog();
    }
    final favCodes = widget.gamification.favoriteBookCodes;
    final List<NcertBook> favs = [];

    for (final code in favCodes) {
      final b = _repository.findBookByCode(code);
      if (b != null && !favs.any((item) => item.code == b.code)) {
        favs.add(b);
      }
    }

    if (favs.isEmpty && favCodes.isNotEmpty) {
      for (final cls in _repository.getAvailableClasses()) {
        for (final subj in _repository.getSubjectsForClass(cls)) {
          for (final b in _repository.getBooks(cls, subj)) {
            if (favCodes.contains(b.code) && !favs.any((item) => item.code == b.code)) {
              favs.add(b);
            }
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
    return BlocBuilder<BooksBloc, BooksState>(
      builder: (context, state) {
        return MaxContentConstraint(
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
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saved Favorites',
                          style: GoogleFonts.roboto(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Quick access to your starred textbooks',
                          style: GoogleFonts.roboto(
                            fontSize: 13,
                            color: const Color(0xFF777777),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)))
                        : _favoriteBooks.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF181818),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFF282828),
                                          width: 1.0,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.favorite_border_rounded,
                                        size: 28,
                                        color: AppTheme.accentRose,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      'No favorites added yet',
                                      style: GoogleFonts.roboto(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tap the heart icon on any book to add it here',
                                      style: GoogleFonts.roboto(
                                        fontSize: 12.5,
                                        color: const Color(0xFF777777),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : GridView.builder(
                                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 95),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  childAspectRatio: 0.88,
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
        );
      },
    );
  }
}
