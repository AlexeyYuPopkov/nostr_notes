import 'package:common/app/theme/sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final class PrymaryButton extends StatelessWidget {
  static const minWidth = 100.0;
  static const disabledOpacity = 0.5;

  final String title;
  final Widget? icon;
  final VoidCallback? onPressed;

  const PrymaryButton({
    super.key,
    required this.title,
    this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final color = onPressed == null
        ? theme.colorScheme.onSurface.withValues(
            alpha: PrymaryButton.disabledOpacity,
          )
        : theme.colorScheme.onPrimary;

    return CupertinoButton.filled(
      onPressed: onPressed,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: minWidth),
        child: DefaultTextStyle(
          style: TextStyle(color: color),
          child: icon == null
              ? Text(title, textAlign: TextAlign.center)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: .spaceEvenly,
                  children: [
                    Expanded(child: Text(title, textAlign: TextAlign.center)),
                    icon!,
                  ],
                ),
        ),
      ),
    );
  }
}

final class OpacityOutlinedButton extends StatelessWidget {
  static const minWidth = 100.0;
  static const disabledOpacity = 0.5;
  final Widget title;
  final Color? backgroundColor;

  final VoidCallback? onPressed;

  const OpacityOutlinedButton({
    super.key,
    required this.title,
    this.backgroundColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CupertinoButton(
      onPressed: onPressed,
      padding: .zero,
      sizeStyle: .small,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: minWidth),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.transparent,
            border: Border.all(color: theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Sizes.indent2x,
              vertical: Sizes.indent,
            ),
            child: title,
          ),
        ),
      ),
    );
  }
}

final class PrymaryLoadingButtonVM extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }
}

final class PrymaryLoadingButton extends StatelessWidget {
  final String title;
  final double? width;
  final PrymaryLoadingButtonVM vm;
  final VoidCallback? onTap;

  const PrymaryLoadingButton({
    super.key,
    required this.title,
    this.width,
    required this.vm,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        final theme = Theme.of(context);
        final color = vm.isLoading
            ? Colors.transparent
            : onTap == null
            ? theme.colorScheme.onSurface.withValues(
                alpha: PrymaryButton.disabledOpacity,
              )
            : theme.colorScheme.onPrimary;

        return Stack(
          children: [
            SizedBox(
              width: width,
              child: CupertinoButton.filled(
                onPressed: vm.isLoading || onTap == null
                    ? null
                    : () {
                        vm.setLoading(true);
                        onTap?.call();
                      },
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: PrymaryButton.minWidth,
                  ),
                  child: DefaultTextStyle(
                    style: TextStyle(color: color),
                    child: Text(title, textAlign: TextAlign.center),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: vm.isLoading,
              child: const Positioned.fill(
                child: Center(
                  child: SizedBox(
                    width: Sizes.iconSmall,
                    height: Sizes.iconSmall,
                    child: CircularProgressIndicator.adaptive(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
