part of 'crypto_service_impl_mobile.dart';

class Spec256k1Isolate implements Disposable {
  SendPort? _sendPort;
  Isolate? _isolate;

  Future<void> init() async {
    final receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_entryPoint, receivePort.sendPort);
    _sendPort = await receivePort.first as SendPort;
  }

  Future<Uint8List> compute({
    required Uint8List senderPrivateKey,
    required Uint8List recipientPublicKey,
  }) async {
    if (_sendPort == null || _isolate == null) {
      await dispose();
      await init();
    }

    assert(_sendPort != null, 'Call init() first');
    final completer = Completer<Uint8List>();
    final responsePort = RawReceivePort((dynamic response) {});
    responsePort.handler = (dynamic response) {
      responsePort.close();
      completer.complete(response as Uint8List);
    };
    _sendPort!.send((
      senderPrivateKey,
      recipientPublicKey,
      responsePort.sendPort,
    ));
    return completer.future;
  }

  @override
  Future<void> dispose() async {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _sendPort = null;
  }

  static void _entryPoint(SendPort mainSendPort) {
    final port = ReceivePort();
    mainSendPort.send(port.sendPort);

    const deriveKeys = DeriveKeys();

    port.listen((dynamic message) {
      final (Uint8List privateKey, Uint8List publicKey, SendPort replyPort) =
          message as (Uint8List, Uint8List, SendPort);

      final result = deriveKeys.spec256k1FromBytes(
        privateKeyBytes: privateKey,
        publicKeyBytes: publicKey,
      );
      replyPort.send(result);
    });
  }
}
