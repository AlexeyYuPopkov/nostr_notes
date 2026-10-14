import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Usage: the app was launched before
Future<void> theAppWasLaunchedBefore(WidgetTester tester) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('is_first_launch_flag', false);
}
