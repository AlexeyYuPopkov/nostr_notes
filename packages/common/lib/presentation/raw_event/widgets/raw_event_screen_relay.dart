import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/tools/list_item_position.dart';
import 'package:flutter/material.dart';
import 'package:common/presentation/raw_event/widgets/copy_button.dart';

final class RawEventScreenRelay extends StatefulWidget {
  final ListItemPosition position;
  final String relay;
  final void Function(BuildContext)? onChangeDependencies;

  const RawEventScreenRelay({
    super.key,
    required this.relay,
    required this.position,
    this.onChangeDependencies,
  });

  @override
  State<RawEventScreenRelay> createState() => _RelayTileState();
}

final class _RelayTileState extends State<RawEventScreenRelay> {
  late final _vm = CopyButtonVM(widget.relay);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.onChangeDependencies != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && context.mounted) {
          widget.onChangeDependencies?.call(context);
        }
      });
    }
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: widget.position.getRadius(),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: Sizes.indent2x,
          top: widget.position == .first ? Sizes.indent : Sizes.zero,
          right: Sizes.indent2x,
          bottom: widget.position == .last ? Sizes.indent : Sizes.zero,
        ),
        child: Row(
          spacing: Sizes.indentVariant2x,
          children: [
            Icon(
              Icons.wifi,
              size: Sizes.iconSmall,
              color: theme.colorScheme.primary,
            ),

            Text(widget.relay, style: theme.textTheme.bodyLarge),
            const Spacer(),
            CopyButton(
              vm: _vm,
              padding: const EdgeInsets.only(
                top: Sizes.indent,
                bottom: Sizes.indent,
                left: Sizes.indent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
