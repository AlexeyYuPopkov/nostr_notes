import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/dialogs/dialog_helper.dart';
import 'package:common/presentation/tools/list_item_position.dart';
import 'package:common/presentation/widgets/settings_item_tile.dart';
import 'package:di_storage/di_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/common/presentation/account_avatar.dart';
import 'package:nostr_notes/l10n/localization.dart';
import 'package:nostr_notes/common/domain/usecase/get_user_usecase.dart';
import 'package:nostr_notes/unauth/presentation/acc_switcher/account_chip_vm.dart';

import 'bloc/account_switcher_bloc.dart';
import 'bloc/account_switcher_event.dart';
import 'bloc/account_switcher_state.dart';

final class AccountSwitcherPanel extends StatelessWidget with DialogHelper {
  final VoidCallback? onAddAccount;

  const AccountSwitcherPanel({super.key, this.onAddAccount});

  void _listener(BuildContext context, AccountSwitcherState state) {
    switch (state) {
      case CommonState():
      case LoadingState():
        break;
      case ErrorState():
        showError(context, error: state.e);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.accountSwitcherTitle),
        automaticallyImplyLeading: false,
        centerTitle: false,
      ),
      body: BlocProvider(
        create: (context) => AccountSwitcherBloc(),
        child: BlocConsumer<AccountSwitcherBloc, AccountSwitcherState>(
          listener: _listener,
          builder: (context, state) {
            final accounts = state.data.accounts;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: Sizes.indent2x),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (index, pubkey) in accounts.indexed)
                      _AccountTile(
                        pubkey: pubkey,
                        isCurrent: pubkey == state.data.currentUserPubkey,
                        position: ListItemPosition.fromIndex(
                          index,
                          length: accounts.length,
                        ),
                        onTap: () => context.read<AccountSwitcherBloc>().add(
                          AccountSwitcherEvent.switchAccount(pubkey),
                        ),
                      ),
                    const SizedBox(height: Sizes.indent2x),
                    SettingsItemTile(
                      title: Text(
                        l10n.accountSwitcherAddAccount,
                        style: TextStyle(color: theme.colorScheme.primary),
                      ),
                      trailing: Icon(
                        Icons.add,
                        color: theme.colorScheme.primary,
                      ),
                      position: ListItemPosition.single,
                      onTap: onAddAccount,
                    ),
                    const SizedBox(height: Sizes.indent2x),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

final class _AccountTile extends StatefulWidget {
  final String pubkey;
  final bool isCurrent;
  final ListItemPosition position;
  final VoidCallback onTap;

  const _AccountTile({
    required this.pubkey,
    required this.isCurrent,
    required this.position,
    required this.onTap,
  });

  @override
  State<_AccountTile> createState() => _AccountTileState();
}

final class _AccountTileState extends State<_AccountTile> {
  late final GetUserUsecase getUserUsecase = DiStorage.shared.resolve();
  late var vm = AccountChipVM(
    pubkey: widget.pubkey,
    getUserUsecase: getUserUsecase,
  );

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _AccountTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.pubkey != widget.pubkey) {
      vm.dispose();
      vm = AccountChipVM(pubkey: widget.pubkey, getUserUsecase: getUserUsecase);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SettingsItemTile(
      title: ListenableBuilder(
        listenable: vm,
        builder: (context, _) {
          final user = vm.user;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AccountAvatar(
                pubkey: widget.pubkey,
                size: Sizes.iconMedium,
                pictureUrl: user?.picture,
              ),
              const SizedBox(width: Sizes.indent),
              Flexible(
                child: Text(
                  user?.displayName ??
                      user?.name ??
                      truncatePubkey(widget.pubkey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        },
      ),
      trailing: widget.isCurrent
          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
          : null,
      position: widget.position,
      onTap: widget.isCurrent ? null : widget.onTap,
    );
  }
}
