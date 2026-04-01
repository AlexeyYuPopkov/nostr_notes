import 'package:flutter/foundation.dart';

final class AppPlatform {
  const AppPlatform();

  bool get isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  bool get isDesktopLayout => !isMobile;
}
