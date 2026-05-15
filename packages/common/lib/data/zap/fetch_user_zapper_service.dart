import 'dart:convert';
import 'dart:developer';
import 'package:common/data/zap/zapper.dart';
import 'package:common/data/zap/zaps.dart';
import 'package:common/domain/error/app_error.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:nostr/key_tool/bech32_tool.dart';
import 'package:nostr/model/nostr_event.dart';

class FetchUserZapperService {
  const FetchUserZapperService();

  Future<UserDataZapper?> fetchUserZapper(String lightningAddress) async {
    final lnurl = await userLnUrl(lightningAddress);
    if (lnurl == null) {
      return null;
    }
    return tryGet(lnurl);
  }

  Future<String?> userLnUrl(String lightningAddress) async {
    final lnurl = ZapUtils.deriveLnUrl(lightningAddress);
    return lnurl == null || lnurl.isEmpty ? null : lnurl;
  }

  Future<UserDataZapper?> tryGet(String lnurl) async {
    try {
      final decodeLnrl = Bech32Tool.decodeBytes(lnurl);

      final data = decodeLnrl.data;

      if (data.isEmpty) {
        return null;
      }

      final url = utf8.decode(data);
      final uri = Uri.parse(url);

      final res = await http.get(uri);
      final body = res.body;

      final parsed = _tryParseJson<Map<String, dynamic>>(body);
      if (parsed != null) {
        if (parsed.containsKey('callback')) {
          return UserDataZapper.fromMap(parsed, originalLnurl: lnurl);
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      log('FetchUserZapperService: $e', name: 'Zaps');
      return null;
    }
  }

  Future<String?> getInvoice({
    required UserDataZapper zapper,
    required int sats,
    required NostrEvent event,
  }) {
    return _Inv.getInvoice(zapper: zapper, sats: sats, event: event);
  }

  static T? _tryParseJson<T>(String source) {
    try {
      final result = jsonDecode(source);
      return result is T ? result : null;
    } catch (e) {
      return null;
    }
  }
}

abstract class _Inv {
  static Future<String?> getInvoice({
    required UserDataZapper zapper,
    required int sats,
    required NostrEvent event,
  }) async {
    final encodedJsonEvent = jsonEncode({
      'id': event.id,
      'content': event.content,
      'created_at': event.createdAt,
      'pubkey': event.pubkey,
      'kind': event.kind,
      'sig': event.sig,
      'tags': event.tags,
    });

    final ecodedUriEvent = Uri.encodeComponent(encodedJsonEvent);

    final callback = zapper.callback;

    if (callback == null) {
      return null;
    }

    final url =
        '$callback?amount=${sats * 1000}&nostr=$ecodedUriEvent&lnurl=${zapper.originalLnurl}';

    log('Zap callback url: $url', name: 'Zaps');

    try {
      final result = await http.get(Uri.parse(url));

      if (result.statusCode >= 200 && result.statusCode < 300) {
        final decoded = jsonDecode(result.body) as Map<String, dynamic>;

        if (decoded['status'] == 'ERROR') {
          throw FailedToGetInvoiceError(
            statusCode: result.statusCode,
            reason: decoded['reason'] as String? ?? '',
          );
        }

        final invoice = decoded['pr'] as String;

        return invoice;
      } else {
        try {
          final decoded = jsonDecode(result.body) as Map<String, dynamic>;
          throw FailedToGetInvoiceError(
            statusCode: result.statusCode,
            reason: decoded['error'] == true
                ? decoded['message'] as String? ??
                      decoded['reason'] as String? ??
                      ''
                : '',
          );
        } catch (e) {
          throw FailedToGetInvoiceError(
            statusCode: result.statusCode,
            reason: '',
            parentError: e,
          );
        }
      }
    } catch (e) {
      if (e is FailedToGetInvoiceError) {
        rethrow;
      } else {
        throw FailedToGetInvoiceError(
          statusCode: null,
          reason: '',
          parentError: e,
        );
      }
    }
  }
}

final class FailedToGetInvoiceError extends AppError {
  const FailedToGetInvoiceError({
    required this.statusCode,
    required super.reason,
    super.parentError,
  });
  final int? statusCode;

  @override
  String get message {
    final parentErrorStr = parentError != null ? parentError.toString() : '';
    final str = <String>[
      'Failed to get invoice',
      if (statusCode != null) 'Status code: $statusCode',
      if (reason.isNotEmpty) 'Reason: $reason',
      if (parentErrorStr.isNotEmpty) 'Parent error: $parentErrorStr',
    ].join('. ');

    return str;
  }
}
