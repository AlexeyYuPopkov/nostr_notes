import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/app/sizes.dart';
import 'package:nostr_notes/auth/domain/model/relay_info.dart';
import 'package:nostr_notes/common/presentation/buttons/prymary_button.dart';
import 'package:nostr_notes/common/presentation/dialogs/dialog_helper.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/pages/onboarding_relays_page/bloc/onboarding_relays_bloc.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/pages/onboarding_relays_page/bloc/onboarding_relays_event.dart';

import 'bloc/onboarding_relays_state.dart';

final class OnboardingRelaysPage extends StatelessWidget with DialogHelper {
  static const headerIconSize = 60.0;
  const OnboardingRelaysPage({super.key});

  void _listener(BuildContext context, OnboardingRelaysState state) {
    switch (state) {
      case CommonState():
        break;
      case LoadingState():
        break;
      case ErrorState():
        showError(context, error: state.e);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return BlocProvider(
      create: (context) => OnboardingRelaysBloc(),
      child: BlocConsumer<OnboardingRelaysBloc, OnboardingRelaysState>(
        listener: _listener,
        builder: (context, state) {
          final bloc = context.read<OnboardingRelaysBloc>();
          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: Icon(Icons.cell_tower, size: headerIconSize),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: Sizes.indentVariant4x),
              ),
              SliverToBoxAdapter(
                child: Center(
                  child: Text(
                    l10n.onboardingRelaysPageTitle,
                    style: theme.textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: Sizes.indentVariant4x),
              ),
              SliverToBoxAdapter(
                child: Center(
                  child: Text(
                    l10n.onboardingRelaysPageDescription,
                    style: theme.textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: Sizes.indentVariant4x),
              ),
              SliverList.separated(
                itemBuilder: (context, index) {
                  final relay = state.data.relays[index];
                  return _RelayTile(
                    relay: relay,
                    isSelected: state.data.isSelected(relay),
                    onChanged: (v) => _onToggle(context, relay: relay),
                  );
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: Sizes.halfIndent),
                itemCount: state.data.relays.length,
              ),

              const SliverToBoxAdapter(child: SizedBox(height: Sizes.indent2x)),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: bloc.controller,
                            onTapOutside: (event) =>
                                FocusScope.of(context).unfocus(),
                            decoration: InputDecoration(
                              hintText: l10n.onboardingRelaysPageAddCustomHint,
                              border: const OutlineInputBorder(),

                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: Sizes.indent2x,
                                vertical: Sizes.indent,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: Sizes.indent),
                        FilledButton(
                          onPressed: _onAddCustom,
                          child: Text(l10n.onboardingRelaysPageAddButton),
                        ),
                      ],
                    ),
                    const SizedBox(height: Sizes.indent4x),
                    const SizedBox(height: Sizes.indent4x),
                    Center(
                      child: PrymaryButton(
                        title: l10n.commonButtonNext,
                        onTap: _onNext,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onToggle(BuildContext context, {required RelayInfo relay}) {
    final bloc = context.read<OnboardingRelaysBloc>();
    bloc.add(OnboardingRelaysEvent.toggle(relay));
  }

  void _onAddCustom() {
    // final url = _controller.text.trim();
    // if (!url.startsWith('wss://')) {
    //   setState(() => _error = context.l10n.onboardingRelaysPageErrorInvalidUrl);
    //   return;
    // }
    // if (_selectedRelays.contains(url) || _customRelays.contains(url)) {
    //   return;
    // }
    // setState(() {
    //   _error = null;
    //   _customRelays.add(url);
    //   _selectedRelays.add(url);
    //   _controller.clear();
    // });
  }

  void _onNext() {
    // if (_selectedRelays.isEmpty) {
    //   setState(() {
    //     _error = context.l10n.onboardingRelaysPageErrorSelectAtLeastOne;
    //   });
    //   return;
    // }
    // context.read<OnboardingScreenBloc>().add(
    //   OnboardingScreenEvent.onRelaysSelected(_selectedRelays.toList()),
    // );
  }
}

final class _RelayTile extends StatelessWidget {
  final RelayInfo relay;
  final bool isSelected;
  final ValueChanged<bool?> onChanged;

  const _RelayTile({
    required this.relay,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      spacing: Sizes.indent,
      children: [
        Expanded(
          child: Text(relay.url.toString(), style: theme.textTheme.bodyLarge),
        ),
        Checkbox(value: isSelected, onChanged: onChanged),
        // CupertinoButton(
        //   child: SizedBox(
        //     width: 24.0,
        //     height: 24.0,
        //     child: Icon(
        //       isSelected
        //           ? Icons.check_circle_outline_outlined
        //           : Icons.circle_outlined,
        //       size: 24.0,
        //     ),
        //   ),
        //   onPressed: () => onChanged(!isSelected),
        // ),
      ],
    );

    //  CheckboxListTile(
    //   value: isSelected,
    //   onChanged: onChanged,
    //   title: Text(relay.url.toString(), style: theme.textTheme.bodyLarge),
    //   contentPadding: EdgeInsets.zero,
    //   controlAffinity: ListTileControlAffinity.leading,
    // );
  }
}
