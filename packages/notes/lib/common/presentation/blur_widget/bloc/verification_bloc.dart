import 'dart:async';
import 'package:di_storage/di_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/common/domain/repository/biometric_repository.dart';
import 'package:nostr_notes/common/domain/usecase/verification_usecase.dart';

import 'package:rxdart/rxdart.dart';

import 'verification_bloc_event.dart';
import 'verification_bloc_state.dart';

final class VerificationBloc
    extends Bloc<VerificationBlocEvent, VerificationBlocState> {
  static const debounceGuard = Duration(milliseconds: 200);
  final BiometricRepositoryRequest biometricRequest;
  late final VerificationUsecase verificationUsecase = DiStorage.shared
      .resolve();

  late final Stream<Verification> verificationUsecaseStream =
      verificationUsecase.createStream(biometryRequest: biometricRequest);
  late final StreamSubscription stateStreamSubscription;

  VerificationBloc({required this.biometricRequest})
    : super(const VerificationBlocState.hidden()) {
    _setupHandlers();
    _setupSubscriptions();
  }

  @override
  Future<void> close() async {
    await stateStreamSubscription.cancel();
    await verificationUsecase.dispose();
    return super.close();
  }

  void _setupHandlers() {
    on<ShowOverlayEvent>(
      _onShowOverlayEvent,
      transformer: (events, mapper) =>
          events.debounceTime(debounceGuard).switchMap(mapper),
    );
    on<HideOverlayEvent>(
      _onHideOverlayEvent,
      transformer: (events, mapper) =>
          events.debounceTime(debounceGuard).switchMap(mapper),
    );
  }

  void _setupSubscriptions() {
    stateStreamSubscription = verificationUsecaseStream
        .debounceTime(debounceGuard)
        .listen((e) {
          _onStateChanged(e);
        });
  }

  void _onShowOverlayEvent(
    ShowOverlayEvent event,
    Emitter<VerificationBlocState> emit,
  ) => emit(const VerificationBlocState.visible());

  void _onHideOverlayEvent(
    HideOverlayEvent event,
    Emitter<VerificationBlocState> emit,
  ) => emit(const VerificationBlocState.hidden());

  void _onStateChanged(Verification status) {
    switch (status) {
      case Allow():
        add(const VerificationBlocEvent.hide());
      case Deny():
        add(const VerificationBlocEvent.show());
      case Processing():
        break;
    }
  }
}
