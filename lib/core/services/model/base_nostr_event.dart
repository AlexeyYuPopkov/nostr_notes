abstract class BaseNostrEvent {
  const BaseNostrEvent();

  EventType get eventType;
}

enum EventType {
  request('REQ'),
  eose('EOSE'),
  event('EVENT');

  final String type;
  const EventType(this.type);
}
