import 'package:common/app/theme/sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/gen_pass_usecase.dart';
import 'package:nostr_notes/l10n/localization.dart';

import 'login_item_go_icon.dart';

final class LoginItemFormGenPassIcon extends StatelessWidget {
  final VoidCallback? onTap;
  const LoginItemFormGenPassIcon({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CupertinoButton(
      minimumSize: Size.zero,
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: Sizes.indentVariant,
        children: [
          Icon(
            Icons.auto_awesome,
            color: theme.colorScheme.primary,
            size: LoginItemGoIcon.size,
          ),
          Text(
            context.l10n.accsFormGenPassButton,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

final class LoginItemFormGenPassPanel extends StatefulWidget {
  final TextEditingController passwordController;
  final GenPassUsecase genPassUsecase;

  const LoginItemFormGenPassPanel({
    super.key,
    required this.passwordController,
    this.genPassUsecase = const GenPassUsecase(),
  });
  @override
  State<LoginItemFormGenPassPanel> createState() =>
      _LoginItemFormGenPassPanelState();
}

final class _LoginItemFormGenPassPanelState
    extends State<LoginItemFormGenPassPanel> {
  late final _genPassUsecase = widget.genPassUsecase;

  PassStyle _style = PassStyle.randomStyle;

  @override
  void initState() {
    super.initState();

    widget.passwordController.text = _genPassUsecase.execute(_style);
  }

  void _regenerate(PassStyle style) {
    setState(() {
      _style = style;
      widget.passwordController.text = _genPassUsecase.execute(style);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(Sizes.indent2x),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(Sizes.radiusVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Sizes.indent2x,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.passwordController.text,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontFamily: 'monospace',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              CupertinoButton(
                minimumSize: Size.zero,
                padding: EdgeInsets.zero,
                onPressed: () => _regenerate(_style),
                child: Icon(
                  Icons.refresh,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: Sizes.iconMedium,
                ),
              ),
            ],
          ),
          _StyleSwitch(style: _style, onChanged: _regenerate),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Sizes.indent,
            children: [
              Icon(
                Icons.info_outline,
                size: Sizes.iconSmall,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              Expanded(
                child: Text(
                  l10n.accsFormGenPassHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

final class _StyleSwitch extends StatelessWidget {
  final PassStyle style;
  final ValueChanged<PassStyle> onChanged;

  const _StyleSwitch({required this.style, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(Sizes.thicknessHalf * 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(Sizes.radius),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StyleSwitchSegment(
              title: l10n.accsFormGenPassStyleRandom,
              isSelected: style == PassStyle.randomStyle,
              onTap: () => onChanged(PassStyle.randomStyle),
            ),
          ),
          Expanded(
            child: _StyleSwitchSegment(
              title: l10n.accsFormGenPassStyleWords,
              isSelected: style == PassStyle.dicewareStyle,
              onTap: () => onChanged(PassStyle.dicewareStyle),
            ),
          ),
        ],
      ),
    );
  }
}

final class _StyleSwitchSegment extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _StyleSwitchSegment({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppDurations.medium,
        padding: const EdgeInsets.symmetric(vertical: Sizes.indentVariant2x),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(Sizes.radiusSmall),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
