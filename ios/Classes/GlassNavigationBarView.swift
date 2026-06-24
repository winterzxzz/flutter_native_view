import Flutter
import SwiftUI
import UIKit

// MARK: - Factory

final class GlassNavigationBarViewFactory: NSObject, FlutterPlatformViewFactory {
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
    GlassNavigationBarPlatformView(
      frame: frame, viewId: viewId,
      args: args as? [String: Any] ?? [:], messenger: messenger)
  }
}

// MARK: - Platform view

final class GlassNavigationBarPlatformView: NSObject, FlutterPlatformView {
  private let container = UIView()
  private let channel: FlutterMethodChannel
  private let model: GlassNavigationBarModel
  private var host: UIViewController?

  init(frame: CGRect, viewId: Int64, args: [String: Any], messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: "\(FlutterNativeViewPlugin.navigationBarViewType)/\(viewId)", binaryMessenger: messenger)
    model = GlassNavigationBarModel(args: args)
    container.backgroundColor = .clear
    super.init()

    model.onAction = { [weak channel] id in
      channel?.invokeMethod("onAction", arguments: id)
    }

    if #available(iOS 16.0, *) {
      let hosting = UIHostingController(rootView: GlassNavigationBarRoot(model: model))
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

struct NavBarActionItem {
  let id: String
  let sfSymbol: String
}

final class GlassNavigationBarModel: ObservableObject {
  @Published var title: String?
  @Published var leading: [NavBarActionItem] = []
  @Published var trailing: [NavBarActionItem] = []
  var onAction: ((String) -> Void)?

  init(args: [String: Any]) {
    apply(args: args)
  }

  func apply(args: [String: Any]) {
    title = args["title"] as? String
    if let items = args["leading"] as? [[String: Any]] {
      leading = items.map { NavBarActionItem(id: $0["id"] as? String ?? "", sfSymbol: $0["sfSymbol"] as? String ?? "") }
    }
    if let items = args["trailing"] as? [[String: Any]] {
      trailing = items.map { NavBarActionItem(id: $0["id"] as? String ?? "", sfSymbol: $0["sfSymbol"] as? String ?? "") }
    }
  }
}

// MARK: - SwiftUI

@available(iOS 16.0, *)
struct GlassNavigationBarRoot: View {
  @ObservedObject var model: GlassNavigationBarModel

  var body: some View {
    if #available(iOS 26.0, *) {
      GlassEffectContainer(spacing: 0) {
        HStack(spacing: 0) {
          ForEach(model.leading, id: \.id) { item in
            Button(action: { model.onAction?(item.id) }) {
              Image(systemName: item.sfSymbol)
                .font(.system(size: 20, weight: .semibold))
                .padding(.horizontal, 12)
            }
            .buttonStyle(.plain)
          }
          Spacer()
          if let title = model.title {
            Text(title)
              .font(.system(size: 17, weight: .semibold))
              .lineLimit(1)
          }
          Spacer()
          ForEach(model.trailing, id: \.id) { item in
            Button(action: { model.onAction?(item.id) }) {
              Image(systemName: item.sfSymbol)
                .font(.system(size: 20, weight: .semibold))
                .padding(.horizontal, 12)
            }
            .buttonStyle(.plain)
          }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
      }
    } else {
      HStack(spacing: 0) {
        ForEach(model.leading, id: \.id) { item in
          Button(action: { model.onAction?(item.id) }) {
            Image(systemName: item.sfSymbol)
              .font(.system(size: 20, weight: .semibold))
              .padding(.horizontal, 12)
          }
          .buttonStyle(.plain)
        }
        Spacer()
        if let title = model.title {
          Text(title)
            .font(.system(size: 17, weight: .semibold))
            .lineLimit(1)
        }
        Spacer()
        ForEach(model.trailing, id: \.id) { item in
          Button(action: { model.onAction?(item.id) }) {
            Image(systemName: item.sfSymbol)
              .font(.system(size: 20, weight: .semibold))
              .padding(.horizontal, 12)
          }
          .buttonStyle(.plain)
        }
      }
      .padding(.horizontal, 8)
      .padding(.vertical, 8)
      .background(.ultraThinMaterial)
    }
  }
}
