import 'dart:async';
import 'package:flutter/material.dart';

import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/app/sizes.dart';
import 'package:nostr_notes/common/data/relays_monitoring_usecase_impl.dart';
import 'package:nostr_notes/common/domain/relay_validator.dart';
import 'package:nostr_notes/common/domain/relays_monitoring_usecase.dart';
import 'package:nostr_notes/services/nostr_client/channel_factory.dart';

class RelayInputTextField extends StatefulWidget {
  final ValueChanged<String>? onAdd;
  const RelayInputTextField({super.key, required this.onAdd});

  @override
  State<RelayInputTextField> createState() => _RelayInputTextFieldState();
}

final class _RelayInputTextFieldState extends State<RelayInputTextField> {
  late final inputRelayVm = RelayInputTextFieldVM();

  @override
  void dispose() {
    inputRelayVm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _RelayInputTextField(vm: inputRelayVm, onAddCustom: widget.onAdd);
}

final class RelayInputTextFieldVM extends ChangeNotifier with RelayValidator {
  late final GlobalKey<FormState> formKey = GlobalKey<FormState>(
    debugLabel: 'RelayInputTextField.formKey',
  );
  late final controller = TextEditingController();
  final ChannelFactory channelFactory;

  RelaysMonitoringUsecase _createRelaysMonitoringUsecase(String url) {
    return RelaysMonitoringUsecaseImpl(
      uri: Uri.parse(url),
      channelFactory: channelFactory,
    );
  }

  bool isConnecting = false;
  bool? canConnect;

  RelayInputTextFieldVM({this.channelFactory = const ChannelFactory()}) {
    controller.addListener(() {
      if (canConnect != null) {
        canConnect = null;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  FutureOr<bool> canConnectToRelay(String url) async {
    final relaysMonitoringRepo = _createRelaysMonitoringUsecase(url);
    if (!relaysMonitoringRepo.isValidRelayUrl(url)) {
      return false;
    }
    isConnecting = true;
    notifyListeners();
    try {
      await Future.delayed(Durations.long2);
      final result = await relaysMonitoringRepo.canConnect();
      canConnect = result.canConnect();
      return canConnect!;
    } catch (e) {
      canConnect = false;
      return false;
    } finally {
      isConnecting = false;
      notifyListeners();
      await relaysMonitoringRepo.dispose();
    }
  }
}

final class _RelayInputTextField extends StatelessWidget {
  static const Size buttonSize = Size(80.0, 48.0);
  final RelayInputTextFieldVM vm;
  final ValueChanged<String>? onAddCustom;
  const _RelayInputTextField({required this.vm, this.onAddCustom});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      crossAxisAlignment: .start,
      children: [
        Expanded(
          child: Form(
            key: vm.formKey,
            child: ListenableBuilder(
              listenable: vm,
              builder: (context, child) {
                return TextFormField(
                  controller: vm.controller,
                  onTapOutside: (event) => FocusScope.of(context).unfocus(),
                  autocorrect: false,
                  keyboardType: TextInputType.url,
                  forceErrorText: _forceErrorText(context),
                  decoration: InputDecoration(
                    hintText: l10n.relaysPageAddCustomHint,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: Sizes.indent2x,
                      vertical: Sizes.indent,
                    ),
                    suffix: SizedBox(
                      width: Sizes.iconSmall,
                      height: Sizes.iconSmall,
                      child: vm.isConnecting
                          ? const CircularProgressIndicator()
                          : Center(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: Sizes.halfIndent,
                                ),
                                child: switch (vm.canConnect) {
                                  true => const Icon(
                                    Icons.check,
                                    color: Colors.green,
                                    size: Sizes.iconSmall,
                                  ),
                                  false => const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                    size: Sizes.iconSmall,
                                  ),
                                  null => const SizedBox(
                                    width: Sizes.iconSmall,
                                    height: Sizes.iconSmall,
                                  ),
                                },
                              ),
                            ),
                    ),
                  ),
                  validator: (str) => _validator(context, str),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: Sizes.indent),
        ValueListenableBuilder(
          valueListenable: vm.controller,
          builder: (context, value, child) {
            return ListenableBuilder(
              listenable: vm,
              builder: (context, child) {
                return SizedBox(
                  width: buttonSize.width,
                  height: buttonSize.height,
                  child: FittedBox(
                    child: FilledButton(
                      onPressed: value.text.isNotEmpty
                          ? vm.canConnect == true
                                ? _onAddCustom
                                : _onCheck
                          : null,
                      child: Text(
                        vm.canConnect == true
                            ? l10n.relaysPageAddButton
                            : l10n.relaysPageCheckButton,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  String? _validator(BuildContext context, String? str) {
    final error = vm.validateRelayUrl(str);

    if (error == null) {
      return null;
    }

    switch (error) {
      case RelayValidatorErrorEmpty():
        return context.l10n.relaysPageErrorInvalidRelayUrlEmpty;
      case RelayValidatorErrorScheme():
        return context.l10n.relaysPageErrorInvalidUrl;
      case RelayValidatorErrorFormat():
        return context.l10n.relaysPageErrorInvalidRelayAddressFormat;
    }
  }

  String? _forceErrorText(BuildContext context) {
    final l10n = context.l10n;
    if (vm.canConnect == false) {
      return l10n.relaysPageErrorFailedToConnectToRelay(vm.controller.text);
    }
    return null;
  }

  void _onAddCustom() {
    onAddCustom?.call(vm.controller.text);
    vm.controller.clear();
  }

  Future<void> _onCheck() async {
    final isValid = vm.formKey.currentState?.validate();

    if (isValid == true) {
      vm.formKey.currentState?.save();

      final url = vm.controller.text.trim();

      await vm.canConnectToRelay(url);
    }
  }
}
