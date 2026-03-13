import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/app/sizes.dart';
import 'package:nostr_notes/auth/domain/model/relay_info.dart';
import 'package:nostr_notes/common/presentation/buttons/prymary_button.dart';
import 'package:nostr_notes/common/presentation/dialogs/dialog_helper.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/pages/onboarding_relays_page/bloc/onboarding_relays_bloc.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/pages/onboarding_relays_page/bloc/onboarding_relays_event.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/pages/onboarding_relays_page/widgets/relay_input_text_field.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/pages/onboarding_relays_page/widgets/relay_tile.dart';

import 'bloc/onboarding_relays_state.dart';

final class OnboardingRelaysPage extends StatelessWidget with DialogHelper {
  static const headerIconSize = 60.0;
  const OnboardingRelaysPage({super.key});

  void _listener(BuildContext context, OnboardingRelaysState state) {
    switch (state) {
      case CommonState():
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
                    l10n.relaysPageTitle,
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
                    l10n.relaysPageDescription,
                    style: theme.textTheme.titleSmall,
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
                  return RelayTile(
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
                    RelayInputTextField(
                      onAdd: (str) => _onAddCustom(context, urlStr: str),
                    ),
                    const SizedBox(height: Sizes.indent4x),
                    Center(
                      child: PrymaryButton(
                        title: l10n.commonButtonSave,
                        onTap: state.data.hasChanges
                            ? () => _onNext(context)
                            : null,
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

  void _onAddCustom(BuildContext context, {required String urlStr}) {
    final bloc = context.read<OnboardingRelaysBloc>();
    final relay = RelayInfo(url: Uri.parse(urlStr));
    bloc.add(OnboardingRelaysEvent.onAdd(relay));
  }

  void _onNext(BuildContext context) {
    final bloc = context.read<OnboardingRelaysBloc>();
    bloc.add(const OnboardingRelaysEvent.save());
  }
}
