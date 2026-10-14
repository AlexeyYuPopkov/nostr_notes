// Usage (see e.g. NotePreviewScreen, ExportImportScreen):
//
//   // 1. Wrap the screen; the HUD is drawn into the nearest Overlay
//   //    (the app's Navigator provides one).
//   @override
//   Widget build(BuildContext context) {
//     return ProgressHudScopeWidget(
//       child: BlocProvider(
//         create: (_) => SomeBloc(),
//         child: BlocListener<SomeBloc, SomeState>(
//           listener: _listener,
//           child: ...,
//         ),
//       ),
//     );
//   }
//
//   // 2. Drive it from a context *below* the wrapper — `ProgressHud.of`
//   //    returns null for the context that builds ProgressHudScopeWidget.
//   void _listener(BuildContext context, SomeState state) {
//     final hud = ProgressHud.of(context);
//     hud?.setLoading(isLoading: state is LoadingState);
//     if (state is LoadingState) hud?.vm.progress = state.progress; // 0..1
//   }
//
//   // Look: spinner + checkmark at progress >= 0.9 (default),
//   // spinner only, or a silent input blocker.
//   hud?.setLoading(isLoading: true, policy: HudPolicy.indicator(hint: '…'));
//   hud?.setLoading(isLoading: true, policy: HudPolicy.blocking());

import 'dart:developer';

import 'package:common/app/theme/sizes.dart';
import 'package:common/app/theme/success_colors.dart';
import 'package:flutter/material.dart';

part 'hud_policy_part.dart';

final class ProgressHud extends InheritedWidget {
  static const semanticsId = 'ProgressHud';
  const ProgressHud({super.key, required this.vm, required super.child});
  final ProgressHudVm vm;

  static ProgressHud? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ProgressHud>();
  }

  static void setLoadingOf(
    BuildContext context, {
    required bool isLoading,
    ProgressHudStyle policy = const ProgressHudStyle.defaultValue(),
  }) {
    of(context)?.setLoading(isLoading: isLoading, policy: policy);
  }

  void setLoading({
    required bool isLoading,
    ProgressHudStyle policy = const ProgressHudStyle.defaultValue(),
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
  ProgressHudVm({this._policy = const ProgressHudStyle.defaultValue()});
  ProgressHudStyle _policy;

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
    ProgressHudStyle policy = const ProgressHudStyle.defaultValue(),
  }) {
    if (_isLoading != value) {
      _isLoading = value;
      _progress = null;
      _policy = value ? policy : const Indicator();
      notifyListeners();
    }
  }
}

final class ProgressHudScopeWidget extends StatefulWidget {
  const ProgressHudScopeWidget({super.key, required this.child});
  final Widget child;

  @override
  State<ProgressHudScopeWidget> createState() => _ProgressHudScopeWidgetState();
}

final class _ProgressHudScopeWidgetState extends State<ProgressHudScopeWidget> {
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
    vm.dispose();
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
    return Semantics(
      identifier: ProgressHud.semanticsId,
      child: Stack(
        children: [
          const Positioned.fill(child: ColoredBox(color: Color(0x4D9E9E9E))),
          widget.vm._policy.build(context, widget.vm),
        ],
      ),
    );
  }
}
