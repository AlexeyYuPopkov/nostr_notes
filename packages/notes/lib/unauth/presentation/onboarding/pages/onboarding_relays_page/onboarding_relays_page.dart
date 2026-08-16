import 'package:common/app/theme/sizes.dart';
import 'package:common/app/theme/success_colors.dart';
import 'package:common/l10n/localization.dart';
import 'package:common/presentation/dialogs/dialog_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:common/domain/model/relay_info.dart';
import 'package:common/presentation/buttons/prymary_button.dart';
import 'package:nostr/model/relay_health.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/pages/onboarding_relays_page/bloc/onboarding_relays_bloc.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/pages/onboarding_relays_page/bloc/onboarding_relays_event.dart';
import 'package:common/presentation/relay_input_text_field.dart';
import 'package:common/presentation/widgets/relay_tile.dart';

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
    final successColor =
        theme.extension<SuccessColors>()?.success ?? theme.colorScheme.primary;
    final commonL10n = context.commonL10n;

    return BlocProvider(
      create: (context) => OnboardingRelaysBloc(),
      child: BlocConsumer<OnboardingRelaysBloc, OnboardingRelaysState>(
        listener: _listener,
        builder: (context, state) {
          final monitor = context.read<OnboardingRelaysBloc>().monitor;

          return StreamBuilder<Map<String, RelayStatus>>(
            stream: monitor.statuses,
            builder: (context, statusSnapshot) {
              final statuses = statusSnapshot.data ?? const {};

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Icon(
                      Icons.cell_tower,
                      size: headerIconSize,
                      color: successColor,
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: Sizes.indentVariant4x),
                  ),
                  SliverToBoxAdapter(
                    child: Center(
                      child: Text(
                        commonL10n.relaysPageTitle,
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
                        commonL10n.relaysPageDescription,
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
                      final url = relay.url.toString();
                      return RelayTile1(
                        url: url,
                        isSelected: state.data.isSelected(relay),
                        isConnecting: false,
                        status: statuses[url],
                        onChanged: (v) => _onToggle(context, relay: relay),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: Sizes.halfIndent),
                    itemCount: state.data.relays.length,
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: Sizes.indent2x),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RelayInputTextField(
                          onAdd: (str) => _onAddCustom(context, urlStr: str),
                        ),
                        const SizedBox(height: Sizes.halfIndent),
                        Tooltip(
                          message: commonL10n.relaysPageAddCustomLabel,
                          child: Row(
                            spacing: Sizes.indent,
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: Sizes.indent2x,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              Expanded(
                                child: Text(
                                  commonL10n.relaysPageAddCustomLabel,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: Sizes.indent4x),
                        Center(
                          child: PrymaryLoadingButton(
                            title: commonL10n.commonButtonSave,
                            vm: context
                                .read<OnboardingRelaysBloc>()
                                .saveButtonVm,
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
    bloc.add(OnboardingRelaysEvent.onAdd(urlStr));
  }

  void _onNext(BuildContext context) {
    final bloc = context.read<OnboardingRelaysBloc>();
    bloc.add(const OnboardingRelaysEvent.save());
  }
}
