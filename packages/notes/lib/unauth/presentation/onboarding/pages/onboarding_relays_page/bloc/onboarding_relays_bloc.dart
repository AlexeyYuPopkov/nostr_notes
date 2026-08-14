import 'package:common/domain/model/relay_info.dart';
import 'package:common/domain/usecases/relays_monitoring_usecase.dart';
import 'package:di_storage/di_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:common/domain/repo/relays_list_repo.dart';
import 'package:common/domain/usecases/get_relays_usecase.dart';
import 'package:common/presentation/buttons/prymary_button.dart';
import 'package:nostr/nostr_client/nostr_client.dart';
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
  late final saveButtonVm = PrymaryLoadingButtonVM();

  late final NostrClient _client = DiStorage.shared.resolve();
  // Same app-wide singleton the dashboard's RelayStatusIndicator reads —
  // not a bloc-owned instance, so it isn't disposed here (see close()) and
  // there's only ever one NostrClientDelegate registered on _client.
  late final RelaysMonitoringUsecase monitor = DiStorage.shared.resolve();

  OnboardingRelaysBloc()
    : super(
        OnboardingRelaysState.common(data: OnboardingRelaysData.initial()),
      ) {
    _setupHandlers();

    add(const OnboardingRelaysEvent.initial());
  }

  @override
  Future<void> close() {
    // _client (and monitor) are the app-wide singletons, so any toggling
    // done here that was never saved must be rolled back on the way out —
    // otherwise unsaved candidates stay connected in the shared client.
    final persisted = _relaysListRepo
        .getRelaysList()
        .map((url) => RelayInfo(url: Uri.parse(url)))
        .toSet();
    _syncClientRelays(persisted);
    return super.close();
  }

  /// Keeps [_client]'s relay set in lockstep with [selected], so
  /// [monitor] only tracks (and probes) relays the user has actually
  /// picked — mirrors [NotesRepositoryImpl.syncRelays]'s diff pattern.
  void _syncClientRelays(Set<RelayInfo> selected) {
    final selectedUrls = selected.map((r) => r.url.toString()).toSet();
    final current = _client.relaysList.toSet();
    for (final removed in current.difference(selectedUrls)) {
      _client.removeRelay(removed);
    }
    _client.addRelays(selectedUrls.difference(current));
  }

  void _setupHandlers() {
    on<InitialEvent>(_onInitialEvent);
    on<ToggleEvent>(
      _onToggleEvent,
      transformer: (events, mapper) =>
          events.debounceTime(debounceDuration).switchMap(mapper),
    );
    on<SaveEvent>(
      _onSaveEvent,
      transformer: (events, mapper) =>
          events.debounceTime(debounceDuration).switchMap(mapper),
    );
    on<OnAddEvent>(
      _onAddEvent,
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
      _syncClientRelays(result.selected);

      emit(
        OnboardingRelaysState.common(
          data: data.copyWith(
            relays: result.relays,
            selectedRelays: result.selected,
            initialRelays: result.selected,
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
    _syncClientRelays(selected);

    emit(
      OnboardingRelaysState.common(
        data: data.copyWith(selectedRelays: selected),
      ),
    );
  }

  void _onSaveEvent(
    SaveEvent event,
    Emitter<OnboardingRelaysState> emit,
  ) async {
    try {
      saveButtonVm.setLoading(true);
      await Future.delayed(Durations.medium2);
      await _relaysListRepo.saveRelaysList(
        data.selectedRelays.map((e) => e.url.toString()).toSet(),
      );

      add(const OnboardingRelaysEvent.initial());
    } catch (e) {
      emit(OnboardingRelaysState.error(e: e, data: data));
    } finally {
      saveButtonVm.setLoading(false);
    }
  }

  void _onAddEvent(OnAddEvent event, Emitter<OnboardingRelaysState> emit) {
    try {
      final relay = RelayInfo(url: Uri.parse(event.urlStr));
      final selectedRelays = {...data.selectedRelays, relay};
      _syncClientRelays(selectedRelays);

      emit(
        OnboardingRelaysState.common(
          data: data.copyWith(
            relays: data.relays.any((r) => r.url == relay.url)
                ? null
                : [...data.relays, relay],
            selectedRelays: selectedRelays,
          ),
        ),
      );
    } catch (e) {
      emit(OnboardingRelaysState.error(e: e, data: data));
    }
  }
}
