import 'package:common/l10n/localization.dart';
import 'package:common/presentation/widgets/onboarding_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nostr_notes/app/icons/app_icons.dart';
import 'package:nostr_notes/l10n/localization.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:nostr_notes/common/domain/usecase/auth_usecase.dart';
import 'package:common/presentation/buttons/prymary_loading_button.dart';
import 'package:common/presentation/buttons/vm/loading_button_vm.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/validators/nsec_validator.dart';

import '../../bloc/onboarding_screen_bloc.dart';
import '../../bloc/onboarding_screen_event.dart';

final class OnboardingNsecSignIn extends StatefulWidget {
  const OnboardingNsecSignIn({super.key});

  @override
  State<OnboardingNsecSignIn> createState() => _OnboardingNsecSignInState();
}

final class _OnboardingNsecSignInState extends State<OnboardingNsecSignIn>
    with NsecValidator, WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>(
    debugLabel: 'OnboardingNsecPage.FormKey',
  );
  late final _controller = TextEditingController();
  bool _keyboardVisible = false;

  late final AuthUsecase _authUsecase = context
      .read<OnboardingScreenBloc>()
      .authUsecase;

  @override
  AuthUsecase getAuthUsecase(BuildContext context) => _authUsecase;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    if (!mounted) return;
    final visible = View.of(context).viewInsets.bottom > 0;
    if (visible != _keyboardVisible) {
      setState(() => _keyboardVisible = visible);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final commonL10n = context.commonL10n;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: SvgPicture.asset(
              AppIcons.nsecIcon,
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
              validator: (str) => validateNsec(context, str),
            ),
          ),
          AnimatedSize(
            duration: AppDurations.medium,
            child: _keyboardVisible
                ? const SizedBox()
                : Column(
                    children: [
                      const SizedBox(height: Sizes.indentVariant4x),
                      Center(
                        child: Text(
                          l10n.onboardingNsecPageLabelHint,
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: Sizes.indent4x),
                    ],
                  ),
          ),
          const SizedBox(height: Sizes.indent4x),
          Center(
            child: PrymaryLoadingButton(
              title: commonL10n.commonButtonNext,
              onTap: (vm) => _onNext(context, vm),
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
              onPressed: () => _onSignUp(context),
              child: Text(l10n.onboardingNsecPageButtonSignUp),
            ),
          ),
        ],
      ),
    );
  }

  void _onSignUp(BuildContext context) {
    // context.read<OnboardingScreenBloc>().add(
    //   const OnboardingScreenEvent.onStep(OnboardingSignUp()),
    // );
    final vm = context.read<OnboardingScreenBloc>().nsecPageVm;
    vm.toggleMode();
  }

  void _onNext(BuildContext context, LoadingButtonVM vm) {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (isValid) {
      _formKey.currentState?.save();
      context.read<OnboardingScreenBloc>().add(
        OnboardingScreenEvent.onNsec(_controller.text, vm),
      );
    }
  }
}
