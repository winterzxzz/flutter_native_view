import Flutter
import SwiftUI
import UIKit

// MARK: - Factory

final class GlassTextFieldViewFactory: NSObject, FlutterPlatformViewFactory {
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
    GlassTextFieldPlatformView(
      frame: frame, viewId: viewId,
      args: args as? [String: Any] ?? [:], messenger: messenger)
  }
}

// MARK: - Platform view

final class GlassTextFieldPlatformView: NSObject, FlutterPlatformView {
  private let container = UIView()
  private let channel: FlutterMethodChannel
  private let model: GlassTextFieldModel
  private var host: UIViewController?

  init(frame: CGRect, viewId: Int64, args: [String: Any], messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: "\(FlutterNativeViewPlugin.textFieldViewType)/\(viewId)", binaryMessenger: messenger)
    model = GlassTextFieldModel(args: args)
    container.backgroundColor = .clear

    super.init()

    model.onChanged = { [weak channel] text in
      channel?.invokeMethod("onChanged", arguments: text)
    }
    model.onSubmitted = { [weak channel] text in
      channel?.invokeMethod("onSubmitted", arguments: text)
    }

    if #available(iOS 16.0, *) {
      let hosting = UIHostingController(rootView: GlassTextFieldRoot(model: model))
      hosting.view.backgroundColor = .clear
      hosting.view.frame = container.bounds
      hosting.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      container.addSubview(hosting.view)
      host = hosting
    }

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(nil); return }
      switch call.method {
      case "setText":
        if let text = call.arguments as? String { self.model.text = text }
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  func view() -> UIView { container }
}

// MARK: - SwiftUI

final class GlassTextFieldModel: ObservableObject {
  @Published var text: String
  @Published var placeholder: String
  @Published var obscureText: Bool
  @Published var tint: UIColor?
  @Published var respectAccessibility: Bool
  var onChanged: ((String) -> Void)?
  var onSubmitted: ((String) -> Void)?

  init(args: [String: Any]) {
    text = args["text"] as? String ?? ""
    placeholder = args["placeholder"] as? String ?? ""
    obscureText = args["obscureText"] as? Bool ?? false
    tint = GlassColor.fromARGB(args["tint"] as? Int)
    respectAccessibility = args["respectAccessibility"] as? Bool ?? true
  }
}

@available(iOS 16.0, *)
struct GlassTextFieldRoot: View {
  @ObservedObject var model: GlassTextFieldModel
  @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

  private func shape() -> RoundedRectangle {
    RoundedRectangle(cornerRadius: 12, style: .continuous)
  }

  var body: some View {
    field
      .onSubmit { model.onSubmitted?(model.text) }
      .onChange(of: model.text) { newValue in model.onChanged?(newValue) }
      .padding(.horizontal, 14)
      .padding(.vertical, 10)
      .background(background)
  }

  @ViewBuilder
  private var field: some View {
    if model.obscureText {
      SecureField(model.placeholder, text: $model.text)
    } else {
      TextField(model.placeholder, text: $model.text)
    }
  }

  @ViewBuilder
  private var background: some View {
    let solid = GlassAccessibility.solidFallback(
      respect: model.respectAccessibility, reduceTransparency: reduceTransparency)
    if !solid, #available(iOS 26.0, *) {
      shape().fill(.clear).glassEffect(resolvedGlass(), in: shape())
    } else {
      shape().fill(Color(uiColor: model.tint ?? .secondarySystemBackground))
    }
  }

  @available(iOS 26.0, *)
  private func resolvedGlass() -> Glass {
    var glass = Glass.regular
    if let tint = model.tint { glass = glass.tint(Color(uiColor: tint).opacity(0.5)) }
    return glass
  }
}
