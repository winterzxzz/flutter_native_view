import Flutter
import SwiftUI
import UIKit

// MARK: - Factory

final class GlassToggleViewFactory: NSObject, FlutterPlatformViewFactory {
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
    GlassTogglePlatformView(
      frame: frame, viewId: viewId,
      args: args as? [String: Any] ?? [:], messenger: messenger)
  }
}

// MARK: - Platform view

final class GlassTogglePlatformView: NSObject, FlutterPlatformView {
  private let container = UIView()
  private let channel: FlutterMethodChannel
  private let model: GlassToggleModel
  private var host: UIViewController?

  init(frame: CGRect, viewId: Int64, args: [String: Any], messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: "\(FlutterNativeViewPlugin.toggleViewType)/\(viewId)", binaryMessenger: messenger)
    model = GlassToggleModel(args: args)
    container.backgroundColor = .clear

    super.init()

    model.onChanged = { [weak channel] value in
      channel?.invokeMethod("onChanged", arguments: value)
    }

    if #available(iOS 16.0, *) {
      let hosting = UIHostingController(rootView: GlassToggleRoot(model: model))
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
        if let v = call.arguments as? Bool { self.model.isOn = v }
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

final class GlassToggleModel: ObservableObject {
  @Published var isOn: Bool
  @Published var tint: UIColor?
  var onChanged: ((Bool) -> Void)?

  init(args: [String: Any]) {
    isOn = args["value"] as? Bool ?? false
    tint = GlassColor.fromARGB(args["tint"] as? Int)
  }

  func apply(args: [String: Any]) {
    isOn = args["value"] as? Bool ?? isOn
    tint = GlassColor.fromARGB(args["tint"] as? Int)
  }
}

@available(iOS 16.0, *)
struct GlassToggleRoot: View {
  @ObservedObject var model: GlassToggleModel

  var body: some View {
    Toggle(
      "",
      isOn: Binding(
        get: { model.isOn },
        set: { newValue in
          model.isOn = newValue
          model.onChanged?(newValue)
        })
    )
    .labelsHidden()
    .tint(model.tint.map { Color(uiColor: $0) })
  }
}
