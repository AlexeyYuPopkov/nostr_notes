import 'package:equatable/equatable.dart';
import 'package:nostr_notes/common/domain/error/app_error.dart';
import 'package:nostr_notes/common/domain/model/session/session.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/services/key_tool/key_tool.dart';

final class CredentialsDataUsecase {
  final SessionUsecase _session;

  const CredentialsDataUsecase({required SessionUsecase session})
    : _session = session;

  Future<CredentialsData> execute() async {
    final session = _session.currentSession;

    if (session is! Unlocked) {
      throw const AppError.notAuthenticated();
    }
    final keys = session.keys;

    final data = CredentialsData(
      nsec: KeyTool.nsecKey(keys.privateKey),
      publicKey: keys.publicKey,
      privateKey: keys.privateKey,
      pin: session.pin,
    );

    return data;
  }
}

final class CredentialsData extends Equatable {
  final String publicKey;
  final String privateKey;
  final String nsec;
  final String pin;

  const CredentialsData({
    required this.publicKey,
    required this.privateKey,
    required this.nsec,
    required this.pin,
  });

  @override
  List<Object?> get props => [publicKey, privateKey, nsec, pin];
}
