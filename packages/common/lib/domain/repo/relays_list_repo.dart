import 'package:common/tools/disposable.dart';

abstract interface class RelaysListRepo implements Disposable {
  Set<String> getRelaysList();
  Future<void> saveRelaysList(Set<String> relays);
  Set<String> getSuggestedRelays();
  Stream<Set<String>> get relaysListStream;
  Future<void> clear();
}
