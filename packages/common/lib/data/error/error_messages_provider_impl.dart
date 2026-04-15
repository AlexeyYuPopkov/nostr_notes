import 'package:common/domain/error/error_messages_provider.dart';
import 'package:common/presentation/tools/root_context_provider/root_context_provider.dart';

final class ErrorMessagesProviderImpl implements ErrorMessagesProvider {
  // ignore: unused_field
  final RootContextProvider _rootContextProvider;

  const ErrorMessagesProviderImpl({
    required RootContextProvider rootContextProvider,
  }) : _rootContextProvider = rootContextProvider;

  // TODO: localize these messages
  @override
  String get commonError => 'Something went wrong';

  @override
  String get authError => 'Authentication error';

  @override
  String get notUnlocked => 'The app is not unlocked';

  @override
  String get emptyNsec => 'NSEC key cannot be empty';

  @override
  String get invalidNsecFormat => 'Invalid NSEC key format';

  @override
  String get emptyPubkey => 'Public key cannot be empty';

  @override
  String get emptyPin => 'PIN or password cannot be empty';

  @override
  String errorInvalidPinFormatMinCount(int minCount) {
    return 'PIN or password must be at least ${minCount.toString()} characters long';
  }

  @override
  String get noteScreenNoteContentCannotBeEmpty =>
      'Note content cannot be empty';
  // _rootContextProvider.l10n.noteScreenErrorNoteContentCannotBeEmpty;

  @override
  String get errorPublishOperationTimedOut => 'Publish operation timed out';
  // _rootContextProvider.l10n.errorPublishOperationTimedOut;
}
