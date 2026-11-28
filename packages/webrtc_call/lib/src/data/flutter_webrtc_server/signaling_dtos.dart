import 'package:json_annotation/json_annotation.dart';

import '../../domain/signaling_message.dart';

part 'signaling_dtos.g.dart';

@JsonSerializable(checked: true, fieldRename: FieldRename.snake)
final class PeerDto {
  final String id;
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(defaultValue: '')
  final String userAgent;

  const PeerDto({required this.id, this.name = '', this.userAgent = ''});

  factory PeerDto.fromJson(Map<String, Object?> json) =>
      _$PeerDtoFromJson(json);

  factory PeerDto.fromDomain(SignalingPeer peer) =>
      PeerDto(id: peer.id, name: peer.name, userAgent: peer.userAgent);

  Map<String, Object?> toJson() => _$PeerDtoToJson(this);

  SignalingPeer toDomain() =>
      SignalingPeer(id: id, name: name, userAgent: userAgent);
}

@JsonSerializable(checked: true)
final class SessionDescriptionDto {
  final String sdp;
  final String type;

  const SessionDescriptionDto({required this.sdp, required this.type});

  factory SessionDescriptionDto.fromJson(Map<String, Object?> json) =>
      _$SessionDescriptionDtoFromJson(json);

  factory SessionDescriptionDto.fromDomain(SessionDescription description) =>
      SessionDescriptionDto(sdp: description.sdp, type: description.type);

  Map<String, Object?> toJson() => _$SessionDescriptionDtoToJson(this);

  SessionDescription toDomain() => SessionDescription(sdp: sdp, type: type);
}

@JsonSerializable(checked: true)
final class IceCandidateDto {
  final String candidate;
  final String? sdpMid;
  final int? sdpMLineIndex;

  const IceCandidateDto({
    required this.candidate,
    this.sdpMid,
    this.sdpMLineIndex,
  });

  factory IceCandidateDto.fromJson(Map<String, Object?> json) =>
      _$IceCandidateDtoFromJson(json);

  factory IceCandidateDto.fromDomain(IceCandidate candidate) => IceCandidateDto(
    candidate: candidate.candidate,
    sdpMid: candidate.sdpMid,
    sdpMLineIndex: candidate.sdpMLineIndex,
  );

  Map<String, Object?> toJson() => _$IceCandidateDtoToJson(this);

  IceCandidate toDomain() => IceCandidate(
    candidate: candidate,
    sdpMid: sdpMid,
    sdpMLineIndex: sdpMLineIndex,
  );
}
