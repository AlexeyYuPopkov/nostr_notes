import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/app/sizes.dart';
import 'package:nostr_notes/auth/presentation/settings/settings/bloc/settings_screen_bloc.dart';
import 'package:nostr_notes/auth/presentation/settings/settings/bloc/settings_screen_state.dart';
import 'package:nostr_notes/common/presentation/dialogs/dialog_helper.dart';

import 'items/settings_screen_item.dart';

final class SettingsScreen extends StatelessWidget with DialogHelper {
  const SettingsScreen({super.key});

  void _listener(BuildContext context, SettingsScreenState state) {
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: BackButton(
          onPressed: () => Scaffold.of(context).closeEndDrawer(),
        ),
        title: Text(context.l10n.settingsScreenTitle),
      ),
      body: SafeArea(
        child: BlocProvider(
          create: (context) => SettingsScreenBloc(),
          child: BlocConsumer<SettingsScreenBloc, SettingsScreenState>(
            listener: _listener,
            builder: (context, state) {
              return AbsorbPointer(
                absorbing: state is LoadingState,
                child: ListView.builder(
                  itemCount: SettingsItem.items.length,
                  itemBuilder: (context, index) {
                    final item = SettingsItem.items[index];
                    return _ItemTile(item: item);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

final class _ItemTile extends StatelessWidget {
  final SettingsItem item;
  const _ItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final position = item.position;

    final insets = switch (position) {
      .first => const EdgeInsets.only(top: Sizes.halfIndent),
      .last => const EdgeInsets.only(bottom: Sizes.halfIndent),
      .single => const EdgeInsets.symmetric(vertical: Sizes.halfIndent),
      .middle => EdgeInsets.zero,
    };

    final showSectionTitle = switch (position) {
      .first => true,
      .single => true,
      .middle => false,
      .last => false,
    };

    return Column(
      children: [
        if (showSectionTitle) _SectionTitle(item: item),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sizes.indent2x),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,

              borderRadius: position.getRadius(),
              border: position.getBorder(
                theme.colorScheme.outline,
                thickness: Sizes.thicknessHalf,
              ),
            ),
            child: Column(
              children: [
                CupertinoButton(
                  foregroundColor: item.getTitleTextColor(context),
                  padding:
                      const EdgeInsets.symmetric(
                        horizontal: Sizes.indent2x,
                        vertical: Sizes.indent,
                      ) +
                      insets,
                  minimumSize: .zero,
                  onPressed: () => item.onTap(context),
                  child: _ButtonContent(item: item),
                ),
                if (position.needsSeparator())
                  Divider(
                    indent: Sizes.indent2x,
                    endIndent: Sizes.indent2x,
                    height: Sizes.thicknessHalf,
                    thickness: Sizes.thicknessHalf,
                    color: theme.colorScheme.outline,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

final class _ButtonContent extends StatelessWidget {
  final SettingsItem item;
  const _ButtonContent({required this.item});

  @override
  Widget build(BuildContext context) {
    final subtitle = item.getInfoText(context);

    return subtitle.isEmpty
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(item.getTitle(context)), item.trailing(context)],
          )
        : _ButtonContentWithSubtitle(item: item, subtitle: subtitle);
  }
}

final class _ButtonContentWithSubtitle extends StatelessWidget {
  final SettingsItem item;
  final String subtitle;

  const _ButtonContentWithSubtitle({
    required this.item,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(item.getTitle(context)), item.trailing(context)],
        ),
        const SizedBox(height: Sizes.halfIndent),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

final class _SectionTitle extends StatelessWidget {
  final SettingsItem item;
  const _SectionTitle({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Sizes.indent2x,
        Sizes.indent2x,
        Sizes.indent2x,
        Sizes.indent,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          item.getSectionTitle(context),
          style: theme.textTheme.titleMedium,
        ),
      ),
    );
  }
}
