import 'dart:convert';

import 'package:common/domain/model/zap_confirmation.dart';
import 'package:nostr/model/nostr_event.dart';
import 'package:nostr_notes/core/event_kind.dart';

final class ZapConfirmationDto implements ZapConfirmation {
  final NostrEvent event;
  @override
  final String id;
  @override
  final int kind;
  @override
  final bool isValid;
  @override
  final String invoiceId;
  @override
  final int invoiceKind;
  @override
  final int invoiceSats;

  const ZapConfirmationDto({
    required this.event,
    required this.id,
    required this.kind,
    required this.isValid,
    required this.invoiceId,
    required this.invoiceKind,
    required this.invoiceSats,
  });
}

final class ZapConfirmationMapper {
  const ZapConfirmationMapper._();

  static ZapConfirmationDto map(NostrEvent event) {
    final map = _zapRequestMap(event);

    final invoiceId = _invoiceId(map);
    final invoiceKind = _invoiceKind(map);
    final invoiceSats = _invoiceSats(event, map);
    final isValid =
        event.id.isNotEmpty &&
        event.kind == NostrKind.zapConfirmation &&
        invoiceId.isNotEmpty &&
        invoiceKind != 0 &&
        invoiceSats > 0;

    return ZapConfirmationDto(
      event: event,
      id: event.id,
      kind: event.kind,
      isValid: isValid,
      invoiceId: invoiceId,
      invoiceKind: invoiceKind,
      invoiceSats: invoiceSats,
    );
  }

  static String _invoiceId(Map<String, dynamic>? map) {
    if (map == null) return '';

    final value = map['id'];
    return value is String ? value : '';
  }

  static int _invoiceKind(Map<String, dynamic>? map) {
    if (map == null) return 0;

    final value = map['kind'];
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;

    return 0;
  }

  static int _invoiceSats(NostrEvent event, Map<String, dynamic>? map) {
    // NIP-57: zap request carries "amount" in millisats.
    final requestAmountMillisats = _requestAmountMillisats(map);
    if (requestAmountMillisats != null && requestAmountMillisats > 0) {
      return requestAmountMillisats ~/ 1000;
    }

    final receiptAmountMillisats = _parseInt(event.getFirstTagStr('amount'));
    if (receiptAmountMillisats != null && receiptAmountMillisats > 0) {
      return receiptAmountMillisats ~/ 1000;
    }

    return 0;
  }

  static Map<String, dynamic>? _zapRequestMap(NostrEvent event) {
    final description = event.getFirstTagStr('description');
    if (description == null || description.isEmpty) return null;

    try {
      final decoded = jsonDecode(description);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  static int? _requestAmountMillisats(Map<String, dynamic>? map) {
    if (map == null) return null;

    final tags = map['tags'];
    if (tags is! List) return null;

    for (final tag in tags) {
      if (tag is! List || tag.length < 2) continue;

      final key = tag[0];
      final value = tag[1];
      if (key == 'amount') {
        return _parseInt(value);
      }
    }

    return null;
  }

  static int? _parseInt(Object? value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
