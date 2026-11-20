import '../model/blue_model.dart' show DeviceInfo, PackageInfo;
import 'blue_core_messages.g.dart';
import 'blue_core_platform.dart';

/// Loads and caches metadata through the registered platform implementation.
class BlueCoreImpl {
  const BlueCoreImpl._();

  static DeviceInfo? _currentDeviceInfo;
  static PackageInfo? _currentPackageInfo;

  static Future<void> init() async {
    await Future.wait<Object>([getDeviceInfo(), getPackageInfo()]);
  }

  static Future<List<String>> getConnectionStaus() => BlueCorePlatform.instance.getConnectionStaus();

  static Stream<List<String>> onConnectionStatus() => BlueCorePlatform.instance.onConnectionStatus();

  static DeviceInfo getCurrentDeviceInfo() =>
      _currentDeviceInfo ??
      (throw StateError(
        'Device info has not been loaded. Call BlueCore.init() first.',
      ));

  static PackageInfo getCurrentPackageInfo() =>
      _currentPackageInfo ??
      (throw StateError(
        'Package info has not been loaded. Call BlueCore.init() first.',
      ));

  static Future<DeviceInfo> getDeviceInfo() async {
    final info =
        (await BlueCorePlatform.instance.getDeviceInfo()).toDeviceInfo();
    _currentDeviceInfo = info;
    return info;
  }

  static Future<PackageInfo> getPackageInfo() async {
    final info =
        (await BlueCorePlatform.instance.getPackageInfo()).toPackageInfo();
    _currentPackageInfo = info;
    return info;
  }
}

extension DeviceInfoMessageModel on DeviceInfoMessage {
  DeviceInfo toDeviceInfo() => DeviceInfo.fromJson({
        'platform': platform,
        'type': type,
        'name': name,
        'model': model,
        'version': version,
      });
}

extension PackageInfoMessageModel on PackageInfoMessage {
  PackageInfo toPackageInfo() => PackageInfo.fromJson({
        'appName': appName,
        'packageName': packageName,
        'version': version,
        'buildNumber': buildNumber,
      });
}
