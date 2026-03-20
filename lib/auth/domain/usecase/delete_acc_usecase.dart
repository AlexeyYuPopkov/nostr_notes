import 'package:nostr_notes/auth/domain/repo/notes_repository.dart';
import 'package:nostr_notes/auth/domain/repo/relays_list_repo.dart';
import 'package:nostr_notes/common/domain/error/app_error.dart';
import 'package:nostr_notes/common/domain/usecase/auth_usecase.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/services/nostr_client/publish_event_report.dart';

final class DeleteAccUsecase {
  final SessionUsecase _sessionUsecase;
  final NotesRepository _notesRepository;
  final RelaysListRepo _relaysListRepo;
  final AuthUsecase _authUsecase;

  const DeleteAccUsecase({
    required NotesRepository notesRepository,
    required SessionUsecase sessionUsecase,
    required RelaysListRepo relaysListRepo,
    required AuthUsecase authUsecase,
  }) : _sessionUsecase = sessionUsecase,
       _notesRepository = notesRepository,
       _relaysListRepo = relaysListRepo,
       _authUsecase = authUsecase;

  Stream<DeleteAccStatus> execute([Duration dalay = Duration.zero]) async* {
    final pubkey = _sessionUsecase.currentSession.pubkey;
    final privateKey = _sessionUsecase.currentSession.keys?.privateKey;

    if (pubkey.isEmpty || privateKey == null || privateKey.isEmpty) {
      throw const AppError.notAuthenticated();
    }

    yield DeleteAccStatus.preparing;

    try {
      final aTags = await Future.wait([
        _notesRepository.collectATags(pubkey: pubkey),
        Future.delayed(dalay),
      ]).then((results) => results.first as ATagsAndIds);

      yield DeleteAccStatus.kind5Publishing;
      final report = await Future.wait([
        _notesRepository.deletionRequest(
          aTags: aTags,
          publicKey: pubkey,
          privateKey: privateKey,
          relays: _relaysListRepo.getRelaysList().toSet(),
        ),
        Future.delayed(dalay),
      ]).then((results) => results.first as PublishEventReport?);

      if (report != null) {
        if (!report.isAnySuccess) {
          throw const AppError.common(
            message: 'Failed to publish deletion event',
          );
        }
      }

      yield DeleteAccStatus.clearLocalStorages;
      await Future.wait([
        _notesRepository.clearLocalStorages(aTags: aTags, pubkey: pubkey),
        Future.delayed(dalay),
      ]);
      yield DeleteAccStatus.logout;
      await Future.delayed(dalay);
      await _authUsecase.logout();
    } catch (e) {
      throw DeleteAccError(parent: e);
    }
  }
}

enum DeleteAccStatus {
  preparing,
  kind5Publishing,
  clearLocalStorages,
  logout;

  static List<DeleteAccStatus> steps = [
    DeleteAccStatus.preparing,
    DeleteAccStatus.kind5Publishing,
    DeleteAccStatus.clearLocalStorages,
    DeleteAccStatus.logout,
  ];

  bool isCompleted(DeleteAccStatus status) =>
      steps.indexOf(status) < steps.indexOf(this);

  bool isExecuting(DeleteAccStatus status) => status == this;
}

final class DeleteAccError implements Exception {
  final Object parent;
  const DeleteAccError({required this.parent});

  String get message => 'DeleteAccError: ${parent.toString()}';
}
