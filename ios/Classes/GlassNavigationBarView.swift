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
  @Published var topSafeArea: CGFloat = 0
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
    if let top = args["topSafeArea"] as? Double {
      topSafeArea = CGFloat(top)
    }
  }
}

// MARK: - SwiftUI

@available(iOS 16.0, *)
struct GlassNavigationBarRoot: View {
  @ObservedObject var model: GlassNavigationBarModel

  var body: some View {
    if #available(iOS 26.0, *) {
      // GlassEffectContainer + per-button .glassEffect gives each action its own
      // circular Liquid Glass capsule; the spacing lets adjacent buttons merge.
      GlassEffectContainer(spacing: 8) {
        bar(spacing: 8) { glassButton($0) }
      }
      .padding(.top, model.topSafeArea)
    } else {
      bar(spacing: 8) { materialButton($0) }
        .padding(.top, model.topSafeArea)
        .background(.ultraThinMaterial)
    }
  }

  /// Shared layout: leading actions · title · trailing actions.
  private func bar<B: View>(
    spacing: CGFloat, @ViewBuilder button: @escaping (NavBarActionItem) -> B
  ) -> some View {
    HStack(spacing: spacing) {
      ForEach(model.leading, id: \.id) { button($0) }
      Spacer(minLength: 8)
      if let title = model.title {
        Text(title)
          .font(.system(size: 17, weight: .semibold))
          .foregroundStyle(.white)
          .lineLimit(1)
      }
      Spacer(minLength: 8)
      ForEach(model.trailing, id: \.id) { button($0) }
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
  }

  /// iOS 26 action button: an SF Symbol on a circular Liquid Glass capsule.
  @available(iOS 26.0, *)
  private func glassButton(_ item: NavBarActionItem) -> some View {
    Button(action: { model.onAction?(item.id) }) {
      Image(systemName: item.sfSymbol)
        .font(.system(size: 18, weight: .semibold))
        .foregroundStyle(.white)
        .frame(width: 40, height: 40)
        .glassEffect(.regular.interactive(), in: Circle())
    }
    .buttonStyle(.plain)
  }

  /// Fallback for iOS 16–25: a circular material capsule instead of glass.
  private func materialButton(_ item: NavBarActionItem) -> some View {
    Button(action: { model.onAction?(item.id) }) {
      Image(systemName: item.sfSymbol)
        .font(.system(size: 18, weight: .semibold))
        .foregroundStyle(.white)
        .frame(width: 40, height: 40)
        .background(.ultraThinMaterial, in: Circle())
    }
    .buttonStyle(.plain)
  }
}
