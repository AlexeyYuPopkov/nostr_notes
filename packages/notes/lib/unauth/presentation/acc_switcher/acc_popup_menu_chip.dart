import 'package:common/app/theme/sizes.dart';

import 'package:flutter/material.dart';
import 'package:nostr_notes/common/domain/model/user.dart';
import 'package:nostr_notes/common/presentation/account_avatar.dart';
import 'package:nostr_notes/common/domain/usecase/get_user_usecase.dart';

import 'account_chip_vm.dart';

final class AccountChip extends StatelessWidget with _GetDisplayNameMixin {
  static const menuWidth = 250.0;

  final bool showChevron;
  final ValueNotifier<bool> isOpened;
  final AccountChipVM vm;
  const AccountChip({
    super.key,
    required this.showChevron,
    required this.vm,
    required this.isOpened,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: AccountChip.menuWidth,
      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.indent,
        vertical: Sizes.halfIndent,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Sizes.indent4x),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: ListenableBuilder(
        listenable: vm,
        builder: (context, _) {
          final user = vm.user;
          return Row(
            mainAxisSize: .max,

            spacing: Sizes.indent,
            children: [
              AccountAvatar(
                pubkey: vm.pubkey,
                size: Sizes.iconMedium,
                pictureUrl: user?.picture,
              ),
              Expanded(
                child: Text(
                  getDisplayName(user, vm.pubkey),
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              if (showChevron)
                ValueListenableBuilder(
                  valueListenable: isOpened,
                  builder: (context, value, child) {
                    return AnimatedRotation(
                      duration: const Duration(milliseconds: 300),
                      turns: value ? 0.5 : 0,
                      child: const Icon(Icons.arrow_drop_down),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

final class AccountItemChip extends StatefulWidget {
  final GetUserUsecase getUserUsecase;
  final bool isSelected;
  final String pubkey;

  const AccountItemChip({
    super.key,
    required this.getUserUsecase,
    required this.isSelected,
    required this.pubkey,
  });

  @override
  State<AccountItemChip> createState() => _AccountItemChipState();
}

final class _AccountItemChipState extends State<AccountItemChip>
    with _GetDisplayNameMixin {
  late var vm = AccountChipVM(
    pubkey: widget.pubkey,
    getUserUsecase: widget.getUserUsecase,
  );

  @override
  void didUpdateWidget(covariant AccountItemChip oldWidget) {
    if (oldWidget.pubkey != widget.pubkey) {
      vm.dispose();
      vm = AccountChipVM(
        pubkey: widget.pubkey,
        getUserUsecase: widget.getUserUsecase,
      );
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        final user = vm.user;
        return Container(
          color: widget.isSelected
              ? theme.colorScheme.primaryContainer
              : Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(Sizes.indent),
            child: Row(
              children: [
                AccountAvatar(
                  pubkey: widget.pubkey,
                  size: Sizes.icon,
                  pictureUrl: user?.picture,
                ),
                const SizedBox(width: Sizes.indent),
                Expanded(
                  child: Text(
                    getDisplayName(user, widget.pubkey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Visibility.maintain(
                  visible: widget.isSelected,
                  child: Icon(
                    Icons.check,
                    size: Sizes.iconSmall,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

mixin _GetDisplayNameMixin {
  String getDisplayName(User? user, String pubkey) {
    if (user == null) return truncatePubkey(pubkey);
    return user.displayName ?? user.name ?? truncatePubkey(pubkey);
  }
}
