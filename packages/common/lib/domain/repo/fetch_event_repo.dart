import 'package:common/domain/model/event.dart';

abstract interface class FetchEventRepo {
  Stream<Iterable<BaseEvent>> getEvents(String eventId);
}
