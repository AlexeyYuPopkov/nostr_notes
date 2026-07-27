import 'package:common/app/theme/sizes.dart';
import 'package:common/l10n/localization.dart';
import 'package:common/presentation/dialogs/dialog_button.dart';
import 'package:common/presentation/dialogs/dialog_helper.dart';
import 'package:di_storage/di_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nostr_notes/common/domain/model/session/session.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/l10n/localization.dart';

mixin DecryptFailedDialogMixin {
  Future<void> showDecryptFailedDialog(
    BuildContext context, {
    required int failedCount,
    required int totalCount,
  }) async {
    final retry = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AppAlertDialog(
          contentPadding: EdgeInsets.zero,
          content: _DialogContent(
            failedCount: failedCount,
            totalCount: totalCount,
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(bottom: Sizes.indent),
              child: _EnterPinButton(),
            ),
          ],
        );
      },
    );

    if (retry != true) return;

    final sessionUsecase = DiStorage.shared.resolve<SessionUsecase>();
    final session = sessionUsecase.currentSession;
    if (session is Unlocked) {
      sessionUsecase.setSession(session.toAuth());
    }
  }
}

final class _DialogContent extends StatelessWidget {
  final int failedCount;
  final int totalCount;

  const _DialogContent({required this.failedCount, required this.totalCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    final allFailed = failedCount >= totalCount;
    final message = allFailed
        ? l10n.notesListDecryptFailedDialogMessageAll
        : l10n.notesListDecryptFailedDialogMessage(failedCount, totalCount);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sizes.indent),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Sizes.indent2x,
        children: [
          Stack(
            children: [
              const Positioned(right: Sizes.indent, child: _CloseButton()),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: Sizes.indent2x),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(Sizes.indentVariant4x),
                      child: Icon(
                        Icons.lock_open,
                        size: Sizes.icon,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: Sizes.indent),
            child: Text(
              l10n.notesListDecryptFailedDialogTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          Text(
            message,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.25,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Sizes.indent),
        ],
      ),
    );
  }
}

final class _EnterPinButton extends StatelessWidget {
  const _EnterPinButton();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DialogTextButtonFilled(
      text: l10n.notesListDecryptFailedDialogRetry,
      onPressed: () => Navigator.of(context).pop(true),
    );
  }
}

final class _CloseButton extends StatelessWidget {
  const _CloseButton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final commonL10n = context.commonL10n;
    return Semantics(
      button: true,
      label: commonL10n.commonButtonCancel,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        onPressed: () => Navigator.of(context).pop(false),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: const EdgeInsets.all(Sizes.indent),
            child: Icon(
              Icons.close,
              size: Sizes.iconMedium,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
