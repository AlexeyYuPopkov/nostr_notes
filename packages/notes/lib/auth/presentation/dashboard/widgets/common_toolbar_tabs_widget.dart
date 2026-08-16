import 'package:common/app/theme/sizes.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'tabbar_choice_chip.dart';

abstract class CommonToolbarTabsWidgetTab implements Equatable {
  const CommonToolbarTabsWidgetTab();
  String getLocalizedTitle(BuildContext context);
}

final class CommonToolbarTabsWidget extends StatelessWidget {
  const CommonToolbarTabsWidget({
    super.key,
    required this.currentTab,
    required this.tabs,
    required this.onChangeTab,
    this.padding = const EdgeInsets.symmetric(horizontal: Sizes.indent),
  });
  static const height = Sizes.indent4x;

  final CommonToolbarTabsWidgetTab currentTab;
  final List<CommonToolbarTabsWidgetTab> tabs;
  final EdgeInsets padding;

  final void Function(BuildContext, int, CommonToolbarTabsWidgetTab)
  onChangeTab;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: padding,
      clipBehavior: Clip.none,
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: Sizes.indent,
        children: [
          for (final (index, tab) in tabs.indexed)
            TabbarChoiceChip(
              selected: tab == currentTab,
              onSelected: (selected) => onChangeTab(context, index, tab),
              label: Text(tab.getLocalizedTitle(context)),
            ),
        ],
      ),
    );
  }
}
