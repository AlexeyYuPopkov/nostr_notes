import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/services/model/nostr_event.dart';
import 'package:nostr_notes/services/model/tag/tag.dart';

void main() {
  group('NostrEventTags', () {
    test('getFirstTag', () {
      const event = NostrEvent(
        kind: 1,
        id: 'eventid1',
        pubkey: 'pubkey1',
        content: 'content',
        sig: 'sig',
        createdAt: 0,
        tags: [
          ['p', 'pubkey1', 'pubkey11', 'pubkey111'],
          ['p', 'pubkey2'],
          ['p', 'pubkey3'],
          ['e', 'e1'],
          ['t', 't1'],
        ],
      );

      expect(event.getFirstTag(Tag.p), 'pubkey1');
      expect(event.getFirstTag(Tag.e), 'e1');
      expect(event.getFirstTag(Tag.t), 't1');
      expect(event.getFirstTag(Tag.a), null);
    });

    test('getTagsSet', () {
      const event = NostrEvent(
        kind: 1,
        id: 'eventid1',
        pubkey: 'pubkey1',
        content: 'content',
        sig: 'sig',
        createdAt: 0,
        tags: [
          ['p', 'pubkey1'],
          ['p', 'pubkey2'],
          ['p', 'pubkey3', 'extra'],
          ['e', 'e1'],
          ['e', 'e2', 'e3'],
          ['t', 't1'],
          ['t', 't2', 't3'],
          ['custom', 'custom1', 'custom2'],
        ],
      );

      expect(event.getTagsSet(Tag.p), {
        'pubkey1',
        'pubkey2',
        'pubkey3',
        'extra',
      });
      expect(event.getTagsSet(Tag.e), {'e1', 'e2', 'e3'});
      expect(event.getTagsSet(Tag.t), {'t1', 't2', 't3'});
      expect(event.getTagsSet(Tag.a), <String>{});
      expect(event.getTagsSet(const CustomTag()), {'custom1', 'custom2'});
    });
  });
}

final class CustomTag extends BaseTag {
  const CustomTag();

  @override
  String get value => 'custom';
}
