import 'package:common/app/theme/sizes.dart';
import 'package:common/l10n/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../onboarding_state.dart';

const _defaultRelays = [
  'wss://relay.damus.io',
  'wss://nos.lol',
  'wss://relay.nostr.band',
  'wss://nostr.wine',
  'wss://relay.snort.social',
];

final class OnboardingRelaysPage extends ConsumerStatefulWidget {
  const OnboardingRelaysPage({super.key});

  @override
  ConsumerState<OnboardingRelaysPage> createState() =>
      _OnboardingRelaysPageState();
}

final class _OnboardingRelaysPageState
    extends ConsumerState<OnboardingRelaysPage> {
  final Set<String> _selected = {..._defaultRelays};

  @override
  Widget build(BuildContext context) {
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
        SliverList.separated(
          itemCount: _defaultRelays.length,
          separatorBuilder: (_, __) => const SizedBox(height: Sizes.halfIndent),
          itemBuilder: (context, index) {
            final relay = _defaultRelays[index];
            final isSelected = _selected.contains(relay);
            return _RelayTile(
              url: relay,
              isSelected: isSelected,
              onChanged: (_) => setState(() {
                if (isSelected) {
                  _selected.remove(relay);
                } else {
                  _selected.add(relay);
                }
              }),
            );
          },
        ),
        const SliverToBoxAdapter(child: SizedBox(height: Sizes.indent2x)),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(height: Sizes.indent4x),
              Center(
                child: ElevatedButton(
                  onPressed: _selected.isNotEmpty ? _onSave : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Sizes.indent2x,
                      vertical: Sizes.indent,
                    ),
                    child: Text(commonL10n.commonButtonSave),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onSave() {
    ref.read(onboardingStateProvider.notifier).onRelaysDone();
  }
}

final class _RelayTile extends StatelessWidget {
  final String url;
  final bool isSelected;
  final ValueChanged<bool?> onChanged;

  const _RelayTile({
    required this.url,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(Sizes.radius),
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: onChanged,
        title: Text(
          url,
          style: theme.textTheme.bodyMedium,
          overflow: TextOverflow.ellipsis,
        ),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }
}
