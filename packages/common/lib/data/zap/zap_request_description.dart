import 'dart:convert';

import 'package:nostr/model/nostr_event.dart';
import 'package:nostr/model/tag/tag_value.dart';

final class ZapRequestDescription {
  const ZapRequestDescription._();

  static Map<String, dynamic>? parseFromReceipt(NostrEvent event) {
    final description = event.getFirstTagStr('description');
    if (description == null || description.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(description);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  static bool matchesInvoiceId(
    Map<String, dynamic>? descriptionMap,
    String invoiceEventId,
  ) {
    if (invoiceEventId.isEmpty) {
      return true;
    }

    final id = descriptionMap?['id'];
    return id is String && id == invoiceEventId;
  }

  static bool hasClientTag(
    Map<String, dynamic>? descriptionMap,
    String clientTagValue,
  ) {
    if (clientTagValue.isEmpty) {
      return true;
    }

    final tags = descriptionMap?['tags'];
    if (tags is! List) {
      return false;
    }

    for (final rawTag in tags) {
      if (rawTag is! List || rawTag.length < 2) {
        continue;
      }

      if (rawTag[0] == TagValue.client && rawTag[1] == clientTagValue) {
        return true;
      }
    }

    return false;
  }
}
