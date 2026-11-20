import Foundation
import Network

enum ConnectionStatus {
  @available(iOS 12.0, macOS 10.14, *)
  static func types(_ path: NWPath) -> [String] {
    guard path.status == .satisfied else { return ["none"] }
    var result: [String] = []
    if path.usesInterfaceType(.wifi) { result.append("wifi") }
    if path.usesInterfaceType(.wiredEthernet) { result.append("ethernet") }
    if path.usesInterfaceType(.cellular) { result.append("mobile") }
    if result.isEmpty || path.usesInterfaceType(.other) { result.append("other") }
    return result
  }

  static func read(completion: @escaping (Result<[String], Error>) -> Void) {
    guard #available(iOS 12.0, macOS 10.14, *) else {
      completion(.failure(NSError(
        domain: "blue_core.connection",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Connection status requires macOS 10.14 or later."]
      )))
      return
    }
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "com.ysfgrl.blue_core.connection")
    var finished = false
    monitor.pathUpdateHandler = { path in
      guard !finished else { return }
      finished = true
      let result = types(path)
      monitor.cancel()
      monitor.pathUpdateHandler = nil
      DispatchQueue.main.async { completion(.success(result)) }
    }
    monitor.start(queue: queue)
  }
}
