import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'blue_core_connection_api.dart';
import 'blue_core_messages.g.dart';
import 'util/connection_status.dart';

class BlueCorePlatform extends PlatformInterface {
  BlueCorePlatform() : super(token: _token);

  /// Native Pigeon API used by the default implementation.
  final BlueCoreApi api = BlueCoreApi();
  static final Object _token = Object();
  static BlueCorePlatform _instance = BlueCorePlatform();

  /// Defaults to the Pigeon host API on Android, iOS and macOS.
  static BlueCorePlatform get instance => _instance;

  static set instance(BlueCorePlatform platform) {
    PlatformInterface.verify(platform, _token);
    _instance = platform;
  }

  Future<DeviceInfoMessage> getDeviceInfo() => api.getDeviceInfo();

  Future<PackageInfoMessage> getPackageInfo() => api.getPackageInfo();

  /// Reports connection types, returning ['none'] when disconnected.
  Future<List<String>> getConnectionStaus() async => normalizeConnectionStatus(await api.getConnectionStaus());

  late final Stream<List<String>> _connectionChanges = api.onConnectionStatus();

  Stream<List<String>> get onConnectionChanged => _connectionChanges;

  Stream<List<String>> onConnectionStatus() => onConnectionChanged;
}
