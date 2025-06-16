abstract class BaseNostrEvent {
  const BaseNostrEvent();

  EventType get eventType;
}

enum EventType {
  request('REQ'),
  eose('EOSE'),
  event('EVENT'),
  ok('OK');

  final String type;
  const EventType(this.type);
}
