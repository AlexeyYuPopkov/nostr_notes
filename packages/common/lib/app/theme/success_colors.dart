import 'package:flutter/material.dart';

@immutable
class SuccessColors extends ThemeExtension<SuccessColors> {
  final Color success;
  final Color onSuccess;

  const SuccessColors({required this.success, required this.onSuccess});

  static const light = SuccessColors(
    success: Color(0xFF34A853),
    onSuccess: Colors.white,
  );

  static const dark = SuccessColors(
    success: Color(0xFF81C784),
    onSuccess: Colors.black,
  );

  @override
  SuccessColors copyWith({Color? success, Color? onSuccess}) {
    return SuccessColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
    );
  }

  @override
  SuccessColors lerp(ThemeExtension<SuccessColors>? other, double t) {
    if (other is! SuccessColors) return this;
    return SuccessColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
    );
  }
}
