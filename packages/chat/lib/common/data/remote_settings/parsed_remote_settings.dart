import 'package:chat/common/domain/remote_settings.dart';

/// Parameter keys in the Firebase console and their built-in defaults.
/// Listed in doc/firebase-plan.md.
abstract final class RemoteSettingsKeys {
  static const signalingUrl = 'signaling_url';
  static const stunUrls = 'stun_urls';
  static const turnUrls = 'turn_urls';
  static const callAnswerTimeoutSeconds = 'call_answer_timeout_seconds';
  static const callRelayOnly = 'call_relay_only';
  static const signalingClientName = 'signaling_client_name';
  static const chatRelay = 'chat_relay';
}

abstract final class RemoteSettingsDefaults {
  static const signalingUrl = 'wss://alekseiiapi.site:8086/ws';
  static const stunUrls = ['stun:alekseiiapi.site:3478'];
  static const turnUrls = [
    'turn:alekseiiapi.site:3478?transport=udp',
    'turn:alekseiiapi.site:3478?transport=tcp',
    'turns:alekseiiapi.site:443?transport=tcp',
  ];
  static const callAnswerTimeout = Duration(seconds: 45);
  static const callRelayOnly = false;
  static const signalingClientName = 'Mosty';
  static const chatRelay = 'wss://alekseiiapi.site:8443';
}

/// [RemoteSettings] parsed from raw strings, as Remote Config stores them.
///
/// A missing, empty or malformed value falls back to its default, so a typo
/// in the console never breaks calls. Lists are comma-separated.
final class ParsedRemoteSettings implements RemoteSettings {
  final String Function(String key) _read;

  const ParsedRemoteSettings(this._read);

  /// Only the built-in defaults; also what tests use.
  ParsedRemoteSettings.defaults() : _read = _noValue;

  @override
  Uri get signalingUri => _webSocketUri(
    RemoteSettingsKeys.signalingUrl,
    RemoteSettingsDefaults.signalingUrl,
  );

  @override
  Uri get chatRelay => _webSocketUri(
    RemoteSettingsKeys.chatRelay,
    RemoteSettingsDefaults.chatRelay,
  );

  @override
  List<String> get stunUrls =>
      _list(RemoteSettingsKeys.stunUrls) ?? RemoteSettingsDefaults.stunUrls;

  @override
  List<String> get turnUrls =>
      _list(RemoteSettingsKeys.turnUrls) ?? RemoteSettingsDefaults.turnUrls;

  @override
  Duration get callAnswerTimeout {
    final seconds = int.tryParse(
      _value(RemoteSettingsKeys.callAnswerTimeoutSeconds) ?? '',
    );
    return seconds != null && seconds > 0
        ? Duration(seconds: seconds)
        : RemoteSettingsDefaults.callAnswerTimeout;
  }

  @override
  bool get callRelayOnly =>
      switch (_value(RemoteSettingsKeys.callRelayOnly)?.toLowerCase()) {
        'true' => true,
        'false' => false,
        _ => RemoteSettingsDefaults.callRelayOnly,
      };

  @override
  String get signalingClientName =>
      _value(RemoteSettingsKeys.signalingClientName) ??
      RemoteSettingsDefaults.signalingClientName;

  Uri _webSocketUri(String key, String defaultUrl) {
    final uri = Uri.tryParse(_value(key) ?? '');
    final isWebSocket =
        uri != null &&
        uri.host.isNotEmpty &&
        (uri.isScheme('wss') || uri.isScheme('ws'));
    return isWebSocket ? uri : Uri.parse(defaultUrl);
  }

  String? _value(String key) {
    final value = _read(key).trim();
    return value.isEmpty ? null : value;
  }

  List<String>? _list(String key) {
    final items = (_value(key) ?? '')
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    return items.isEmpty ? null : items;
  }

  static String _noValue(String _) => '';
}
