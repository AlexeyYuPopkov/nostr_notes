import 'package:common/domain/model/event.dart';

abstract interface class GetEventRepo {
  Future<Event> getEvent(String eventId);
}
