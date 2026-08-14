import 'package:common/app/theme/sizes.dart';
import 'package:common/app/theme/success_colors.dart';
import 'package:common/domain/usecases/relays_monitoring_usecase.dart';
import 'package:common/presentation/dialogs/opacity_button.dart';
import 'package:di_storage/di_storage.dart';
import 'package:flutter/material.dart';
import 'package:nostr/model/relay_health.dart';
import 'package:nostr_notes/l10n/localization.dart';

final class RelayStatusIndicatorVM {
  final RelaysMonitoringUsecase relaysMonitoringUsecase;

  late final Stream<RelayStatusInfo> relayStatusInfoStream =
      relaysMonitoringUsecase.statuses.map(
        (statuses) => RelayStatusInfo(statuses: statuses),
      );

  RelayStatusIndicatorVM({required this.relaysMonitoringUsecase});

  factory RelayStatusIndicatorVM.fromDi() {
    final relaysMonitoringUsecase = DiStorage.shared
        .resolve<RelaysMonitoringUsecase>();
    return RelayStatusIndicatorVM(
      relaysMonitoringUsecase: relaysMonitoringUsecase,
    );
  }
}

final class RelayStatusInfo {
  final Map<String, RelayStatus> statuses;

  bool get isEmpty => statuses.isEmpty;

  late final entries = statuses.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  late final total = entries.length;
  late final okCount = entries
      .where((e) => e.value == RelayStatus.connected)
      .length;

  late final indicatorValue = total == 0 ? null : okCount / total;

  RelayStatusInfo({required this.statuses});

  @override
  String toString() =>
      'RelayStatusInfo(total: $total, okCount: $okCount, indicatorValue: $indicatorValue)';
}

final class RelayStatusIndicator extends StatefulWidget {
  static const _size = Size(30.0, 30.0);
  final Size size;

  const RelayStatusIndicator({super.key, this.size = _size});

  @override
  State<RelayStatusIndicator> createState() => _RelayStatusIndicatorState();
}

final class _RelayStatusIndicatorState extends State<RelayStatusIndicator> {
  late final vm = RelayStatusIndicatorVM.fromDi();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<RelayStatusInfo>(
      stream: vm.relayStatusInfoStream,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null || data.isEmpty) {
          return const SizedBox.shrink();
        }
        return _RelayStatusButton(relayStatusInfo: data);
      },
    );
  }
}

final class _RelayStatusButton extends StatelessWidget {
  final RelayStatusInfo relayStatusInfo;
  const _RelayStatusButton({required this.relayStatusInfo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OpacityButton(
      onTap: () {},
      child: Tooltip(
        triggerMode: TooltipTriggerMode.tap,
        showDuration: const Duration(seconds: 30),
        padding: const EdgeInsets.all(Sizes.indent2x),
        margin: const EdgeInsets.symmetric(horizontal: Sizes.indent2x),
        decoration: BoxDecoration(
          color: theme.colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(Sizes.radiusVariant),
          border: Border.all(
            color: theme.colorScheme.outline,
            width: Sizes.thickness,
          ),
        ),
        richMessage: WidgetSpan(
          child: _RelayStatusPopover(relayStatusInfo: relayStatusInfo),
        ),
        onTriggered: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sizes.indent),
          child: RelayStatusWidget(
            relayStatusInfo: relayStatusInfo,
            size: RelayStatusIndicator._size,
          ),
        ),
      ),
    );
  }
}

final class RelayStatusWidget extends StatelessWidget {
  static const _iconSizeRatio = 0.6;

  final RelayStatusInfo relayStatusInfo;
  final Size size;
  const RelayStatusWidget({
    super.key,
    required this.relayStatusInfo,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final successColor =
        theme.extension<SuccessColors>()?.success ?? theme.colorScheme.primary;

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: relayStatusInfo.indicatorValue,
            strokeWidth: 2.5,
            color: successColor,
            backgroundColor: theme.colorScheme.error,
          ),
          Icon(
            Icons.cell_tower,
            size: size.shortestSide * _iconSizeRatio,
            color: successColor,
          ),
        ],
      ),
    );
  }
}

final class _RelayStatusPopover extends StatelessWidget {
  final RelayStatusInfo relayStatusInfo;

  const _RelayStatusPopover({required this.relayStatusInfo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    const size = Size(40, 40);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 240),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RelayStatusWidget(
                relayStatusInfo: RelayStatusInfo(
                  statuses: relayStatusInfo.statuses,
                ),
                size: size,
              ),
              const SizedBox(width: Sizes.indent2x),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.relayStatusTitle(
                        relayStatusInfo.okCount,
                        relayStatusInfo.total,
                      ),
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: Sizes.tinyIndent),
                    Text(
                      l10n.relayStatusSubtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Sizes.indent2x),
          for (final entry in relayStatusInfo.entries)
            _RelayRow(url: entry.key, status: entry.value),
          const SizedBox(height: Sizes.halfIndent),
        ],
      ),
    );
  }
}

final class _RelayRow extends StatelessWidget {
  final String url;
  final RelayStatus status;
  const _RelayRow({required this.url, required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final success =
        theme.extension<SuccessColors>()?.success ?? theme.colorScheme.primary;

    final dotColor = switch (status) {
      RelayStatus.connected => success,
      RelayStatus.warning => theme.colorScheme.onSurfaceVariant,
      RelayStatus.disconnected => theme.colorScheme.error,
    };

    final statusText = switch (status) {
      RelayStatus.connected => l10n.relayStatusOnline,
      RelayStatus.warning => l10n.relayStatusConnecting,
      RelayStatus.disconnected => l10n.relayStatusNoResponse,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sizes.tinyIndent),
      child: Row(
        children: [
          Container(
            width: Sizes.indentVariant,
            height: Sizes.indentVariant,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: Sizes.indent),
          Expanded(
            child: Text(
              _hostOnly(url),
              style: theme.textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            statusText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  static String _hostOnly(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) return url;
    return uri.host;
  }
}
