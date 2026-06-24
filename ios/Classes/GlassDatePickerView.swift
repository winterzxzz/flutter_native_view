import Flutter
import SwiftUI
import UIKit

// MARK: - Factory

final class GlassDatePickerViewFactory: NSObject, FlutterPlatformViewFactory {
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
    GlassDatePickerPlatformView(
      frame: frame, viewId: viewId,
      args: args as? [String: Any] ?? [:], messenger: messenger)
  }
}

// MARK: - Platform view

final class GlassDatePickerPlatformView: NSObject, FlutterPlatformView {
  private let container = UIView()
  private let channel: FlutterMethodChannel
  private let model: GlassDatePickerModel
  private var host: UIViewController?

  init(frame: CGRect, viewId: Int64, args: [String: Any], messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: "\(FlutterNativeViewPlugin.datePickerViewType)/\(viewId)", binaryMessenger: messenger)
    model = GlassDatePickerModel(args: args)
    container.backgroundColor = .clear
    super.init()

    model.onChanged = { [weak channel] millis in
      channel?.invokeMethod("onChanged", arguments: millis)
    }

    if #available(iOS 16.0, *) {
      let hosting = UIHostingController(rootView: GlassDatePickerRoot(model: model))
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
        if let millis = call.arguments as? Double {
          self.model.date = Date(timeIntervalSince1970: millis / 1000)
        }
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func intrinsicSize() -> [String: Double] {
    guard let view = host?.view else { return ["width": 200, "height": 200] }
    view.setNeedsLayout()
    view.layoutIfNeeded()
    let size = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    return ["width": Double(size.width), "height": Double(size.height)]
  }

  func view() -> UIView { container }
}

// MARK: - SwiftUI

final class GlassDatePickerModel: ObservableObject {
  @Published var date: Date
  @Published var minDate: Date?
  @Published var maxDate: Date?
  @Published var mode: String
  var onChanged: ((Int64) -> Void)?

  init(args: [String: Any]) {
    let millis = args["value"] as? Double ?? 0
    date = Date(timeIntervalSince1970: millis / 1000)
    if let minMillis = args["min"] as? Double {
      minDate = Date(timeIntervalSince1970: minMillis / 1000)
    }
    if let maxMillis = args["max"] as? Double {
      maxDate = Date(timeIntervalSince1970: maxMillis / 1000)
    }
    mode = args["mode"] as? String ?? "date"
  }
}

@available(iOS 16.0, *)
struct GlassDatePickerRoot: View {
  @ObservedObject var model: GlassDatePickerModel

  private var picker: some View {
    DatePicker(
      selection: Binding(get: { model.date }, set: { model.date = $0; model.onChanged?(Int64($0.timeIntervalSince1970 * 1000)) }),
      in: (model.minDate ?? Date.distantPast)...(model.maxDate ?? Date.distantFuture),
      displayedComponents: model.mode == "time" ? .hourAndMinute : (model.mode == "dateAndTime" ? [.date, .hourAndMinute] : .date)
    ) {
      EmptyView()
    }
    .datePickerStyle(.compact)
    .labelsHidden()
  }

  var body: some View {
    if #available(iOS 26.0, *) {
      picker
        .glassEffect(Glass.regular.interactive(), in: Capsule())
    } else {
      picker
    }
  }
}
