import 'dart:async';
import 'package:common/app/theme/sizes.dart';
import 'package:flutter/material.dart';
import 'package:common/domain/model/relay_info.dart';
import 'package:common/data/repo/single_relay_monitoring_usecase_impl.dart';
import 'package:nostr/model/relay_health.dart';
import 'package:common/domain/usecases/single_relay_monitoring_usecase.dart';
import 'package:nostr/nostr_client/channel_factory.dart';
import 'package:rxdart/rxdart.dart';

final class RelayTile extends StatefulWidget {
  final RelayInfo relay;
  final bool isSelected;
  final ValueChanged<bool?> onChanged;

  const RelayTile({
    super.key,
    required this.relay,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  State<RelayTile> createState() => _RelayTileState();
}

final class _RelayTileState extends State<RelayTile> {
  late RelayTileVM vm;

  @override
  void initState() {
    super.initState();
    vm = RelayTileVM(
      url: widget.relay.url.toString(),
      isSelected: widget.isSelected,
    );
    if (widget.isSelected) {
      vm.startMonitoring();
    }
  }

  @override
  void didUpdateWidget(covariant RelayTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.relay.url.toString() != widget.relay.url.toString()) {
      vm.dispose();
      setState(() {
        vm = RelayTileVM(
          url: widget.relay.url.toString(),
          isSelected: widget.isSelected,
        );
      });
      if (widget.isSelected) vm.startMonitoring();
      return;
    }

    if (oldWidget.isSelected != widget.isSelected) {
      if (widget.isSelected) {
        vm.startMonitoring();
      } else {
        vm.stopMonitoring();
      }
    }
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vm,
      builder: (context, child) {
        return RelayTile1(
          url: widget.relay.url.toString(),
          isSelected: vm.isSelected,
          isConnecting: vm.isConnecting,
          status: vm.status,
          onChanged: _onChanged,
        );
      },
    );
  }

  void _onChanged(bool? value) {
    final selected = value ?? false;
    vm.isSelected = selected;
    widget.onChanged(vm.isSelected);
    if (selected) {
      vm.startMonitoring();
    } else {
      vm.stopMonitoring();
    }
  }
}

final class RelayTile1 extends StatelessWidget {
  final String url;
  final bool isSelected;
  final bool isConnecting;
  final RelayStatus? status;
  final ValueChanged<bool?> onChanged;

  const RelayTile1({
    super.key,
    required this.url,
    required this.isSelected,
    required this.isConnecting,
    this.status,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      spacing: Sizes.indent,
      children: [
        SizedBox(
          width: Sizes.iconSmall,
          child: Center(
            child: StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 5), (x) => x)
                  .asyncExpand(
                    (e) => Stream.value(
                      0.5,
                    ).concatWith([Stream.value(1.0).delay(Durations.medium1)]),
                  ),

              builder: (context, asyncSnapshot) {
                return AnimatedOpacity(
                  duration: Durations.medium3,
                  opacity: asyncSnapshot.data ?? 1.0,
                  child: _StatusIcon(
                    isConnecting: isConnecting,
                    status: status,
                  ),
                );
              },
            ),
          ),
        ),

        Expanded(child: Text(url.toString(), style: theme.textTheme.bodyLarge)),
        Checkbox.adaptive(
          value: isSelected,
          activeColor: theme.colorScheme.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

final class RelayTileVM extends ChangeNotifier {
  final String url;
  final ChannelFactory channelFactory;
  bool isSelected;

  StreamSubscription<RelayStatus>? _sub;
  RelayStatus? status;
  bool isConnecting = false;
  late final SingleRelayMonitoringUsecase _relaysMonitoringUsecase =
      _createRelaysMonitoringUsecase(url);

  RelayTileVM({
    required this.url,
    required this.isSelected,
    this.channelFactory = const ChannelFactory(),
  });

  SingleRelayMonitoringUsecase _createRelaysMonitoringUsecase(String url) {
    return SingleRelayMonitoringUsecaseImpl(
      uri: Uri.parse(url),
      channelFactory: channelFactory,
    );
  }

  void startMonitoring() {
    if (_sub != null) {
      return;
    }

    isConnecting = true;
    notifyListeners();

    _sub = _relaysMonitoringUsecase
        .health()
        .map((e) => e.toStatus())
        .debounceTime(Durations.medium1)
        .listen(_onRelaysStatus, onError: (_) {});
  }

  void _onRelaysStatus(RelayStatus status) {
    isConnecting = false;
    this.status = status;
    notifyListeners();
  }

  void stopMonitoring() {
    _sub?.cancel();
    _sub = null;

    isConnecting = false;
    status = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _sub = null;
    _relaysMonitoringUsecase.dispose();
    super.dispose();
  }
}

final class _StatusIcon extends StatelessWidget {
  static const iconSize = 18.0;
  final RelayStatus? status;
  final bool isConnecting;

  const _StatusIcon({required this.isConnecting, required this.status});

  @override
  Widget build(BuildContext context) {
    if (isConnecting) {
      return const SizedBox(
        width: Sizes.iconSmall,
        height: Sizes.iconSmall,
        child: CircularProgressIndicator(),
      );
    }
    final status = this.status;
    if (status == null) {
      return const SizedBox(width: iconSize, height: iconSize);
    }
    switch (status) {
      case RelayStatus.connected:
        return const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: iconSize,
        );

      case RelayStatus.warning:
        return const Icon(Icons.error, color: Colors.orange, size: iconSize);

      case RelayStatus.disconnected:
        return const Icon(Icons.cancel, color: Colors.red, size: iconSize);
    }
  }
}
