import 'package:flutter/foundation.dart';

import 'signaling_message.dart';

enum SignalingConnectionState { disconnected, connecting, connected }

/// Transport for call negotiation, independent of the server behind it.
abstract interface class SignalingChannel {
  ValueListenable<SignalingConnectionState> get connectionState;

  /// Incoming messages; transport keep-alives are not delivered here.
  Stream<SignalingMessage> get messages;

  /// Throws [ArgumentError] when [self]'s id is not valid for this transport.
  Future<void> connect({required SignalingPeer self});

  void send(SignalingMessage message);

  /// Session id for a call [callerId] starts with [calleeId].
  String sessionIdFor({required String callerId, required String calleeId});

  Future<void> disconnect();

  Future<void> dispose();
}
