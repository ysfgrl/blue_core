
import 'dart:io';

import '../blue_core_messages.g.dart';
import '../util/blue_core_json.dart';

Future<PackageInfoMessage> readLinuxPackageInfo({String? executablePath}) async {
  final executable = executablePath ?? Platform.resolvedExecutable;
  final directory = File(executable).parent;
  final file = File.fromUri(directory.uri.resolve('data/flutter_assets/version.json'),
  );
  return decodePackageInfoJson(await file.readAsString());
}

Future<DeviceInfoMessage> readLinuxDeviceInfo() async {
  if (!Platform.isLinux) {
    throw UnsupportedError('Linux device info requires Linux');
  }
  var model = '';
  for (final path in [
    '/sys/class/dmi/id/product_name',
    '/proc/device-tree/model',
  ]) {
    try {
      model = (await File(path).readAsString()).replaceAll('\u0000', '').trim();
      if (model.isNotEmpty) {
        break;
      }
    } on FileSystemException {
      // Containers and some machines do not expose a hardware model.
    }
  }
  return DeviceInfoMessage(
    platform: 'linux',
    type: 'desktop',
    name: Platform.localHostname,
    model: model,
    version: Platform.operatingSystemVersion,
  );
}
