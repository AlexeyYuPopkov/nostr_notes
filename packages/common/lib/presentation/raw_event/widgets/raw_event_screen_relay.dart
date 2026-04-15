import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/tools/list_item_position.dart';
import 'package:flutter/material.dart';
import 'package:common/presentation/raw_event/widgets/copy_button.dart';

final class RawEventScreenRelay extends StatefulWidget {
  final ListItemPosition position;
  final String relay;
  const RawEventScreenRelay({
    super.key,
    required this.relay,
    required this.position,
  });

  @override
  State<RawEventScreenRelay> createState() => _RelayTileState();
}

final class _RelayTileState extends State<RawEventScreenRelay> {
  late final _vm = CopyButtonVM(widget.relay);

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
        color: theme.colorScheme.outlineVariant,
        borderRadius: widget.position.getRadius(),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: Sizes.indent,
          top: widget.position == .first ? Sizes.halfIndent : Sizes.zero,
          right: Sizes.indent,
          bottom: widget.position == .last ? Sizes.halfIndent : Sizes.zero,
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
