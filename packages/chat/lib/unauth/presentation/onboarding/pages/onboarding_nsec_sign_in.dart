import 'package:chat/l10n/localization.dart';
import 'package:common/app/icons/app_icons.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:common/l10n/localization.dart';
import 'package:common/presentation/buttons/prymary_loading_button.dart';
import 'package:common/presentation/buttons/vm/loading_button_vm.dart';
import 'package:common/presentation/widgets/onboarding_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nostr/key_tool/key_tool.dart';
import '../provider/onboarding_provider.dart';

final class OnboardingNsecSignIn extends ConsumerStatefulWidget {
  const OnboardingNsecSignIn({super.key});

  @override
  ConsumerState<OnboardingNsecSignIn> createState() =>
      _OnboardingNsecSignInState();
}

final class _OnboardingNsecSignInState
    extends ConsumerState<OnboardingNsecSignIn> {
  static final _formKey = GlobalKey<FormState>(
    debugLabel: 'OnboardingNsecSignIn.FormKey',
  );

  late final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final commonL10n = context.commonL10n;

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: SvgPicture.asset(
              CommonIcons.nsecIcon,
              width: Sizes.iconTitle,
              height: Sizes.iconTitle,
              semanticsLabel: 'Nsec icon',
            ),
          ),
          const SizedBox(height: Sizes.indentVariant4x),
          Center(
            child: Text(
              l10n.onboardingNsecPageTitle,
              style: theme.textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: Sizes.indentVariant4x),
          Center(
            child: Text(
              l10n.onboardingNsecPageDescription,
              style: theme.textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: Sizes.indentVariant4x),
          Form(
            key: _formKey,
            child: OnboardingTextFormField(
              initialValue: _controller.text,
              controller: _controller,
              hint: l10n.onboardingNsecPageTextFieldHint,
              validator: (str) => _validateNsec(str, l10n),
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
              title: commonL10n.commonButtonNext,
              onTap: (vm) => _onNext(vm),
            ),
          ),
          const SizedBox(height: Sizes.indent4x),
          Center(
            child: Text(
              l10n.onboardingNsecPageDontHaveAccount,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: Sizes.indent2x),
          Center(
            child: TextButton(
              onPressed: _onSignUp,
              child: Text(l10n.onboardingNsecPageButtonSignUp),
            ),
          ),
        ],
      ),
    );
  }

  String? _validateNsec(String? value, Localization l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.onboardingNsecPageValidationEmpty;
    }
    final trimmed = value.trim();
    if (trimmed.startsWith('npub')) {
      return l10n.onboardingNsecPageValidationNpub;
    }
    final privateKey = KeyTool.tryDecodeNsecKeyToPrivateKey(trimmed);
    if (privateKey == null) {
      return l10n.onboardingNsecPageValidationInvalid;
    }
    return null;
  }

  void _onSignUp() {
    ref.read(onboardingProviderProvider.notifier).nsecPageVm.toggleMode();
  }

  Future<void> _onNext(LoadingButtonVM vm) async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (isValid) {
      _formKey.currentState?.save();
      await ref
          .read(onboardingProviderProvider.notifier)
          .onNsec(_controller.text.trim(), vm);
    }
  }
}
