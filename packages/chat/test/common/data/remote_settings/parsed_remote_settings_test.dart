import 'package:chat/common/data/remote_settings/parsed_remote_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ParsedRemoteSettings settingsWith(Map<String, String> values) =>
      ParsedRemoteSettings((key) => values[key] ?? '');

  test('without values every setting is its default', () {
    final settings = ParsedRemoteSettings.defaults();

    expect(
      settings.signalingUri,
      Uri.parse(RemoteSettingsDefaults.signalingUrl),
    );
    expect(settings.stunUrls, RemoteSettingsDefaults.stunUrls);
    expect(settings.turnUrls, RemoteSettingsDefaults.turnUrls);
    expect(
      settings.callAnswerTimeout,
      RemoteSettingsDefaults.callAnswerTimeout,
    );
    expect(settings.callRelayOnly, RemoteSettingsDefaults.callRelayOnly);
    expect(
      settings.signalingClientName,
      RemoteSettingsDefaults.signalingClientName,
    );
    expect(settings.chatRelay, Uri.parse(RemoteSettingsDefaults.chatRelay));
  });

  test('remote values override the defaults', () {
    final settings = settingsWith({
      RemoteSettingsKeys.signalingUrl: 'wss://signaling.test/ws',
      RemoteSettingsKeys.stunUrls: 'stun:a.test:3478, stun:b.test:3478',
      RemoteSettingsKeys.turnUrls: 'turn:t.test:3478',
      RemoteSettingsKeys.callAnswerTimeoutSeconds: '30',
      RemoteSettingsKeys.callRelayOnly: 'TRUE',
      RemoteSettingsKeys.signalingClientName: 'Mosty beta',
      RemoteSettingsKeys.chatRelay: 'wss://relay.test',
    });

    expect(settings.signalingUri, Uri.parse('wss://signaling.test/ws'));
    expect(settings.chatRelay, Uri.parse('wss://relay.test'));
    expect(settings.stunUrls, ['stun:a.test:3478', 'stun:b.test:3478']);
    expect(settings.turnUrls, ['turn:t.test:3478']);
    expect(settings.callAnswerTimeout, const Duration(seconds: 30));
    expect(settings.callRelayOnly, isTrue);
    expect(settings.signalingClientName, 'Mosty beta');
  });

  test('malformed values fall back to the defaults', () {
    final settings = settingsWith({
      RemoteSettingsKeys.signalingUrl: 'https://not-a-socket.test',
      RemoteSettingsKeys.stunUrls: ' , ',
      RemoteSettingsKeys.callAnswerTimeoutSeconds: '-5',
      RemoteSettingsKeys.callRelayOnly: 'yes',
      RemoteSettingsKeys.signalingClientName: '   ',
      RemoteSettingsKeys.chatRelay: 'wss://',
    });

    expect(
      settings.signalingUri,
      Uri.parse(RemoteSettingsDefaults.signalingUrl),
    );
    expect(settings.stunUrls, RemoteSettingsDefaults.stunUrls);
    expect(
      settings.callAnswerTimeout,
      RemoteSettingsDefaults.callAnswerTimeout,
    );
    expect(settings.callRelayOnly, RemoteSettingsDefaults.callRelayOnly);
    expect(
      settings.signalingClientName,
      RemoteSettingsDefaults.signalingClientName,
    );
    expect(settings.chatRelay, Uri.parse(RemoteSettingsDefaults.chatRelay));
  });
}
