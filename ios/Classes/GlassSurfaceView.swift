import Flutter
import SwiftUI
import UIKit

class GlassSurfaceViewFactory: NSObject, FlutterPlatformViewFactory {
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
    GlassSurfacePlatformView(frame: frame, args: args as? [String: Any] ?? [:])
  }
}

class GlassSurfacePlatformView: NSObject, FlutterPlatformView {
  private let host: UIHostingController<AnyView>

  init(frame: CGRect, args: [String: Any]) {
    let radius = CGFloat((args["cornerRadius"] as? Double) ?? 20)
    let variant = args["variant"] as? String ?? "regular"
    let tint = GlassColor.fromARGB(args["tintColor"] as? Int)

    let root: AnyView
    if #available(iOS 26.0, *) {
      root = AnyView(GlassSurface(cornerRadius: radius, variant: variant, tint: tint))
    } else {
      root = AnyView(FallbackSurface(cornerRadius: radius, tint: tint))
    }

    host = UIHostingController(rootView: root)
    host.view.backgroundColor = .clear
    // Non-opaque + clear background lets the glass sample the Flutter content
    // rendered behind this platform view; otherwise the effect looks flat.
    host.view.isOpaque = false
    host.view.frame = frame
    // The surface is purely decorative: let all touches fall through to the
    // Flutter widgets stacked on top (buttons, etc.).
    host.view.isUserInteractionEnabled = false
    super.init()
  }

  func view() -> UIView { host.view }
}

@available(iOS 26.0, *)
private struct GlassSurface: View {
  let cornerRadius: CGFloat
  let variant: String
  let tint: Color?

  var body: some View {
    let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    let base: Glass = (variant == "clear") ? .clear : .regular
    let glass = tint.map { base.tint($0) } ?? base
    Color.clear.glassEffect(glass, in: shape)
  }
}

/// iOS < 26 fallback: a frosted material in the same rounded shape.
private struct FallbackSurface: View {
  let cornerRadius: CGFloat
  let tint: Color?

  var body: some View {
    let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    shape
      .fill(.ultraThinMaterial)
      .overlay(shape.fill((tint ?? .clear).opacity(0.15)))
  }
}
