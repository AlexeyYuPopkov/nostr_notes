import 'dart:async';

import 'package:common/l10n/localization.dart';
import 'package:common/presentation/widgets/onboarding_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nostr_notes/app/icons/app_icons.dart';
import 'package:nostr_notes/l10n/localization.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:nostr_notes/common/domain/usecase/pin_usecase.dart';
import 'package:common/presentation/buttons/prymary_loading_button.dart';
import 'package:common/presentation/buttons/vm/loading_button_vm.dart';
import 'package:common/presentation/dialogs/common_tooltip.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/bloc/onboarding_screen_state.dart';

import '../../bloc/onboarding_screen_bloc.dart';
import '../../bloc/onboarding_screen_event.dart';
import '../../validators/pin_validator.dart';

part 'onboarding_pin_page_vm.dart';

final class OnboardingPinPage extends StatefulWidget {
  const OnboardingPinPage({super.key});

  @override
  State<OnboardingPinPage> createState() => _OnboardingPinPageState();
}

final class _OnboardingPinPageState extends State<OnboardingPinPage>
    with WidgetsBindingObserver {
  late final _vm = _VM();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _vm.maybeStartAutoUnlock(context.read<OnboardingScreenBloc>());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _vm.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    if (!mounted) return;
    final bottom = View.of(context).viewInsets.bottom;
    final visible = bottom > 0;
    if (visible != _vm._keyboardVisible.value) {
      _vm._keyboardVisible.value = visible;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingScreenBloc, OnboardingScreenState>(
      listenWhen: (prev, curr) => prev.data.autoUnlock != curr.data.autoUnlock,
      listener: (context, state) {
        _vm.resetAutoUnlock();
        if (state.data.autoUnlock) {
          _vm.maybeStartAutoUnlock(context.read<OnboardingScreenBloc>());
        }
      },
      child: BlocSelector<OnboardingScreenBloc, OnboardingScreenState, bool>(
        selector: (state) => state.data.autoUnlock,
        builder: (context, autoUnlock) {
          return ValueListenableBuilder(
            valueListenable: _vm._autoUnlockCancelled,
            builder: (context, autoUnlockCancelled, child) {
              return (autoUnlock && autoUnlockCancelled == false)
                  ? _AutoUnlock(vm: _vm)
                  : _PinForm(vm: _vm);
            },
          );
        },
      ),
    );
  }
}

String _truncatePubkey(String pubkey) {
  if (pubkey.length <= 16) return pubkey;
  return '${pubkey.substring(0, 8)}…${pubkey.substring(pubkey.length - 6)}';
}

final class _AutoUnlock extends StatelessWidget {
  final _VM vm;
  const _AutoUnlock({required this.vm});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final commonL10n = context.commonL10n;
    final pubkey = context
        .read<OnboardingScreenBloc>()
        .authUsecase
        .currentSession
        .pubkey;

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
              l10n.onboardingPinPageAutoUnlockTitle,
              style: theme.textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: Sizes.indent2x),
          Center(
            child: Text(
              _truncatePubkey(pubkey),
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: Sizes.indent4x),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Center(child: CircularProgressIndicator.adaptive()),
              const SizedBox(height: Sizes.indent2x),
              Center(
                child: TextButton(
                  onPressed: vm.cancelAutoUnlock,
                  child: Text(commonL10n.commonButtonCancel),
                ),
              ),
            ],
          ),
          // ValueListenableBuilder<bool>(
          //   valueListenable: vm._autoUnlockCancelled,
          //   builder: (context, cancelled, _) {
          //     if (!cancelled) {
          //       return Column(
          //         mainAxisSize: MainAxisSize.min,
          //         children: [
          //           const Center(child: CircularProgressIndicator.adaptive()),
          //           const SizedBox(height: Sizes.indent2x),
          //           Center(
          //             child: TextButton(
          //               onPressed: vm.cancelAutoUnlock,
          //               child: Text(commonL10n.commonButtonCancel),
          //             ),
          //           ),
          //         ],
          //       );
          //     }
          //     return Center(
          //       child: PrymaryLoadingButton(
          //         title: l10n.onboardingPinPageAutoUnlockButton,
          //         onTap: (buttonVm) => vm.unlockWithoutPin(
          //           context.read<OnboardingScreenBloc>(),
          //           buttonVm,
          //         ),
          //       ),
          //     );
          //   },
          // ),
        ],
      ),
    );
  }
}

final class _PinForm extends StatelessWidget {
  final _VM vm;
  const _PinForm({required this.vm});

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
            key: vm._formKey,
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
                      initialValue: vm._controller.text,
                      isEnabled: data.$2,
                      controller: vm._controller,
                      obscureText: true,
                      hint: l10n.onboardingPinPageTextFieldHint,
                      keyboardType: data.$1,
                      validator: (str) =>
                          vm.validatePin(context, str, usePin: data.$2),
                      onSubmitted: (_) => vm.onNext(context, null),
                      onTapOutside: (e) {
                        final box =
                            vm._doneButtonKey.currentContext?.findRenderObject()
                                as RenderBox?;
                        if (box != null) {
                          final rect =
                              box.localToGlobal(Offset.zero) & box.size;
                          if (rect.contains(e.position)) {
                            return;
                          }
                        }
                        FocusScope.of(context).unfocus();
                      },
                    );
                  },
                ),
                Row(
                  spacing: Sizes.indent,
                  children: [
                    CommonTooltip(
                      title: commonL10n.commonInfo,
                      message: l10n.onboardingPinPageInfoPin,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: Sizes.iconMedium,
                          minHeight: Sizes.buttonHeight,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Icon(
                            Icons.info_outline,
                            size: Sizes.iconSmall,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
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
                                  return Row(
                                    mainAxisAlignment: .spaceBetween,
                                    children: [
                                      Text(
                                        l10n.onboardingPinPageLabelCheckboxUsePin,
                                      ),
                                      Checkbox.adaptive(
                                        value: isUsePin,
                                        activeColor: theme.colorScheme.primary,
                                        onChanged: (e) => vm.onCheckboxChanged(
                                          context,
                                          field,
                                          e,
                                        ),
                                      ),
                                    ],
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
          ValueListenableBuilder(
            valueListenable: vm._keyboardVisible,
            builder: (context, value, child) {
              return AnimatedSize(
                duration: AppDurations.medium,
                child: value
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
              );
            },
          ),

          Center(
            key: vm._doneButtonKey,
            child: PrymaryLoadingButton(
              title: commonL10n.commonButtonDone,
              onTap: (buttonVm) => vm.onNext(context, buttonVm),
            ),
          ),
        ],
      ),
    );
  }
}
