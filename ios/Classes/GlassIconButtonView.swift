import Flutter
import SwiftUI
import UIKit

// MARK: - Factory

final class GlassIconButtonViewFactory: NSObject, FlutterPlatformViewFactory {
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
    GlassIconButtonPlatformView(
      frame: frame, viewId: viewId,
      args: args as? [String: Any] ?? [:], messenger: messenger)
  }
}

// MARK: - Platform view

final class GlassIconButtonPlatformView: NSObject, FlutterPlatformView {
  private let container = UIView()
  private let channel: FlutterMethodChannel
  private let model: GlassIconButtonModel
  private var host: UIViewController?

  init(frame: CGRect, viewId: Int64, args: [String: Any], messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: "\(FlutterNativeViewPlugin.iconButtonViewType)/\(viewId)", binaryMessenger: messenger)
    model = GlassIconButtonModel(args: args)
    container.backgroundColor = .clear

    super.init()

    model.onPressed = { [weak channel] in channel?.invokeMethod("onPressed", arguments: nil) }

    if #available(iOS 16.0, *) {
      let hosting = UIHostingController(rootView: GlassIconButtonRoot(model: model))
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
    guard let view = host?.view else { return ["width": 44, "height": 44] }
    view.setNeedsLayout()
    view.layoutIfNeeded()
    let size = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    return ["width": Double(size.width), "height": Double(size.height)]
  }

  func view() -> UIView { container }
}

// MARK: - SwiftUI

final class GlassIconButtonModel: ObservableObject {
  @Published var sfSymbol: String
  @Published var size: CGFloat
  @Published var iconSize: CGFloat
  @Published var tint: UIColor?
  @Published var iconColor: UIColor?
  @Published var cornerRadius: CGFloat?
  @Published var interactive: Bool
  @Published var respectAccessibility: Bool
  var onPressed: (() -> Void)?

  init(args: [String: Any]) {
    sfSymbol = args["sfSymbol"] as? String ?? "star"
    size = (args["size"] as? Double).map { CGFloat($0) } ?? 44
    iconSize = (args["iconSize"] as? Double).map { CGFloat($0) } ?? 20
    tint = GlassColor.fromARGB(args["tint"] as? Int)
    iconColor = GlassColor.fromARGB(args["iconColor"] as? Int)
    cornerRadius = (args["cornerRadius"] as? Double).map { CGFloat($0) }
    interactive = args["interactive"] as? Bool ?? true
    respectAccessibility = args["respectAccessibility"] as? Bool ?? true
  }

  func apply(args: [String: Any]) {
    sfSymbol = args["sfSymbol"] as? String ?? sfSymbol
    size = (args["size"] as? Double).map { CGFloat($0) } ?? size
    iconSize = (args["iconSize"] as? Double).map { CGFloat($0) } ?? iconSize
    tint = GlassColor.fromARGB(args["tint"] as? Int)
    iconColor = GlassColor.fromARGB(args["iconColor"] as? Int)
    cornerRadius = (args["cornerRadius"] as? Double).map { CGFloat($0) }
    interactive = args["interactive"] as? Bool ?? interactive
    respectAccessibility = args["respectAccessibility"] as? Bool ?? respectAccessibility
  }
}

@available(iOS 16.0, *)
struct GlassIconButtonRoot: View {
  @ObservedObject var model: GlassIconButtonModel
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  private func shape() -> AnyShape {
    if let r = model.cornerRadius {
      return AnyShape(RoundedRectangle(cornerRadius: r, style: .continuous))
    }
    return AnyShape(Circle())
  }

  private var icon: some View {
    Image(systemName: model.sfSymbol)
      .font(.system(size: model.iconSize, weight: .semibold))
      .foregroundStyle(
        model.iconColor.map { Color(uiColor: $0) }
        ?? model.tint.map { Color(uiColor: $0) }
        ?? .primary
      )
      .frame(width: model.size, height: model.size)
  }

  var body: some View {
    if #available(iOS 26.0, *) {
      GlassEffectContainer(spacing: 20) {
        Button(action: { model.onPressed?() }) {
          icon
            .contentShape(shape())
            .glassEffect(resolvedGlass(), in: shape())
        }
        .buttonStyle(.plain)
      }
    } else {
      Button(action: { model.onPressed?() }) { icon }
        .buttonStyle(.borderedProminent)
        .tint(model.tint.map { Color(uiColor: $0) } ?? .accentColor)
        .clipShape(shape())
    }
  }

  @available(iOS 26.0, *)
  private func resolvedGlass() -> Glass {
    var glass = Glass.regular
    let interactive = GlassAccessibility.interactive(
      model.interactive, respect: model.respectAccessibility, reduceMotion: reduceMotion)
    if interactive { glass = glass.interactive() }
    if let tint = model.tint { glass = glass.tint(Color(uiColor: tint)) }
    return glass
  }
}
