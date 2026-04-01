import 'package:flutter/material.dart';
import 'package:nostr_notes/app/sizes.dart';

enum ListItemPosition {
  first,
  middle,
  last,
  single;

  static ListItemPosition fromIndex(int index, {required int length}) {
    if (length == 1) {
      return ListItemPosition.single;
    } else if (index == 0) {
      return ListItemPosition.first;
    } else if (index == length - 1) {
      return ListItemPosition.last;
    } else {
      return ListItemPosition.middle;
    }
  }

  BorderRadius getRadius([
    Radius radius = const Radius.circular(Sizes.radius),
  ]) {
    switch (this) {
      case ListItemPosition.single:
        return BorderRadius.all(radius);

      case ListItemPosition.first:
        return BorderRadius.vertical(top: radius);

      case ListItemPosition.last:
        return BorderRadius.vertical(bottom: radius);

      case ListItemPosition.middle:
        return BorderRadius.zero;
    }
  }

  Border getBorder(Color color, {double thickness = Sizes.thickness}) {
    switch (this) {
      case ListItemPosition.single:
        return Border.all(color: color, width: thickness);

      case ListItemPosition.first:
        return Border(
          top: BorderSide(color: color, width: thickness),
          left: BorderSide(color: color, width: thickness),
          right: BorderSide(color: color, width: thickness),
        );

      case ListItemPosition.last:
        return Border(
          bottom: BorderSide(color: color, width: thickness),
          left: BorderSide(color: color, width: thickness),
          right: BorderSide(color: color, width: thickness),
        );

      case ListItemPosition.middle:
        return Border(
          left: BorderSide(color: color, width: thickness),
          right: BorderSide(color: color, width: thickness),
        );
    }
  }

  bool needsSeparator() {
    switch (this) {
      case ListItemPosition.single:
      case ListItemPosition.last:
        return false;
      case ListItemPosition.first:
      case ListItemPosition.middle:
        return true;
    }
  }
}
