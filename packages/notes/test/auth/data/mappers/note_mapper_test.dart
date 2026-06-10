import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr/model/nostr_event.dart';
import 'package:nostr_notes/auth/data/mappers/note_mapper.dart';
import 'package:nostr_notes/auth/domain/model/label.dart';

import '../fixtures/notes_fixtures.dart';

void main() {
  group('NoteMapper tests with real data', () {
    test('maps complex real event correctly (Kind 30023)', () {
      final json = jsonDecode(NotesFixtures.eventJson1);
      final event = NostrEvent.fromJson(json[2] as Map<String, dynamic>);

      final note = NoteMapper.fromNostrEvent(event);

      expect(note, isNotNull);
      expect(
        note!.eventId,
        equals(
          'a826d76e943cab49f4d10cbc7c609e8b2f34c1f215ac4db7d4a55af96aa57dbd',
        ),
      );
      expect(note.dTag, equals('06e492d0-22c9-11f1-b2b7-af1d94bcfeaf'));
      expect(note.createdAt.millisecondsSinceEpoch ~/ 1000, equals(1780644645));
      expect(note.updatedAt.millisecondsSinceEpoch ~/ 1000, equals(1773838222));
      expect(note.summary, startsWith('AgA75nMio'));
      expect(note.labels, hasLength(1));

      final rawEvent = NoteMapper.toNostrEvent(
        note,

        pubkey:
            '8c78952169177d4fba467bee54029da5877ef4ffdaf10192baa74044a914df8f',
      );

      expect(rawEvent.id, equals(note.eventId));
      expect(rawEvent.kind, equals(30023));
      expect(
        rawEvent.pubkey,
        equals(
          '8c78952169177d4fba467bee54029da5877ef4ffdaf10192baa74044a914df8f',
        ),
      );
      expect(rawEvent.content, equals(event.content));
      expect(rawEvent.tags, equals(event.tags));
    });

    test('fromNostrEvents maps array of two real events', () {
      final json1 = jsonDecode(NotesFixtures.eventJson1);
      final json2 = jsonDecode(NotesFixtures.eventJson2);
      final event1 = NostrEvent.fromJson(json1[2] as Map<String, dynamic>);
      final event2 = NostrEvent.fromJson(json2[2] as Map<String, dynamic>);

      final notes = NoteMapper.fromNostrEvents([event1, event2]);

      expect(notes, hasLength(2));

      // event1: has updated_at and labels
      expect(
        notes[0].eventId,
        equals(
          'a826d76e943cab49f4d10cbc7c609e8b2f34c1f215ac4db7d4a55af96aa57dbd',
        ),
      );
      expect(notes[0].dTag, equals('06e492d0-22c9-11f1-b2b7-af1d94bcfeaf'));
      expect(
        notes[0].updatedAt.millisecondsSinceEpoch ~/ 1000,
        equals(1773838222),
      );
      expect(notes[0].labels, hasLength(1));

      // event2: no updated_at → updatedAt == createdAt, no labels
      expect(
        notes[1].eventId,
        equals(
          'abd1e0dd92bdd51e7b08f56822b72177ea8e4b303f3817865f44beccdc193ea4',
        ),
      );
      expect(notes[1].dTag, equals('ca980f90-22c9-11f1-b2b7-af1d94bcfeaf'));
      expect(
        notes[1].createdAt.millisecondsSinceEpoch ~/ 1000,
        equals(1773838550),
      );
      expect(notes[1].updatedAt, equals(notes[1].createdAt));
      expect(notes[1].labels, isEmpty);

      // round-trip for event2 (no updated_at / labels in reconstructed tags)
      final rawEvent2 = NoteMapper.toNostrEvent(
        notes[1],

        pubkey:
            '8c78952169177d4fba467bee54029da5877ef4ffdaf10192baa74044a914df8f',
      );
      expect(rawEvent2.tags, equals(event2.tags));
    });

    group('labels round-trip', () {
      test(
        'fromNostrEvent parses NIP-44 blob as EncryptedLabel (internal storage)',
        () {
          final json = jsonDecode(NotesFixtures.eventJson1);
          final event = NostrEvent.fromJson(json[2] as Map<String, dynamic>);

          final note = NoteMapper.fromNostrEvent(event)!;

          expect(note.labels, hasLength(1));
          expect(note.labels.first, isA<EncryptedLabel>());
        },
      );

      test(
        'fromNostrEvent parses joined JSON array as Label objects (export format)',
        () {
          final json = jsonDecode(NotesFixtures.eventJson1);
          final event = NostrEvent.fromJson(json[2] as Map<String, dynamic>);

          // Simulate an exported event where the labels tag holds a plain JSON array
          final exportedEvent = NostrEvent(
            id: event.id,
            kind: event.kind,
            pubkey: event.pubkey,
            createdAt: event.createdAt,
            content: event.content,
            sig: event.sig,
            tags: [
              ...event.tags.where((t) => t.first != 'labels'),
              const ['labels', '["work","personal"]'],
            ],
          );

          final note = NoteMapper.fromNostrEvent(exportedEvent)!;

          expect(note.labels, hasLength(2));
          expect(note.labels.every((l) => l is Label), isTrue);
          expect(
            note.labels.map((l) => l.textValue),
            containsAll(const ['work', 'personal']),
          );
        },
      );

      test('toNostrEvent writes plain Label list as a single joined tag', () {
        final json = jsonDecode(NotesFixtures.eventJson1);
        final event = NostrEvent.fromJson(json[2] as Map<String, dynamic>);
        final note = NoteMapper.fromNostrEvent(
          event,
        )!.copyWith(labels: [Label.from('work'), Label.from('personal')]);

        final rawEvent = NoteMapper.toNostrEvent(note);

        final labelsTags = rawEvent.tags
            .where((t) => t.first == 'labels')
            .toList();
        expect(labelsTags, hasLength(1));
        expect(labelsTags.first[1], equals('["work","personal"]'));
      });

      test(
        'toNostrEvent writes EncryptedLabel as its raw blob (no joining)',
        () {
          final json = jsonDecode(NotesFixtures.eventJson1);
          final event = NostrEvent.fromJson(json[2] as Map<String, dynamic>);
          final note = NoteMapper.fromNostrEvent(event)!;
          final encryptedBlob = (note.labels.first as EncryptedLabel).textValue;

          final rawEvent = NoteMapper.toNostrEvent(note);

          final labelsTags = rawEvent.tags
              .where((t) => t.first == 'labels')
              .toList();
          expect(labelsTags, hasLength(1));
          expect(labelsTags.first[1], equals(encryptedBlob));
        },
      );
    });
  });
}

// const NotesFixtures.eventJson1 = r'''
// [
//     "EVENT",
//     "f5996f40-6622-11f0-b6aa-77622cb064581",
//     {
//         "content": "AnnU/0Et8TZDkMJKWjzxQRva1kH3gbtwEoVR/5r66SkYdQrajRgGXs4yA9dfD1v/9gpsgHU3VRKuhbjqqtO+6asuw+I8sOXqIPKTtQ5h9HSK8/RpOb059d4N06lAs/QXnEPDel+4YOuw8b6MoJrqovTHi53uiJEPAFFXhmzBVomt/ZLsA41/LOJRInsIU3RtMkfw0pG8JAuNwyo6jDiGgyyKCvd7iyi0vSJSNMKLPAAzW93rIZtFegHBUoxKBOf7YFJTgmVDEjiZtvTrtfQwvn4HoT5vT94YFhnyX1Usok/yUSdK7cxF0nIOIikZGAfo3cicFLfOm1AHkD7YQ5GzONpCwM3U/mekGWHrcbgAN9/L8kxANIk0Mnu4i25V57fWQbbImpjRYUMFv3pVwkQzBRjh8oYMAr6YkbiAtl8CZWFlwHB/WTYKw+gvSuR+b52I6LTCujELEPUFoaKFixyu6L16wgyJrzcDSAbe1YQFwfpzaHsHkTX1qlZnCN58FJrCS6sMjsbDV/MSh8E6pJDhDn/4/yF0LHcFiv/EGrs6KJf9U3h9vHpNtQHMg9M72TVO0tIW8cImly5vrQ0LSFlR/Muab3BUjcTHmyCXGuj/RxmHxdeict5ajUeXZlMrKMgaEsX6zscg2eVpX4iJl9aVia58BNsXOf9v4ZSe1yVSyVuDEU5owFxHX72ozI7YRTaI1dobfKdLIihTL9sSuQ/SDE+dvy5rxrGT4gvU3zhD2mgnHMkQfRmQdgvKwih/neAft1U8dg5eSLnNh3FF1l+LSFzRnYLKaB5aojhgCV846auoewn9xdDsxdfwuUU15BwQCbK6tEJmT6Q5ofZKEJgZ6tYrLMMgREsrcOdKVvxEUkR9GNXP2iViKXGPRck+QkL/jjVTe33/EdCEXQ1pOpm8h1PjYGXTsWJzaTTphae0eybUA2I=",
//         "created_at": 1780644645,
//         "id": "a826d76e943cab49f4d10cbc7c609e8b2f34c1f215ac4db7d4a55af96aa57dbd",
//         "kind": 30023,
//         "pubkey": "8c78952169177d4fba467bee54029da5877ef4ffdaf10192baa74044a914df8f",
//         "sig": "1c7fdaaa6a3d9bbb4c4b9437e1079c0077ef329805bf519145b7f6fbc463d4c877b7b9b7efc1637dc21b8e3322da029f17b015272b15729a1607ebc24ed30253",
//         "tags": [
//             [
//                 "client",
//                 "996e10ba"
//             ],
//             [
//                 "t",
//                 "996e10ba"
//             ],
//             [
//                 "d",
//                 "06e492d0-22c9-11f1-b2b7-af1d94bcfeaf"
//             ],
//             [
//                 "p",
//                 "8c78952169177d4fba467bee54029da5877ef4ffdaf10192baa74044a914df8f"
//             ],
//             [
//                 "summary",
//                 "AgA75nMioUyWltO2Y3Cjr5sz1r3pLvDTIf/wGrejOtBg26v6q+EJUBQ1cfBHJk1OR3SpQjOv1ny5LsZw7tSByKqn4Qbyv+mRCUb/RkTtEXHSEE8H76Q/jJAzbrXyCANFnuQoZX3i6Y3sSrxwEX6GIQQZdVlnW8DRS+NZBiz7mT1epwu8Vw1187gAmQDWTBvNPXflNFF81MwnYkqK2TcGhl1zHA=="
//             ],
//             [
//                 "updated_at",
//                 "1773838222"
//             ],
//             [
//                 "labels",
//                 "At1vZM5263zzJ3ho1nC4bP4g7Y2DPdSG764Aqb8s9lMRbThGN08b81cR2Hnel3IH5/HD4AY8+5GZivECh9B2viV2sLcbcCKdcUmYLNDXDbfXIrQrnk1BYQES4thfcUGUhCLc"
//             ]
//         ]
//     }
// ]
// ''';
// const NotesFixtures.eventJson2 = r'''
// [
//     "EVENT",
//     "f5996f40-6622-11f0-b6aa-77622cb064581",
//     {
//         "content": "AuoYbYaME453YpHOAoYX6IjLrZoedMF5fqRqQHB/rOGBS0t2t+cxZxhDAZHMcc2JE52fjxlnK6eAeLgSnxAiMPVLDZNGhRZG0eDi4G7bJ1OagRfG7kexnTHQ8vNaPmrYnUjvYqqU5T7krpzbUUgO+AxE2pRA2P+O4lyuwqu806hNlhdcAGRNEHjlO8OxqnUJHvRzWj2ICp37yCDwNclJTeJjyuFOcngINOdIjwAZvz/HyW80zKKw2Wd9ERM1CyXkbB2kYDfKknGmLfQhIDre7v2uAlvaNPtPq3XXefesctpSrSqmvobyw1jHbSx3LiThqXkXTDn4p0ao49SO7aXU2E6AQnSiMkcYSOiQoKKJbV8rFVvxmUZbQQeHgTGdp83AWJBqwfhU17KE7Jz/KIkTgO5bSM9cfEEs3DSJsvVT+PRJgcbohSrfwn333z+epjfdSagETVRvkJbinI3H98V3dWZT4CaT7L63dtKowb6EjkVtmLgFXhES/wrt7UOlbUbdPjUWPEGDdTTIghnSZhFqQD4vU4MPMi2nz17WEPF1bIhCJVBCnAHeiGjvdmfaHkbuqPJiaEzPKSehY8BCd7SZhrBjDop/bdNPoOS7lQhgb26+xWThDZkvLYE5oacDfKtXyrlRx6GW9lfYes5vJtfq5612llTtATYyz3SMUoxFPgvyDoRWe+8GkmzG4arVbwqPFGW9+3UfJYRX9ZP9I9rXHQ9p5I5rNnxhUJNewcUnVT5SNGRuznKUTjZk06dJXF/G1dID0mUgyUhhGjsAjo+VXCQXwBCarDjBee4V1FeiWC1ObHWeNT9GUGRJUSvivQ4uSdEjYg5DfsIuBDpUsZWjPdWagkn0on1YmtPsmkRMS5JErGrOswGkffCCjoBUM/4EUdEHHZwSNp+5cdBqM5ggwbKri2Z6RMmPHLW5uN4DQJjuHReEQvinEL25hgP4Z2/pjtV5i1zW2ozfnfzgqjyUoDTcfS1i1ZNLwbbJWzKYtKzzxSq+7c5PKcsrqp0OzMHaW1K/eRQn6PsiNAfCQhjfh9ld3YodeXnlt42peNEgZHy8xMFkpLXQgugPPwSnLIoJpjqf/AwrpizGg68/Xql7TFrgACIV4Dkrhxnkxf/oCtloeyr/RtwfI+CASEvN3N9xN/TOTQ7SdwvOAgxkM5gO1FrJANX3Nd5qFphZwsg4O9174d/j9OADeGOgs/lsN/yPpiFsf3kqeyc6tuZNeAjA4YMpwmhZqqnHygjcc8rSg7ozqQ5VG7SsUp1Lazrb9Idd5uw3",
//         "created_at": 1773838550,
//         "id": "abd1e0dd92bdd51e7b08f56822b72177ea8e4b303f3817865f44beccdc193ea4",
//         "kind": 30023,
//         "pubkey": "8c78952169177d4fba467bee54029da5877ef4ffdaf10192baa74044a914df8f",
//         "sig": "9ce2838add32633e84aee2c2153b19e5ecb22454b017097c904dd601e7bdf681edc62fc785700d7bf73422494d4bb40b0d57acc5ea10b11c039b9672bf0ba88e",
//         "tags": [
//             [
//                 "client",
//                 "996e10ba"
//             ],
//             [
//                 "t",
//                 "996e10ba"
//             ],
//             [
//                 "d",
//                 "ca980f90-22c9-11f1-b2b7-af1d94bcfeaf"
//             ],
//             [
//                 "p",
//                 "8c78952169177d4fba467bee54029da5877ef4ffdaf10192baa74044a914df8f"
//             ],
//             [
//                 "summary",
//                 "AuMYFFgcKKNRWMCCdy7Yawy6vEnHAf4bdJ3xXH3eigXLVwQxtHm2Jjt7Umucj5fRaU5a8zbrY9ZnGJyZtZcuriQkjC6B0288vYzqeKQ1fOLjof00JEUmozWAYQXRpde8j9Oz30QOXNBuv46HA0PzcYD4O0l7Q15Z5AvqnYxLFFNrxli0Wyk+2O41bSddhSZqlwtBMY1N3YfxRXotOPI11ia0+usrWbGixZrx43wLWjuLS2Wk+6duv2LqCTjtQEgm0IIT"
//             ]
//         ]
//     }
// ]''';
