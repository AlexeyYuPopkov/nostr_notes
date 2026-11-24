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
          ? _PeersList(vm: vm, session: session)
          : CallView(session: session, peerName: peerId),
    );
  }
}

final class _PeersList extends StatelessWidget {
  final CallDemoVm vm;
  final PeerConnectionSession session;

  const _PeersList({required this.vm, required this.session});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        vm.otherPeers,
        session.lastEndReason,
        session.lastError,
      ]),
      builder: (context, _) {
        final peers = vm.otherPeers.value;
        final endReason = session.lastEndReason.value;
        final error = session.lastError.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (endReason != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Last call: ${endReason.name}'
                  '${error == null ? '' : ' ($error)'}',
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
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Semantics(
                                    identifier:
                                        'call_demo.peer.${peer.id}.audio',
                                    child: IconButton(
                                      icon: const Icon(Icons.call),
                                      onPressed: () =>
                                          vm.call(peer, CallMedia.audio),
                                    ),
                                  ),
                                  Semantics(
                                    identifier:
                                        'call_demo.peer.${peer.id}.video',
                                    child: IconButton(
                                      icon: const Icon(Icons.videocam),
                                      onPressed: () =>
                                          vm.call(peer, CallMedia.video),
                                    ),
                                  ),
                                ],
                              ),
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
