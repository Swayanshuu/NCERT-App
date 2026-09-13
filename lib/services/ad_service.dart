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

  static String get bannerAdUnitId {
    if (!isSupportedMobilePlatform) return '';
    if (customProductionBannerId != null && customProductionBannerId!.isNotEmpty) {
      return customProductionBannerId!;
    }
    try {
      if (Platform.isAndroid) {
        return 'ca-app-pub-5596738423702241/5748316933';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/2934735716';
      }
    } catch (_) {}
    return 'ca-app-pub-5596738423702241/5748316933';
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

