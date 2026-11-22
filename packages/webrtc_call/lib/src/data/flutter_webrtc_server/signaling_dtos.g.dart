// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signaling_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PeerDto _$PeerDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PeerDto', json, ($checkedConvert) {
      final val = PeerDto(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String? ?? ''),
        userAgent: $checkedConvert('user_agent', (v) => v as String? ?? ''),
      );
      return val;
    }, fieldKeyMap: const {'userAgent': 'user_agent'});

Map<String, dynamic> _$PeerDtoToJson(PeerDto instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'user_agent': instance.userAgent,
};

SessionDescriptionDto _$SessionDescriptionDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SessionDescriptionDto', json, ($checkedConvert) {
  final val = SessionDescriptionDto(
    sdp: $checkedConvert('sdp', (v) => v as String),
    type: $checkedConvert('type', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$SessionDescriptionDtoToJson(
  SessionDescriptionDto instance,
) => <String, dynamic>{'sdp': instance.sdp, 'type': instance.type};

IceCandidateDto _$IceCandidateDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('IceCandidateDto', json, ($checkedConvert) {
      final val = IceCandidateDto(
        candidate: $checkedConvert('candidate', (v) => v as String),
        sdpMid: $checkedConvert('sdpMid', (v) => v as String?),
        sdpMLineIndex: $checkedConvert(
          'sdpMLineIndex',
          (v) => (v as num?)?.toInt(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$IceCandidateDtoToJson(IceCandidateDto instance) =>
    <String, dynamic>{
      'candidate': instance.candidate,
      'sdpMid': instance.sdpMid,
      'sdpMLineIndex': instance.sdpMLineIndex,
    };
