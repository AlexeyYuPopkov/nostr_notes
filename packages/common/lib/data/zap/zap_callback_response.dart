import 'package:json_annotation/json_annotation.dart';

part 'zap_callback_response.g.dart';

@JsonSerializable()
final class ZapCallbackResponse {
  const ZapCallbackResponse({
    this.pr,
    this.status,
    this.reason,
    this.error,
    this.message,
  });

  factory ZapCallbackResponse.fromJson(Map<String, dynamic> json) =>
      _$ZapCallbackResponseFromJson(json);

  /// The payment request (bolt11 invoice).
  final String? pr;

  /// Status field; "ERROR" indicates a LNURL-level error.
  final String? status;

  /// Human-readable error reason from LNURL error response.
  final String? reason;

  /// Some servers return `{"error": true, ...}` instead of `{"status": "ERROR"}`.
  final bool? error;

  /// Error message used with [error] == true.
  final String? message;

  Map<String, dynamic> toJson() => _$ZapCallbackResponseToJson(this);

  bool get isLnurlError => status == 'ERROR';

  bool get isGenericError => error == true;

  String get errorReason {
    if (isLnurlError) return reason ?? '';
    if (isGenericError) return message ?? reason ?? '';
    return '';
  }
}
