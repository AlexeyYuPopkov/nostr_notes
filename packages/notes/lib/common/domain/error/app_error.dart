import 'package:nostr_notes/common/domain/error/error_messages_provider.dart';

abstract class AppError implements Exception {
  String get message => '';
  final String reason;
  final Object? parentError;

  const AppError({this.reason = '', this.parentError});

  const factory AppError.notAuthenticated({
    Object? parentError,
    String reason,
  }) = NotAuthenticatedError;

  const factory AppError.notUnlocked({Object? parentError, String reason}) =
      NotUnlockedError;

  const factory AppError.common({
    required String message,
    Object? parentError,
    String reason,
  }) = CommonError;

  const factory AppError.undefined({Object? parentError, String reason}) =
      UndefinedError;

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
    final message = error is AppError && error.message.isNotEmpty
        ? error.message
        : null;

    return message;
  }
}

final class CommonError extends AppError {
  @override
  final String message;

  const CommonError({required this.message, super.parentError, super.reason});
}

final class UndefinedError extends AppError {
  const UndefinedError({super.parentError, super.reason});

  @override
  String get message => ErrorMessagesProvider.defaultProvider.commonError;
}

final class NotAuthenticatedError extends AppError {
  const NotAuthenticatedError({super.parentError, super.reason});

  @override
  String get message => ErrorMessagesProvider.defaultProvider.authError;
}

final class NotUnlockedError extends AppError {
  const NotUnlockedError({super.parentError, super.reason});

  @override
  String get message => ErrorMessagesProvider.defaultProvider.authError;
}
