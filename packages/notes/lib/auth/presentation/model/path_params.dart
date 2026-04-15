import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'path_params.g.dart';

@immutable
@JsonSerializable()
final class PathParams {
  @JsonKey(name: 'id', defaultValue: '')
  final String id;

  const PathParams({required this.id});

  factory PathParams.fromJson(Map<String, dynamic> json) =>
      _$PathParamsFromJson(json);

  Map<String, dynamic> toJson() => _$PathParamsToJson(this);
}

@immutable
@JsonSerializable()
final class PathParamsEventId {
  @JsonKey(name: 'eventId', defaultValue: '')
  final String eventId;

  const PathParamsEventId({required this.eventId});

  factory PathParamsEventId.fromJson(Map<String, dynamic> json) =>
      _$PathParamsEventIdFromJson(json);

  Map<String, dynamic> toJson() => _$PathParamsEventIdToJson(this);
}
