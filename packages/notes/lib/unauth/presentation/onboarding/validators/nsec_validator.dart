import 'package:flutter/widgets.dart';

import 'package:nostr_notes/common/domain/usecase/auth_usecase.dart';

mixin NsecValidator {
  AuthUsecase getAuthUsecase(BuildContext context);

  String? validateNsec(BuildContext context, String? str) {
    return getAuthUsecase(context).validateNsec(str)?.message;
  }
}
