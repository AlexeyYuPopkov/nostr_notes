import 'dart:developer';
import 'dart:io';

import 'package:common/app/theme/sizes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nostr_notes/app/app_config.dart';

final class AdBanner extends StatefulWidget {
  static const defaultMaxHeight = 133;

  final int maxHeight;
  final BorderRadius borderRadius;

  const AdBanner({
    super.key,
    this.maxHeight = defaultMaxHeight,
    this.borderRadius = const BorderRadius.all(Radius.circular(Sizes.radius)),
  });

  static bool get isSupported =>
      AppConfig.showAds && !kIsWeb && (Platform.isIOS || Platform.isAndroid);

  @override
  State<AdBanner> createState() => _AdBannerState();
}

final class _AdBannerState extends State<AdBanner> {
  static final String _bannerId = Platform.isIOS
      ? AppConfig.admobBannerIdIos
      : AppConfig.admobBannerIdAndroid;

  BannerAd? _ad;
  AdSize? _loadedSize;
  double? _requestedWidth;

  @override
  void didUpdateWidget(AdBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.maxHeight != widget.maxHeight) {
      // The cap is baked into the request, so a new one is needed.
      _requestedWidth = null;
    }
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  /// Reloads only when the usable width actually changes — rotation or a
  /// window resize — since the ad size is derived from it.
  void _loadFor(double width) {
    final rounded = width.truncateToDouble();
    if (_requestedWidth == rounded) return;
    _requestedWidth = rounded;

    _ad?.dispose();
    _ad = null;
    _loadedSize = null;

    final ad = BannerAd(
      adUnitId: _bannerId,
      size: AdSize.getInlineAdaptiveBannerAdSize(
        rounded.toInt(),
        widget.maxHeight,
      ),
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) async {
          final size = await (ad as BannerAd).getPlatformAdSize();
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() => _loadedSize = size);
        },
        onAdFailedToLoad: (ad, error) {
          log('Failed to load banner: $error', name: 'AdBanner');
          ad.dispose();
          if (identical(_ad, ad)) _ad = null;
        },
      ),
    );
    _ad = ad;
    ad.load();
  }

  @override
  Widget build(BuildContext context) {
    if (!AdBanner.isSupported) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width.isFinite && width > 0) {
          // Deferred: load() must not run while this frame is laying out.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _loadFor(width);
          });
        }

        final ad = _ad;
        final size = _loadedSize;
        if (ad == null || size == null) return const SizedBox.shrink();

        // Corners only. AdMob requires the creative itself to stay fully
        // visible, so this must not grow into cropping or overlaying.
        return ClipRRect(
          borderRadius: widget.borderRadius,
          child: SizedBox(
            width: size.width.toDouble(),
            height: size.height.toDouble(),
            child: AdWidget(ad: ad),
          ),
        );
      },
    );
  }
}
