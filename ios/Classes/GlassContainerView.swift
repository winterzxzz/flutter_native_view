import Flutter
import SwiftUI
import UIKit

// MARK: - Factory

final class GlassContainerViewFactory: NSObject, FlutterPlatformViewFactory {
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
    GlassContainerPlatformView(
      frame: frame, viewId: viewId,
      args: args as? [String: Any] ?? [:], messenger: messenger)
  }
}

// MARK: - Platform view

final class GlassContainerPlatformView: NSObject, FlutterPlatformView {
  private let container = UIView()
  private var host: UIViewController?

  init(frame: CGRect, viewId: Int64, args: [String: Any], messenger: FlutterBinaryMessenger) {
    let model = GlassContainerModel(args: args)
    container.backgroundColor = .clear
    super.init()

    if #available(iOS 16.0, *) {
      let hosting = UIHostingController(rootView: GlassContainerRoot(model: model))
      hosting.view.backgroundColor = .clear
      hosting.view.frame = container.bounds
      hosting.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      container.addSubview(hosting.view)
      host = hosting
    }
  }

  func view() -> UIView { container }
}

// MARK: - SwiftUI

final class GlassContainerModel: ObservableObject {
  @Published var tint: UIColor?
  @Published var cornerRadius: CGFloat

  init(args: [String: Any]) {
    tint = GlassColor.fromARGB(args["tint"] as? Int)
    cornerRadius = (args["cornerRadius"] as? Double).map { CGFloat($0) } ?? 20
  }
}

@available(iOS 16.0, *)
struct GlassContainerRoot: View {
  @ObservedObject var model: GlassContainerModel

  private let defaultTint = UIColor(white: 1, alpha: 0.12)

  private func shape() -> RoundedRectangle {
    RoundedRectangle(cornerRadius: model.cornerRadius, style: .continuous)
  }

  var body: some View {
    if #available(iOS 26.0, *) {
      GlassEffectContainer(spacing: 0) {
        shape()
          .fill(.white.opacity(0.15))
          .glassEffect(resolvedGlass(), in: shape())
      }
    } else {
      shape()
        .fill(Color(uiColor: model.tint ?? defaultTint).opacity(0.15))
        .overlay(
          shape()
            .stroke(Color(uiColor: model.tint ?? defaultTint).opacity(0.30), lineWidth: 1)
        )
    }
  }

  @available(iOS 26.0, *)
  private func resolvedGlass() -> Glass {
    var glass = Glass.regular
    if let tint = model.tint { glass = glass.tint(Color(uiColor: tint)) }
    return glass
  }
}
