import 'package:chat/l10n/localization.dart';
import 'package:flutter/material.dart';

final class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settingsTitle)),
      body: Center(child: Text(context.l10n.settingsPlaceholder)),
    );
  }
}
