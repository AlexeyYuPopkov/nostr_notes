import 'package:common/presentation/tools/section_scroll_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/auth/presentation/settings/settings/bloc/settings_screen_bloc.dart';
import 'package:nostr_notes/auth/presentation/settings/settings/bloc/settings_screen_state.dart';
import 'package:common/presentation/widgets/settings_item_tile.dart';
import 'package:common/presentation/dialogs/dialog_helper.dart';
import 'package:nostr_notes/l10n/localization.dart';

import 'items/settings_screen_item.dart';

final class SettingsScreen extends StatefulWidget with DialogHelper {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

final class _SettingsScreenState extends State<SettingsScreen>
    with DialogHelper {
  final scrollController = ScrollController();
  late final _vm = SectionScrollVm<SettingsItem>(
    scrollController: scrollController,
  );

  @override
  void dispose() {
    _vm.dispose();
    scrollController.dispose();
    super.dispose();
  }

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
    final l10n = context.l10n;
    final onBack = Scaffold.of(context).closeEndDrawer;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: onBack),

        title: ValueListenableBuilder(
          valueListenable: _vm.currentItemNotifier,
          builder: (context, value, child) {
            return value == null
                ? Text(l10n.settingsScreenSectionSettingsTitle)
                : Text(value.getSectionTitle(context));
          },
        ),
      ),
      body: BlocProvider(
        create: (context) => SettingsScreenBloc(),
        child: BlocConsumer<SettingsScreenBloc, SettingsScreenState>(
          listener: _listener,
          builder: (context, state) {
            return AbsorbPointer(
              absorbing: state is LoadingState,
              child: ListView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                controller: _vm.scrollController,
                itemCount: SettingsItem.items.length,
                itemBuilder: (context, index) {
                  final item = SettingsItem.items[index];
                  return SettingsItemTile(
                    title: item.getTitle(context),
                    subtitle: item.getInfoText(context),
                    titleTextColorBuilder: item.getTitleTextColor,
                    sectionTitle: item.getSectionTitle(context),
                    position: item.position,
                    trailing: item.trailing(context),
                    onTap: () => item.onTap(context),
                    onBuildSectionTitle: (ctx) =>
                        _vm.registerSection(item, ctx),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
