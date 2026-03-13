import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nostr_notes/app/icons/app_icons.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/app/sizes.dart';
import 'package:nostr_notes/common/domain/usecase/pin_usecase.dart';
import 'package:nostr_notes/common/presentation/buttons/prymary_loading_button.dart';
import 'package:nostr_notes/common/presentation/buttons/vm/loading_button_vm.dart';
import 'package:nostr_notes/common/presentation/dialogs/common_tooltip.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/bloc/onboarding_screen_state.dart';

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

  late final PinUsecase _pinUsecase = context
      .read<OnboardingScreenBloc>()
      .pinUsecase;

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
              style: theme.textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: Sizes.indentVariant4x),
          Form(
            key: _formKey,
            child: Column(
              children: [
                BlocSelector<
                  OnboardingScreenBloc,
                  OnboardingScreenState,
                  (TextInputType?, bool)
                >(
                  selector: (state) => (
                    state.data.pinKeyboardType.toTextInputType(),
                    state.data.isUsePin,
                  ),
                  builder: (context, data) {
                    return OnboardingTextFormField(
                      initialValue: _controller.text,
                      isEnabled: data.$2,
                      controller: _controller,
                      obscureText: true,
                      hint: l10n.onboardingPinPageTextFieldHint,
                      keyboardType: data.$1,
                      validator: (str) =>
                          validatePin(context, str, usePin: data.$2),
                      onSubmitted: (_) => _onNext(context, null),
                    );
                  },
                ),
                Row(
                  spacing: Sizes.indent,
                  children: [
                    CommonTooltip(
                      title: l10n.commonInfo,
                      message: l10n.onboardingPinPageInfoPin,
                      child: CupertinoButton(
                        minimumSize: .zero,
                        padding: .zero,
                        onPressed: () {},
                        child: Icon(
                          Icons.info_outline,
                          size: Sizes.iconSmall,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(
                      child: FormField<bool>(
                        initialValue: false,
                        builder: (field) => Align(
                          alignment: Alignment.centerLeft,
                          child:
                              BlocSelector<
                                OnboardingScreenBloc,
                                OnboardingScreenState,
                                bool
                              >(
                                selector: (state) {
                                  return state.data.isUsePin;
                                },
                                builder: (context, isUsePin) {
                                  return CheckboxListTile(
                                    value: isUsePin,
                                    contentPadding: EdgeInsets.zero,
                                    onChanged: (e) =>
                                        _onCheckboxChanged(context, field, e),
                                    title: Text(
                                      l10n.onboardingPinPageLabelCheckboxUsePin,
                                    ),
                                  );
                                },
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
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
          ),
        ],
      ),
    );
  }

  void _onCheckboxChanged(
    BuildContext context,
    FormFieldState<bool> field,
    bool? value,
  ) {
    _formKey.currentState?.reset();
    field.didChange(value);
    final bloc = context.read<OnboardingScreenBloc>();
    bloc.add(OnboardingScreenEvent.didChangeUsePinFlag(value ?? true));
  }

  void _onNext(BuildContext context, LoadingButtonVM? vm) {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (isValid) {
      _formKey.currentState?.save();
      final bloc = context.read<OnboardingScreenBloc>();
      final isUsePin = bloc.state.data.isUsePin;
      bloc.add(
        OnboardingScreenEvent.onPin(
          pin: _controller.text,
          vm: vm,
          usePin: isUsePin,
        ),
      );
    }
  }
}
