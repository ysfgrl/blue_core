import Foundation
import Flutter
import UIKit

public class BlueCorePlugin: NSObject, FlutterPlugin, BlueCoreApi {
  func getConnectionStaus(completion: @escaping (Result<[String], Error>) -> Void) {
    ConnectionStatus.read(completion: completion)
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let plugin = BlueCorePlugin()
    BlueCoreApiSetup.setUp(binaryMessenger: registrar.messenger(), api: plugin)
    OnConnectionStatusStreamHandler.register(with: registrar.messenger(), streamHandler: ConnectionStream())
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
    let device = UIDevice.current
    let type: String
    switch device.userInterfaceIdiom {
    case .phone: type = "phone"
    case .pad: type = "tablet"
    case .tv: type = "tv"
    case .carPlay: type = "car"
    default: type = "unknown"
    }
    var system = utsname()
    uname(&system)
    let capacity = MemoryLayout.size(ofValue: system.machine)
    let model = withUnsafePointer(to: &system.machine) { pointer in
      pointer.withMemoryRebound(to: CChar.self, capacity: capacity) {
        String(cString: $0)
      }
    }
    return DeviceInfoMessage(
      platform: "ios",
      type: type,
      name: device.name,
      model: model,
      version: device.systemVersion
    )
  }

}
