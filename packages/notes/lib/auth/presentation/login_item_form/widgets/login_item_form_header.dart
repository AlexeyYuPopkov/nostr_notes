import 'package:common/app/theme/sizes.dart';
import 'package:flutter/material.dart';
import 'package:nostr_notes/auth/presentation/widgets/brand_avatar.dart';

final class LoginItemFormHeader extends StatelessWidget {
  static const _avatarSize = 92.0;

  final TextEditingController titleController;
  final TextEditingController websiteController;
  final Widget title;
  final List<Widget> actions;

  const LoginItemFormHeader({
    super.key,
    required this.titleController,
    required this.websiteController,
    required this.title,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      stretch: true,
      centerTitle: false,
      title: title,
      actions: actions,
      expandedHeight:
          kToolbarHeight + Sizes.indent + _avatarSize + Sizes.indent,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final side =
              constraints.maxHeight -
              MediaQuery.paddingOf(context).top -
              kToolbarHeight -
              Sizes.indent2x;

          if (side < 1) {
            return const SizedBox.shrink();
          }

          return Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: Sizes.indent),
              child: _Avatar(
                side: side,
                titleController: titleController,
                websiteController: websiteController,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Feeds the live [titleController]/[websiteController] text into
/// [BrandAvatar], rebuilding as the user types.
final class _Avatar extends StatelessWidget {
  final double side;
  final TextEditingController titleController;
  final TextEditingController websiteController;

  const _Avatar({
    required this.side,
    required this.titleController,
    required this.websiteController,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([titleController, websiteController]),
      builder: (context, _) {
        return BrandAvatar(
          side: side,
          title: titleController.text,
          website: websiteController.text,
        );
      },
    );
  }
}
