import 'package:nostr_notes/common/domain/error/error_messages_provider.dart';

final class MockErrorMessagesProvider implements ErrorMessagesProvider {
  @override
  final String authError;
  @override
  final String commonError;
  @override
  final String emptyNsec;
  @override
  final String emptyPin;
  @override
  final String emptyPubkey;
  @override
  final String errorPublishOperationTimedOut;
  @override
  final String invalidNsecFormat;
  @override
  final String notUnlocked;
  @override
  final String noteScreenNoteContentCannotBeEmpty;

  const MockErrorMessagesProvider({
    this.authError = 'authError',
    this.commonError = 'commonError',
    this.emptyNsec = 'emptyNsec',
    this.emptyPin = 'emptyPin',
    this.emptyPubkey = 'emptyPubkey',
    this.errorPublishOperationTimedOut = 'errorPublishOperationTimedOut',
    this.invalidNsecFormat = 'invalidNsecFormat',
    this.notUnlocked = 'notUnlocked',
    this.noteScreenNoteContentCannotBeEmpty =
        'noteScreenNoteContentCannotBeEmpty',
  });

  @override
  String errorInvalidPinFormatMinCount(int minCount) {
    return 'Invalid pin format, minimum count is $minCount';
  }
}
