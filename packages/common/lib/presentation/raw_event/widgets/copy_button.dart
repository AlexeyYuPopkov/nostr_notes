import 'package:common/app/theme/sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final class CopyButtonVM extends ChangeNotifier {
  final String relay;
  final isCopying = ValueNotifier(false);

  CopyButtonVM(this.relay);

  void copy() {
    if (relay.isEmpty || isCopying.value) {
      return;
    }
    isCopying.value = true;

    Clipboard.setData(ClipboardData(text: relay)).then((_) {
      Future.delayed(AppDurations.extraLong2x, () => isCopying.value = false);
    });
  }
}

final class CopyButton extends StatelessWidget {
  final CopyButtonVM vm;
  final EdgeInsets padding;
  const CopyButton({
    super.key,
    required this.vm,
    this.padding = const EdgeInsets.all(Sizes.indent),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CupertinoButton(
      onPressed: () => vm.copy(),
      padding: padding,
      minimumSize: .zero,
      child: ValueListenableBuilder(
        valueListenable: vm.isCopying,
        builder: (context, isCopying, child) {
          return AnimatedSwitcher(
            duration: AppDurations.medium,
            child: isCopying
                ? Icon(
                    Icons.check,
                    size: Sizes.iconSmall,
                    color: theme.colorScheme.primary,
                  )
                : Icon(
                    Icons.copy,
                    size: Sizes.iconSmall,
                    color: theme.colorScheme.onSurface,
                  ),
          );
        },
      ),
    );
  }
}
