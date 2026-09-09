import 'package:common/app/theme/sizes.dart';
import 'package:common/app/theme/success_colors.dart';
import 'package:flutter/material.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/password_strength_usecase.dart';
import 'package:nostr_notes/l10n/localization.dart';

final class PasswordStrengthIndicator extends StatefulWidget {
  final String password;
  final PasswordStrengthUsecase _strengthUsecase;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    PasswordStrengthUsecase strengthUsecase = const PasswordStrengthUsecase(),
  }) : _strengthUsecase = strengthUsecase;

  @override
  State<PasswordStrengthIndicator> createState() =>
      _PasswordStrengthIndicatorState();
}

final class _PasswordStrengthIndicatorState
    extends State<PasswordStrengthIndicator> {
  late final _strengthUsecase = widget._strengthUsecase;
  PasswordStrength? _strength;
  static final _segmentCount = PasswordStrength.values.length;

  @override
  void initState() {
    super.initState();
    _updateStrength();
  }

  @override
  void didUpdateWidget(covariant PasswordStrengthIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.password != widget.password) {
      _updateStrength();
    }
  }

  Future<void> _updateStrength() async {
    setState(() {
      _strength = _strengthUsecase.execute(widget.password);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _color(theme);
    final liveSegments = _getLiveSegments();

    return Row(
      spacing: Sizes.indentVariant,
      children: [
        for (var i = 0; i < _segmentCount; i++)
          Expanded(
            child: AnimatedContainer(
              duration: AppDurations.medium,
              height: Sizes.thickness2x,
              decoration: BoxDecoration(
                color: i < liveSegments
                    ? color
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(Sizes.radiusSmall),
              ),
            ),
          ),

        Text(
          _label(context),
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  int _getLiveSegments() => switch (_strength) {
    null => 1,
    PasswordStrength.danger => 1,
    PasswordStrength.weak => 2,
    PasswordStrength.good => 3,
    PasswordStrength.strong => 4,
  };

  Color _color(ThemeData theme) {
    return switch (_strength) {
      null => theme.colorScheme.error,
      PasswordStrength.danger => theme.colorScheme.error,
      PasswordStrength.weak => Colors.orange,
      PasswordStrength.good => Colors.lightGreen,
      PasswordStrength.strong =>
        theme.extension<SuccessColors>()?.success ?? Colors.green,
    };
  }

  String _label(BuildContext context) {
    final l10n = context.l10n;
    return switch (_strength) {
      null => '',
      PasswordStrength.danger => l10n.accsFormGenPassStrengthDanger,
      PasswordStrength.weak => l10n.accsFormGenPassStrengthWeak,
      PasswordStrength.good => l10n.accsFormGenPassStrengthGood,
      PasswordStrength.strong => l10n.accsFormGenPassStrengthStrong,
    };
  }
}
