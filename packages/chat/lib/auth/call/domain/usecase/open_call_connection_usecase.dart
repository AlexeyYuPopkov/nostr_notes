import 'package:webrtc_call/webrtc_call.dart';

/// The current user on the signaling server, with a call session on top.
abstract interface class CallConnection {
  PeerConnectionSession get session;

  /// Ends any call and leaves the signaling server.
  Future<void> close();
}

abstract interface class OpenCallConnectionUsecase {
  /// Joins signaling as the current user; [CallConnection.session] is ready
  /// to place a call.
  Future<CallConnection> execute();
}
