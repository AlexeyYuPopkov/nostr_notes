import 'package:di_storage/di_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/auth/domain/repo/relays_list_repo.dart';
import 'package:nostr_notes/auth/domain/usecase/get_relays_usecase.dart';
import 'package:rxdart/rxdart.dart';

import 'onboarding_relays_data.dart';
import 'onboarding_relays_event.dart';
import 'onboarding_relays_state.dart';

final class OnboardingRelaysBloc
    extends Bloc<OnboardingRelaysEvent, OnboardingRelaysState> {
  static const debounceDuration = Duration(milliseconds: 300);
  OnboardingRelaysData get data => state.data;
  late final RelaysListRepo _relaysListRepo = DiStorage.shared.resolve();
  late final _getRelaysUsecase = GetRelaysUsecase(
    relaysListRepo: _relaysListRepo,
  );
  late final controller = TextEditingController();

  OnboardingRelaysBloc()
    : super(
        OnboardingRelaysState.common(data: OnboardingRelaysData.initial()),
      ) {
    _setupHandlers();

    add(const OnboardingRelaysEvent.initial());
  }

  void _setupHandlers() {
    on<InitialEvent>(_onInitialEvent);
    on<ToggleEvent>(
      _onToggleEvent,
      transformer: (events, mapper) =>
          events.debounceTime(debounceDuration).switchMap(mapper),
    );
  }

  void _onInitialEvent(
    InitialEvent event,
    Emitter<OnboardingRelaysState> emit,
  ) async {
    try {
      final result = await _getRelaysUsecase.execute();

      emit(
        OnboardingRelaysState.common(
          data: data.copyWith(
            relays: result.relays,
            selectedRelays: result.selected,
          ),
        ),
      );
    } catch (e) {
      emit(OnboardingRelaysState.error(e: e, data: data));
    }
  }

  void _onToggleEvent(ToggleEvent event, Emitter<OnboardingRelaysState> emit) {
    final isSelected = data.isSelected(event.relay);
    final selected = isSelected
        ? data.selectedRelays.where((r) => r != event.relay).toSet()
        : {...data.selectedRelays, event.relay};

    emit(
      OnboardingRelaysState.common(
        data: data.copyWith(selectedRelays: selected),
      ),
    );
  }
}
