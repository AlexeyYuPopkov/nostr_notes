import 'package:nostr_notes/common/domain/error/app_error.dart';
import 'package:nostr_notes/common/domain/error/error_messages_provider.dart';
import 'package:nostr_notes/core/tools/now.dart';
import 'package:uuid/uuid.dart';

abstract interface class EventPublisher {
  Future<EventPublisherResult> publishNote({
    required String content,
    required String publicKey,
    required String privateKey,
    required String? dTag,
    Now? now,
    Uuid? uuid,
    List<int>? randomBytes,
  });
}

final class EventPublisherResult {
  final List<PublishReport> reports;
  final PublishTimeoutError? timeoutError;

  const EventPublisherResult({
    required this.reports,
    required this.timeoutError,
  });
}

final class PublishReport {
  final String relay;
  final String errorMessage;

  const PublishReport({
    required this.relay,
    required this.errorMessage,
  });
}

final class PublishTimeoutError extends AppError {
  const PublishTimeoutError({
    super.parentError,
  }) : super(reason: 'Publish operation timed out');

  @override
  String get message =>
      ErrorMessagesProvider.defaultProvider.errorPublishOperationTimedOut;
}
