import 'package:flutter/material.dart';

final class NoteScreen extends StatelessWidget {
  const NoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Text(
          'Детали для ...',
          style: theme.textTheme.headlineMedium,
        ),
      ),
    );
  }
}
