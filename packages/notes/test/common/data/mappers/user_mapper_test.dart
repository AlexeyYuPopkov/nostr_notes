import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr/model/nostr_event.dart';
import 'package:nostr_notes/common/data/mappers/user_mapper.dart';
import 'package:nostr_notes/common/domain/model/user.dart';

void main() {
  group('UserMapper test', () {
    late List<NostrEvent> events;

    setUpAll(() {
      final rawEvents = jsonDecode(_Helper.jsonStr) as List<dynamic>;
      events = rawEvents.map((e) {
        final payload = e[2] as Map<String, dynamic>;
        return NostrEvent.fromJson(payload);
      }).toList();
    });

    test('should return null if event kind is not metadata (0)', () {
      const invalidEvent = NostrEvent(
        kind: 1, // Text Note
        id: '123',
        pubkey: 'pubkey',
        createdAt: 0,
        tags: [],
        content: '{"name": "test"}',
        sig: 'sig',
      );

      final result = UserMapper.fromNostrEvent(invalidEvent);

      expect(result, isNull);
    });

    test('should return null if content is invalid json', () {
      const invalidEvent = NostrEvent(
        kind: 0,
        id: '123',
        pubkey: 'pubkey',
        createdAt: 0,
        tags: [],
        content: '{invalid_json}',
        sig: 'sig',
      );

      final result = UserMapper.fromNostrEvent(invalidEvent);

      expect(result, isNull);
    });

    test(
      'should successfully map 1st valid event with mixed nip05 & lud16',
      () {
        final user = UserMapper.fromNostrEvent(events[0]);

        expect(user, isA<User>());
        expect(
          user!.pubkey,
          '875707cc561b3aa8222752592ccc9725d641c4628fbcfa5c4795c5d3f6fcd0ad',
        );
        expect(user.name, 'sats_per_zloty');
        expect(user.displayName, 'sats per złoty');
        expect(user.website, 'https://hodl.camp/');
        expect(
          user.picture,
          'https://hodl.camp/nostr/sats_per_zloty-profile.jpg',
        );
        expect(user.nip05, 'sats_per_zloty@hodl.camp');
        expect(user.lud16, 'mutatrum@hodl.camp');
      },
    );

    test('should map 2nd event with minimal fields', () {
      final user = UserMapper.fromNostrEvent(events[1]);

      expect(user, isA<User>());
      expect(
        user!.pubkey,
        'a3b992c81450f5cbdb73c838b7a7a71397c7f244668afca1a5fd971621b5ff0f',
      );
      expect(user.name, 'luca');
      expect(user.displayName, 'luca');
      expect(user.about, isNull);
      expect(user.picture, isNull);
    });

    test('should map 3rd event with lud16 and display_name', () {
      final user = UserMapper.fromNostrEvent(events[2]);

      expect(user, isA<User>());
      expect(
        user!.pubkey,
        '9594cba44e882e5b367001081196f7020c2bcb9ac6f933f3f839fcf93936ab3c',
      );
      expect(user.name, isNull);
      expect(user.displayName, 'Gfgxdf');
      expect(
        user.lud16,
        'npub1jk2vhfzw3qh9kdnsqyypr9hhqgxzhju6cmun8ulc8870jwfk4v7qrx9qcp@npub.cash',
      );
    });

    test('should map 4th event with all fields and unicode characters', () {
      final user = UserMapper.fromNostrEvent(events[3]);

      expect(user, isA<User>());
      expect(
        user!.pubkey,
        'f6edcd7e35ee2b864b65512c89458d5b52b614be06c504d62e0569ad8b1294dd',
      );
      expect(user.name, 'まいるす');
      expect(user.displayName, 'まいるす');
      expect(user.about, 'ペンギンおじさん。主夫。餃子を焼くのがちょう得意');
      expect(
        user.banner,
        'https://nostr.build/i/nostr.build_15f2858962dc8b1106ee6f1b7f20436292505bba0b50167b2dd1c741b5186a20.jpg',
      );
      expect(user.nip05, 'milestone@iris.to');
      expect(user.lud16, 'motherlaura02@walletofsatoshi.com');
    });

    test(
      'should map 5th event with empty lud16 and custom fields correctly handling missing standard fields',
      () {
        final user = UserMapper.fromNostrEvent(events[4]);

        expect(user, isA<User>());
        expect(
          user!.pubkey,
          '5369b58d5089b26829e5fad4f6c76b9ab8250226e24a99cbbac1200f42bbfa09',
        );
        expect(user.name, 'Celsians Club');
        expect(user.displayName, isNull);
        expect(user.nip05, 'celsians@bchnostr.com');
        expect(user.lud16, isEmpty);
      },
    );
  });
}

final class _Helper {
  static const jsonStr = r'''
  [
      [
          "EVENT",
          "f5996f40-6622-11f0-b6aa-77622cb064581",
          {
              "content": "{\"name\":\"sats_per_zloty\",\"display_name\":\"sats per złoty\",\"about\":\"Posts sats per Polish złoty every four hours. Price data from Binance. Automation by nostr:npub1hklphk7fkfdgmzwclkhshcdqmnvr0wkfdy04j7yjjqa9lhvxuflsa23u2k.\",\"website\":\"https://hodl.camp/\",\"picture\":\"https://hodl.camp/nostr/sats_per_zloty-profile.jpg\",\"nip05\":\"sats_per_zloty@hodl.camp\",\"nip05valid\":true,\"lud16\":\"mutatrum@hodl.camp\"}",
              "created_at": 1783693800,
              "id": "c9d07e25982b31dd92def6d817e82aa52081075972ae74bbc30cb9229bd9eb56",
              "kind": 0,
              "pubkey": "875707cc561b3aa8222752592ccc9725d641c4628fbcfa5c4795c5d3f6fcd0ad",
              "sig": "3b89c6b8e869be710d7f8b902287e876a2a4b14719b0b8dabbde544c6be9ec6865aacf6d4bf1e03602f4205bb04d7081dd00912cbdf256b70df2c0b99d6a8507",
              "tags": []
          }
      ],
      [
          "EVENT",
          "f5996f40-6622-11f0-b6aa-77622cb064581",
          {
              "content": "{\"name\":\"luca\",\"display_name\":\"luca\"}",
              "created_at": 1783693881,
              "id": "d411db2258b57bcb6eae997afc6c0a28eea7d16427701feb5fca4937571fd1f4",
              "kind": 0,
              "pubkey": "a3b992c81450f5cbdb73c838b7a7a71397c7f244668afca1a5fd971621b5ff0f",
              "sig": "74df096b4b0ae01746b20e276c49fc18e3f1bc358c33f88a51a165e9f71ed9fec0db18b23908d9c0863cc513c68de672e24f7aa58475fc4b4bfebc20480dba9b",
              "tags": []
          }
      ],
      [
          "EVENT",
          "f5996f40-6622-11f0-b6aa-77622cb064581",
          {
              "content": "{\"display_name\":\"Gfgxdf\",\"lud16\":\"npub1jk2vhfzw3qh9kdnsqyypr9hhqgxzhju6cmun8ulc8870jwfk4v7qrx9qcp@npub.cash\"}",
              "created_at": 1783693889,
              "id": "553ec825490a9e4a5bd493fc4a53089b1f0ee2919e89381552da49f48a27394b",
              "kind": 0,
              "pubkey": "9594cba44e882e5b367001081196f7020c2bcb9ac6f933f3f839fcf93936ab3c",
              "sig": "26474eddc0092206694c9eeb71ba0c227b1f2eb52e385f891867463b33c2231d23dc275270a0e880488cf4db39cb47b0ae5309f0df4a33761478761ab9defa8f",
              "tags": []
          }
      ],
      [
          "EVENT",
          "f5996f40-6622-11f0-b6aa-77622cb064581",
          {
              "content": "{\"banner\":\"https://nostr.build/i/nostr.build_15f2858962dc8b1106ee6f1b7f20436292505bba0b50167b2dd1c741b5186a20.jpg\",\"nip05\":\"milestone@iris.to\",\"picture\":\"https://cdn-ak.f.st-hatena.com/images/fotolife/m/milestone/20250827/20250827215032.jpg\",\"display_name\":\"まいるす\",\"about\":\"ペンギンおじさん。主夫。餃子を焼くのがちょう得意\",\"name\":\"まいるす\",\"username\":\"milestone\",\"displayName\":\"まいるす\",\"lud16\":\"motherlaura02@walletofsatoshi.com\",\"created_at\":1677204427,\"nip05valid\":true}",
              "created_at": 1783693890,
              "id": "87a702c348d10ec5422f57c5da843db88f534bae3dcfef4bfd10e6fb7e18de85",
              "kind": 0,
              "pubkey": "f6edcd7e35ee2b864b65512c89458d5b52b614be06c504d62e0569ad8b1294dd",
              "sig": "0f412783ff3d7e71abe4e013c018aaab360d8e49e9e17f3a4c8fe8702a0a84669c708552bd77db8ee59488a03c511d856233fcbebd5c8735eaba9123ade2a953",
              "tags": [
                  [
                      "alt",
                      "User profile for まいるす"
                  ],
                  [
                      "name",
                      "まいるす"
                  ],
                  [
                      "display_name",
                      "まいるす"
                  ],
                  [
                      "picture",
                      "https://cdn-ak.f.st-hatena.com/images/fotolife/m/milestone/20250827/20250827215032.jpg"
                  ],
                  [
                      "banner",
                      "https://nostr.build/i/nostr.build_15f2858962dc8b1106ee6f1b7f20436292505bba0b50167b2dd1c741b5186a20.jpg"
                  ],
                  [
                      "about",
                      "ペンギンおじさん。主夫。餃子を焼くのがちょう得意"
                  ],
                  [
                      "nip05",
                      "milestone@iris.to"
                  ],
                  [
                      "lud16",
                      "motherlaura02@walletofsatoshi.com"
                  ],
                  [
                      "client",
                      "Amethyst"
                  ]
              ]
          }
      ],
      [
          "EVENT",
          "f5996f40-6622-11f0-b6aa-77622cb064581",
          {
              "content": "{\"name\":\"Celsians Club\",\"about\":\"Join us in shaping a future where \\ndecentralized stewardship thrives \\nhttps://celsians.github.io/club/\",\"picture\":\"https://npub12d5mtr2s3xexs209lt20d3mtn2uz2q3xuf9fnja6cysq7s4mlgysqk793a.blossom.band/6068b29a70efb41b80402f5c6314508561d37388f018f57f327e87ece9dd8506.webp\",\"banner\":\"https://npub12d5mtr2s3xexs209lt20d3mtn2uz2q3xuf9fnja6cysq7s4mlgysqk793a.blossom.band/94e63d42456d7bebe49cd34db224626d2b5f89c1382db2d4ac99adb964fc08bf.webp\",\"nip05\":\"celsians@bchnostr.com\",\"lud16\":\"\",\"bch_address\":\"qrpxyz493g4fhmdc9qwacgc7h4ud82x35ueqxrrgcl\"}",
              "created_at": 1783693904,
              "id": "57a6971c59c63fff233dffeb21a37d0238cc4895c7bf25c8d984e8a2316d7144",
              "kind": 0,
              "pubkey": "5369b58d5089b26829e5fad4f6c76b9ab8250226e24a99cbbac1200f42bbfa09",
              "sig": "56a19d45f9b8376e74ee6c23fb2a3733a25507fa4090c5c11ab1051a66ea3d90db474f444c1158782cdc8f4a03ac3b861789975e6897008a065282b727d91950",
              "tags": []
          }
      ]
  ]
''';
}
