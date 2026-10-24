import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _isInitialized = false;

  /// Optional production banner unit ID configured by app publisher.
  static String? customProductionBannerId = 'ca-app-pub-5596738423702241/5748316933';

  /// Standard Google AdMob test banner ad unit IDs.
  static const String testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String testBannerIos = 'ca-app-pub-3940256099942544/2934735716';

  /// Real production banner ad unit IDs.
  static const String prodBannerAndroid = 'ca-app-pub-5596738423702241/5748316933';
  static const String prodBannerIos = 'ca-app-pub-5596738423702241/5748316933';

  /// Whether the app is currently running in debug mode.
  static bool get isDebugMode => kDebugMode;

  /// Returns whether banner ads should be shown.
  static bool get isSupportedMobilePlatform {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (_) {
      return false;
    }
  }

  /// Returns whether banner ads should be shown.
  static bool get shouldShowAds {
    if (!isSupportedMobilePlatform) return false;
    return true;
  }

  /// Returns test ad unit ID for current platform.
  static String get testBannerAdUnitId {
    try {
      if (Platform.isIOS) return testBannerIos;
    } catch (_) {}
    return testBannerAndroid;
  }

  /// Returns real production banner unit ID for current platform.
  static String get productionBannerAdUnitId {
    if (customProductionBannerId != null && customProductionBannerId!.isNotEmpty) {
      return customProductionBannerId!;
    }
    try {
      if (Platform.isIOS) return prodBannerIos;
    } catch (_) {}
    return prodBannerAndroid;
  }

  /// Banner ad unit ID.
  /// When in debug mode: returns Google AdMob test ad unit ID only.
  /// When in release mode: returns real production ad unit ID only.
  static String get bannerAdUnitId {
    if (!isSupportedMobilePlatform) return '';
    if (kDebugMode) {
      return testBannerAdUnitId;
    }
    return productionBannerAdUnitId;
  }

  Future<void> init() async {
    if (_isInitialized || !isSupportedMobilePlatform) return;
    if (!shouldShowAds) return;
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
    } catch (e) {
      debugPrint('MobileAds initialize error: $e');
    }
  }
}

