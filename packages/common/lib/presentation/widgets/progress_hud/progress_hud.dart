import 'dart:developer';

import 'package:common/app/theme/sizes.dart';
import 'package:flutter/material.dart';

final class ProgressHud extends InheritedWidget {
  const ProgressHud({super.key, required this.vm, required super.child});
  final ProgressHudVm vm;

  static ProgressHud? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ProgressHud>();
  }

  static void setLoadingOf(
    BuildContext context, {
    required bool isLoading,
    HudPolicy policy = const HudPolicy.defaultValue(),
  }) {
    of(context)?.setLoading(isLoading: isLoading, policy: policy);
  }

  void setLoading({
    required bool isLoading,
    HudPolicy policy = const HudPolicy.defaultValue(),
  }) {
    if (vm.isLoading != isLoading) {
      log('Setting isLoading to $isLoading', name: 'ProgressHud');
      vm.setLoading(isLoading, policy: policy);
    }
  }

  static void setProgress(BuildContext context, {required double progress}) {
    final hud = of(context);
    if (hud != null && hud.vm.progress != progress) {
      log('Setting progress to $progress', name: 'ProgressHud');
      hud.vm.progress = progress;
    }
  }

  @override
  bool updateShouldNotify(covariant ProgressHud oldWidget) => false;
}

final class ProgressHudVm extends ChangeNotifier {
  ProgressHudVm({HudPolicy policy = const HudPolicy.defaultValue()})
    : _policy = policy;
  HudPolicy _policy;

  double? _progress;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  double? get progress => _progress;

  set progress(double? value) {
    if (_progress != value) {
      _progress = value;
      notifyListeners();
    }
  }

  void setLoading(
    bool value, {
    HudPolicy policy = const HudPolicy.defaultValue(),
  }) {
    if (_isLoading != value) {
      _isLoading = value;
      _progress = null;
      _policy = value ? policy : const Indicator();
      notifyListeners();
    }
  }
}

final class ProgressHudWidget extends StatelessWidget {
  const ProgressHudWidget({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Overlay(
      initialEntries: [
        OverlayEntry(builder: (_) => ProgressHudWidgetContent(child: child)),
      ],
    );
  }
}

final class ProgressHudWidgetContent extends StatefulWidget {
  const ProgressHudWidgetContent({super.key, required this.child});
  final Widget child;

  @override
  State<ProgressHudWidgetContent> createState() =>
      _ProgressHudWidgetContentState();
}

final class _ProgressHudWidgetContentState
    extends State<ProgressHudWidgetContent> {
  late final vm = ProgressHudVm();
  OverlayEntry? overlayEntry;

  @override
  void initState() {
    vm.addListener(_onVmChanged);
    super.initState();
  }

  @override
  void dispose() {
    vm.removeListener(_onVmChanged);
    _hideOverlay();
    super.dispose();
  }

  void _onVmChanged() {
    vm.isLoading ? _showOverlay() : _hideOverlay();
  }

  void _hideOverlay() {
    overlayEntry?.remove();
    overlayEntry?.dispose();
    overlayEntry = null;
  }

  void _showOverlay() {
    _hideOverlay();
    overlayEntry = OverlayEntry(builder: (context) => _OverlayContent(vm: vm));
    Overlay.of(context, debugRequiredFor: widget).insert(overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHud(vm: vm, child: widget.child);
  }
}

class _OverlayContent extends StatefulWidget {
  const _OverlayContent({required this.vm});
  final ProgressHudVm vm;

  @override
  State<_OverlayContent> createState() => _OverlayContentState();
}

final class _OverlayContentState extends State<_OverlayContent> {
  late final ProgressHudVm vm = widget.vm;

  @override
  void initState() {
    vm.addListener(_onVmChanged);
    super.initState();
  }

  void _onVmChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    vm.removeListener(_onVmChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: ColoredBox(color: Color(0x4D9E9E9E))),
        widget.vm._policy.build(context, widget.vm),
      ],
    );
  }
}

sealed class HudPolicy {
  const factory HudPolicy.defaultValue() = Indicator;
  factory HudPolicy.indicator({String? hint}) => Indicator(hint: hint ?? '');
  factory HudPolicy.blocking() = Blocking;
  const HudPolicy();
  Widget build(BuildContext context, ProgressHudVm vm);
}

final class Indicator extends HudPolicy {
  const Indicator({this.hint = ''});
  final String hint;

  @override
  Widget build(BuildContext context, ProgressHudVm vm) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Sizes.indent2x),
        child: RepaintBoundary(
          child: Container(
            height: 110.0,
            width: 110.0,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(Sizes.padding2x),
            ),
            clipBehavior: Clip.hardEdge,
            child: Material(
              child: Stack(
                children: [
                  Center(
                    child: SizedBox(
                      width: Sizes.defaultRowHeight,
                      height: Sizes.defaultRowHeight,
                      child: CircularProgressIndicator(value: vm.progress),
                    ),
                  ),
                  if (hint.isNotEmpty)
                    Positioned(
                      bottom: Sizes.indent,
                      left: Sizes.indent,
                      right: Sizes.indent,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          hint,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: TextSizes.error,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class Blocking extends HudPolicy {
  const Blocking();

  @override
  Widget build(BuildContext context, ProgressHudVm vm) {
    return const SizedBox.expand();
  }
}
