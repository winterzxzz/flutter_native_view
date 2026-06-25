import Flutter
import SwiftUI
import UIKit

// MARK: - Factory

final class GlassToolbarViewFactory: NSObject, FlutterPlatformViewFactory {
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
    GlassToolbarPlatformView(
      frame: frame, viewId: viewId,
      args: args as? [String: Any] ?? [:], messenger: messenger)
  }
}

// MARK: - Platform view

final class GlassToolbarPlatformView: NSObject, FlutterPlatformView {
  private let container = UIView()
  private let channel: FlutterMethodChannel
  private let model: GlassToolbarModel
  private var host: UIViewController?

  init(frame: CGRect, viewId: Int64, args: [String: Any], messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: "\(FlutterNativeViewPlugin.toolbarViewType)/\(viewId)", binaryMessenger: messenger)
    model = GlassToolbarModel(args: args)
    container.backgroundColor = .clear
    super.init()

    model.onAction = { [weak channel] id in
      channel?.invokeMethod("onAction", arguments: id)
    }

    if #available(iOS 16.0, *) {
      let hosting = UIHostingController(rootView: GlassToolbarRoot(model: model))
      hosting.view.backgroundColor = .clear
      hosting.view.frame = container.bounds
      hosting.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      container.addSubview(hosting.view)
      host = hosting
    }

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(nil); return }
      switch call.method {
      case "updateConfig":
        self.model.apply(args: call.arguments as? [String: Any] ?? [:])
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  func view() -> UIView { container }
}

// MARK: - Model

struct ToolbarActionItem {
  let id: String
  let sfSymbol: String
  let tint: UIColor?
  let iconColor: UIColor?
}

final class GlassToolbarModel: ObservableObject {
  @Published var actions: [ToolbarActionItem] = []
  var onAction: ((String) -> Void)?

  init(args: [String: Any]) {
    apply(args: args)
  }

  func apply(args: [String: Any]) {
    if let items = args["actions"] as? [[String: Any]] {
      actions = items.map {
        ToolbarActionItem(
          id: $0["id"] as? String ?? "",
          sfSymbol: $0["sfSymbol"] as? String ?? "",
          tint: GlassColor.fromARGB($0["tint"] as? Int),
          iconColor: GlassColor.fromARGB($0["iconColor"] as? Int)
        )
      }
    }
  }
}

// MARK: - SwiftUI

@available(iOS 16.0, *)
struct GlassToolbarRoot: View {
  @ObservedObject var model: GlassToolbarModel

  @available(iOS 26.0, *)
  private func resolvedGlass(for item: ToolbarActionItem) -> Glass {
    var glass = Glass.regular
    if let tint = item.tint {
      glass = glass.tint(Color(uiColor: tint))
    }
    return glass
  }

  private func iconView(for item: ToolbarActionItem) -> some View {
    Image(systemName: item.sfSymbol)
      .font(.system(size: 20, weight: .semibold))
      .foregroundStyle(
        item.iconColor.map { Color(uiColor: $0) }
        ?? item.tint.map { Color(uiColor: $0) }
        ?? .primary
      )
      .padding(.horizontal, 16)
      .padding(.vertical, 8)
  }

  var body: some View {
    if #available(iOS 26.0, *) {
      GlassEffectContainer(spacing: 0) {
        HStack(spacing: 0) {
          Spacer()
          ForEach(model.actions, id: \.id) { item in
            Button(action: { model.onAction?(item.id) }) {
              iconView(for: item)
                .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .glassEffect(resolvedGlass(for: item), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
          }
          Spacer()
        }
      }
    } else {
      HStack(spacing: 0) {
        Spacer()
        ForEach(model.actions, id: \.id) { item in
          Button(action: { model.onAction?(item.id) }) {
            iconView(for: item)
          }
          .buttonStyle(.plain)
        }
        Spacer()
      }
      .background(.ultraThinMaterial)
    }
  }
}
