import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/tools/section_scroll_vm.dart';
import 'package:flutter/material.dart';
import 'package:nostr_notes/auth/presentation/settings/preferences/bloc/items/preferences_item.dart';
import 'package:common/presentation/widgets/settings_item_tile.dart';
import 'package:common/presentation/dialogs/dialog_helper.dart';

import 'bloc/app_settings_state.dart';

final class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen>
    with DialogHelper {
  final scrollController = ScrollController();
  late final _vm = SectionScrollVm<PreferencesItem>(
    scrollController: scrollController,
  );

  @override
  void dispose() {
    _vm.dispose();
    scrollController.dispose();
    super.dispose();
  }

  // ignore: unused_element
  void _listener(BuildContext context, AppSettingsState state) {
    switch (state) {
      case CommonState():
        break;
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
        title: ValueListenableBuilder(
          valueListenable: _vm.currentItemNotifier,
          builder: (context, value, child) {
            return value == null
                ? SizedBox()
                : Text(value.getSectionTitle(context));
          },
        ),
        toolbarHeight: Sizes.appBarHeight,
      ),
      body: ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        controller: _vm.scrollController,
        itemCount: PreferencesItem.items.length,
        itemBuilder: (context, index) {
          final item = PreferencesItem.items[index];

          return SettingsItemTile(
            title: item.getTitle(context),
            position: item.position,
            sectionTitle: item.getSectionTitle(context),
            trailing: item.trailing(context),
            onTap: () => item.onTap(context),
            onBuildSectionTitle: (ctx) => _vm.registerSection(item, ctx),
          );
        },
      ),
      // ),
    );
  }
}
