import 'package:common/l10n/localization.dart';
import 'package:common/presentation/tools/section_scroll_vm.dart';
import 'package:common/presentation/widgets/settings_item_tile.dart';
import 'package:flutter/material.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/dialogs/dialog_helper.dart';
import 'package:common/presentation/tools/list_item_position.dart';
import 'package:common/presentation/raw_event/raw_event_screen_vm.dart';

import 'widgets/raw_event_screen_json.dart';
import 'widgets/raw_event_screen_relay.dart';

final class RawEventScreen extends StatefulWidget {
  final String eventId;
  const RawEventScreen({super.key, required this.eventId});

  @override
  State<RawEventScreen> createState() => _RawEventScreenState();
}

enum _Section {
  relays,
  json;

  String getSectionTitle(CommonL10n l10n, int relaysCount) {
    switch (this) {
      case .relays:
        return l10n.relaysCount(relaysCount);
      case .json:
        return l10n.rawEventScreenSectionTitleJson;
    }
  }
}

final class _RawEventScreenState extends State<RawEventScreen>
    with DialogHelper {
  late final _vm = RawEventScreenVm(eventId: widget.eventId);
  final scrollController = ScrollController();
  late final _scrollVm = SectionScrollVm<_Section>(
    scrollController: scrollController,
  );

  @override
  void initState() {
    super.initState();
    _vm.addListener(_onVmChanged);
  }

  @override
  void dispose() {
    _vm.dispose();
    _scrollVm.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _onVmChanged() {
    final error = _vm.error;
    if (error != null) {
      showError(context, error: error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final commonL10n = context.commonL10n;

    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        final relaysCount = _vm.relays.length;
        return Scaffold(
          appBar: AppBar(
            title: ValueListenableBuilder(
              valueListenable: _scrollVm.currentItemNotifier,
              builder: (context, value, child) {
                return Text(
                  value == null
                      ? commonL10n.title
                      : value.getSectionTitle(commonL10n, relaysCount),
                );
              },
            ),
          ),
          body: Builder(
            builder: (context) {
              if (_vm.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              }

              final event = _vm.event.value;

              if (event == null) {
                // TODO: improve placeholder
                return Center(
                  child: Text(commonL10n.commonNoDataPlaceholderText),
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: Sizes.indent2x),
                child: ListView(
                  controller: _scrollVm.scrollController,
                  children: [
                    SectionTitle(
                      padding: const EdgeInsets.only(
                        top: Sizes.indent2x,
                        bottom: Sizes.indent2x,
                        right: Sizes.indent2x,
                      ),
                      sectionTitle: _Section.relays.getSectionTitle(
                        commonL10n,
                        relaysCount,
                      ),
                      onChangeDependencies: (ctx) =>
                          _scrollVm.registerSection(.relays, ctx),
                    ),

                    for (int i = 0; i < relaysCount; i++)
                      RawEventScreenRelay(
                        relay: _vm.relays[i],
                        position: ListItemPosition.fromIndex(
                          i,
                          length: relaysCount,
                        ),
                        onChangeDependencies: (ctx) =>
                            _scrollVm.registerSection(.json, ctx),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: Sizes.indent,
                        bottom: Sizes.indent4x,
                      ),
                      child: RawEventScreenJson(vm: _vm),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

extension on CommonL10n {
  String get title => rawEventScreenTitle;
  String relaysCount(int count) =>
      rawEventScreenSectionTitleRelaysCount(count.toString());
}
