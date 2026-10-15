import FlutterMacOS
import Foundation

/// Receives an EPUB opened from Finder and keeps it until Dart is listening.
final class OpenedEpubRelay: NSObject, FlutterStreamHandler {
  static let shared = OpenedEpubRelay()
  static let channelName = "com.somosliora.app/open_epub"

  private var sink: FlutterEventSink?
  private var pending: [[String: String]] = []

  func register(messenger: FlutterBinaryMessenger) {
    let channel = FlutterEventChannel(name: Self.channelName, binaryMessenger: messenger)
    channel.setStreamHandler(self)
  }

  @discardableResult
  func handle(url: URL) -> Bool {
    guard url.pathExtension.lowercased() == "epub" else { return false }
    DispatchQueue.global(qos: .userInitiated).async {
      let accessed = url.startAccessingSecurityScopedResource()
      let copied = self.copy(url)
      if accessed { url.stopAccessingSecurityScopedResource() }
      guard let copied else { return }
      let name = url.lastPathComponent
      DispatchQueue.main.async {
        self.emit(path: copied.path, name: name.isEmpty ? "book.epub" : name)
      }
    }
    return true
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    sink = events
    for event in pending {
      events(event)
    }
    pending.removeAll()
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    sink = nil
    return nil
  }

  private func emit(path: String, name: String) {
    let event = ["path": path, "name": name]
    if let sink {
      sink(event)
    } else {
      pending.append(event)
    }
  }

  private func copy(_ url: URL) -> URL? {
    guard let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
      return nil
    }
    let directory = caches.appendingPathComponent("opened_epubs", isDirectory: true)
    do {
      try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
      let destination = directory.appendingPathComponent("\(DispatchTime.now().uptimeNanoseconds)_\(safeName(url.lastPathComponent))")
      if FileManager.default.fileExists(atPath: destination.path) {
        try FileManager.default.removeItem(at: destination)
      }
      try FileManager.default.copyItem(at: url, to: destination)
      return destination
    } catch {
      return nil
    }
  }

  private func safeName(_ raw: String) -> String {
    let base = (raw as NSString).lastPathComponent
    let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "._- "))
    let cleaned = String(base.unicodeScalars.filter { allowed.contains($0) })
    let name = cleaned.isEmpty ? "book.epub" : cleaned
    return name.lowercased().hasSuffix(".epub") ? name : "\(name).epub"
  }
}
