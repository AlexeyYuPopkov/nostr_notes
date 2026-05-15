// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zap_callback_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ZapCallbackResponse _$ZapCallbackResponseFromJson(Map<String, dynamic> json) =>
    ZapCallbackResponse(
      pr: json['pr'] as String?,
      status: json['status'] as String?,
      reason: json['reason'] as String?,
      error: json['error'] as bool?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$ZapCallbackResponseToJson(
  ZapCallbackResponse instance,
) => <String, dynamic>{
  'pr': instance.pr,
  'status': instance.status,
  'reason': instance.reason,
  'error': instance.error,
  'message': instance.message,
};
