import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:common/data/repo/fetch_event_repo_impl.dart';
import 'package:common/domain/repo/fetch_event_repo.dart';
import 'package:di_storage/di_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nostr/model/nostr_event.dart';
import 'package:common/data/repo/get_event_repo_impl.dart';
import 'package:rxdart/rxdart.dart';

import 'widgets/copy_button.dart';

final class RawEventScreenVm extends ChangeNotifier {
  final String eventId;
  final isLoading = ValueNotifier(false);
  final isJsonExpanded = ValueNotifier(true);
  final isCopying = ValueNotifier(false);
  final event = ValueNotifier<NostrEvent?>(null);
  final json = ValueNotifier('');
  CopyButtonVM copyJsonButtonVm = CopyButtonVM('');

  late final _repo = GetEventRepoImpl(eventStore: DiStorage.shared.resolve());
  late final FetchEventRepo _fetchEventRepo = FetchEventRepoImpl(
    eventStore: DiStorage.shared.resolve(),
    client: DiStorage.shared.resolve(),
  );
  StreamSubscription? _eventSubscription;

  List<String> relays = [];
  Object? error;

  RawEventScreenVm({required this.eventId}) {
    _load();
    _eventSubscription = _fetchEventRepo
        .getEvents(eventId)
        .debounceTime(AppDurations.extraLong)
        .listen((event) {
          _load(silent: true);
        });
  }

  @override
  void dispose() {
    super.dispose();
    _eventSubscription?.cancel();
  }

  void toggleJsonExpanded() {
    isJsonExpanded.value = !isJsonExpanded.value;
  }

  Future<void> reload() => _load();

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      error = null;
      isLoading.value = true;
      notifyListeners();
    }

    var changed = false;
    try {
      final theEvent = await _repo.getEvent(eventId);

      if (event.value?.id != theEvent.id) {
        event.value = theEvent;
        json.value = const JsonEncoder.withIndent(
          '  ',
        ).convert(theEvent.toJson());
        copyJsonButtonVm = CopyButtonVM(json.value);
        changed = true;
      }

      final relays = await _repo
          .getEventRelays(eventId)
          .then((e) => e.sorted());

      if (!const ListEquality().equals(this.relays, relays)) {
        this.relays = relays;
        changed = true;
      }
    } catch (e) {
      error = e;
      changed = true;
    } finally {
      if (!silent) {
        isLoading.value = false;
        notifyListeners();
      } else if (changed) {
        notifyListeners();
      }
    }
  }

  void copy() {
    final json = this.json.value;
    if (json.isEmpty || isCopying.value) {
      return;
    }
    isCopying.value = true;

    Clipboard.setData(ClipboardData(text: json)).then((_) {
      Future.delayed(AppDurations.extraLong2x, () => isCopying.value = false);
    });
  }
}
