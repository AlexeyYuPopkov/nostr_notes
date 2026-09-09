import 'package:common/app/theme/sizes.dart';
import 'package:di_storage/di_storage.dart';
import 'package:flutter/material.dart';
import 'package:nostr_notes/l10n/localization.dart';
import 'package:nostr_notes/common/domain/usecase/get_user_usecase.dart';
import 'package:nostr_notes/unauth/presentation/acc_switcher/account_chip_vm.dart';

import 'acc_popup_menu_chip.dart';

final class AccountHeader extends StatefulWidget {
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
  State<AccountHeader> createState() => _AccountHeaderState();
}

final class _AccountHeaderState extends State<AccountHeader> {
  late final GetUserUsecase getUserUsecase = DiStorage.shared.resolve();
  late var vm = AccountChipVM(
    pubkey: widget.currentPubkey,
    getUserUsecase: getUserUsecase,
  );

  ValueNotifier<bool> isOpened = ValueNotifier(false);

  @override
  void dispose() {
    vm.dispose();
    isOpened.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AccountHeader oldWidget) {
    if (oldWidget.currentPubkey != widget.currentPubkey) {
      vm.dispose();
      vm = AccountChipVM(
        pubkey: widget.currentPubkey,
        getUserUsecase: getUserUsecase,
      );
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final canSwitch = widget.pubkeys.length > 1;
    final chip = AccountChip(
      showChevron: canSwitch,
      vm: vm,
      isOpened: isOpened,
    );

    if (!canSwitch) return chip;

    return PopupMenuButton<String>(
      tooltip: context.l10n.accountSwitcherTitle,

      offset: const Offset(0, Sizes.padding4x),

      constraints: const BoxConstraints(
        maxWidth: AccountChip.menuWidth,
        minWidth: AccountChip.menuWidth,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Sizes.indent2x),
      ),
      clipBehavior: Clip.antiAlias,
      menuPadding: EdgeInsets.zero,
      onOpened: () => isOpened.value = true,
      onSelected: (pubkey) {
        widget.onSelected(pubkey);
        isOpened.value = false;
      },
      onCanceled: () => isOpened.value = false,
      itemBuilder: (context) => [
        for (final pubkey in widget.pubkeys)
          PopupMenuItem<String>(
            value: pubkey,
            padding: EdgeInsets.zero,
            child: AccountItemChip(
              getUserUsecase: vm.getUserUsecase,
              pubkey: pubkey,
              isSelected: widget.currentPubkey == pubkey,
            ),
          ),
      ],
      child: chip,
    );
  }
}
