import 'package:chat/auth/chat/presentation/common/user_title.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:common/domain/model/user.dart';
import 'package:common/presentation/account_avatar.dart';
import 'package:flutter/material.dart';

final class ContactListCell extends StatelessWidget {
  static const avatarSize = 40.0;

  final User user;
  final VoidCallback onTap;

  const ContactListCell({super.key, required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = user.readableName;
    final subtitle = user.nip05?.trim().isNotEmpty == true
        ? user.nip05!
        : user.shortNpub;

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
      title: Text(user.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: name == null
          ? null
          : Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      onTap: onTap,
    );
  }
}
