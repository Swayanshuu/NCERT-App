import 'package:flutter/material.dart';
import 'package:ncert_books_app/theme/app_theme.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.darkBackground,
      child: child,
    );
  }
}
