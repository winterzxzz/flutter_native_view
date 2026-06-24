import Flutter
import SwiftUI
import UIKit

// MARK: - Factory

final class GlassActivityIndicatorViewFactory: NSObject, FlutterPlatformViewFactory {
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
    GlassActivityIndicatorPlatformView(
      frame: frame, viewId: viewId,
      args: args as? [String: Any] ?? [:], messenger: messenger)
  }
}

// MARK: - Platform view

final class GlassActivityIndicatorPlatformView: NSObject, FlutterPlatformView {
  private let container = UIView()
  private var host: UIViewController?

  init(frame: CGRect, viewId: Int64, args: [String: Any], messenger: FlutterBinaryMessenger) {
    let model = GlassActivityIndicatorModel(args: args)
    container.backgroundColor = .clear
    super.init()

    if #available(iOS 16.0, *) {
      let hosting = UIHostingController(rootView: GlassActivityIndicatorRoot(model: model))
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

final class GlassActivityIndicatorModel: ObservableObject {
  @Published var size: CGFloat
  @Published var tint: UIColor?

  init(args: [String: Any]) {
    size = (args["size"] as? Double).map { CGFloat($0) } ?? 24
    tint = GlassColor.fromARGB(args["tint"] as? Int)
  }
}

@available(iOS 16.0, *)
struct GlassActivityIndicatorRoot: View {
  @ObservedObject var model: GlassActivityIndicatorModel

  var body: some View {
    if #available(iOS 26.0, *) {
      ProgressView()
        .progressViewStyle(.circular)
        .scaleEffect(model.size / 24)
        .tint(model.tint.map { Color(uiColor: $0) })
    } else {
      ProgressView()
        .progressViewStyle(.circular)
        .scaleEffect(model.size / 24)
        .tint(model.tint.map { Color(uiColor: $0) })
    }
  }
}
