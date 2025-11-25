import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nostr_notes/app/icons/app_icons.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/app/sizes.dart';
import 'package:nostr_notes/common/domain/usecase/pin_usecase.dart';
import 'package:nostr_notes/common/presentation/buttons/prymary_loading_button.dart';
import 'package:nostr_notes/common/presentation/buttons/vm/loading_button_vm.dart';

import '../bloc/onboarding_screen_bloc.dart';
import '../bloc/onboarding_screen_event.dart';
import '../validators/pin_validator.dart';
import '../widgets/onboarding_text_field.dart';

final class OnboardingPinPage extends StatefulWidget {
  const OnboardingPinPage({super.key});

  @override
  State<OnboardingPinPage> createState() => _OnboardingPinPageState();
}

final class _OnboardingPinPageState extends State<OnboardingPinPage>
    with PinValidator {
  final _formKey = GlobalKey<FormState>(
    debugLabel: 'OnboardingPinPage.FormKey',
  );

  bool _isUsePin = true;

  late final PinUsecase _pinUsecase =
      context.read<OnboardingScreenBloc>().pinUsecase;

  @override
  PinUsecase getPinUsecase(BuildContext context) => _pinUsecase;

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
            key: _formKey,
            child: Column(
              children: [
                OnboardingTextFormField(
                  initialValue: _controller.text,
                  isEnabled: _isUsePin,
                  controller: _controller,
                  hint: l10n.onboardingPinPageTextFieldHint,
                  validator: (str) =>
                      validatePin(context, str, usePin: _isUsePin),
                ),
                FormField<bool>(
                  initialValue: false,
                  builder: (field) => Align(
                    alignment: Alignment.centerLeft,
                    child: CheckboxListTile(
                      value: _isUsePin,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (e) => _onCheckboxChanged(context, field, e),
                      title: Text(l10n.onboardingPinPageLabelCheckboxUsePin),
                    ),
                  ),
                )
              ],
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

  void _onCheckboxChanged(
      BuildContext context, FormFieldState<bool> field, bool? value) {
    _formKey.currentState?.reset();
    field.didChange(value);
    setState(() => _isUsePin = value ?? true);
  }

  void _onNext(BuildContext context, LoadingButtonVM vm) {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (isValid) {
      _formKey.currentState?.save();
      context.read<OnboardingScreenBloc>().add(OnboardingScreenEvent.onPin(
            pin: _controller.text,
            vm: vm,
            usePin: _isUsePin,
          ));
    }
  }
}
