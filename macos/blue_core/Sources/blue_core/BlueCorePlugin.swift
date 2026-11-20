import Foundation
import Darwin
import FlutterMacOS

public class BlueCorePlugin: NSObject, FlutterPlugin, BlueCoreApi {
  func getConnectionStaus(completion: @escaping (Result<[String], Error>) -> Void) {
    ConnectionStatus.read(completion: completion)
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let plugin = BlueCorePlugin()
    BlueCoreApiSetup.setUp(binaryMessenger: registrar.messenger, api: plugin)
    OnConnectionStatusStreamHandler.register(with: registrar.messenger, streamHandler: ConnectionStream())
  }

  func getPackageInfo() throws -> PackageInfoMessage {
    let bundle = Bundle.main
    return PackageInfoMessage(
      appName: bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        ?? bundle.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "",
      packageName: bundle.bundleIdentifier ?? "",
      version: bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "",
      buildNumber: bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
    )
  }

  func getDeviceInfo() throws -> DeviceInfoMessage {
    var size = 0
    var model = ""
    if sysctlbyname("hw.model", nil, &size, nil, 0) == 0 && size > 0 {
      var buffer = [CChar](repeating: 0, count: size)
      if sysctlbyname("hw.model", &buffer, &size, nil, 0) == 0 {
        model = String(cString: buffer)
      }
    }
    let process = ProcessInfo.processInfo
    let version = process.operatingSystemVersion
    return DeviceInfoMessage(
      platform: "macos",
      type: "desktop",
      name: Host.current().localizedName ?? process.hostName,
      model: model,
      version: "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
    )
  }

}
