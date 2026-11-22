import 'package:material_ui/material_ui.dart';

import 'call_demo_screen.dart';

void main() => runApp(const CallDemoApp());

class CallDemoApp extends StatelessWidget {
  const CallDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebRTC call demo',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: const CallDemoScreen(),
    );
  }
}
