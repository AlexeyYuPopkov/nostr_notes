import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';

import 'app_worker.dart';

final class AppWorkerImpl implements AppWorker {
  SendPort? _sendPort;
  Isolate? _isolate;
  Future<void>? _initializing;
  static StreamSubscription? _isolateSubscription;

  @override
  Future<void> init() {
    _initializing ??= _spawnIsolate();
    return _initializing!;
  }

  Future<void> _spawnIsolate() async {
    final receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_entryPoint, receivePort.sendPort);
    _sendPort = await receivePort.first as SendPort;
  }

  @override
  Future<R> compute<M, R>({
    required M params,
    required ComputeCallback<M, R> callback,
  }) async {
    if (_sendPort == null || _isolate == null) {
      if (_initializing == null) {
        await dispose();
      }
      await init();
    }

    assert(_sendPort != null, 'Call init() first');
    final completer = Completer<R>();
    final responsePort = RawReceivePort((dynamic response) {});
    responsePort.handler = (dynamic response) {
      responsePort.close();
      if (response is RemoteError) {
        completer.completeError(response);
      } else {
        completer.complete(response as R);
      }
    };
    _sendPort!.send((params, callback, responsePort.sendPort));

    return completer.future;
  }

  @override
  Future<void> dispose() async {
    _initializing = null;
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _sendPort = null;
    _isolateSubscription?.cancel();
    _isolateSubscription = null;
  }

  static void _entryPoint(SendPort sendPort) {
    final port = ReceivePort();
    sendPort.send(port.sendPort);

    _isolateSubscription?.cancel();
    _isolateSubscription = null;

    _isolateSubscription = port.listen((dynamic message) async {
      final (dynamic params, dynamic callback, SendPort replyPort) =
          message as (dynamic, dynamic, SendPort);

      try {
        final result = await callback(params);
        replyPort.send(result);
      } catch (e, st) {
        replyPort.send(RemoteError(e.toString(), st.toString()));
      }
    });
  }
}

final class AppWorkerWeb implements AppWorker {
  const AppWorkerWeb();
  @override
  Future<R> compute<M, R>({
    required M params,
    required ComputeCallback<M, R> callback,
  }) async {
    return callback(params);
  }

  @override
  Future<void> dispose() => Future.value();

  @override
  Future<void> init() => Future.value();
}
