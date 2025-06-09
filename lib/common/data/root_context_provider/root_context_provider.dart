import 'package:flutter/widgets.dart';
import 'package:nostr_notes/app/l10n/localization.dart';

/// [RootContextProvider] - e.g. you need to know info about root MediaQuery
final class RootContextProvider {
  static final instance = RootContextProvider._();
  RootContextProvider._();

  BuildContext? _context;

  void setRootContext(BuildContext context) => _context = context;

  BuildContext? get rootContext => _context;
}

extension RootContextProviderTools on RootContextProvider {
  EdgeInsets get rootPadding {
    final context = _context;
    if (context == null) {
      return EdgeInsets.zero;
    }

    return MediaQuery.paddingOf(context);
  }

  Localization get l10n {
    return Localization.of(_context!)!;
  }
}
