import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/platform_interface/blue_core_messages.g.dart',
  kotlinOut: 'android/src/main/kotlin/com/ysfgrl/blue_core/Messages.g.kt',
  kotlinOptions: KotlinOptions(package: 'com.ysfgrl.blue_core'),
  swiftOut: 'ios/blue_core/Sources/blue_core/Messages.g.swift',
  dartPackageName: 'blue_core',
))
@HostApi()
abstract class BlueCoreApi {
  PackageInfoMessage getPackageInfo();
  DeviceInfoMessage getDeviceInfo();
  @async
  List<String> getConnectionStaus();
}

/// Event definition for the public Stream<List<String>> connection API.
@EventChannelApi()
abstract class BlueCoreConnectionEvents {
  List<String> onConnectionStatus();
}

class PackageInfoMessage {
  PackageInfoMessage({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
  });

  String appName;
  String packageName;
  String version;
  String buildNumber;
}

class DeviceInfoMessage {
  DeviceInfoMessage({
    required this.platform,
    required this.name,
    required this.type,
    required this.version,
    required this.model,
  });

  final String platform;
  final String type;
  final String name;
  final String model;
  final String version;
}
