import 'package:flutter/widgets.dart';
import 'package:nostr_notes/common/domain/usecase/pin_usecase.dart';

mixin PinValidator {
  PinUsecase getPinUsecase(BuildContext context);

  String? validatePin(BuildContext context, String? str) {
    return getPinUsecase(context).validate(str)?.message;
  }
}
