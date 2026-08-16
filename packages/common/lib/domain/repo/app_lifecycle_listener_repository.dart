import 'package:common/tools/disposable.dart';

abstract interface class AppLifecycleListenerRepository implements Disposable {
  Stream<bool> get isActiveStream;
}
