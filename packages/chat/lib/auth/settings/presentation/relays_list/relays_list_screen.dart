import 'package:chat/common/presentation/relays/relays_page.dart';
import 'package:chat/l10n/localization.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:material_ui/material_ui.dart';

final class RelaysListScreen extends StatelessWidget {
  const RelaysListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settingsItemRelays)),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: Sizes.indent2x,
            right: Sizes.indent2x,
            bottom: Sizes.indent2x,
          ),
          child: RelaysPage(),
        ),
      ),
    );
  }
}
