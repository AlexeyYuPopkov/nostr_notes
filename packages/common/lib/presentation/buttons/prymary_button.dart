import 'package:common/app/theme/sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final class PrymaryButton extends StatelessWidget {
  static const minWidth = 100.0;
  static const disabledOpacity = 0.5;
  final String title;
  final VoidCallback? onTap;

  const PrymaryButton({super.key, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final color = onTap == null
        ? theme.colorScheme.onSurface.withValues(
            alpha: PrymaryButton.disabledOpacity,
          )
        : theme.colorScheme.onPrimary;

    return CupertinoButton.filled(
      onPressed: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: minWidth),
        child: DefaultTextStyle(
          style: TextStyle(color: color),
          child: Text(title, textAlign: TextAlign.center),
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
  final PrymaryLoadingButtonVM vm;
  final VoidCallback? onTap;
  const PrymaryLoadingButton({
    super.key,
    required this.title,
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
            CupertinoButton.filled(
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
