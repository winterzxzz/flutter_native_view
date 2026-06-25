import Flutter
import SwiftUI
import UIKit

// MARK: - Factory

final class GlassSliderViewFactory: NSObject, FlutterPlatformViewFactory {
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
    GlassSliderPlatformView(
      frame: frame, viewId: viewId,
      args: args as? [String: Any] ?? [:], messenger: messenger)
  }
}

// MARK: - Platform view

final class GlassSliderPlatformView: NSObject, FlutterPlatformView {
  private let container = UIView()
  private let channel: FlutterMethodChannel
  private let model: GlassSliderModel
  private var host: UIViewController?

  init(frame: CGRect, viewId: Int64, args: [String: Any], messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: "\(FlutterNativeViewPlugin.sliderViewType)/\(viewId)", binaryMessenger: messenger)
    model = GlassSliderModel(args: args)
    container.backgroundColor = .clear
    super.init()

    model.onChanged = { [weak channel] value in
      channel?.invokeMethod("onChanged", arguments: value)
    }

    if #available(iOS 16.0, *) {
      let hosting = UIHostingController(rootView: GlassSliderRoot(model: model))
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

final class GlassSliderModel: ObservableObject {
  @Published var value: Double
  @Published var min: Double
  @Published var max: Double
  @Published var tint: UIColor?
  var onChanged: ((Double) -> Void)?

  init(args: [String: Any]) {
    value = args["value"] as? Double ?? 0
    min = args["min"] as? Double ?? 0
    max = args["max"] as? Double ?? 1
    tint = GlassColor.fromARGB(args["tint"] as? Int)
  }

  func apply(args: [String: Any]) {
    value = args["value"] as? Double ?? value
    min = args["min"] as? Double ?? min
    max = args["max"] as? Double ?? max
    tint = GlassColor.fromARGB(args["tint"] as? Int)
  }
}

@available(iOS 16.0, *)
struct GlassSliderRoot: View {
  @ObservedObject var model: GlassSliderModel

  var body: some View {
    if #available(iOS 26.0, *) {
      Slider(value: Binding(get: { model.value }, set: { model.value = $0; model.onChanged?($0) }),
             in: model.min...model.max)
        .tint(model.tint.map { Color(uiColor: $0) })
    } else {
      Slider(value: Binding(get: { model.value }, set: { model.value = $0; model.onChanged?($0) }),
             in: model.min...model.max)
        .tint(model.tint.map { Color(uiColor: $0) })
    }
  }
}
