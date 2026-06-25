import Flutter
import SwiftUI
import UIKit

// MARK: - Factory

final class GlassButtonGroupViewFactory: NSObject, FlutterPlatformViewFactory {
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
    GlassButtonGroupPlatformView(
      frame: frame, viewId: viewId,
      args: args as? [String: Any] ?? [:], messenger: messenger)
  }
}

// MARK: - Platform view

final class GlassButtonGroupPlatformView: NSObject, FlutterPlatformView {
  private let container = UIView()
  private let channel: FlutterMethodChannel
  private let model: GlassButtonGroupModel
  private var host: UIViewController?

  init(frame: CGRect, viewId: Int64, args: [String: Any], messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: "\(FlutterNativeViewPlugin.buttonGroupViewType)/\(viewId)", binaryMessenger: messenger)
    model = GlassButtonGroupModel(args: args)
    container.backgroundColor = .clear
    super.init()

    model.onPressed = { [weak channel] id in
      channel?.invokeMethod("onPressed", arguments: id)
    }

    if #available(iOS 16.0, *) {
      let hosting = UIHostingController(rootView: GlassButtonGroupRoot(model: model))
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
    guard let host = host else { return ["width": 200, "height": 44] }
    // Use the hosting controller's ideal sizing; .compressedSize truncates SwiftUI
    // Text to zero width, which makes labels disappear.
    let unbounded = CGSize(
      width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
    if #available(iOS 16.0, *), let hosting = host as? UIHostingController<GlassButtonGroupRoot> {
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

// MARK: - Model

struct GroupButtonItem {
  let id: String
  let label: String?
  let sfSymbol: String?
}

final class GlassButtonGroupModel: ObservableObject {
  @Published var buttons: [GroupButtonItem] = []
  @Published var spacing: CGFloat = 8
  var onPressed: ((String) -> Void)?

  init(args: [String: Any]) {
    apply(args: args)
  }

  func apply(args: [String: Any]) {
    if let items = args["buttons"] as? [[String: Any]] {
      buttons = items.map { d in
        GroupButtonItem(
          id: d["id"] as? String ?? "",
          label: d["label"] as? String,
          sfSymbol: d["sfSymbol"] as? String
        )
      }
    }
    if let s = args["spacing"] as? Double {
      spacing = CGFloat(s)
    }
  }
}

// MARK: - SwiftUI

@available(iOS 16.0, *)
struct GlassButtonGroupRoot: View {
  @ObservedObject var model: GlassButtonGroupModel

  var body: some View {
    if #available(iOS 26.0, *) {
      GlassEffectContainer(spacing: 8) {
        HStack(spacing: model.spacing) {
          ForEach(model.buttons, id: \.id) { item in
            Button(action: { model.onPressed?(item.id) }) {
              buttonLabel(for: item)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .contentShape(Capsule())
                .glassEffect(Glass.regular.interactive(), in: Capsule())
            }
            .buttonStyle(.plain)
          }
        }
      }
    } else {
      HStack(spacing: model.spacing) {
        ForEach(model.buttons, id: \.id) { item in
          Button(action: { model.onPressed?(item.id) }) {
            buttonLabel(for: item)
              .padding(.horizontal, 16)
              .padding(.vertical, 10)
          }
          .buttonStyle(.borderedProminent)
        }
      }
    }
  }

  @ViewBuilder
  private func buttonLabel(for item: GroupButtonItem) -> some View {
    if let symbol = item.sfSymbol {
      Label(item.label ?? "", systemImage: symbol)
        .font(.system(size: 15, weight: .semibold))
    } else {
      Text(item.label ?? "")
        .font(.system(size: 15, weight: .semibold))
    }
  }
}
