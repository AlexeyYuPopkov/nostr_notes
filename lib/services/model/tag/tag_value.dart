import 'package:nostr_notes/services/model/nostr_event.dart';

final class TagValue {
  static const String e = 'e';
  static const String d = 'd';
  static const String p = 'p';
  static const String a = 'a';
  static const String b = 'b';
  static const String k = 'k';
  static const String t = 't';
  static const String g = 'g';
  static const String client = 'client';
  static const String sig = 'sig';

  static const String sharpK = '#k';
  static const String sharpD = '#d';
}

final class ATag {
  final int kind;
  final String pubkey;
  final String dTag;

  ATag({required this.kind, required this.pubkey, required this.dTag});

  static ATag? fromString(String aTag) {
    final parts = aTag.split(':');
    if (parts.length != 3) {
      return null;
    }

    return ATag(kind: int.parse(parts[0]), pubkey: parts[1], dTag: parts[2]);
  }

  static ATag? fromEvent(NostrEvent event) {
    final aTagValue = event.getATags().firstOrNull;
    if (aTagValue == null) {
      return null;
    }
    return fromString(aTagValue);
  }

  static Set<ATag> getAllFromEvent(NostrEvent event) {
    final aTagValues = event.getAllTagsWithIndex(TagValue.a, 1);
    final result = <ATag>{};
    for (final aTagValue in aTagValues) {
      final aTag = fromString(aTagValue);
      if (aTag != null) {
        result.add(aTag);
      }
    }

    return result;
  }

  String toTagString() {
    return '${kind.toString()}:$pubkey:$dTag';
  }

  List<String> toEventTag() {
    return [TagValue.a, toTagString()];
  }

  @override
  int get hashCode => Object.hash(kind, pubkey, dTag);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    } else if (other is! ATag) {
      return false;
    } else {
      return kind == other.kind && pubkey == other.pubkey && dTag == other.dTag;
    }
  }
}
