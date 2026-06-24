import Flutter
import SwiftUI
import UIKit

class GlassSwitchViewFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    GlassSwitchPlatformView(
      frame: frame,
      viewId: viewId,
      args: args as? [String: Any] ?? [:],
      messenger: messenger)
  }
}

/// Observable state shared between the platform view and the SwiftUI `Toggle`.
private class SwitchModel: ObservableObject {
  @Published var isOn: Bool
  var onToggle: ((Bool) -> Void)?

  init(isOn: Bool) { self.isOn = isOn }
}

class GlassSwitchPlatformView: NSObject, FlutterPlatformView {
  private let host: UIHostingController<AnyView>
  private let model: SwitchModel
  private let channel: FlutterMethodChannel

  init(
    frame: CGRect,
    viewId: Int64,
    args: [String: Any],
    messenger: FlutterBinaryMessenger
  ) {
    let value = args["value"] as? Bool ?? false
    let tint = GlassColor.fromARGB(args["tintColor"] as? Int)

    model = SwitchModel(isOn: value)
    channel = FlutterMethodChannel(
      name: "flutter_native_view/glass_switch_\(viewId)",
      binaryMessenger: messenger)

    host = UIHostingController(rootView: AnyView(GlassSwitch(model: model, tint: tint)))
    host.view.backgroundColor = .clear
    host.view.isOpaque = false
    host.view.frame = frame
    super.init()

    model.onToggle = { [weak self] newValue in
      self?.channel.invokeMethod("onChanged", arguments: newValue)
    }
    channel.setMethodCallHandler { [weak self] call, result in
      if call.method == "setValue", let v = call.arguments as? Bool {
        self?.model.isOn = v
        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }

  func view() -> UIView { host.view }
}

private struct GlassSwitch: View {
  @ObservedObject var model: SwitchModel
  let tint: Color?

  var body: some View {
    let toggle = Toggle("", isOn: Binding(
      get: { model.isOn },
      set: { newValue in
        model.isOn = newValue
        model.onToggle?(newValue)
      }))
      .labelsHidden()

    if let tint = tint {
      toggle.tint(tint)
    } else {
      toggle
    }
  }
}
