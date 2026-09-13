import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ncert_books_app/main.dart';
import 'package:ncert_books_app/services/gamification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App initializes test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final gamification = GamificationService();
    await gamification.init();

    await tester.pumpWidget(NcertBooksApp(gamification: gamification));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(NcertBooksApp), findsOneWidget);
  });
}