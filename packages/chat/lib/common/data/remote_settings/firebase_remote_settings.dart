import 'dart:async';

import 'package:chat/common/data/remote_settings/parsed_remote_settings.dart';
import 'package:chat/common/domain/remote_settings.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

abstract final class FirebaseRemoteSettings {
  static const _fetchTimeout = Duration(seconds: 10);
  static const _releaseFetchInterval = Duration(hours: 1);

  /// Applies the values fetched on a previous launch and fetches fresh ones
  /// in the background for the next launch, so startup never waits for the
  /// network and values don't change under a running app.
  static Future<RemoteSettings> load(FirebaseRemoteConfig config) async {
    try {
      await config.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: _fetchTimeout,
          minimumFetchInterval: kDebugMode
              ? Duration.zero
              : _releaseFetchInterval,
        ),
      );
      await config.activate();
      unawaited(
        config.fetch().catchError(
          (Object error) => debugPrint('[RemoteSettings] fetch failed: $error'),
        ),
      );
      return ParsedRemoteSettings(config.getString);
    } catch (error) {
      debugPrint('[RemoteSettings] using defaults: $error');
      return ParsedRemoteSettings.defaults();
    }
  }
}
