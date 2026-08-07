import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'login_item_details_params.g.dart';

@immutable
@JsonSerializable()
final class LoginItemDetailsParams extends Equatable {
  @JsonKey(name: 'id', defaultValue: '')
  final String id;
  @JsonKey(name: 'readonly', defaultValue: true)
  final bool readonly;

  bool get canEdit => !readonly;

  LoginItemDetailsParams({required this.id, required this.readonly})
    : assert((id.isEmpty && !readonly) || (id.isNotEmpty && readonly));

  factory LoginItemDetailsParams.fromJson(Map<String, dynamic> json) =>
      _$LoginItemDetailsParamsFromJson(json);

  Map<String, dynamic> toJson() => _$LoginItemDetailsParamsToJson(this);

  @override
  List<Object?> get props => [id, readonly];
}
