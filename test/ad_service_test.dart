import 'package:flutter_test/flutter_test.dart';
import 'package:ncert_books_app/services/ad_service.dart';

void main() {
  test('AdService verifies test and production ad unit IDs', () {
    expect(AdService.testBannerAndroid, 'ca-app-pub-3940256099942544/6300978111');
    expect(AdService.testBannerIos, 'ca-app-pub-3940256099942544/2934735716');
    expect(AdService.prodBannerAndroid, 'ca-app-pub-5596738423702241/5748316933');

    // In unit test runner, kDebugMode is true
    expect(AdService.isDebugMode, isTrue);
    expect(AdService.testBannerAdUnitId, isNotEmpty);
    expect(AdService.productionBannerAdUnitId, 'ca-app-pub-5596738423702241/5748316933');
  });
}
