import 'dart:async';
import 'dart:js_interop';

import 'package:dio/dio.dart';
import 'package:web/web.dart' as web;
import 'blue_core_platform.dart';
import 'util/blue_core_json.dart';
import 'web/web.dart';
import 'blue_core_messages.g.dart';
import 'util/connection_status.dart';

class BlueCoreWeb extends BlueCorePlatform {
  BlueCoreWeb({String? baseUrl, Dio? client});

  static void registerWith(Object registrar) {
    BlueCorePlatform.instance = BlueCoreWeb();
  }

  // Browsers expose online status but cannot reliably distinguish transports.
  @override
  Future<List<String>> getConnectionStaus() async =>
      web.window.navigator.onLine ? ['other'] : ['none'];

  late final Stream<List<String>> _changes = _watchConnection();

  @override
  Stream<List<String>> get onConnectionChanged => _changes;

  Stream<List<String>> _watchConnection() {
    late StreamController<List<String>> controller;
    final callback = ((web.Event event) {
      controller.add(web.window.navigator.onLine ? ['other'] : ['none']);
    }).toJS;
    controller = StreamController<List<String>>.broadcast(
      onListen: () {
        web.window.addEventListener('online', callback);
        web.window.addEventListener('offline', callback);
        controller.add(web.window.navigator.onLine ? ['other'] : ['none']);
      },
      onCancel: () {
        web.window.removeEventListener('online', callback);
        web.window.removeEventListener('offline', callback);
      },
    );
    return controller.stream.distinct(sameConnectionStatus);
  }

  @override
  Future<DeviceInfoMessage> getDeviceInfo() {
    Uri uri = Uri.parse(web.document.baseURI);
    return Future.value(
        deviceInfoFromUserAgent(web.window.navigator.userAgent));
  }

  @override
  Future<PackageInfoMessage> getPackageInfo() async {
    final base = Uri.parse(web.document.baseURI);
    final versionUri = base.resolve('version.json');
    final uri = versionUri.replace(
      queryParameters: {
        ...versionUri.queryParameters,
        'cachebuster': DateTime.now().millisecondsSinceEpoch.toString(),
      },
    );
    final dio = Dio();
    try {
      final response = await dio.getUri<String>(
        uri,
        options: Options(responseType: ResponseType.plain),
      );
      final body = response.data;
      if (body == null) {
        throw const FormatException('version.json response is empty');
      }
      return decodePackageInfoJson(body);
    } finally {
      dio.close();
    }
  }
}
