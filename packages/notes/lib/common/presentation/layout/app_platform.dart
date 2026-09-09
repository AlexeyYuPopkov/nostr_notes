import 'package:flutter/foundation.dart';

final class AppPlatform {
  const AppPlatform();

  /// A native iOS or Android build. Deliberately false in a browser, even on
  /// a phone — the web build ships without the things that make a build
  /// "mobile" here (ads, store links, platform review flow).
  bool get isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  bool get isDesktopLayout => !isMobile;

  bool get isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
}
