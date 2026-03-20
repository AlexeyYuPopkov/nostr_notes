import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/app/sizes.dart';
import 'package:nostr_notes/auth/domain/usecase/delete_acc_usecase.dart';
import 'package:nostr_notes/auth/presentation/home_screen/layout_config.dart';
import 'package:nostr_notes/auth/presentation/settings/del_acc/bloc/del_acc_bloc.dart';
import 'package:nostr_notes/auth/presentation/settings/del_acc/bloc/del_acc_state.dart';
import 'package:nostr_notes/common/presentation/dialogs/dialog_button.dart';
import 'package:nostr_notes/common/presentation/dialogs/dialog_helper.dart';

import 'bloc/del_acc_event.dart';

final class DelAccScreen extends StatelessWidget with DialogHelper {
  const DelAccScreen({super.key});

  void _listener(BuildContext context, DelAccState state) {
    switch (state) {
      case CommonState():
      case ExecutingState():
        break;
      case ErrorState():
        showError(context, error: state.e);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return BlocProvider(
      create: (context) => DelAccBloc(),
      child: BlocConsumer<DelAccBloc, DelAccState>(
        listener: _listener,
        builder: (context, state) {
          return AbsorbPointer(
            absorbing: state is ExecutingState,
            child: Scaffold(
              appBar: AppBar(title: Text(l10n.settingsScreenDeleteAccount)),
              body: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: LayoutConfig.desktopScreenWidth,
                  ),
                  child: ListView(
                    children: [
                      Markdown(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(Sizes.indent2x),
                        data: context
                            .l10n
                            .settingsScreenDeleteAccountConfirmationMessage,
                        styleSheet: MarkdownStyleSheet.fromTheme(theme)
                            .copyWith(
                              h1: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              h2: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              h3: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              horizontalRuleDecoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: theme.colorScheme.outline,
                                    width: 1,
                                  ),
                                ),
                              ),
                              p: theme.textTheme.bodyLarge,
                              blockquotePadding: const EdgeInsets.all(
                                Sizes.indent,
                              ),
                              blockquoteDecoration: BoxDecoration(
                                color: theme.colorScheme.errorContainer
                                    .withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(
                                  Sizes.radius,
                                ),
                                border: Border(
                                  left: BorderSide(
                                    color: theme.colorScheme.error,
                                    width: 3,
                                  ),
                                ),
                              ),
                            ),
                      ),
                      const _Footer(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

final class _Footer extends StatelessWidget {
  static const _duration = Duration(milliseconds: 300);
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DelAccBloc, DelAccState>(
      builder: (context, state) {
        final status = state.data.status;
        return AnimatedCrossFade(
          duration: _duration,
          crossFadeState: status == null ? .showFirst : .showSecond,
          firstChild: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              DialogTextButtonUnderlined(
                text: context.l10n.commonButtonCancel,
                onPressed: () => Navigator.of(context).pop(false),
              ),
              DialogTextButton(
                text: context.l10n.commonButtonContinue,
                onPressed: () => _onContinuePressed(context),
              ),
            ],
          ),
          secondChild: status == null
              ? const SizedBox()
              : _ExecutingStateWidget(status: status),
        );
      },
    );
  }

  void _onContinuePressed(BuildContext context) {
    context.read<DelAccBloc>().add(const DelAccEvent.delete());
  }
}

final class _ExecutingStateWidget extends StatelessWidget {
  final DeleteAccStatus status;
  const _ExecutingStateWidget({required this.status});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: Sizes.indent4x),
      itemCount: DeleteAccStatus.steps.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: Sizes.indent),
      itemBuilder: (context, index) => _StatusItem(
        status: DeleteAccStatus.steps[index],
        currentStatus: status,
      ),
    );
  }
}

final class _StatusItem extends StatelessWidget {
  final DeleteAccStatus status;
  final DeleteAccStatus currentStatus;
  const _StatusItem({required this.status, required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      spacing: Sizes.indent2x,
      children: [
        SizedBox(
          width: Sizes.iconMedium,
          height: Sizes.iconMedium,
          child: _getIcon(theme),
        ),
        Text(
          status.getMessage(context),
          style: theme.textTheme.bodyLarge?.copyWith(color: _textColor(theme)),
        ),
      ],
    );
  }

  Widget _getIcon(ThemeData theme) {
    if (currentStatus.isExecuting(status)) {
      return const Center(child: CircularProgressIndicator.adaptive());
    } else if (currentStatus.isCompleted(status)) {
      return Icon(
        Icons.check_circle,
        size: Sizes.iconMedium,
        color: _getIconColor(theme),
      );
    } else {
      return Icon(
        Icons.circle_outlined,
        size: Sizes.iconMedium,
        color: _getIconColor(theme),
      );
    }
  }

  Color _getIconColor(ThemeData theme) {
    if (currentStatus.isExecuting(status)) {
      return Colors.yellow;
    } else if (currentStatus.isCompleted(status)) {
      return Colors.green;
    } else {
      return theme.colorScheme.onSurface.withValues(alpha: 0.5);
    }
  }

  Color _textColor(ThemeData theme) {
    if (currentStatus.isExecuting(status) ||
        currentStatus.isCompleted(status)) {
      return theme.colorScheme.onSurface;
    } else {
      return theme.colorScheme.onSurface.withValues(alpha: 0.5);
    }
  }
}

extension on DeleteAccStatus {
  String getMessage(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case DeleteAccStatus.preparing:
        return l10n.settingsScreenDeleteAccountStatusPreparing;
      case DeleteAccStatus.kind5Publishing:
        return l10n.settingsScreenDeleteAccountStatusKind5Publishing;
      case DeleteAccStatus.clearLocalStorages:
        return l10n.settingsScreenDeleteAccountStatusClearLocalStorages;
      case DeleteAccStatus.logout:
        return l10n.settingsScreenDeleteAccountStatusLogout;
    }
  }
}
