import 'package:nostr_notes/core/tools/disposable.dart';

abstract interface class AppLifecycleListenerRepository implements Disposable {
  Stream<bool> get isActiveStream;
}
