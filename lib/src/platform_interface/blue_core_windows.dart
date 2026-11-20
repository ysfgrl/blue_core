import 'package:blue_core/src/platform_interface/blue_core_messages.g.dart';

import '../model/blue_model.dart' show DeviceInfo, PackageInfo;
import 'blue_core_platform.dart';
import 'blue_core_messages.g.dart';
import 'windows/windows.dart';
import 'windows/connection.dart';
import 'util/connection_status.dart';

class BlueCoreWindows extends BlueCorePlatform {
  BlueCoreWindows({String? executablePath});

  static void registerWith() {
    BlueCorePlatform.instance = BlueCoreWindows();
  }

  @override
  Future<List<String>> getConnectionStaus() => readWindowsConnectionStatus();

  late final Stream<List<String>> _changes = pollConnectionStatus(getConnectionStaus);

  @override
  Stream<List<String>> get onConnectionChanged => _changes;

  @override
  Future<DeviceInfoMessage> getDeviceInfo() async {
    return readWindowsDeviceInfo();
  }

  @override
  Future<PackageInfoMessage> getPackageInfo() async {
    return readWindowsPackageInfo();
  }
}
