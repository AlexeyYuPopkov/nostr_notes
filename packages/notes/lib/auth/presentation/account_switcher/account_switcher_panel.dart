import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/dialogs/dialog_helper.dart';
import 'package:common/presentation/tools/list_item_position.dart';
import 'package:common/presentation/widgets/settings_item_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/l10n/localization.dart';

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

final class _AccountTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SettingsItemTile(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AccountAvatar(pubkey: pubkey, size: Sizes.iconMedium),
          const SizedBox(width: Sizes.indent),
          Flexible(
            child: Text(
              _truncatePubkey(pubkey),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: isCurrent
          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
          : null,
      position: position,
      onTap: isCurrent ? null : onTap,
    );
  }
}

final class AccountAvatar extends StatelessWidget {
  final String pubkey;
  final double size;

  const AccountAvatar({super.key, required this.pubkey, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _colorForPubkey(pubkey),
        shape: BoxShape.circle,
      ),
      child: Text(
        _initialsForPubkey(pubkey),
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

Color _colorForPubkey(String pubkey) {
  final hue = (pubkey.hashCode % 360).abs().toDouble();
  return HSLColor.fromAHSL(1, hue, 0.55, 0.5).toColor();
}

String _initialsForPubkey(String pubkey) {
  return pubkey.length >= 2 ? pubkey.substring(0, 2).toUpperCase() : '??';
}

String _truncatePubkey(String pubkey) {
  if (pubkey.length <= 16) return pubkey;
  return '${pubkey.substring(0, 8)}…${pubkey.substring(pubkey.length - 6)}';
}
