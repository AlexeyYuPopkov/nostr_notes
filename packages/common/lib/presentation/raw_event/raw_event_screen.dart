import 'package:common/l10n/localization.dart';
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

final class _RawEventScreenState extends State<RawEventScreen>
    with DialogHelper {
  late final _vm = RawEventScreenVm(eventId: widget.eventId);

  @override
  void initState() {
    super.initState();
    _vm.addListener(_onVmChanged);
  }

  @override
  void dispose() {
    _vm.dispose();
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(commonL10n.title)),
      body: ListenableBuilder(
        listenable: _vm,
        builder: (context, _) {
          if (_vm.isLoading.value) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          final event = _vm.event.value;

          if (event == null) {
            // TODO: improve placeholder
            return Center(child: Text(commonL10n.commonNoDataPlaceholderText));
          }

          final relaysCount = _vm.relays.length;
          return Column(
            crossAxisAlignment: .start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Sizes.indent2x),
                child: Text(
                  commonL10n.relaysCount(relaysCount),
                  style: theme.textTheme.titleSmall,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(Sizes.indent2x),
                  itemBuilder: (context, index) {
                    if (index < relaysCount) {
                      return RawEventScreenRelay(
                        relay: _vm.relays[index],
                        position: ListItemPosition.fromIndex(
                          index,
                          length: relaysCount,
                        ),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.only(top: Sizes.indent),
                        child: RawEventScreenJson(vm: _vm),
                      );
                    }
                  },

                  itemCount: relaysCount + 1,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

extension on CommonL10n {
  String get title => rawEventScreenTitle;
  String relaysCount(int count) =>
      rawEventScreenSectionTitleRelaysCount(count.toString());
}
