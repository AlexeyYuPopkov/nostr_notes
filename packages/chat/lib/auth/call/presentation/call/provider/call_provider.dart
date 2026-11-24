import 'dart:async';

import 'package:chat/auth/call/domain/usecase/open_call_connection_usecase.dart';
import 'package:chat/auth/chat/domain/usecase/get_contact_usecase.dart';
import 'package:common/domain/model/user.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:webrtc_call/webrtc_call.dart';

import 'call_data.dart';
import 'call_state.dart';

part 'call_provider.g.dart';

/// An outgoing call to [peerPubkey]; it ends when the provider is disposed.
@riverpod
final class CallProvider extends _$CallProvider {
  late final OpenCallConnectionUsecase _openConnection = GetIt.I.get();
  late final GetContactUsecase _getContact = GetIt.I.get();
  CallConnection? _connection;

  @override
  CallState build(String peerPubkey, CallMedia media) {
    final peer = _getContact
        .execute(peerPubkey)
        .listen(
          (peer) => state = state.withData(state.data.copyWith(peer: peer)),
          // Without a profile the call goes on under the short npub.
          onError: (Object _) {},
        );
    ref.onDispose(() {
      unawaited(peer.cancel());
      unawaited(_connection?.close());
    });
    unawaited(_start());

    return CallStarting(
      data: CallData(
        peer: User(pubkey: peerPubkey),
        media: media,
      ),
    );
  }

  Future<void> _start() async {
    try {
      final connection = await _openConnection.execute();
      if (!ref.mounted) {
        await connection.close();
        return;
      }
      _connection = connection;
      state = CallActive(data: state.data, session: connection.session);
      await connection.session.call(peerPubkey, media: media);
    } catch (error) {
      if (!ref.mounted) return;
      state = CallStartError(data: state.data, error: error);
    }
  }
}
