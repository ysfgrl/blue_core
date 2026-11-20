import 'blue_core_messages.g.dart';
import 'blue_core_platform.dart';
import 'linux/linux.dart';
import 'linux/connection.dart';
import 'util/connection_status.dart';

class BlueCoreLinux extends BlueCorePlatform {
  BlueCoreLinux({String? executablePath});
  static void registerWith() {
    BlueCorePlatform.instance = BlueCoreLinux();
  }

  @override
  Future<List<String>> getConnectionStaus() => readLinuxConnectionStatus();

  late final Stream<List<String>> _changes =  pollConnectionStatus(getConnectionStaus);

  @override
  Stream<List<String>> get onConnectionChanged => _changes;

  @override
  Future<DeviceInfoMessage> getDeviceInfo() async {
    return readLinuxDeviceInfo();
  }

  @override
  Future<PackageInfoMessage> getPackageInfo() async {
    return readLinuxPackageInfo();
  }
}
