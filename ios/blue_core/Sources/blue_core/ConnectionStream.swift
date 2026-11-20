import Foundation
import Network
#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

final class ConnectionStream: OnConnectionStatusStreamHandler {
  private var stop: (() -> Void)?
  private var session = UUID()

  override func onListen(withArguments arguments: Any?, sink: PigeonEventSink<[String]>) {
    stop?()
    let token = UUID()
    session = token
    guard #available(iOS 12.0, macOS 10.14, *) else {
      sink.error(code: "unsupported", message: "Connection monitoring requires macOS 10.14 or later.", details: nil)
      return
    }
    let monitor = NWPathMonitor()
    monitor.pathUpdateHandler = { [weak self] path in
      let types = ConnectionStatus.types(path)
      DispatchQueue.main.async {
        guard let self = self, self.session == token else { return }
        sink.success(types)
      }
    }
    monitor.start(queue: DispatchQueue(label: "com.ysfgrl.blue_core.connection.stream"))
    stop = {
      monitor.cancel()
      monitor.pathUpdateHandler = nil
    }
  }

  override func onCancel(withArguments arguments: Any?) {
    session = UUID()
    stop?()
    stop = nil
  }

  deinit { stop?() }
}
