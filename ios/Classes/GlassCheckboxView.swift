import Flutter
import SwiftUI
import UIKit

// MARK: - Factory

final class GlassCheckboxViewFactory: NSObject, FlutterPlatformViewFactory {
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
    GlassCheckboxPlatformView(
      frame: frame, viewId: viewId,
      args: args as? [String: Any] ?? [:], messenger: messenger)
  }
}

// MARK: - Platform view

final class GlassCheckboxPlatformView: NSObject, FlutterPlatformView {
  private let container = UIView()
  private let channel: FlutterMethodChannel
  private let model: GlassCheckboxModel
  private var host: UIViewController?

  init(frame: CGRect, viewId: Int64, args: [String: Any], messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: "\(FlutterNativeViewPlugin.checkboxViewType)/\(viewId)", binaryMessenger: messenger)
    model = GlassCheckboxModel(args: args)
    container.backgroundColor = .clear

    super.init()

    model.onChanged = { [weak channel] value in
      channel?.invokeMethod("onChanged", arguments: value)
    }

    if #available(iOS 16.0, *) {
      let hosting = UIHostingController(rootView: GlassCheckboxRoot(model: model))
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

final class GlassCheckboxModel: ObservableObject {
  @Published var isOn: Bool
  @Published var tint: UIColor?
  @Published var respectAccessibility: Bool
  var onChanged: ((Bool) -> Void)?

  init(args: [String: Any]) {
    isOn = args["value"] as? Bool ?? false
    tint = GlassColor.fromARGB(args["tint"] as? Int)
    respectAccessibility = args["respectAccessibility"] as? Bool ?? true
  }

  func apply(args: [String: Any]) {
    isOn = args["value"] as? Bool ?? isOn
    tint = GlassColor.fromARGB(args["tint"] as? Int)
    respectAccessibility = args["respectAccessibility"] as? Bool ?? respectAccessibility
  }
}

@available(iOS 16.0, *)
struct GlassCheckboxRoot: View {
  @ObservedObject var model: GlassCheckboxModel
  @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

  private func shape() -> RoundedRectangle {
    RoundedRectangle(cornerRadius: 6, style: .continuous)
  }

  private var checkColor: Color { Color(uiColor: model.tint ?? .systemBlue) }

  var body: some View {
    Button(action: {
      let newValue = !model.isOn
      model.isOn = newValue
      model.onChanged?(newValue)
    }) {
      ZStack {
        background
        if model.isOn {
          Image(systemName: "checkmark")
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(.white)
        }
      }
      .frame(width: 26, height: 26)
      .contentShape(shape())
    }
    .buttonStyle(.plain)
  }

  @ViewBuilder
  private var background: some View {
    let solid = GlassAccessibility.solidFallback(
      respect: model.respectAccessibility, reduceTransparency: reduceTransparency)
    if !solid, #available(iOS 26.0, *) {
      shape().fill(.clear).glassEffect(resolvedGlass(), in: shape())
    } else {
      // Opaque fallback (also used under Reduce Transparency).
      shape().fill(model.isOn ? checkColor : checkColor.opacity(0.18))
    }
  }

  @available(iOS 26.0, *)
  private func resolvedGlass() -> Glass {
    var glass = Glass.regular
    if model.isOn { glass = glass.tint(checkColor) }
    return glass
  }
}
