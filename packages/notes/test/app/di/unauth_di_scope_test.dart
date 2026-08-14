import 'package:di_storage/di_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr/nostr_client/nostr_client.dart';
import 'package:nostr_notes/app/di/unauth/unauth_di_scope.dart';

void main() {
  tearDown(() => DiStorage.shared.removeAll());

  group('NostrModule', () {
    test(
      'removeScope<NostrModule> disposes the previously-resolved NostrClient '
      '(the real hot-restart path — DiStorage.removeScope, not removeAll)',
      () async {
        final di = DiStorage.shared;
        const NostrModule().bind(di);

        final oldClient = di.resolve<NostrClient>();

        var relaysStreamDone = false;
        oldClient.relaysListStream.listen(
          (_) {},
          onDone: () => relaysStreamDone = true,
        );

        var errorsStreamDone = false;
        oldClient.relayErrors.listen(
          (_) {},
          onDone: () => errorsStreamDone = true,
        );

        // Mirrors AppDi.removeUnauthModules(): DiStorage.removeScope (not
        // removeAll) is the path a real hot restart / logout takes, and
        // it passes onRemove the raw resolved instance rather than
        // di_storage's internal wrapper.
        di.removeScope<NostrModule>();

        // The done events from closing the subjects land in a microtask.
        await Future.delayed(Duration.zero);

        expect(
          relaysStreamDone,
          isTrue,
          reason:
              'NostrClient.relaysListStream should be closed by '
              'disconnectAndDispose() once NostrModule is removed',
        );
        expect(
          errorsStreamDone,
          isTrue,
          reason:
              'NostrClient.relayErrors should be closed by '
              'disconnectAndDispose() once NostrModule is removed',
        );
      },
    );

    test(
      'rebinding after removeScope hands out a fresh NostrClient instance',
      () {
        final di = DiStorage.shared;
        const NostrModule().bind(di);
        final oldClient = di.resolve<NostrClient>();

        di.removeScope<NostrModule>();
        const NostrModule().bind(di);
        final newClient = di.resolve<NostrClient>();

        expect(identical(newClient, oldClient), isFalse);
      },
    );
  });
}
