import 'package:nostr_notes/services/model/tag/tag.dart';

import '../nostr_event.dart';

extension NostrEventTags on NostrEvent {
  String? getFirstTag(BaseTag tag) {
    final tagValue = tag.name;
    for (final tags in this.tags) {
      if (tags.firstOrNull == tagValue && tags.length >= 2) {
        return tags[1].isEmpty ? null : tags[1];
      }
    }

    return null;
  }

  Set<String> getTagsSet(BaseTag tag) {
    final tags = this.tags;
    final tagValue = tag.name;
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
}
