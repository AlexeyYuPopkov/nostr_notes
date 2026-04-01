import 'package:flutter/material.dart';
import 'package:nostr_notes/app/sizes.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/pages/onboarding_relays_page/onboarding_relays_page.dart';

class RelaysListScreen extends StatelessWidget {
  const RelaysListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: Sizes.indent2x,
            right: Sizes.indent2x,
            bottom: Sizes.indent2x,
          ),
          child: OnboardingRelaysPage(),
        ),
      ),
    );
  }
}
