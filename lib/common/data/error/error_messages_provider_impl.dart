import 'package:nostr_notes/common/data/root_context_provider/root_context_provider.dart';
import 'package:nostr_notes/common/domain/error/error_messages_provider.dart';

final class ErrorMessagesProviderImpl implements ErrorMessagesProvider {
  final RootContextProvider _rootContextProvider;

  const ErrorMessagesProviderImpl({
    required RootContextProvider rootContextProvider,
  }) : _rootContextProvider = rootContextProvider;

  @override
  String get commonError => _rootContextProvider.l10n.commonUndefinedError;

  @override
  String get authError => _rootContextProvider.l10n.authError;

  @override
  String get emptyNsec => _rootContextProvider.l10n.errorEmptyNsec;

  @override
  String get invalidNsecFormat =>
      _rootContextProvider.l10n.errorInvalidNsecFormat;

  @override
  String get emptyPubkey => _rootContextProvider.l10n.errorEmptyPubkey;

  @override
  String get emptyPin => _rootContextProvider.l10n.errorEmptyPin;

  @override
  String errorInvalidPinFormatMinCount(int minCount) {
    return _rootContextProvider.l10n.errorInvalidPinFormatMinCount(
      minCount.toString(),
    );
  }

  @override
  String get noteScreenNoteContentCannotBeEmpty =>
      _rootContextProvider.l10n.noteScreenErrorNoteContentCannotBeEmpty;

  @override
  String get errorPublishOperationTimedOut =>
      _rootContextProvider.l10n.errorPublishOperationTimedOut;
}
