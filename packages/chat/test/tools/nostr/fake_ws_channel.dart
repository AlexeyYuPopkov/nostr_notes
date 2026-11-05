import 'package:nostr/nostr_client/ws_channel.dart';
import 'package:rxdart/rxdart.dart';

/// In-memory relay socket: [onSend] sees every frame the client writes and
/// can answer through [receive].
final class FakeWsChannel implements WsChannel {
  @override
  final String url;

  void Function(String frame, FakeWsChannel channel)? onSend;

  final _incoming = PublishSubject<String>();

  FakeWsChannel({required this.url});

  void receive(String frame) => _incoming.add(frame);

  @override
  void add(dynamic data) => onSend?.call(data as String, this);

  @override
  Stream get stream => _incoming;

  @override
  Future disconnect() => _incoming.close();
}
