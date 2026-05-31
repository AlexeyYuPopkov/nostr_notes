import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/common/domain/repository/biometric_repository.dart';

import 'bloc/verification_bloc.dart';
import 'bloc/verification_bloc_state.dart';

final class VerificationWidget extends StatefulWidget {
  final Widget child;
  const VerificationWidget({super.key, required this.child});

  @override
  State<VerificationWidget> createState() => _VerificationWidgetState();
}

final class _VerificationWidgetState extends State<VerificationWidget> {
  OverlayEntry? overlayEntry;
  final _overlayKey = GlobalKey<OverlayState>();
  late final _bloc = VerificationBloc(
    biometricRequest: BiometricRepositoryRequest(
      localizedReason: context.biometricRequestReason,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<VerificationBloc, VerificationBlocState>(
        listener: _listener,
        buildWhen: (previous, current) => false,
        builder: (_, _) => Overlay(
          key: _overlayKey,
          initialEntries: [OverlayEntry(builder: (_) => widget.child)],
        ),
      ),
    );
  }

  void _listener(BuildContext context, VerificationBlocState state) {
    switch (state) {
      case VisibleOverlayState():
        showOverlay();
        break;
      case HiddenOverlayState():
        hideOverLay();
        break;
    }
  }

  @override
  void dispose() {
    hideOverLay();
    super.dispose();
  }

  void showOverlay() {
    hideOverLay();

    final entry = OverlayEntry(
      builder: (context) {
        return AbsorbPointer(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
            child: const ColoredBox(color: Colors.black12),
          ),
        );
      },
    );

    _overlayKey.currentState?.insert(entry);
    overlayEntry = entry;
    log('Overlay shown', name: 'VerificationWidget');
  }

  void toggleOverLay() {
    overlayEntry == null ? showOverlay() : hideOverLay();
  }

  void hideOverLay() {
    overlayEntry?.remove();
    overlayEntry?.dispose();
    overlayEntry = null;
  }
}

extension on BuildContext {
  String get biometricRequestReason => 'Unlock application';
}
