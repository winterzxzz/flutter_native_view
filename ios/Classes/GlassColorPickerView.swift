import Flutter
import SwiftUI
import UIKit

// MARK: - Factory

final class GlassColorPickerViewFactory: NSObject, FlutterPlatformViewFactory {
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
    GlassColorPickerPlatformView(
      frame: frame, viewId: viewId,
      args: args as? [String: Any] ?? [:], messenger: messenger)
  }
}

// MARK: - Platform view

final class GlassColorPickerPlatformView: NSObject, FlutterPlatformView {
  private let container = UIView()
  private let channel: FlutterMethodChannel
  private let model: GlassColorPickerModel
  private var host: UIViewController?

  init(frame: CGRect, viewId: Int64, args: [String: Any], messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: "\(FlutterNativeViewPlugin.colorPickerViewType)/\(viewId)", binaryMessenger: messenger)
    model = GlassColorPickerModel(args: args)
    container.backgroundColor = .clear
    super.init()

    model.onChanged = { [weak channel] argb in
      channel?.invokeMethod("onChanged", arguments: argb)
    }

    if #available(iOS 16.0, *) {
      let hosting = UIHostingController(rootView: GlassColorPickerRoot(model: model))
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
        if let argb = call.arguments as? Int {
          self.model.selectedColor = UIColor(
            red: CGFloat((argb >> 16) & 0xFF) / 255,
            green: CGFloat((argb >> 8) & 0xFF) / 255,
            blue: CGFloat(argb & 0xFF) / 255,
            alpha: CGFloat((argb >> 24) & 0xFF) / 255
          )
        }
        result(nil)
      case "updateConfig":
        self.model.apply(args: call.arguments as? [String: Any] ?? [:])
        DispatchQueue.main.async { result(self.intrinsicSize()) }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func intrinsicSize() -> [String: Double] {
    guard let view = host?.view else { return ["width": 60, "height": 44] }
    view.setNeedsLayout()
    view.layoutIfNeeded()
    let size = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    return ["width": Double(size.width), "height": Double(size.height)]
  }

  func view() -> UIView { container }
}

// MARK: - SwiftUI

final class GlassColorPickerModel: ObservableObject {
  @Published var selectedColor: UIColor
  var onChanged: ((Int) -> Void)?

  init(args: [String: Any]) {
    let argb = args["color"] as? Int ?? 0xFF000000
    selectedColor = GlassColor.fromARGB(argb) ?? .white
  }

  func apply(args: [String: Any]) {
    if let argb = args["color"] as? Int {
      selectedColor = GlassColor.fromARGB(argb) ?? selectedColor
    }
  }
}

@available(iOS 16.0, *)
struct GlassColorPickerRoot: View {
  @ObservedObject var model: GlassColorPickerModel

  var body: some View {
    if #available(iOS 26.0, *) {
      ColorPicker("", selection: Binding(get: { Color(uiColor: model.selectedColor) }, set: {
        model.selectedColor = UIColor($0)
        var r: CGFloat = 0; var g: CGFloat = 0; var b: CGFloat = 0; var a: CGFloat = 0
        model.selectedColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        let argb = (Int(a * 255) << 24) | (Int(r * 255) << 16) | (Int(g * 255) << 8) | Int(b * 255)
        model.onChanged?(argb)
      }), supportsOpacity: true)
        .labelsHidden()
        .glassEffect(Glass.regular.interactive(), in: Capsule())
    } else {
      ColorPicker("", selection: Binding(get: { Color(uiColor: model.selectedColor) }, set: {
        model.selectedColor = UIColor($0)
        var r: CGFloat = 0; var g: CGFloat = 0; var b: CGFloat = 0; var a: CGFloat = 0
        model.selectedColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        let argb = (Int(a * 255) << 24) | (Int(r * 255) << 16) | (Int(g * 255) << 8) | Int(b * 255)
        model.onChanged?(argb)
      }), supportsOpacity: true)
        .labelsHidden()
    }
  }
}
