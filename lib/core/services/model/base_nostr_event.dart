abstract class BaseNostrEvent {
  const BaseNostrEvent();

  EventType get eventType;

  String serialized(String subscriptionId);
}

enum EventType {
  request('REQ'),
  eose('EOSE'),
  event('EVENT');

  final String type;
  const EventType(this.type);
}
