import 'package:nostr_notes/common/domain/error/app_error.dart';
import 'package:nostr_notes/common/domain/error/error_messages_provider.dart';
import 'package:nostr_notes/common/domain/model/session/session.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';

final class PinUsecase {
  static const minLength = 4;
  final SessionUsecase _sessionUsecase;

  const PinUsecase({required SessionUsecase sessionUsecase})
      : _sessionUsecase = sessionUsecase;

  Future<void> execute({required String pin}) async {
    final validationError = validate(pin);
    if (validationError != null) {
      throw validationError;
    }

    final session = _sessionUsecase.currentSession;
    switch (session) {
      case Unauth():
        throw const AppError.notAuthenticated();

      case Auth():
        _sessionUsecase.setSession(
          session.toUnlocked(pin: pin.trim()),
        );
        break;
      case Unlocked():
        assert(false, 'Session should not be Unlocked when setting a pin');
        return;
    }
  }

  PinError? validate(String? pin) {
    if (pin == null || pin.isEmpty) {
      return const PinErrorEmpty();
    }
    final pinTrimmed = pin.trim();

    if (pinTrimmed.isEmpty) {
      return const PinErrorEmpty();
    }

    if (pinTrimmed.length < minLength) {
      return const PinErrorMinLength(minLength);
    }

    return null;
  }
}

abstract class PinError extends AppError {
  const PinError({required super.reason});
}

final class PinErrorEmpty extends PinError {
  const PinErrorEmpty() : super(reason: 'Invalid PIN format');

  // @override
  // String get message => ErrorMessagesProvider.defaultProvider.errorEmptyPin;

  @override
  String get message => ErrorMessagesProvider.defaultProvider.emptyPubkey;
}

final class PinErrorMinLength extends PinError {
  final int expectedMinCount;
  const PinErrorMinLength(this.expectedMinCount)
      : super(
          reason:
              'PIN must be at least ${PinUsecase.minLength} characters long',
        );

  @override
  String get message => ErrorMessagesProvider.defaultProvider
      .errorInvalidPinFormatMinCount(expectedMinCount);
}
