import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'onboarding_screen_params.g.dart';

@immutable
@JsonSerializable()
final class OnboardingScreenParams {
  @JsonKey(name: 'addAccount', defaultValue: false)
  /// When true, the screen is pushed on top of an unlocked session to add
  /// one more account. Until the new nsec is submitted, the current session
  /// stays untouched and the screen can simply be popped.
  final bool addAccount;

  const OnboardingScreenParams({required this.addAccount});

  factory OnboardingScreenParams.fromJson(Map<String, dynamic> json) =>
      _$OnboardingScreenParamsFromJson(json);

  Map<String, dynamic> toJson() => _$OnboardingScreenParamsToJson(this);
}
