import 'package:common/data/zap/lightning_donation_repo.dart';
import 'package:common/presentation/buttons/prymary_button.dart';
import 'package:di_storage/di_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../tabs/donation_screen_tab.dart';
import 'donate_lightning_data.dart';
import 'donate_lightning_event.dart';
import 'donate_lightning_state.dart';

final class DonateLightningBloc
    extends Bloc<DonateLightningEvent, DonateLightningState> {
  final LightningDonationRepo _repo;
  late final TextEditingController controller = TextEditingController(
    text: data.sats.toString(),
  );

  late final buttonVM = PrymaryLoadingButtonVM();

  DonateLightningData get data => state.data;

  DonateLightningBloc({LightningDonationRepo? repo})
    : _repo = repo ?? DiStorage.shared.resolve(),
      super(DonateLightningState.idle(data: DonateLightningData.initial())) {
    _setupHandlers();
  }

  @override
  Future<void> close() {
    controller.dispose();
    return super.close();
  }

  void _setupHandlers() {
    on<UpdateSatsEvent>(_onUpdateSats);
    on<SelectWalletEvent>(_onSelectWallet);
    on<ChangeTabEvent>(_onChangeTabEvent);
    on<SubmitEvent>(_onSubmit);
  }

  void _onUpdateSats(
    UpdateSatsEvent event,
    Emitter<DonateLightningState> emit,
  ) {
    emit(DonateLightningState.idle(data: data.copyWith(sats: event.sats)));
  }

  void _onSelectWallet(
    SelectWalletEvent event,
    Emitter<DonateLightningState> emit,
  ) {
    // Toggle: selecting the same wallet deselects it.
    final next = event.wallet == data.selectedWallet ? null : event.wallet;
    emit(DonateLightningState.idle(data: data.copyWith(wallet: () => next)));
  }

  void _onChangeTabEvent(
    ChangeTabEvent event,
    Emitter<DonateLightningState> emit,
  ) {
    emit(
      DonateLightningState.idle(
        data: data.copyWith(selectedTab: event.selectedTab),
      ),
    );
  }

  Future<void> _onSubmit(
    SubmitEvent event,
    Emitter<DonateLightningState> emit,
  ) async {
    buttonVM.setLoading(true);
    emit(DonateLightningState.loading(data: data));
    try {
      final invoice = await _repo.getInvoice(sats: data.sats);
      emit(
        DonateLightningState.idle(
          data: invoice.isNotEmpty
              ? data.copyWith(
                  selectedTab: DonationScreenTab.pay(),
                  // wallet: () => null,
                  invoice: invoice,
                )
              : data,
        ),
      );
    } catch (e) {
      emit(DonateLightningState.error(data: data, e: e));
    } finally {
      buttonVM.setLoading(false);
    }
  }
}
