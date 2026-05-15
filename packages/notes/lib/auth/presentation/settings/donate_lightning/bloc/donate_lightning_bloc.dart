import 'package:common/data/zap/lightning_donation_repo.dart';
import 'package:di_storage/di_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'donate_lightning_data.dart';
import 'donate_lightning_event.dart';
import 'donate_lightning_state.dart';

final class DonateLightningBloc
    extends Bloc<DonateLightningEvent, DonateLightningState> {
  final LightningDonationRepo _repo;

  DonateLightningData get data => state.data;

  DonateLightningBloc({LightningDonationRepo? repo})
    : _repo = repo ?? DiStorage.shared.resolve(),
      super(DonateLightningState.idle(data: const DonateLightningData())) {
    on<UpdateSatsEvent>(_onUpdateSats);
    on<SelectWalletEvent>(_onSelectWallet);
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

  Future<void> _onSubmit(
    SubmitEvent event,
    Emitter<DonateLightningState> emit,
  ) async {
    emit(DonateLightningState.loading(data: data));
    try {
      final invoice = await _repo.getInvoice(sats: data.sats);
      emit(DonateLightningState.invoiceReady(data: data, invoice: invoice));
    } catch (e) {
      emit(DonateLightningState.error(data: data, e: e));
    }
  }
}
