import 'dart:async';
import 'package:common/presentation/tools/section_scroll_vm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/common/presentation/formatters/date_group.dart';

import 'accs_event.dart';
import 'accs_state.dart';
import 'accs_data.dart';

final class AccsBloc extends Bloc<AccsEvent, AccsState> {
  AccsData get data => state.data;

  late final scrollController = ScrollController();
  late final sectionScrollVm = SectionScrollVm<NotesListHeader>(
    scrollController: scrollController,
  );

  AccsBloc() : super(AccsState.common(data: AccsData.initial())) {
    _setupHandlers();

    add(const AccsEvent.initial());
  }

  void _setupHandlers() {
    on<InitialEvent>(_onInitialEvent);
  }

  void _onInitialEvent(InitialEvent event, Emitter<AccsState> emit) async {
    try {
      emit(AccsState.loading(data: data));

      await Future.delayed(const Duration(seconds: 2));

      emit(AccsState.common(data: data));
    } catch (e) {
      emit(AccsState.error(e: e, data: data));
    }
  }
}
