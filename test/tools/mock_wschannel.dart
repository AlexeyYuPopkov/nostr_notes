import 'package:nostr_notes/services/nostr_client/ws_channel.dart';
import 'package:rxdart/rxdart.dart';

final class MockWSChannel implements WsChannel {
  final String _url;

  final List<MapEntry<String, dynamic>> calls = [];

  void Function(dynamic data, MockWSChannel channel)? onAdd;

  MockWSChannel({required String url}) : _url = url;

  final mockStream = PublishSubject<String>();

  @override
  void add(data) {
    calls.add(MapEntry('add', data));
    onAdd?.call(data, this);
  }

  @override
  Future disconnect() async {
    calls.add(const MapEntry('disconnect', ''));
  }

  @override
  Future<void> get ready async {
    calls.add(const MapEntry('ready', ''));
  }

  @override
  Stream get stream {
    calls.add(const MapEntry('stream', ''));
    return mockStream;
  }

  @override
  String get url {
    return _url;
  }

  int verifyAddCalled() => _getCallsCount('add');
  int verifyReadyCalled() => _getCallsCount('ready');
  int verifyStreamCalled() => _getCallsCount('stream');
  int verifyDisconnectCalled() => _getCallsCount('disconnect');

  int _getCallsCount(String methodName) {
    return calls.where((e) => e.key == methodName).length;
  }
}
