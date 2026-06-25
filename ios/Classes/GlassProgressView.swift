import Flutter
import SwiftUI
import UIKit

// MARK: - Factory

final class GlassProgressViewFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger
  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }
  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }
  func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?)
    -> FlutterPlatformView
  {
    GlassProgressPlatformView(
      frame: frame, viewId: viewId,
      args: args as? [String: Any] ?? [:], messenger: messenger)
  }
}

// MARK: - Platform view

final class GlassProgressPlatformView: NSObject, FlutterPlatformView {
  private let container = UIView()
  private let channel: FlutterMethodChannel
  private let model: GlassProgressModel
  private var host: UIViewController?

  init(frame: CGRect, viewId: Int64, args: [String: Any], messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: "\(FlutterNativeViewPlugin.progressViewType)/\(viewId)", binaryMessenger: messenger)
    model = GlassProgressModel(args: args)
    container.backgroundColor = .clear
    super.init()

    if #available(iOS 16.0, *) {
      let hosting = UIHostingController(rootView: GlassProgressRoot(model: model))
      hosting.view.backgroundColor = .clear
      hosting.view.frame = container.bounds
      hosting.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      container.addSubview(hosting.view)
      host = hosting
    }

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(nil); return }
      switch call.method {
      case "setValue":
        self.model.value = call.arguments as? Double ?? self.model.value
        result(nil)
      case "updateConfig":
        self.model.apply(args: call.arguments as? [String: Any] ?? [:])
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  func view() -> UIView { container }
}

// MARK: - SwiftUI

final class GlassProgressModel: ObservableObject {
  @Published var value: Double
  @Published var tint: UIColor?

  init(args: [String: Any]) {
    value = args["value"] as? Double ?? 0
    tint = GlassColor.fromARGB(args["tint"] as? Int)
  }

  func apply(args: [String: Any]) {
    value = args["value"] as? Double ?? value
    tint = GlassColor.fromARGB(args["tint"] as? Int)
  }
}

@available(iOS 16.0, *)
struct GlassProgressRoot: View {
  @ObservedObject var model: GlassProgressModel

  var body: some View {
    if #available(iOS 26.0, *) {
      if model.value > 0 {
        ProgressView(value: model.value, total: 1)
          .tint(model.tint.map { Color(uiColor: $0) })
      } else {
        ProgressView()
          .tint(model.tint.map { Color(uiColor: $0) })
      }
    } else {
      if model.value > 0 {
        ProgressView(value: model.value, total: 1)
          .tint(model.tint.map { Color(uiColor: $0) })
      } else {
        ProgressView()
          .tint(model.tint.map { Color(uiColor: $0) })
      }
    }
  }
}
