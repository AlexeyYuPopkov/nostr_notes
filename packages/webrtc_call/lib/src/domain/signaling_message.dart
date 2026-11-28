import 'package:equatable/equatable.dart';

enum CallMedia { audio, video }

final class SignalingPeer extends Equatable {
  final String id;
  final String name;
  final String userAgent;

  const SignalingPeer({
    required this.id,
    required this.name,
    required this.userAgent,
  });

  @override
  List<Object?> get props => [id, name, userAgent];
}

final class SessionDescription extends Equatable {
  final String sdp;

  /// `offer` or `answer`, as WebRTC reports it.
  final String type;

  const SessionDescription({required this.sdp, required this.type});

  @override
  List<Object?> get props => [sdp, type];
}

final class IceCandidate extends Equatable {
  final String candidate;
  final String? sdpMid;
  final int? sdpMLineIndex;

  const IceCandidate({
    required this.candidate,
    required this.sdpMid,
    required this.sdpMLineIndex,
  });

  @override
  List<Object?> get props => [candidate, sdpMid, sdpMLineIndex];
}

sealed class SignalingMessage extends Equatable {
  const SignalingMessage();
}

/// Everyone currently connected to the signaling server, the receiver included.
final class SignalingPeers extends SignalingMessage {
  final Set<SignalingPeer> peers;

  const SignalingPeers(this.peers);

  @override
  List<Object?> get props => [peers];
}

/// A message addressed from one peer to another within one call.
sealed class SignalingNegotiation extends SignalingMessage {
  final String from;
  final String to;
  final String sessionId;

  const SignalingNegotiation({
    required this.from,
    required this.to,
    required this.sessionId,
  });
}

final class SignalingOffer extends SignalingNegotiation {
  final CallMedia media;
  final SessionDescription description;

  const SignalingOffer({
    required super.from,
    required super.to,
    required super.sessionId,
    required this.media,
    required this.description,
  });

  @override
  List<Object?> get props => [from, to, sessionId, media, description];
}

final class SignalingAnswer extends SignalingNegotiation {
  final SessionDescription description;

  const SignalingAnswer({
    required super.from,
    required super.to,
    required super.sessionId,
    required this.description,
  });

  @override
  List<Object?> get props => [from, to, sessionId, description];
}

final class SignalingCandidate extends SignalingNegotiation {
  final IceCandidate candidate;

  const SignalingCandidate({
    required super.from,
    required super.to,
    required super.sessionId,
    required this.candidate,
  });

  @override
  List<Object?> get props => [from, to, sessionId, candidate];
}

/// Ends the call [sessionId]; both sides receive it, the sender too.
final class SignalingBye extends SignalingMessage {
  final String sessionId;

  const SignalingBye({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

/// The server could not handle a message, e.g. the addressee is offline.
final class SignalingError extends SignalingMessage {
  final String request;
  final String reason;

  const SignalingError({required this.request, required this.reason});

  @override
  List<Object?> get props => [request, reason];
}
