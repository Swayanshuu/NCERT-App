import 'dart:io';
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
  bool _triedFallback = false;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  void _loadBanner({bool useTestId = false}) async {
    if (!AdService.shouldShowAds) {
      if (mounted) setState(() => _adFailed = true);
      return;
    }

    final adUnitId = useTestId
        ? (Platform.isAndroid
              ? 'ca-app-pub-3940256099942544/6300978111'
              : 'ca-app-pub-3940256099942544/2934735716')
        : AdService.bannerAdUnitId;

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
              if (!_triedFallback && !useTestId) {
                _triedFallback = true;
                _loadBanner(useTestId: true);
              } else {
                setState(() {
                  _isLoaded = false;
                  _adFailed = true;
                  _bannerAd = null;
                });
              }
            }
          },
        ),
      );
      _bannerAd = ad;
      await ad.load();
    } catch (_) {
      if (mounted) {
        if (!_triedFallback && !useTestId) {
          _triedFallback = true;
          _loadBanner(useTestId: true);
        } else {
          setState(() {
            _isLoaded = false;
            _adFailed = true;
            _bannerAd = null;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    super.dispose();
  }

  Widget _buildFallbackSponsoredCard(bool isDark) {
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
                style: GoogleFonts.roboto(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? const Color(0xFF777777)
                      : const Color(0xFF94A3B8),
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF181818) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF282828) : AppTheme.lightBorder,
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
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF0284C7,
                    ).withValues(alpha: isDark ? 0.18 : 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.campaign_outlined,
                    color: Color(0xFF0284C7),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'NCERT Learning Partner',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.roboto(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF111827),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Offline textbooks, solutions & guides • Ad slot',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.roboto(
                          fontSize: 11,
                          color: isDark
                              ? const Color(0xFF777777)
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF222222)
                        : const Color(0xFFF1F1F4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF282828)
                          : const Color(0xFFE5E7EB),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    'Ad',
                    style: GoogleFonts.roboto(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? const Color(0xFF777777)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!AdService.isSupportedMobilePlatform) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ad = _bannerAd;

    if (_isLoaded && ad != null) {
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
                  style: GoogleFonts.roboto(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? const Color(0xFF777777)
                        : const Color(0xFF94A3B8),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF181818) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF282828)
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

    if (_adFailed) {
      return _buildFallbackSponsoredCard(isDark);
    }

    return const SizedBox.shrink();
  }
}
