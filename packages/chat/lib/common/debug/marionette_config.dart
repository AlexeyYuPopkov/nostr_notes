import 'package:flutter/cupertino.dart';
import 'package:marionette_flutter/marionette_flutter.dart';

const marionetteConfiguration = MarionetteConfiguration(
  isInteractiveElement: _isCupertinoButton,
);

// CupertinoButton taps through RawGestureDetector, which Marionette doesn't detect.
bool _isCupertinoButton(Element element) => element.widget is CupertinoButton;
