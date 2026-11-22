import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:webrtc_call/webrtc_call.dart';

import 'call_demo_vm.dart';

final class CallDemoScreen extends StatefulWidget {
  const CallDemoScreen({super.key});

  @override
  State<CallDemoScreen> createState() => _CallDemoScreenState();
}

final class _CallDemoScreenState extends State<CallDemoScreen> {
  final _vm = CallDemoVm();
  late final _selfIdController = TextEditingController(
    text: _vm.suggestedSelfId,
  );

  @override
  void dispose() {
    _selfIdController.dispose();
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WebRTC call demo')),
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: _vm.session,
          builder: (context, session, _) => session == null
              ? _ConnectForm(
                  selfIdController: _selfIdController,
                  connectionState: _vm.connectionState,
                  connectError: _vm.connectError,
                  onConnect: () => _vm.connect(_selfIdController.text),
                )
              : _ConnectedView(vm: _vm, session: session),
        ),
      ),
    );
  }
}

final class _ConnectForm extends StatelessWidget {
  final TextEditingController selfIdController;
  final ValueListenable<SignalingConnectionState> connectionState;
  final ValueListenable<String?> connectError;
  final VoidCallback onConnect;

  const _ConnectForm({
    required this.selfIdController,
    required this.connectionState,
    required this.connectError,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([connectionState, connectError]),
      builder: (context, _) {
        final isConnecting =
            connectionState.value == SignalingConnectionState.connecting;
        final error = connectError.value;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Semantics(
              identifier: 'call_demo.self_id',
              child: TextField(
                controller: selfIdController,
                decoration: const InputDecoration(labelText: 'My id (no "-")'),
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              identifier: 'call_demo.connect',
              child: FilledButton(
                onPressed: isConnecting ? null : onConnect,
                child: Text(isConnecting ? 'Connecting…' : 'Connect'),
              ),
            ),
            if (error != null) ...[
              const SizedBox(height: 16),
              Text(
                error,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        );
      },
    );
  }
}

final class _ConnectedView extends StatelessWidget {
  final CallDemoVm vm;
  final PeerConnectionSession session;

  const _ConnectedView({required this.vm, required this.session});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: session.peerId,
      builder: (context, peerId, _) => peerId == null
          ? _PeersList(vm: vm, lastError: session.lastError)
          : _CallView(vm: vm, session: session, peerId: peerId),
    );
  }
}

final class _PeersList extends StatelessWidget {
  final CallDemoVm vm;
  final ValueListenable<String?> lastError;

  const _PeersList({required this.vm, required this.lastError});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([vm.otherPeers, lastError]),
      builder: (context, _) {
        final peers = vm.otherPeers.value;
        final error = lastError.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (error != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Last call failed: $error',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            Expanded(
              child: peers.isEmpty
                  ? const Center(child: Text('Nobody else is online'))
                  : ListView(
                      children: [
                        for (final peer in peers)
                          Semantics(
                            identifier: 'call_demo.peer.${peer.id}',
                            child: ListTile(
                              title: Text(peer.id),
                              subtitle: Text(peer.userAgent),
                              trailing: const Icon(Icons.videocam),
                              onTap: () => vm.call(peer),
                            ),
                          ),
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Semantics(
                identifier: 'call_demo.disconnect',
                child: OutlinedButton(
                  onPressed: vm.disconnect,
                  child: const Text('Disconnect'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CallView extends StatelessWidget {
  static const _localPreviewSize = Size(120, 160);

  final CallDemoVm vm;
  final PeerConnectionSession session;
  final String peerId;

  const _CallView({
    required this.vm,
    required this.session,
    required this.peerId,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ColoredBox(
            color: Colors.black,
            child: CallVideoView(renderer: session.remoteRenderer),
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          width: _localPreviewSize.width,
          height: _localPreviewSize.height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CallVideoView(renderer: session.localRenderer, mirror: true),
          ),
        ),
        Positioned(
          left: 16,
          top: 16,
          child: ValueListenableBuilder(
            valueListenable: session.connectionState,
            builder: (context, state, _) => DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  '$peerId\n${state?.name ?? 'starting'}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 32,
          left: 0,
          right: 0,
          child: Center(
            child: Semantics(
              identifier: 'call_demo.hang_up',
              child: FloatingActionButton(
                backgroundColor: Colors.red,
                onPressed: vm.hangUp,
                child: const Icon(Icons.call_end, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
