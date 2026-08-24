import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/app/icons/app_icons.dart';
import 'package:nostr_notes/auth/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:nostr_notes/auth/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:nostr_notes/auth/presentation/dashboard/notes_list_tab.dart';
import 'package:nostr_notes/l10n/localization.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:nostr_notes/common/presentation/layout/layout_config.dart';

enum HomeScreenEmptyStatePlaceholderType {
  createNote,
  createLoginItem;

  String getText(Localization l10n) {
    switch (this) {
      case HomeScreenEmptyStatePlaceholderType.createNote:
        return l10n.homeScreenEmptyStatePlaceholder;
      case HomeScreenEmptyStatePlaceholderType.createLoginItem:
        return l10n.homeScreenEmptyStateAccsPlaceholder;
    }
  }
}

final class HomeScreenEmptyStatePlaceholder extends StatelessWidget {
  static const double opacity = 0.4;

  const HomeScreenEmptyStatePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocSelector<DashboardBloc, DashboardState, NotesListTab>(
      selector: (state) => state.data.tab,
      builder: (context, tab) {
        final type = switch (tab) {
          NotesNotesTab() => HomeScreenEmptyStatePlaceholderType.createNote,
          AccsTab() => HomeScreenEmptyStatePlaceholderType.createLoginItem,
        };
        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final bool isTablet = width >= LayoutConfig.desktopScreenWidth;
            final double iconRatio = isTablet ? 0.1 : 0.2;
            final double iconSize = width * iconRatio;
            final TextStyle textStyle = isTablet
                ? theme.textTheme.headlineLarge!.copyWith(
                    fontWeight: FontWeight.w400,
                  )
                : theme.textTheme.headlineLarge!;
            return Opacity(
              opacity: opacity,
              child: Padding(
                padding: const EdgeInsets.all(Sizes.indent4x),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: Sizes.indent2x,
                    children: [
                      Image.asset(
                        AppIcons.splash,
                        width: iconSize,
                        height: iconSize,
                      ),
                      Text(
                        type.getText(context.l10n),
                        style: textStyle,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
