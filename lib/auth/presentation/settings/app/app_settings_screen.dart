import 'package:flutter/material.dart';
import 'package:nostr_notes/app/sizes.dart';
import 'package:nostr_notes/common/presentation/dialogs/dialog_helper.dart';

import 'bloc/app_settings_state.dart';

final class AppSettingsScreen extends StatelessWidget with DialogHelper {
  AppSettingsScreen({super.key});

  // ignore: unused_element
  void _listener(BuildContext context, AppSettingsState state) {
    switch (state) {
      case CommonState():
        break;
      case LoadingState():
        break;
      case ErrorState():
        showError(context, error: state.e);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(Sizes.indent),
          child: Column(children: []),
        ),
      ),
    );
  }
}
