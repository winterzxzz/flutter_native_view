import Flutter
import SwiftUI
import UIKit

// MARK: - Factory

final class GlassButtonViewFactory: NSObject, FlutterPlatformViewFactory {
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
    GlassButtonPlatformView(
      frame: frame, viewId: viewId,
      args: args as? [String: Any] ?? [:], messenger: messenger)
  }
}

// MARK: - Platform view

final class GlassButtonPlatformView: NSObject, FlutterPlatformView {
  private let container = UIView()
  private let channel: FlutterMethodChannel
  private let model: GlassButtonModel
  private var host: UIViewController?

  init(frame: CGRect, viewId: Int64, args: [String: Any], messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: "\(FlutterNativeViewPlugin.buttonViewType)/\(viewId)", binaryMessenger: messenger)
    model = GlassButtonModel(args: args)
    container.backgroundColor = .clear

    super.init()

    model.onPressed = { [weak channel] in channel?.invokeMethod("onPressed", arguments: nil) }

    if #available(iOS 16.0, *) {
      let hosting = UIHostingController(rootView: GlassButtonRoot(model: model))
      hosting.view.backgroundColor = .clear
      hosting.view.frame = container.bounds
      hosting.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      container.addSubview(hosting.view)
      host = hosting
    }

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(nil); return }
      switch call.method {
      case "getIntrinsicSize":
        result(self.intrinsicSize())
      case "updateConfig":
        self.model.apply(args: call.arguments as? [String: Any] ?? [:])
        DispatchQueue.main.async { result(self.intrinsicSize()) }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func intrinsicSize() -> [String: Double] {
    guard let view = host?.view else { return ["width": 120, "height": 48] }
    view.setNeedsLayout()
    view.layoutIfNeeded()
    let size = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    return ["width": Double(size.width), "height": Double(size.height)]
  }

  func view() -> UIView { container }
}

// MARK: - SwiftUI

final class GlassButtonModel: ObservableObject {
  @Published var title: String
  @Published var tint: UIColor?
  @Published var cornerRadius: CGFloat?
  @Published var interactive: Bool
  var onPressed: (() -> Void)?

  init(args: [String: Any]) {
    title = args["title"] as? String ?? "Button"
    tint = GlassColor.fromARGB(args["tint"] as? Int)
    cornerRadius = (args["cornerRadius"] as? Double).map { CGFloat($0) }
    interactive = args["interactive"] as? Bool ?? true
  }

  func apply(args: [String: Any]) {
    title = args["title"] as? String ?? title
    tint = GlassColor.fromARGB(args["tint"] as? Int)
    cornerRadius = (args["cornerRadius"] as? Double).map { CGFloat($0) }
    interactive = args["interactive"] as? Bool ?? interactive
  }
}

@available(iOS 16.0, *)
struct GlassButtonRoot: View {
  @ObservedObject var model: GlassButtonModel
  @Namespace private var namespace

  private func shape() -> AnyShape {
    if let r = model.cornerRadius {
      return AnyShape(RoundedRectangle(cornerRadius: r, style: .continuous))
    }
    return AnyShape(Capsule())
  }

  private var label: some View {
    Text(model.title)
      .font(.system(size: 17, weight: .semibold))
      .foregroundStyle(model.tint.map { Color(uiColor: $0) } ?? .primary)
      .padding(.horizontal, 20)
      .padding(.vertical, 12)
  }

  var body: some View {
    if #available(iOS 26.0, *) {
      GlassEffectContainer(spacing: 20) {
        Button(action: { model.onPressed?() }) {
          label
            .contentShape(shape())
            .glassEffect(resolvedGlass(), in: shape())
        }
        .buttonStyle(.plain)
      }
    } else {
      Button(action: { model.onPressed?() }) { label }
        .buttonStyle(.borderedProminent)
        .tint(model.tint.map { Color(uiColor: $0) } ?? .accentColor)
        .clipShape(shape())
    }
  }

  @available(iOS 26.0, *)
  private func resolvedGlass() -> Glass {
    var glass = Glass.regular
    if model.interactive { glass = glass.interactive() }
    if let tint = model.tint { glass = glass.tint(Color(uiColor: tint)) }
    return glass
  }
}
