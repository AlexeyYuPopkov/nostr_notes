import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/auth/presentation/settings/settings/bloc/settings_screen_bloc.dart';
import 'package:nostr_notes/auth/presentation/settings/settings/bloc/settings_screen_state.dart';
import 'package:common/presentation/widgets/settings_item_tile.dart';
import 'package:common/presentation/dialogs/dialog_helper.dart';

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
    final theme = Theme.of(context);
    final onBack = Scaffold.of(context).closeEndDrawer;
    return Scaffold(
      body: SafeArea(
        child: BlocProvider(
          create: (context) => SettingsScreenBloc(),
          child: BlocConsumer<SettingsScreenBloc, SettingsScreenState>(
            listener: _listener,
            builder: (context, state) {
              return AbsorbPointer(
                absorbing: state is LoadingState,
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar.medium(
                      leading: BackButton(onPressed: onBack),
                      title: Text(
                        SettingsItemPreferences().getSectionTitle(context),
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    SliverList.builder(
                      itemCount: SettingsItem.items.length,
                      itemBuilder: (context, index) {
                        final item = SettingsItem.items[index];
                        return SettingsItemTile(
                          title: item.getTitle(context),
                          subtitle: item.getInfoText(context),
                          titleTextColorBuilder: item.getTitleTextColor,
                          sectionTitle: index == 0
                              ? ''
                              : item.getSectionTitle(context),
                          position: item.position,
                          trailing: item.trailing(context),
                          onTap: () => item.onTap(context),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
