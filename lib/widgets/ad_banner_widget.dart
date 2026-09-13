import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';
import '../theme/app_theme.dart';

class AdBannerWidget extends StatefulWidget {
  final EdgeInsetsGeometry margin;
  final bool showSectionLabel;

  const AdBannerWidget({
    super.key,
    this.margin = const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    this.showSectionLabel = true,
  });

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _adFailed = false;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  void _loadBanner() async {
    if (!AdService.shouldShowAds) {
      if (mounted) setState(() => _adFailed = true);
      return;
    }
    final adUnitId = AdService.bannerAdUnitId;
    if (adUnitId.isEmpty) {
      if (mounted) setState(() => _adFailed = true);
      return;
    }

    try {
      final ad = BannerAd(
        adUnitId: adUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (mounted) {
              setState(() {
                _isLoaded = true;
                _adFailed = false;
              });
            }
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            if (mounted) {
              setState(() {
                _isLoaded = false;
                _adFailed = true;
                _bannerAd = null;
              });
            }
          },
        ),
      );
      _bannerAd = ad;
      await ad.load();
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoaded = false;
          _adFailed = true;
          _bannerAd = null;
        });
      }
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AdService.isSupportedMobilePlatform || _adFailed) {
      return const SizedBox.shrink();
    }

    final ad = _bannerAd;
    if (_isLoaded && ad != null) {
      final isDark = Theme.of(context).brightness == Brightness.dark;

      return Container(
        margin: widget.margin,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showSectionLabel) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'ADVERTISEMENT',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.darkSurface.withValues(alpha: 0.85)
                    : AppTheme.lightSurface.withValues(alpha: 0.90),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : AppTheme.lightBorder,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: ad.size.width.toDouble(),
                  height: ad.size.height.toDouble(),
                  child: KeyedSubtree(
                    key: ValueKey(ad.hashCode),
                    child: AdWidget(ad: ad),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
