import 'dart:convert';

import 'package:common/data/zap/zap_confirmation_dto.dart';
import 'package:common/domain/model/zap_confirmation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr/model/nostr_event.dart';
import 'package:nostr_notes/core/event_kind.dart';

void main() {
  group('ZapConfirmationMapper.map (NIP-57 fixtures)', () {
    test('maps invoice id/kind/sats from description zap request', () {
      final event = _nip57ReceiptEvent(
        descriptionJson: _nip57ZapRequestDescription(amountMillisats: '21000'),
      );

      final dto = ZapConfirmationMapper.map(event);

      expect(
        dto.id,
        '67b48a14fb66c60c8f9070bdeb37afdfcc3d08ad01989460448e4081eddda446',
      );
      expect(dto.kind, NostrKind.zapConfirmation);
      expect(
        dto.invoiceId,
        'd9cc14d50fcb8c27539aacf776882942c1a11ea4472f8cdec1dea82fab66279d',
      );
      expect(dto.invoiceKind, NostrKind.zapInvoice);
      expect(dto.invoiceSats, 21);
      expect(dto.isValid, isTrue);
    });

    test('uses receipt amount when zap request amount is absent', () {
      final event = _nip57ReceiptEvent(
        amountMillisats: '42000',
        descriptionJson: _nip57ZapRequestDescription(amountMillisats: null),
      );

      final dto = ZapConfirmationMapper.map(event);

      expect(dto.invoiceSats, 42);
      expect(dto.isValid, isTrue);
    });

    test('returns invalid mapping for malformed description', () {
      final event = _nip57ReceiptEvent(descriptionJson: '{not-json');

      final dto = ZapConfirmationMapper.map(event);

      expect(dto.invoiceId, isEmpty);
      expect(dto.invoiceKind, 0);
      expect(dto.invoiceSats, 21);
      expect(dto.isValid, isFalse);
    });

    test('returns invalid mapping when event kind is not zap receipt', () {
      final event = _nip57ReceiptEvent(
        kind: 1,
        descriptionJson: _nip57ZapRequestDescription(amountMillisats: '21000'),
      );

      final dto = ZapConfirmationMapper.map(event);

      expect(dto.invoiceId, isNotEmpty);
      expect(dto.invoiceKind, NostrKind.zapInvoice);
      expect(dto.invoiceSats, 21);
      expect(dto.isValid, isFalse);
    });
  });

  group('ZapConfirmationSum.fromEvents', () {
    test('sums only valid zaps', () {
      final validA = ZapConfirmationMapper.map(
        _nip57ReceiptEvent(
          descriptionJson: _nip57ZapRequestDescription(
            amountMillisats: '21000',
          ),
        ),
      );
      final validB = ZapConfirmationMapper.map(
        _nip57ReceiptEvent(
          id: 'another-valid-receipt',
          amountMillisats: '50000',
          descriptionJson: _nip57ZapRequestDescription(amountMillisats: null),
        ),
      );
      final invalid = ZapConfirmationMapper.map(
        _nip57ReceiptEvent(
          id: 'invalid-receipt',
          descriptionJson: 'broken-json',
        ),
      );

      final sum = ZapConfirmationSum.fromEvents([validA, validB, invalid]);

      expect(sum.satsAmount, 71);
    });
  });
}

NostrEvent _nip57ReceiptEvent({
  int kind = NostrKind.zapConfirmation,
  String id =
      '67b48a14fb66c60c8f9070bdeb37afdfcc3d08ad01989460448e4081eddda446',
  String amountMillisats = '21000',
  required String descriptionJson,
}) {
  return NostrEvent(
    id: id,
    pubkey: '9630f464cca6a5147aa8a35f0bcdd3ce485324e732fd39e09233b1d848238f31',
    createdAt: 1674164545,
    kind: kind,
    tags: [
      const [
        'p',
        '32e1827635450ebb3c5a7d12c1f8e7b2b514439ac10a67eef3d9fd9c5c68e245',
      ],
      const [
        'P',
        '97c70a44366a6535c145b333f973ea86dfdc2d7a99da618c40c64705ad98e322',
      ],
      const [
        'e',
        '3624762a1274dd9636e0c552b53086d70bc88c165bc4dc0f9e836a1eaf86c3b8',
      ],
      const ['k', '1'],
      const ['bolt11', 'lnbc10u1p3unwfusp5t9...'],
      ['amount', amountMillisats],
      ['description', descriptionJson],
      const [
        'preimage',
        '5d006d2cf1e73c7148e7519a4c68adc81642ce0e25a432b2434c99f97344c15f',
      ],
    ],
    content: '',
    sig:
        '77127f636577e9029276be060332ea565deaf89ff215a494ccff16ae3f757065e2bc59b2e8c113dd407917a010b3abd36c8d7ad84c0e3ab7dab3a0b0caa9835d',
  );
}

String _nip57ZapRequestDescription({required String? amountMillisats}) {
  final tags = <List<String>>[
    ['e', '3624762a1274dd9636e0c552b53086d70bc88c165bc4dc0f9e836a1eaf86c3b8'],
    ['p', '32e1827635450ebb3c5a7d12c1f8e7b2b514439ac10a67eef3d9fd9c5c68e245'],
    [
      'relays',
      'wss://relay.damus.io',
      'wss://nostr-relay.wlvs.space',
      'wss://nostr.fmt.wiz.biz',
    ],
  ];

  if (amountMillisats != null) {
    tags.add(['amount', amountMillisats]);
  }

  return jsonEncode({
    'pubkey':
        '97c70a44366a6535c145b333f973ea86dfdc2d7a99da618c40c64705ad98e322',
    'content': '',
    'id': 'd9cc14d50fcb8c27539aacf776882942c1a11ea4472f8cdec1dea82fab66279d',
    'created_at': 1674164539,
    'sig':
        '77127f636577e9029276be060332ea565deaf89ff215a494ccff16ae3f757065e2bc59b2e8c113dd407917a010b3abd36c8d7ad84c0e3ab7dab3a0b0caa9835d',
    'kind': NostrKind.zapInvoice,
    'tags': tags,
  });
}
