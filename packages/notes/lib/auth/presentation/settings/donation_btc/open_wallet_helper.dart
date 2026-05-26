import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class OpenWalletHelper {
  static bool get isWebOrDesktop =>
      kIsWeb ||
      (!kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux));

  static Future<void> openLightningInvoice(
    BuildContext context, {
    required String lightningInvoice,
    required LightningApps? lightningApp,
  }) async {
    assert(isWebOrDesktop == false);
    final uriStr = kIsWeb || lightningApp == null
        ? 'lightning:$lightningInvoice'
        : '${lightningApp.uriPrefix}$lightningInvoice';

    final launched = await tryLaunchUri(uriStr);

    if (!launched) {
      if (lightningApp != null) {
        await tryLaunchUri(lightningApp.crossPlatformUri());
      } else {
        await tryLaunchUri(
          '${LightningApps.walletOfSatoshis.uriPrefix}$lightningInvoice',
        );
      }
    }
  }

  static Future<bool> tryLaunchUri(String urlStr) async {
    if (urlStr.isEmpty) return false;

    final uri = Uri.tryParse(urlStr);
    if (uri == null) return false;

    if (await canLaunchUrl(uri)) {
      final mode = kIsWeb
          ? LaunchMode.externalApplication
          : LaunchMode.platformDefault;
      await launchUrl(uri, mode: mode);
      return true;
    }

    return false;
  }
}

enum LightningApps {
  walletOfSatoshis('id1438599608', 'com.livingroomofsatoshi.wallet'),
  strike('1488724463', 'zapsolutions.strike'),
  muun('id1482037683', 'io.muun.apollo'),
  zebedee('id1484394401', 'io.zebedee.wallet'),
  bitcoinBeach('id1531383905', 'com.galoyapp'),
  blueWallet('id1376878040', 'io.bluewallet.bluewallet'),
  phoenix('id1544097028', 'fr.acinq.phoenix.mainnet'),
  breeze('id1463604142', 'com.breez.client'),
  zeus('id1456038895', 'app.zeusln.zeus'),
  cashApp('id711923939', 'com.squareup.cash');

  const LightningApps(this.id, this.appId);

  final String id;
  final String appId;

  String get displayName {
    return switch (this) {
      LightningApps.walletOfSatoshis => 'Wallet of satoshis',
      LightningApps.strike => 'Strike',
      LightningApps.muun => 'Muun',
      LightningApps.zebedee => 'Zebedee',
      LightningApps.bitcoinBeach => 'Bitcoin Beach',
      LightningApps.blueWallet => 'BlueWallet',
      LightningApps.phoenix => 'Phoenix',
      LightningApps.breeze => 'Breeze',
      LightningApps.zeus => 'Zeus',
      LightningApps.cashApp => 'Cash App',
    };
  }

  String get uriPrefix {
    return switch (this) {
      LightningApps.walletOfSatoshis => 'walletofsatoshi:lightning:',
      LightningApps.strike => 'strike://',
      LightningApps.muun => 'muun:',
      LightningApps.zebedee => 'zebedee:lightning:',
      LightningApps.bitcoinBeach => 'bitcoinbeach://',
      LightningApps.blueWallet => 'bluewallet:lightning://',
      LightningApps.phoenix => 'phoenix:',
      LightningApps.breeze => 'breez://',
      LightningApps.zeus => 'zeusln:lightning://',
      LightningApps.cashApp => 'cashapppay:',
    };
  }

  String get playStoreUri => 'market://details?id=$appId';

  String get appStoreUri => 'itms-apps://itunes.apple.com/app/$id';

  String crossPlatformUri() {
    if (!kIsWeb && Platform.isAndroid) {
      return playStoreUri;
    } else if (!kIsWeb && Platform.isIOS) {
      return appStoreUri;
    } else {
      return appStoreUri;
    }
  }
}
