import 'package:common/app/theme/sizes.dart';
import 'package:common/domain/error/app_error.dart';
import 'package:common/presentation/dialogs/dialog_helper.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/auth/presentation/settings/donate_lightning/bloc/donate_lightning_bloc.dart';
import 'package:nostr_notes/auth/presentation/settings/donate_lightning/bloc/donate_lightning_state.dart';
import 'package:nostr_notes/auth/presentation/settings/donate_lightning/tabs/donation_screen_tab.dart';
import 'package:nostr_notes/l10n/localization.dart';

final class DonateLightningScreen extends StatelessWidget with DialogHelper {
  const DonateLightningScreen({super.key});

  void _listener(BuildContext context, DonateLightningState state) {
    switch (state) {
      case ErrorState():
        final message =
            AppError.getMessageOrNull(state.error) ??
            context.l10n.donateLightningScreenErrorInvoice;
        showError(context, error: AppError.common(message: message));

      case IdleState():
      case LoadingState():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DefaultTabController(
      length: DonationScreenTab.tabs.length,
      child: BlocProvider(
        create: (_) => DonateLightningBloc(),
        child: BlocConsumer<DonateLightningBloc, DonateLightningState>(
          listener: _listener,
          buildWhen: (a, b) =>
              a.data.selectedTab != b.data.selectedTab ||
              a.runtimeType != b.runtimeType,
          builder: (context, state) {
            return BlocListener<DonateLightningBloc, DonateLightningState>(
              listenWhen: (a, b) => a.data.selectedTab != b.data.selectedTab,
              listener: (context, state) {
                DefaultTabController.of(
                  context,
                ).animateTo(state.data.selectedTab.getIndex());
              },
              child: Scaffold(
                appBar: AppBar(
                  title: Text(l10n.donateLightningScreenTitle),
                  bottom: _Tabbar(index: state.data.selectedTab.getIndex()),
                ),
                body: AbsorbPointer(
                  absorbing: state is LoadingState,
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      for (final tab in DonationScreenTab.tabs)
                        tab.build(context),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

final class _Tabbar extends StatefulWidget implements PreferredSizeWidget {
  static const thikness = Sizes.thickness2x;
  final int index;

  const _Tabbar({required this.index});

  @override
  State<_Tabbar> createState() => _TabbarState();

  @override
  Size get preferredSize => const Size.fromHeight(_Tabbar.thikness);
}

class _TabbarState extends State<_Tabbar> with SingleTickerProviderStateMixin {
  late int index = widget.index;

  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  late final _animation = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(_controller);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _Tabbar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.index != widget.index) {
      index = widget.index;
      if (index == 0) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final width2 = width / 2.0;
        final theme = Theme.of(context);
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, _) {
            return Stack(
              children: [
                SizedBox(height: _Tabbar.thikness, width: width),
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: _animation.value * width2,
                  width: width2,
                  child: Divider(
                    height: _Tabbar.thikness,
                    color: theme.colorScheme.primary,
                    thickness: _Tabbar.thikness,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
