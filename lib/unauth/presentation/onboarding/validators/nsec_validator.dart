import 'package:flutter/widgets.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/common/domain/repository/key_tool_repository.dart';
import 'package:nostr_notes/common/domain/usecase/auth_usecase.dart';

mixin NsecValidator {
  AuthUsecase getAuthUsecase(BuildContext context);

  String? validateNsec(BuildContext context, String? str) {
    return getAuthUsecase(context).validate(str)?.getMessage(context);
  }
}

extension InvalidNsecErrorMessage on NsecError {
  String getMessage(BuildContext context) {
    return context.l10n.errorInvalidNsec;
  }
}
