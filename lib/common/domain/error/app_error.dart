abstract class AppError {
  String get message => '';
  final String reason;
  final Object? parentError;

  const AppError({
    this.reason = '',
    this.parentError,
  });

  @override
  String toString() {
    return [
      '$runtimeType:',
      if (message.isNotEmpty) message,
      if (reason.isNotEmpty) reason,
      if (parentError != null) parentError.toString(),
    ].join('\n');
  }

  static String? getMessageOrNull(Object error) {
    final message =
        error is AppError && error.message.isNotEmpty ? error.message : null;

    return message;
  }
}

final class CommonError extends AppError {
  @override
  final String message;

  const CommonError({
    required this.message,
    super.parentError,
    super.reason,
  });
}
