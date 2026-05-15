import 'dart:convert';
import 'dart:developer';
import 'package:common/data/zap/zap_callback_response.dart';
import 'package:common/data/zap/zapper.dart';
import 'package:common/domain/error/app_error.dart';
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
    return _tryGet(lnurl);
  }

  Future<String?> userLnUrl(String lightningAddress) async {
    final lnurl = _deriveLnUrl(lightningAddress);
    return lnurl == null || lnurl.isEmpty ? null : lnurl;
  }

  Future<UserDataZapper?> _tryGet(String lnurl) async {
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

  String? _deriveLnUrl(String address) {
    if (address.startsWith('lnurl1')) {
      return address;
    }

    // url
    if (address.contains('://')) {
      final url = address;

      final bytes = utf8.encode(url);

      final result = Bech32Tool.encodeBech32FromBytes(
        'lnurl',
        bytes,
        maxLength: 200,
      );

      return result;
    }

    // lud16 address
    if (address.contains('@')) {
      final split = address.split('@');

      if (split.length == 2) {
        final [name, domain] = split;

        final url = 'https://$domain/.well-known/lnurlp/$name';

        final bytes = utf8.encode(url);

        final result = Bech32Tool.encodeBech32FromBytes(
          'lnurl',
          bytes,
          maxLength: 300,
        );

        return result;
      }
    }
    return null;
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
        final decoded = _tryParseJson<Map<String, dynamic>>(result.body);
        if (decoded == null) {
          throw FailedToGetInvoiceError(
            payload: FetchUserZapperServiceErrorType.invalidResponse,
            statusCode: result.statusCode,
          );
        }

        final response = ZapCallbackResponse.fromJson(decoded);

        if (response.isLnurlError) {
          throw FailedToGetInvoiceError(
            payload: FetchUserZapperServiceErrorType.lnurlError,
            statusCode: result.statusCode,
            reason: response.errorReason,
          );
        }

        final invoice = response.pr;
        if (invoice == null || invoice.isEmpty) {
          throw FailedToGetInvoiceError(
            payload: FetchUserZapperServiceErrorType.missingInvoice,
            statusCode: result.statusCode,
          );
        }

        return invoice;
      } else {
        final decoded = _tryParseJson<Map<String, dynamic>>(result.body);
        final response = decoded != null
            ? ZapCallbackResponse.fromJson(decoded)
            : null;
        throw FailedToGetInvoiceError(
          payload: FetchUserZapperServiceErrorType.httpError,
          statusCode: result.statusCode,
          reason: response?.errorReason ?? '',
        );
      }
    } catch (e) {
      if (e is FailedToGetInvoiceError) {
        rethrow;
      } else {
        throw FailedToGetInvoiceError(
          payload: FetchUserZapperServiceErrorType.unknown,
          parentError: e,
        );
      }
    }
  }
}

T? _tryParseJson<T>(String source) {
  try {
    final result = jsonDecode(source);
    return result is T ? result : null;
  } catch (e) {
    return null;
  }
}

enum FetchUserZapperServiceErrorType {
  invalidResponse,
  lnurlError,
  missingInvoice,
  httpError,
  unknown,
}

final class FailedToGetInvoiceError
    extends CustomError<FetchUserZapperServiceErrorType> {
  final int? statusCode;

  const FailedToGetInvoiceError({
    required super.payload,
    this.statusCode,
    super.reason,
    super.parentError,
  });

  String get debugMessage {
    final description = switch (payload) {
      FetchUserZapperServiceErrorType.invalidResponse =>
        'Invalid response from server',
      FetchUserZapperServiceErrorType.lnurlError => 'LNURL error',
      FetchUserZapperServiceErrorType.missingInvoice =>
        'Missing payment request in response',
      FetchUserZapperServiceErrorType.httpError => 'HTTP error',
      FetchUserZapperServiceErrorType.unknown => 'Unknown error',
    };
    return <String>[
      description,
      if (statusCode != null) 'Status code: $statusCode',
      if (reason.isNotEmpty) 'Reason: $reason',
      if (parentError != null) 'Parent error: $parentError',
    ].join('. ');
  }
}
