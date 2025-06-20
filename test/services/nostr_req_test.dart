import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/services/model/nostr_filter.dart';
import 'package:nostr_notes/services/model/nostr_req.dart';

void main() {
  group('NostrReq', () {
    test('serialization of main tags', () {
      const filter = NostrFilter(
        kinds: [1, 2],
        ids: ['id1', 'id2'],
        authors: ['author1', 'author2'],
        e: ['e1', 'e2'],
        t: ['t1', 't2'],
        p: ['p1', 'p2'],
        a: ['a1', 'a2'],
        since: 123,
        until: 456,
        limit: 10,
        search: 'query',
      );

      const nostrReq = NostrReq(
        filters: [filter],
      );

      final nostrReqStr = nostrReq.serialized('subscriptionId');

      expect(nostrReqStr, isA<String>());

      const expected = r'["REQ","subscriptionId",'
          r'{"kinds":[1,2],'
          r'"ids":["id1","id2"],'
          r'"authors":["author1","author2"],'
          r'"#e":["e1","e2"],'
          r'"#t":["t1","t2"],'
          r'"#p":["p1","p2"],'
          r'"#a":["a1","a2"],'
          r'"since":123,"until":456,"limit":10,"search":"query"}]';

      expect(nostrReqStr, expected);
    });

    test('serialization of additional tags', () {
      const filter = NostrFilter(
        kinds: [1, 2],
        additional: {
          '#customKey1': 'customValue1',
          '#customKey2': ['customValue2', 'relay2'],
        },
      );

      const nostrReq = NostrReq(
        filters: [filter],
      );

      final nostrReqStr = nostrReq.serialized('subscriptionId');

      expect(nostrReqStr, isA<String>());

      const expected = r'["REQ",'
          r'"subscriptionId",'
          r'{"kinds":[1,2],'
          r'"#customKey1":"customValue1",'
          r'"#customKey2":["customValue2","relay2"]}]';

      expect(nostrReqStr, expected);
    });
  });
}
