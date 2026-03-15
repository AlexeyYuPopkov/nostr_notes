import 'package:nostr_notes/auth/domain/repo/desktop_ratio_repo.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';

final class DesktopRatioUsecase {
  final DesktopRatioRepo _repo;
  final SessionUsecase _sessionUsecase;

  const DesktopRatioUsecase({
    required DesktopRatioRepo repo,
    required SessionUsecase sessionUsecase,
  }) : _sessionUsecase = sessionUsecase,
       _repo = repo;

  double? get() {
    final pubkey = _sessionUsecase.currentSession.pubkey;
    return _repo.getForUser(pubkey);
  }

  Future<void> set(double ratio) async {
    final pubkey = _sessionUsecase.currentSession.pubkey;
    await _repo.setForUser(ratio, pubkey: pubkey);
  }
}
