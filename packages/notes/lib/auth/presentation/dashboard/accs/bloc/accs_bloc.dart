import 'dart:async';
import 'package:common/presentation/tools/section_scroll_vm.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/common/presentation/formatters/date_group.dart';

import '../../bloc/dashboard_bloc.dart';
import '../../bloc/dashboard_command.dart';
import 'accs_event.dart';
import 'accs_state.dart';
import 'accs_data.dart';

final class AccsBloc extends Bloc<AccsEvent, AccsState> {
  AccsData get data => state.data;

  final SectionScrollVm<NotesListHeader> sectionScrollVm;

  StreamSubscription<DashboardCommand>? _dashboardCommandSubscription;

  AccsBloc({required DashboardBloc dashboardBloc})
    : sectionScrollVm = SectionScrollVm<NotesListHeader>(
        scrollController: dashboardBloc.scrollController,
      ),
      super(AccsState.common(data: AccsData.initial())) {
    _setupHandlers();

    // Re-sync on refresh / app-resume, same as every other tab.
    _dashboardCommandSubscription = dashboardBloc.commands.listen(
      (_) => add(const AccsEvent.initial()),
    );

    add(const AccsEvent.initial());
  }

  @override
  Future<void> close() {
    _dashboardCommandSubscription?.cancel();
    sectionScrollVm.dispose();
    return super.close();
  }

  void _setupHandlers() {
    on<InitialEvent>(_onInitialEvent);
  }

  void _onInitialEvent(InitialEvent event, Emitter<AccsState> emit) async {
    try {
      emit(AccsState.loading(data: data));

      await Future.delayed(const Duration(seconds: 2));

      if (isClosed) {
        return;
      }
      emit(AccsState.common(data: data));
    } catch (e) {
      if (isClosed) {
        return;
      }
      emit(AccsState.error(e: e, data: data));
    }
  }
}
