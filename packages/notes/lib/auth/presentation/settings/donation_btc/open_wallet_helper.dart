import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class OpenWalletHelper {
  static bool get isWebOrDesktop =>
      kIsWeb ||
      (!kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux));

  static Future<bool> openLightningInvoice({required String lightningInvoice}) {
    if (isWebOrDesktop) return Future.value(false);
    return tryLaunchUri('lightning:$lightningInvoice');
  }

  static Future<bool> tryLaunchUri(String urlStr) async {
    if (urlStr.isEmpty) return false;

    final uri = Uri.tryParse(urlStr);
    if (uri == null) return false;

    try {
      const mode = kIsWeb
          ? LaunchMode.externalApplication
          : LaunchMode.platformDefault;
      return await launchUrl(uri, mode: mode);
    } catch (_) {
      return false;
    }
  }
}
