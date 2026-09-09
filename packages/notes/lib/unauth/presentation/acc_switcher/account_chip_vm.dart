import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:nostr_notes/common/domain/model/user.dart';
import 'package:nostr_notes/common/domain/usecase/get_user_usecase.dart';

final class AccountChipVM extends ChangeNotifier {
  final String pubkey;

  final GetUserUsecase getUserUsecase;

  User? _user;
  User? get user => _user;

  StreamSubscription? _subscription;

  AccountChipVM({required this.pubkey, required this.getUserUsecase}) {
    _subscription = getUserUsecase.execute(pubkey: pubkey).listen((user) {
      if (user == null || user == _user) return;

      _user = user;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
