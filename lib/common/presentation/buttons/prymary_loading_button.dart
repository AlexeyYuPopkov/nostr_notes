import 'package:flutter/cupertino.dart';

import 'send_form_button_wrapper.dart';
import 'vm/loading_button_vm.dart';

final class PrymaryLoadingButton extends StatefulWidget {
  final String title;
  final ValueChanged<LoadingButtonVM>? onTap;
  final VoidCallback? onComplete;
  final bool stretch;

  const PrymaryLoadingButton({
    super.key,
    required this.title,
    this.onTap,
    this.onComplete,
    this.stretch = false,
  });

  @override
  State<PrymaryLoadingButton> createState() => _PrymaryLoadingButtonState();
}

final class _PrymaryLoadingButtonState extends State<PrymaryLoadingButton> {
  late final LoadingButtonVM vm = LoadingButtonVM();

  @override
  void initState() {
    super.initState();
    vm.addListener(_shouldUpdate);
  }

  @override
  void dispose() {
    vm.removeListener(_shouldUpdate);
    super.dispose();
  }

  void _shouldUpdate() {
    setState(() {});

    if (vm.isComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          widget.onComplete?.call();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SendFormButtonWrapper(
      isLoading: vm.isLoading,
      isEnabled: !vm.isLoading,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 100.0),
        child: CupertinoButton.filled(
          onPressed: () => widget.onTap?.call(vm),
          child: Visibility.maintain(
            visible: !vm.isLoading,
            child: SizedBox(
              width: widget.stretch ? double.infinity : null,
              child: Text(
                widget.title,
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
