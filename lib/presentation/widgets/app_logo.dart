import 'package:flutter/material.dart';

/// Brand logo. [AppLogo.full] includes the "AL NOOR QURAN" wordmark;
/// [AppLogo.mark] is the emblem alone, for small spots.
class AppLogo extends StatelessWidget {
  const AppLogo.full({super.key, required this.size}) : _asset = fullAsset, _radius = 0.22;
  const AppLogo.mark({super.key, required this.size}) : _asset = markAsset, _radius = 0.5;

  static const fullAsset = 'assets/brand/logo_full.png';
  static const markAsset = 'assets/brand/logo_mark.png';

  final double size;
  final String _asset;
  final double _radius;

  static Future<void> precache(BuildContext context) => Future.wait([
        precacheImage(const AssetImage(fullAsset), context),
        precacheImage(const AssetImage(markAsset), context),
      ]);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * _radius),
      child: Image.asset(
        _asset,
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        isAntiAlias: true,
        cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round().clamp(1, 1024),
      ),
    );
  }
}
