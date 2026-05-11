import 'package:chat/unauth/presentation/onboarding/pages/relays/provider/onboarding_relays_state.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:common/domain/model/relay_info.dart';
import 'package:common/l10n/localization.dart';
import 'package:common/presentation/buttons/prymary_button.dart';
import 'package:common/presentation/dialogs/dialog_helper.dart';
import 'package:common/presentation/relay_input_text_field.dart';
import 'package:common/presentation/widgets/relay_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'provider/onboarding_relays_provider.dart';

final class OnboardingRelaysPage extends ConsumerWidget with DialogHelper {
  const OnboardingRelaysPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<OnboardingRelaysState>(onboardingRelaysVmProvider, (prev, next) {
      switch (next) {
        case CommonState():
          break;

        case ErrorState():
          showError(context, error: next.error);
          break;
      }
    });

    final theme = Theme.of(context);
    final commonL10n = context.commonL10n;

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: Icon(Icons.cell_tower, size: 60.0)),
        const SliverToBoxAdapter(
          child: SizedBox(height: Sizes.indentVariant4x),
        ),
        SliverToBoxAdapter(
          child: Center(
            child: Text(
              'Connect to Relays',
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
              'Choose the relays to connect to. Relays route your messages across the Nostr network.',
              style: theme.textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: Sizes.indentVariant4x),
        ),
        Builder(
          builder: (context) {
            final state = ref.watch(onboardingRelaysVmProvider);
            return SliverList.separated(
              itemBuilder: (context, index) {
                final relay = state.data.relays[index];
                return RelayTile(
                  relay: relay,
                  isSelected: state.data.isSelected(relay),
                  onChanged: (v) => _onToggle(ref, relay),
                );
              },
              separatorBuilder: (context, index) =>
                  const SizedBox(height: Sizes.halfIndent),
              itemCount: state.data.relays.length,
            );
          },
        ),
        const SliverToBoxAdapter(child: SizedBox(height: Sizes.indent2x)),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              RelayInputTextField(
                onAdd: (str) => _onAddCustom(ref, urlStr: str),
              ),
              const SizedBox(height: Sizes.indent4x),
              Center(
                child: Builder(
                  builder: (context) {
                    final state = ref.watch(onboardingRelaysVmProvider);
                    return PrymaryLoadingButton(
                      title: commonL10n.commonButtonSave,
                      vm: ref
                          .read(onboardingRelaysVmProvider.notifier)
                          .saveButtonVm,
                      onTap: state.data.hasChanges ? () => _onNext(ref) : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onToggle(WidgetRef ref, RelayInfo relay) {
    ref.read(onboardingRelaysVmProvider.notifier).onToggle(relay);
  }

  void _onAddCustom(WidgetRef ref, {required String urlStr}) {
    ref.read(onboardingRelaysVmProvider.notifier).onAdd(urlStr);
  }

  void _onNext(WidgetRef ref) {
    ref.read(onboardingRelaysVmProvider.notifier).onSave();
  }
}
