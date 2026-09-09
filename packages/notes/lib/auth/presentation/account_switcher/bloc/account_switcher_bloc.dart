import 'package:di_storage/di_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/auth/domain/repo/accounts_repo.dart';
import 'package:nostr_notes/common/domain/usecase/auth_usecase.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';

import 'account_switcher_data.dart';
import 'account_switcher_event.dart';
import 'account_switcher_state.dart';

final class AccountSwitcherBloc
    extends Bloc<AccountSwitcherEvent, AccountSwitcherState> {
  AccountSwitcherData get data => state.data;
  DiStorage get _di => DiStorage.shared;

  late final SessionUsecase sessionUsecase = _di.resolve();
  late final AuthUsecase authUsecase = _di.resolve();
  late final AccountsRepo accountsRepo = _di.resolve();

  AccountSwitcherBloc()
    : super(AccountSwitcherState.loading(data: AccountSwitcherData.initial())) {
    _setupHandlers();

    add(const AccountSwitcherEvent.initial());
  }

  void _setupHandlers() {
    on<InitialEvent>(_onInitialEvent);
    on<SwitchAccountEvent>(_onSwitchAccountEvent);
  }

  void _onInitialEvent(InitialEvent event, Emitter<AccountSwitcherState> emit) {
    try {
      final currentPubkey = sessionUsecase.currentSession.pubkey;
      final accounts = accountsRepo.getAccounts();
      // Accounts stored before the multi-account registry appeared are only
      // known through the active session.
      final allAccounts =
          currentPubkey.isEmpty || accounts.contains(currentPubkey)
          ? accounts
          : [currentPubkey, ...accounts];

      emit(
        AccountSwitcherState.common(
          data: data.copyWith(
            currentUserPubkey: currentPubkey,
            accounts: allAccounts,
          ),
        ),
      );
    } catch (e) {
      emit(AccountSwitcherState.error(e: e, data: data));
    }
  }

  Future<void> _onSwitchAccountEvent(
    SwitchAccountEvent event,
    Emitter<AccountSwitcherState> emit,
  ) async {
    if (event.pubkey == data.currentUserPubkey) {
      return;
    }

    try {
      emit(AccountSwitcherState.loading(data: data));

      // Locks the session with the selected account's keys; the router
      // reacts by sending the user to the PIN step to unlock it.
      await authUsecase.switchAccount(pubkey: event.pubkey);
    } catch (e) {
      emit(AccountSwitcherState.error(e: e, data: data));
      // The accounts list may have changed (a stale account with no stored
      // key gets dropped by the failed switch attempt).
      add(const AccountSwitcherEvent.initial());
    }
  }
}
