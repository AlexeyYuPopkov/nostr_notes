import 'package:common/app/theme/sizes.dart';
import 'package:common/domain/model/user.dart';
import 'package:common/presentation/account_avatar.dart';
import 'package:flutter/material.dart';
import 'package:nostr/key_tool/key_tool.dart';

final class ContactListCell extends StatelessWidget {
  static const avatarSize = 40.0;

  final User user;
  final VoidCallback onTap;

  const ContactListCell({super.key, required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final npub = truncatePubkey(KeyTool.npubKey(user.pubkey));
    final name = [user.displayName, user.name].whereType<String>().firstWhere(
      (e) => e.trim().isNotEmpty,
      orElse: () => '',
    );
    final subtitle = user.nip05?.trim().isNotEmpty == true ? user.nip05! : npub;

    return ListTile(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.colorScheme.outlineVariant),
        borderRadius: const BorderRadius.all(Radius.circular(Sizes.radius)),
      ),
      leading: AccountAvatar(
        pubkey: user.pubkey,
        size: avatarSize,
        pictureUrl: user.picture,
      ),
      title: Text(
        name.isEmpty ? npub : name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: name.isEmpty
          ? null
          : Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      onTap: onTap,
    );
  }
}
