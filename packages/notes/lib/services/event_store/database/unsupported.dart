import 'package:nostr_notes/services/event_store/database/app_database.dart';

Never _unsupported() {
  throw UnsupportedError(
    'No suitable database implementation was found on this platform.',
  );
}

AppDatabase get database => _unsupported();
