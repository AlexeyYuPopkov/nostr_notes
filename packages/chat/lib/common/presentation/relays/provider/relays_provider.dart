import 'package:chat/common/presentation/relays/provider/relays_data.dart';
import 'package:chat/common/presentation/relays/provider/relays_state.dart';
import 'package:common/domain/model/relay_info.dart';
import 'package:common/domain/repo/relays_list_repo.dart';
import 'package:common/domain/usecases/get_relays_usecase.dart';
import 'package:common/presentation/buttons/prymary_button.dart';
import 'package:material_ui/material_ui.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'relays_provider.g.dart';

@riverpod
final class RelaysProvider extends _$RelaysProvider {
  late final RelaysListRepo _relaysListRepo = GetIt.I.get();
  late final _getRelaysUsecase = GetRelaysUsecase(
    relaysListRepo: _relaysListRepo,
  );
  late final saveButtonVm = PrymaryLoadingButtonVM();

  RelaysData get data => state.data;

  RelaysProvider() {
    _onInit();
  }

  @override
  RelaysState build() {
    return RelaysState.common(data: RelaysData.initial());
  }

  void _onInit() async {
    try {
      final result = await _getRelaysUsecase.execute();

      state = RelaysState.common(
        data: data.copyWith(
          relays: result.relays,
          selectedRelays: result.selected,
          initialRelays: result.selected,
        ),
      );
    } catch (e) {
      state = RelaysState.error(error: e, data: data);
    }
  }

  void onToggle(RelayInfo relay) {
    final isSelected = data.isSelected(relay);
    final selected = isSelected
        ? data.selectedRelays.where((r) => r != relay).toSet()
        : {...data.selectedRelays, relay};

    state = RelaysState.common(data: data.copyWith(selectedRelays: selected));
  }

  void onSave() async {
    try {
      saveButtonVm.setLoading(true);
      await Future.delayed(Durations.medium2);
      await _relaysListRepo.saveRelaysList(
        data.selectedRelays.map((e) => e.url.toString()).toSet(),
      );

      _onInit();
    } catch (e) {
      state = RelaysState.error(error: e, data: data);
    } finally {
      saveButtonVm.setLoading(false);
    }
  }

  void onAdd(String urlStr) {
    try {
      final relay = RelayInfo(url: Uri.parse(urlStr));
      final selectedRelays = {...data.selectedRelays, relay};

      state = RelaysState.common(
        data: data.copyWith(
          relays: data.relays.any((r) => r.url == relay.url)
              ? null
              : [...data.relays, relay],
          selectedRelays: selectedRelays,
        ),
      );
    } catch (e) {
      state = RelaysState.error(error: e, data: data);
    }
  }
}
