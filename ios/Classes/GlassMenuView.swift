import Flutter
import SwiftUI
import UIKit

// MARK: - Factory

final class GlassMenuViewFactory: NSObject, FlutterPlatformViewFactory {
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
    GlassMenuPlatformView(
      frame: frame, viewId: viewId,
      args: args as? [String: Any] ?? [:], messenger: messenger)
  }
}

// MARK: - Platform view

final class GlassMenuPlatformView: NSObject, FlutterPlatformView {
  private let container = UIView()
  private let channel: FlutterMethodChannel
  private let model: GlassMenuModel
  private var host: UIViewController?

  init(frame: CGRect, viewId: Int64, args: [String: Any], messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: "\(FlutterNativeViewPlugin.menuViewType)/\(viewId)", binaryMessenger: messenger)
    model = GlassMenuModel(args: args)
    container.backgroundColor = .clear

    super.init()

    model.onSelected = { [weak channel] id in
      channel?.invokeMethod("onSelected", arguments: id)
    }

    if #available(iOS 16.0, *) {
      let hosting = UIHostingController(rootView: GlassMenuRoot(model: model))
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
    guard let view = host?.view else { return ["width": 100, "height": 44] }
    view.setNeedsLayout()
    view.layoutIfNeeded()
    let size = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    return ["width": Double(size.width), "height": Double(size.height)]
  }

  func view() -> UIView { container }
}

// MARK: - SwiftUI

final class GlassMenuModel: ObservableObject {
  @Published var label: String
  @Published var sfSymbol: String
  @Published var items: [[String: Any]]
  @Published var tint: UIColor?
  @Published var iconColor: UIColor?
  var onSelected: ((String) -> Void)?

  init(args: [String: Any]) {
    label = args["label"] as? String ?? "Menu"
    sfSymbol = args["sfSymbol"] as? String ?? ""
    items = args["items"] as? [[String: Any]] ?? []
    tint = GlassColor.fromARGB(args["tint"] as? Int)
    iconColor = GlassColor.fromARGB(args["iconColor"] as? Int)
  }

  func apply(args: [String: Any]) {
    label = args["label"] as? String ?? label
    sfSymbol = args["sfSymbol"] as? String ?? sfSymbol
    items = args["items"] as? [[String: Any]] ?? items
    tint = GlassColor.fromARGB(args["tint"] as? Int)
    iconColor = GlassColor.fromARGB(args["iconColor"] as? Int)
  }
}

@available(iOS 16.0, *)
struct GlassMenuRoot: View {
  @ObservedObject var model: GlassMenuModel

  private var trigger: some View {
    HStack(spacing: 6) {
      if !model.sfSymbol.isEmpty {
        Image(systemName: model.sfSymbol)
          .font(.system(size: 16, weight: .semibold))
      }
      Text(model.label)
        .font(.system(size: 17, weight: .semibold))
    }
    .foregroundStyle(
      model.iconColor.map { Color(uiColor: $0) }
      ?? model.tint.map { Color(uiColor: $0) }
      ?? .primary
    )
    .padding(.horizontal, 16)
    .padding(.vertical, 10)
  }

  var body: some View {
    if #available(iOS 26.0, *) {
      Menu {
        ForEach(model.items.indices, id: \.self) { index in
          let item = model.items[index]
          Button(action: { model.onSelected?(item["id"] as? String ?? "") }) {
            if let symbol = item["sfSymbol"] as? String, !symbol.isEmpty {
              Label(item["title"] as? String ?? "", systemImage: symbol)
            } else {
              Text(item["title"] as? String ?? "")
            }
          }
        }
      } label: {
        trigger
          .contentShape(Capsule())
          .glassEffect(resolvedGlass(), in: Capsule())
      }
      .buttonStyle(.plain)
    } else {
      Menu {
        ForEach(model.items.indices, id: \.self) { index in
          let item = model.items[index]
          Button(action: { model.onSelected?(item["id"] as? String ?? "") }) {
            if let symbol = item["sfSymbol"] as? String, !symbol.isEmpty {
              Label(item["title"] as? String ?? "", systemImage: symbol)
            } else {
              Text(item["title"] as? String ?? "")
            }
          }
        }
      } label: {
        trigger
      }
      .buttonStyle(.borderedProminent)
      .tint(model.tint.map { Color(uiColor: $0) } ?? .accentColor)
      .clipShape(Capsule())
    }
  }

  @available(iOS 26.0, *)
  private func resolvedGlass() -> Glass {
    var glass = Glass.regular.interactive()
    if let tint = model.tint { glass = glass.tint(Color(uiColor: tint)) }
    return glass
  }
}
