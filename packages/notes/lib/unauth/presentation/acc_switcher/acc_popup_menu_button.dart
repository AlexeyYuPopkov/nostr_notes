import 'package:common/app/theme/sizes.dart';
import 'package:flutter/material.dart';
import 'package:nostr_notes/common/presentation/account_avatar.dart';
import 'package:nostr_notes/l10n/localization.dart';

/// Shows which account the PIN step is for. When more than one account is
/// stored, it becomes a dropdown to switch the pending account.
final class AccountHeader extends StatelessWidget {
  final String currentPubkey;
  final List<String> pubkeys;
  final ValueChanged<String> onSelected;

  const AccountHeader({
    super.key,
    required this.currentPubkey,
    required this.pubkeys,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {

    final canSwitch = pubkeys.length > 1;
    final chip = _AccountChip(pubkey: currentPubkey, showChevron: canSwitch);

    if (!canSwitch) return chip;

    return PopupMenuButton<String>(
      tooltip: context.l10n.accountSwitcherTitle,
      onSelected: onSelected,
      offset: const Offset(0, Sizes.padding4x),
      itemBuilder: (context) => [
        for (final pubkey in pubkeys)
          PopupMenuItem<String>(
            value: pubkey,
            child: Row(
              children: [
                AccountAvatar(pubkey: pubkey, size: Sizes.iconMedium),
                const SizedBox(width: Sizes.indent),
                Expanded(
                  child: Text(
                    truncatePubkey(pubkey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (pubkey == currentPubkey)
                  Icon(
                    Icons.check,
                    size: Sizes.iconSmall,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
          ),
      ],
      child: chip,
    );
  }
}

final class _AccountChip extends StatelessWidget {
  final String pubkey;
  final bool showChevron;
  const _AccountChip({required this.pubkey, required this.showChevron});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.indent,
        vertical: Sizes.halfIndent,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Sizes.indent4x),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AccountAvatar(pubkey: pubkey, size: Sizes.iconMedium),
          const SizedBox(width: Sizes.indent),
          Flexible(
            child: Text(
              truncatePubkey(pubkey),
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall,
            ),
          ),
          if (showChevron) const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }
}
