import Flutter
import SwiftUI
import UIKit

// MARK: - Factory

final class GlassStepperViewFactory: NSObject, FlutterPlatformViewFactory {
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
    GlassStepperPlatformView(
      frame: frame, viewId: viewId,
      args: args as? [String: Any] ?? [:], messenger: messenger)
  }
}

// MARK: - Platform view

final class GlassStepperPlatformView: NSObject, FlutterPlatformView {
  private let container = UIView()
  private let channel: FlutterMethodChannel
  private let model: GlassStepperModel
  private var host: UIViewController?

  init(frame: CGRect, viewId: Int64, args: [String: Any], messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: "\(FlutterNativeViewPlugin.stepperViewType)/\(viewId)", binaryMessenger: messenger)
    model = GlassStepperModel(args: args)
    container.backgroundColor = .clear
    super.init()

    model.onChanged = { [weak channel] value in
      channel?.invokeMethod("onChanged", arguments: value)
    }

    if #available(iOS 16.0, *) {
      let hosting = UIHostingController(rootView: GlassStepperRoot(model: model))
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
      case "setValue":
        self.model.value = call.arguments as? Int ?? self.model.value
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func intrinsicSize() -> [String: Double] {
    guard let host = host else { return ["width": 140, "height": 44] }
    // Use the hosting controller's ideal sizing; .compressedSize truncates SwiftUI
    // Text to zero width, which makes labels disappear.
    let unbounded = CGSize(
      width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
    if #available(iOS 16.0, *), let hosting = host as? UIHostingController<GlassStepperRoot> {
      let size = hosting.sizeThatFits(in: unbounded)
      return ["width": Double(ceil(size.width)), "height": Double(ceil(size.height))]
    }
    let view = host.view!
    view.setNeedsLayout()
    view.layoutIfNeeded()
    let size = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    return ["width": Double(size.width), "height": Double(size.height)]
  }

  func view() -> UIView { container }
}

// MARK: - SwiftUI

final class GlassStepperModel: ObservableObject {
  @Published var value: Int
  @Published var step: Int
  @Published var min: Int?
  @Published var max: Int?
  var onChanged: ((Int) -> Void)?

  init(args: [String: Any]) {
    value = args["value"] as? Int ?? 0
    step = args["step"] as? Int ?? 1
    min = args["min"] as? Int
    max = args["max"] as? Int
  }
}

@available(iOS 16.0, *)
struct GlassStepperRoot: View {
  @ObservedObject var model: GlassStepperModel

  var body: some View {
    if #available(iOS 26.0, *) {
      stepperContent
        .glassEffect(Glass.regular.interactive(), in: Capsule())
    } else {
      stepperContent
    }
  }

  private var stepperContent: some View {
    Stepper(value: Binding(get: { model.value }, set: { model.value = $0; model.onChanged?($0) }),
            in: (model.min ?? Int.min)...(model.max ?? Int.max),
            step: model.step) {
      Text("\(model.value)")
    }
    .fixedSize()
  }
}
