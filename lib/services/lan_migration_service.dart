import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../models/note.dart';
import 'migration_package_service.dart';

class LanMigrationPayload {
  const LanMigrationPayload({
    required this.confirmationCode,
    required this.noteCount,
    required this.packageText,
  });

  final String confirmationCode;
  final int noteCount;
  final String packageText;

  static LanMigrationPayload fromJson(Map<String, Object?> json) {
    final confirmationCode = json['confirmationCode'];
    final noteCount = json['noteCount'];
    final packageText = json['packageText'];
    if (confirmationCode is! String ||
        noteCount is! int ||
        packageText is! String) {
      throw const MigrationPackageException('Invalid LAN migration payload.');
    }
    return LanMigrationPayload(
      confirmationCode: confirmationCode,
      noteCount: noteCount,
      packageText: packageText,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'confirmationCode': confirmationCode,
      'noteCount': noteCount,
      'packageText': packageText,
    };
  }
}

class LanMigrationSession {
  const LanMigrationSession({
    required this.url,
    required this.alternativeUrls,
    required this.confirmationCode,
    required this.noteCount,
  });

  final String url;
  final List<String> alternativeUrls;
  final String confirmationCode;
  final int noteCount;
}

class LanMigrationRequest {
  LanMigrationRequest._({required this.remoteAddress, required this._approval});

  final String remoteAddress;
  final Completer<bool> _approval;

  void approve() {
    if (!_approval.isCompleted) {
      _approval.complete(true);
    }
  }

  void deny() {
    if (!_approval.isCompleted) {
      _approval.complete(false);
    }
  }
}

class LanMigrationServer {
  LanMigrationServer._({
    required this.session,
    required this._server,
    required this._timeoutTimer,
  });

  final LanMigrationSession session;
  final HttpServer _server;
  final Timer _timeoutTimer;
  final Completer<void> _closed = Completer<void>();
  bool _stopped = false;

  Future<void> get closed => _closed.future;

  Future<void> stop() async {
    if (_stopped) {
      return;
    }
    _stopped = true;
    _timeoutTimer.cancel();
    await _server.close(force: true);
    if (!_closed.isCompleted) {
      _closed.complete();
    }
  }
}

class LanMigrationService {
  LanMigrationService(
    this._packageService, {
    Duration? sessionTtl,
    String? advertisedAddress,
  }) : _sessionTtl = sessionTtl ?? const Duration(minutes: 10),
       _advertisedAddress =
           advertisedAddress == null || advertisedAddress.isEmpty
           ? null
           : advertisedAddress;

  final MigrationPackageService _packageService;
  final Duration _sessionTtl;
  final String? _advertisedAddress;
  final Random _random = Random.secure();

  Future<LanMigrationServer> startServer({
    required List<Note> notes,
    required String passphrase,
    void Function(LanMigrationRequest request)? onReceiveRequest,
  }) async {
    final packageText = await _packageService.exportNotes(
      notes: notes,
      passphrase: passphrase,
    );
    final token = _randomToken();
    final confirmationCode = _confirmationCode();
    final payload = LanMigrationPayload(
      confirmationCode: confirmationCode,
      noteCount: notes.length,
      packageText: packageText,
    );
    final httpServer = await HttpServer.bind(InternetAddress.anyIPv4, 0);
    final addresses = _advertisedAddress == null
        ? await _localAddresses()
        : [_advertisedAddress];
    final address = addresses.first;
    final alternativeUrls = addresses
        .skip(1)
        .map((address) => 'http://$address:${httpServer.port}/migration/$token')
        .toList(growable: false);
    late final LanMigrationServer migrationServer;
    migrationServer = LanMigrationServer._(
      timeoutTimer: Timer(_sessionTtl, () {
        unawaited(migrationServer.stop());
      }),
      server: httpServer,
      session: LanMigrationSession(
        url: 'http://$address:${httpServer.port}/migration/$token',
        alternativeUrls: alternativeUrls,
        confirmationCode: confirmationCode,
        noteCount: notes.length,
      ),
    );
    httpServer.listen((request) {
      _handleRequest(request, token, payload, onReceiveRequest);
    });

    return migrationServer;
  }

  Future<LanMigrationPayload> fetchPayload(String url) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 8);
      final request = await client.getUrl(Uri.parse(url.trim()));
      request.headers.set('X-Secure-Notes-Migration', '1');
      final response = await request.close();
      final body = await utf8.decodeStream(response);
      client.close(force: true);
      if (response.statusCode != HttpStatus.ok) {
        throw const MigrationPackageException('LAN migration request failed.');
      }
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, Object?>) {
        throw const MigrationPackageException('Invalid LAN migration payload.');
      }
      return LanMigrationPayload.fromJson(decoded);
    } catch (_) {
      throw const MigrationPackageException(
        'Cannot connect to the LAN migration address.',
      );
    }
  }

  Future<void> _handleRequest(
    HttpRequest request,
    String token,
    LanMigrationPayload payload,
    void Function(LanMigrationRequest request)? onReceiveRequest,
  ) async {
    final response = request.response;
    response.headers.contentType = ContentType.json;
    if (request.method != 'GET' || request.uri.path != '/migration/$token') {
      response.statusCode = HttpStatus.notFound;
      response.write(jsonEncode({'error': 'not_found'}));
      await response.close();
      return;
    }

    if (request.headers.value('X-Secure-Notes-Migration') != '1') {
      response.statusCode = HttpStatus.forbidden;
      response.write(jsonEncode({'error': 'app_client_required'}));
      await response.close();
      return;
    }

    if (onReceiveRequest != null) {
      final approval = Completer<bool>();
      onReceiveRequest(
        LanMigrationRequest._(
          remoteAddress: request.connectionInfo?.remoteAddress.address ?? '',
          approval: approval,
        ),
      );
      final approved = await approval.future.timeout(
        const Duration(minutes: 2),
        onTimeout: () => false,
      );
      if (!approved) {
        response.statusCode = HttpStatus.forbidden;
        response.write(jsonEncode({'error': 'request_denied'}));
        await response.close();
        return;
      }
    }

    response.write(jsonEncode(payload.toJson()));
    await response.close();
  }

  Future<List<String>> _localAddresses() async {
    final interfaces = await NetworkInterface.list(
      includeLinkLocal: false,
      type: InternetAddressType.IPv4,
    );
    final addresses = <String>[];
    for (final interface in interfaces) {
      for (final address in interface.addresses) {
        if (!address.isLoopback) {
          addresses.add(address.address);
        }
      }
    }
    addresses.sort(_compareLanAddress);
    return addresses.isEmpty
        ? [InternetAddress.loopbackIPv4.address]
        : addresses;
  }

  int _compareLanAddress(String left, String right) {
    return _addressPriority(left).compareTo(_addressPriority(right));
  }

  int _addressPriority(String address) {
    if (address.startsWith('192.168.')) {
      return 0;
    }
    if (address.startsWith('10.')) {
      return 1;
    }
    final parts = address.split('.');
    final second = parts.length > 1 ? int.tryParse(parts[1]) : null;
    if (address.startsWith('172.') &&
        second != null &&
        second >= 16 &&
        second <= 31) {
      return 2;
    }
    return 3;
  }

  String _confirmationCode() {
    return List<int>.generate(6, (_) => _random.nextInt(10)).join();
  }

  String _randomToken() {
    const alphabet =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List<String>.generate(
      18,
      (_) => alphabet[_random.nextInt(alphabet.length)],
    ).join();
  }
}
