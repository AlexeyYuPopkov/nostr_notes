import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nostr_notes/app/icons/app_icons.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/app/sizes.dart';
import 'package:nostr_notes/common/presentation/buttons/prymary_loading_button.dart';
import 'package:nostr_notes/common/presentation/buttons/vm/loading_button_vm.dart';

import '../bloc/onboarding_screen_bloc.dart';
import '../bloc/onboarding_screen_event.dart';

final class OnboardingPinPage extends StatefulWidget {
  static final _formKey = GlobalKey<FormState>(
    debugLabel: 'OnboardingPinPage.FormKey',
  );
  const OnboardingPinPage({super.key});

  @override
  State<OnboardingPinPage> createState() => _OnboardingPinPageState();
}

class _OnboardingPinPageState extends State<OnboardingPinPage> {
  late final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: SvgPicture.asset(
              AppIcons.pinIcon,
              width: Sizes.iconTitle,
              height: Sizes.iconTitle,
              semanticsLabel: 'Pin icon',
            ),
          ),
          const SizedBox(height: Sizes.indentVariant4x),
          Center(
            child: Text(
              l10n.onboardingPinPageTitle,
              style: theme.textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: Sizes.indentVariant4x),
          Center(
            child: Text(
              l10n.onboardingPinPageDescription,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: Sizes.indentVariant4x),
          Form(
            key: OnboardingPinPage._formKey,
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: l10n.onboardingPinPageTextFieldHint,
              ),
              textAlign: TextAlign.center,
              onTapOutside: (e) => FocusScope.of(context).unfocus(),
            ),
          ),
          const SizedBox(height: Sizes.indentVariant4x),
          Center(
            child: Text(
              l10n.onboardingNsecPageLabelHint,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: Sizes.indent4x),
          const SizedBox(height: Sizes.indent4x),
          Center(
            child: PrymaryLoadingButton(
              title: l10n.commonButtonDone,
              onTap: (vm) => _onNext(context, vm),
            ),
          )
        ],
      ),
    );
  }

  void _onNext(BuildContext context, LoadingButtonVM vm) {
    final isValid =
        OnboardingPinPage._formKey.currentState?.validate() ?? false;
    if (isValid) {
      OnboardingPinPage._formKey.currentState?.save();
      context
          .read<OnboardingScreenBloc>()
          .add(OnboardingScreenEvent.onPin(_controller.text, vm));
    }
  }
}
