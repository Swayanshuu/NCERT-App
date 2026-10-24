import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncert_books_app/screens/home/widgets/subject_bento_grid.dart';
import 'package:ncert_books_app/screens/books/subject_books_screen.dart';
import 'package:ncert_books_app/services/gamification_service.dart';
import 'package:ncert_books_app/widgets/painters/bento_watermark_painter.dart';

void main() {
  testWidgets('BentoWatermarkPainter paints all watermark types without error',
      (WidgetTester tester) async {
    for (final type in BentoWatermarkType.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: const Size(200, 200),
              painter: BentoWatermarkPainter(
                type: type,
                tintColor: Colors.blue,
                opacity: 0.1,
              ),
            ),
          ),
        ),
      );
      expect(find.byType(CustomPaint), findsWidgets);
    }
  });

  testWidgets('SubjectBentoGrid renders correctly and navigates on subject tap',
      (WidgetTester tester) async {
    String selectedSubject = '';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: SubjectBentoGrid(
                  selectedClass: '10',
                  selectedSubject: '',
                  subjects: const [
                    'Mathematics',
                    'Science',
                    'Social Science',
                    'English',
                    'Hindi',
                    'Sanskrit',
                  ],
                  isDark: true,
                  onSubjectSelected: (subj) {
                    setState(() {
                      selectedSubject = subj;
                    });
                  },
                ),
              );
            },
          ),
        ),
      ),
    );

    // Verify section header
    expect(find.text('THE STUDY SHELF'), findsWidgets);
    expect(find.text('Your subjects'), findsOneWidget);

    // Verify subject titles
    expect(find.text('Mathematics'), findsOneWidget);
    expect(find.text('Science'), findsOneWidget);
    expect(find.text('Social Science'), findsOneWidget);

    // Verify diagonal arrows exist on cards
    expect(find.byIcon(Icons.north_east_rounded), findsWidgets);

    // Tap on Mathematics hero card
    await tester.tap(find.text('Mathematics'));
    await tester.pump(const Duration(milliseconds: 200));

    expect(selectedSubject, 'Mathematics');

    // Tap on Science card
    await tester.tap(find.text('Science'));
    await tester.pump(const Duration(milliseconds: 200));

    expect(selectedSubject, 'Science');
  });

  testWidgets('SubjectBooksScreen renders subject title and local search bar',
      (WidgetTester tester) async {
    final gamification = GamificationService();

    await tester.pumpWidget(
      MaterialApp(
        home: SubjectBooksScreen(
          className: '10',
          subjectName: 'Mathematics',
          gamification: gamification,
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 200));

    // Subject title & Class badge
    expect(find.text('Mathematics'), findsWidgets);
    expect(find.text('Class 10'), findsOneWidget);

    // Local search bar
    expect(find.byType(TextField), findsOneWidget);
  });
}
