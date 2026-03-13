import 'package:di_storage/di_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/auth/domain/usecase/credentials_data_usecase.dart';
import 'package:nostr_notes/auth/presentation/settings/preferences/credentials_data_screen/bloc/credentials_data_data.dart';
import 'package:nostr_notes/auth/presentation/settings/preferences/credentials_data_screen/bloc/credentials_data_event.dart';
import 'package:nostr_notes/auth/presentation/settings/preferences/credentials_data_screen/bloc/credentials_data_state.dart';

final class CredentialsDataBloc
    extends Bloc<CredentialsDataEvent, CredentialsDataState> {
  late final _credentialsDataUsecase = CredentialsDataUsecase(
    session: DiStorage.shared.resolve(),
  );

  CredentialsDataData get data => state.data;

  CredentialsDataBloc()
    : super(CredentialsDataState.common(data: CredentialsDataData.initial())) {
    _setupHandlers();

    add(const CredentialsDataEvent.initial());
  }

  void _setupHandlers() {
    on<InitialEvent>(_onInitialEvent);
  }

  void _onInitialEvent(
    InitialEvent event,
    Emitter<CredentialsDataState> emit,
  ) async {
    try {
      emit(CredentialsDataState.loading(data: data));

      final result = await _credentialsDataUsecase.execute();

      emit(
        CredentialsDataState.common(
          data: data.copyWith(
            nsec: result.nsec,
            pubkey: result.publicKey,
            privateKey: result.privateKey,
            pin: result.pin,
          ),
        ),
      );
    } catch (e) {
      emit(CredentialsDataState.error(error: e, data: data));
    }
  }
}
