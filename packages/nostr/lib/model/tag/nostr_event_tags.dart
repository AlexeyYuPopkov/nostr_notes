import '../nostr_event.dart';
import 'tag.dart';
import 'tag_value.dart';

extension NostrEventTags on NostrEvent {
  String? getDTag() => getFirstTag(Tag.d);

  String? getFirstTag(BaseTag tag) {
    final tagValue = tag.value;
    return getFirstTagStr(tagValue);
  }

  String? getFirstTagStr(String tag) {
    for (final tags in this.tags) {
      if (tags.firstOrNull == tag && tags.length >= 2) {
        return tags[1].isEmpty ? null : tags[1];
      }
    }

    return null;
  }

  Set<String> getATags() {
    final result = <String>{};
    for (final tags in this.tags) {
      if (tags.firstOrNull == TagValue.a && tags.length >= 2) {
        if (tags[1].isNotEmpty) {
          result.add(tags[1]);
        }
      }
    }

    return result;
  }

  Set<String> getAllTagsWithIndex(String tag, int index) {
    final result = <String>{};

    for (final sublist in tags) {
      if (sublist.firstOrNull == tag && sublist.length > index) {
        final res = sublist[index].isEmpty ? null : sublist[index];
        if (res != null) {
          result.add(res);
        }
      }
    }

    return result;
  }

  Set<String> getTagsSet(BaseTag tag) {
    final tags = this.tags;
    final tagValue = tag.value;
    Set<String> result = {};
    if (tags.isNotEmpty) {
      for (final tagList in tags) {
        if (tagList.firstOrNull == tagValue) {
          result.addAll(tagList.skip(1));
        }
      }
    }

    return result;
  }

  // ATagComponents? getATagComponents() =>
  //     ATagComponents.fromATagValue(getFirstTag(Tag.a));
}

// final class ATagComponents {
//   final String dTag;
//   final String pubkey;
//   final int kind;

//   const ATagComponents({
//     required this.dTag,
//     required this.pubkey,
//     required this.kind,
//   });

//   static ATagComponents? fromATagValue(String? aTagValue) {
//     if (aTagValue == null || aTagValue.isEmpty) {
//       return null;
//     }
//     final parts = aTagValue.split(':');
//     if (parts.length != 3) {
//       return null; // Invalid format
//     }
//     return ATagComponents(
//       kind: int.parse(parts[0]),
//       pubkey: parts[1],
//       dTag: parts[2],
//     );
//   }
// }
