import 'package:di_storage/di_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';

import 'account_switcher_data.dart';
import 'account_switcher_event.dart';
import 'account_switcher_state.dart';

final class AccountSwitcherBloc
    extends Bloc<AccountSwitcherEvent, AccountSwitcherState> {
  AccountSwitcherData get data => state.data;
  late final sessionUsecase = DiStorage.shared.resolve<SessionUsecase>();

  AccountSwitcherBloc()
    : super(AccountSwitcherState.loading(data: AccountSwitcherData.initial())) {
    _setupHandlers();

    add(const AccountSwitcherEvent.initial());
  }

  void _setupHandlers() {
    on<InitialEvent>(_onInitialEvent);
  }

  void _onInitialEvent(InitialEvent event, Emitter<AccountSwitcherState> emit) {
    try {
      late final sessionUsecase = DiStorage.shared.resolve<SessionUsecase>();

      emit(
        AccountSwitcherState.common(
          data: data.copyWith(
            currentUserPubkey: sessionUsecase.currentSession.pubkey,
            // accounts: sessionUsecase.getAllSessions().map((e) => e.pubkey).toList(),
          ),
        ),
      );
    } catch (e) {
      emit(AccountSwitcherState.error(e: e, data: data));
    }
  }
}
