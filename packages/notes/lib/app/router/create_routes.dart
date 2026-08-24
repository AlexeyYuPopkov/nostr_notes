import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_notes/app/router/app_router_path.dart';
import 'package:nostr_notes/auth/presentation/login_item_form/bloc/login_item_details_params.dart';

/// Opens [path] in the detail pane.
///
/// Pushes when the pane is still empty and replaces once something is
/// already open there, so browsing the list swaps the pane instead of
/// stacking a route per visited item — otherwise "back" walks the whole
/// browsing history rather than returning to the empty pane.
extension PaneNavigation on GoRouter {
  FutureOr<dynamic>  openInPane(String path, {Object? extra}) {
    if (state.fullPath == AppRouterPath.home) {
      push(path, extra: extra);
    } else {
      pushReplacement(path, extra: extra);
    }
  }
}

/// Navigation for the create buttons, shared by the coordinators of every
/// screen that can host one. They live in separate router libraries, so this
/// is a plain file rather than a part.
mixin NewLoginItemRoute {
  void newLoginItem(BuildContext context) {
    GoRouter.of(context).openInPane(
      '${AppRouterPath.home}${AppRouterPath.loginItemForm}',
      extra: LoginItemDetailsParams(id: '', readonly: false).toJson(),
    );
  }
}

mixin NewNoteRoute {
  void newNote(BuildContext context) {
    GoRouter.of(
      context,
    ).openInPane('${AppRouterPath.home}/${AppRouterPath.editNote}');
  }
}
