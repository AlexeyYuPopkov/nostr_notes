import 'package:equatable/equatable.dart';
import 'package:webrtc_call/webrtc_call.dart';

import 'call_data.dart';

sealed class CallState extends Equatable {
  final CallData data;

  const CallState({required this.data});

  CallState withData(CallData data);

  @override
  List<Object?> get props => [data];
}

/// Joining the signaling server.
final class CallStarting extends CallState {
  const CallStarting({required super.data});

  @override
  CallState withData(CallData data) => CallStarting(data: data);
}

/// The call itself; its progress is in [session].
final class CallActive extends CallState {
  final PeerConnectionSession session;

  const CallActive({required super.data, required this.session});

  @override
  CallState withData(CallData data) => CallActive(data: data, session: session);

  @override
  List<Object?> get props => [data, session];
}

final class CallStartError extends CallState {
  final Object error;

  const CallStartError({required super.data, required this.error});

  @override
  CallState withData(CallData data) => CallStartError(data: data, error: error);

  @override
  List<Object?> get props => [data, error];
}
