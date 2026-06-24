import Flutter
import SwiftUI
import UIKit

// MARK: - Factory

final class GlassSegmentedViewFactory: NSObject, FlutterPlatformViewFactory {
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
    GlassSegmentedPlatformView(
      frame: frame, viewId: viewId,
      args: args as? [String: Any] ?? [:], messenger: messenger)
  }
}

// MARK: - Platform view

final class GlassSegmentedPlatformView: NSObject, FlutterPlatformView {
  private let container = UIView()
  private let channel: FlutterMethodChannel
  private let model: GlassSegmentedModel
  private var host: UIViewController?

  init(frame: CGRect, viewId: Int64, args: [String: Any], messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: "\(FlutterNativeViewPlugin.segmentedViewType)/\(viewId)", binaryMessenger: messenger)
    model = GlassSegmentedModel(args: args)
    container.backgroundColor = .clear

    super.init()

    model.onIndexChanged = { [weak channel] index in
      channel?.invokeMethod("onIndexChanged", arguments: index)
    }

    if #available(iOS 16.0, *) {
      let hosting = UIHostingController(rootView: GlassSegmentedRoot(model: model))
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
    guard let view = host?.view else { return ["width": 200, "height": 32] }
    view.setNeedsLayout()
    view.layoutIfNeeded()
    let size = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    return ["width": Double(size.width), "height": Double(size.height)]
  }

  func view() -> UIView { container }
}

// MARK: - SwiftUI

final class GlassSegmentedModel: ObservableObject {
  @Published var segments: [String]
  @Published var selectedIndex: Int
  @Published var tint: UIColor?
  var onIndexChanged: ((Int) -> Void)?

  init(args: [String: Any]) {
    segments = args["segments"] as? [String] ?? ["A", "B"]
    selectedIndex = args["selectedIndex"] as? Int ?? 0
    tint = GlassColor.fromARGB(args["tint"] as? Int)
  }

  func apply(args: [String: Any]) {
    segments = args["segments"] as? [String] ?? segments
    selectedIndex = args["selectedIndex"] as? Int ?? selectedIndex
    tint = GlassColor.fromARGB(args["tint"] as? Int)
  }
}

@available(iOS 16.0, *)
struct GlassSegmentedRoot: View {
  @ObservedObject var model: GlassSegmentedModel

  var body: some View {
    if #available(iOS 26.0, *) {
      Picker("", selection: $model.selectedIndex) {
        ForEach(Array(model.segments.enumerated()), id: \.offset) { _, label in
          Text(label).tag(Int?.none)
        }
      }
      .pickerStyle(.segmented)
      .tint(model.tint.map { Color(uiColor: $0) })
      .onChange(of: model.selectedIndex) { _, newValue in
        model.onIndexChanged?(newValue)
      }
    } else {
      Picker("", selection: $model.selectedIndex) {
        ForEach(Array(model.segments.enumerated()), id: \.offset) { _, label in
          Text(label).tag(Int?.none)
        }
      }
      .pickerStyle(.segmented)
      .tint(model.tint.map { Color(uiColor: $0) })
      .onChange(of: model.selectedIndex) { _, newValue in
        model.onIndexChanged?(newValue)
      }
    }
  }
}
