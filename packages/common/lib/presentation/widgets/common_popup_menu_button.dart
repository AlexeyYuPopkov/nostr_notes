import 'package:common/app/theme/sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final class CommonPopupMenuItem<T> {
  const CommonPopupMenuItem({required this.title, required this.payload});
  final Widget title;
  final T payload;
}

final class CommonPopupMenuButton extends StatelessWidget {
  const CommonPopupMenuButton({
    super.key,
    required this.icon,
    required this.items,
    required this.offset,
    required this.onSelected,
    this.size = const Size(Sizes.icon, Sizes.iconTiny),
    this.itemBuilder = defaultItemBuilder,
  });
  static const useRootNavigator = true;
  final Widget icon;
  final Offset offset;
  final List<CommonPopupMenuItem> items;
  final Size size;
  final Future<void> Function(CommonPopupMenuItem) onSelected;
  final PopupMenuEntry<CommonPopupMenuItem> Function(
    BuildContext,
    CommonPopupMenuItem,
  )
  itemBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: PopupMenuButton(
          padding: EdgeInsets.zero,
          color: theme.colorScheme.surface.withValues(alpha: 0.90),
          offset: offset,
          useRootNavigator: useRootNavigator,
          borderRadius: const BorderRadius.all(
            Radius.circular(Sizes.radiusVariant),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(Sizes.radiusVariant),
            ),
          ),
          shadowColor: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          onSelected: (value) {
            // Wait for the popup close animation before executing the action,
            // otherwise navigator operations crash during the route's layout pass.
            Future.delayed(
              const Duration(milliseconds: 300),
              () => onSelected(value),
            );
          },
          itemBuilder: (context) {
            return [for (final item in items) itemBuilder(context, item)];
          },
          child: Center(child: _FadeOnPress(child: icon)),
        ),
      ),
    );
  }

  static PopupMenuEntry<CommonPopupMenuItem> defaultItemBuilder(
    BuildContext context,
    CommonPopupMenuItem item,
  ) {
    const minItemHeight = 32.0;

    return PopupMenuItem(
      value: item,
      height: minItemHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Sizes.indent),
        child: item.title,
      ),
    );
  }
}

final class _FadeOnPress extends StatefulWidget {
  const _FadeOnPress({required this.child});
  final Widget child;

  @override
  State<_FadeOnPress> createState() => _FadeOnPressState();
}

final class _FadeOnPressState extends State<_FadeOnPress> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedOpacity(
        opacity: _pressed ? 0.4 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}

final class PopupItemCupertinoButton extends StatefulWidget
    implements PopupMenuEntry<CommonPopupMenuItem<VoidCallback?>> {
  const PopupItemCupertinoButton({super.key, required this.value});
  final CommonPopupMenuItem<VoidCallback?> value;

  @override
  State<PopupItemCupertinoButton> createState() =>
      _PopupItemCupertinoButtonState();

  @override
  double get height => 28.0;

  @override
  bool represents(CommonPopupMenuItem<VoidCallback?>? value) =>
      value == this.value;
}

final class _PopupItemCupertinoButtonState
    extends State<PopupItemCupertinoButton> {
  @override
  Widget build(BuildContext context) {
    const minWidth = 146.0;

    final isEnabled = widget.value.payload != null;
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: minWidth),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: Sizes.indent2x),
        sizeStyle: CupertinoButtonSize.small,
        alignment: Alignment.centerLeft,
        onPressed: isEnabled
            ? () {
                Navigator.of(
                  context,
                  rootNavigator: CommonPopupMenuButton.useRootNavigator,
                ).pop();

                Future.microtask(() {
                  widget.value.payload?.call();
                });
              }
            : null,
        minimumSize: Size(widget.height, widget.height),
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.5,
          child: widget.value.title,
        ),

        // Text(
        //   widget.value.title,
        //   style: theme.textTheme.bodyMedium?.copyWith(
        //     color: isEnabled
        //         ? theme.colorScheme.onSurfaceVariant
        //         : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        //     letterSpacing: letterSpacing,
        //   ),
        // ),
      ),
    );
  }
}
