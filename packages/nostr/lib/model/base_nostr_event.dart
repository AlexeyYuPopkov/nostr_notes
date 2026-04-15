abstract class BaseNostrEvent {
  const BaseNostrEvent();

  EventType get eventType;
}

enum EventType {
  request('REQ'),
  eose('EOSE'),
  event('EVENT'),
  ok('OK'),
  close('CLOSE'),
  closed('CLOSED');

  final String type;
  const EventType(this.type);

  static EventType? tryFromString(String type) {
    switch (type) {
      case 'REQ':
        return EventType.request;
      case 'EOSE':
        return EventType.eose;
      case 'EVENT':
        return EventType.event;
      case 'OK':
        return EventType.ok;
      case 'CLOSE':
        return EventType.close;
      case 'CLOSED':
        return EventType.closed;
      default:
        return null;
    }
  }
}
