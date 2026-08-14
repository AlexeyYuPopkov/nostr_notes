with open('test/onboarding/onboarding_pin_page_auto_unlock_test.dart', 'r') as f:
    lines = f.readlines()
for i, line in enumerate(lines):
    if "expect(find.text('Set a PIN or password'), findsNothing);" in line:
        lines[i] = line.replace("findsNothing", "findsOneWidget")
    if "expect(find.byType(PopupMenuButton<String>), findsOneWidget);" in line:
        lines[i] = line.replace("findsOneWidget", "findsNWidgets(2)")
    if "expect(find.text(truncatePubkey(_keys.publicKey)), findsOneWidget);" in line:
        lines[i] = line.replace("findsOneWidget", "findsNWidgets(2)")
    if "await tester.tap(find.byType(PopupMenuButton<String>));" in line:
        lines[i] = line.replace("PopupMenuButton<String>)", "PopupMenuButton<String>).last")
    if "expect(find.text(truncatePubkey(_keys.publicKey)), findsNWidgets(2));" in line and i > 125: # for the final expectation
        lines[i] = line.replace("findsNWidgets(2)", "findsNWidgets(3)")
with open('test/onboarding/onboarding_pin_page_auto_unlock_test.dart', 'w') as f:
    f.writelines(lines)
