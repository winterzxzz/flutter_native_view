import Flutter
import SwiftUI
import UIKit

// MARK: - Factory

final class GlassTabBarViewFactory: NSObject, FlutterPlatformViewFactory {
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
    GlassTabBarPlatformView(
      frame: frame, viewId: viewId,
      args: args as? [String: Any] ?? [:], messenger: messenger)
  }
}

// MARK: - Platform view

final class GlassTabBarPlatformView: NSObject, FlutterPlatformView {
  private let container = UIView()
  private let channel: FlutterMethodChannel
  private let model: GlassTabBarModel
  private var host: UIViewController?

  init(frame: CGRect, viewId: Int64, args: [String: Any], messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: "\(FlutterNativeViewPlugin.tabBarViewType)/\(viewId)", binaryMessenger: messenger)
    model = GlassTabBarModel(args: args)
    container.backgroundColor = .clear
    super.init()

    model.onIndexChanged = { [weak channel] index in
      channel?.invokeMethod("onIndexChanged", arguments: index)
    }
    model.onAccessoryTap = { [weak channel] in
      channel?.invokeMethod("onAccessoryTap", arguments: nil)
    }

    if #available(iOS 16.0, *) {
      let hosting = UIHostingController(rootView: GlassTabBarRoot(model: model))
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

struct TabBarItem {
  let label: String
  let sfSymbol: String?
}

final class GlassTabBarModel: ObservableObject {
  @Published var items: [TabBarItem] = []
  @Published var currentIndex: Int = 0
  @Published var accessorySymbol: String?
  @Published var tint: UIColor?
  var onIndexChanged: ((Int) -> Void)?
  var onAccessoryTap: (() -> Void)?

  init(args: [String: Any]) {
    apply(args: args)
  }

  func apply(args: [String: Any]) {
    if let itemsData = args["items"] as? [[String: Any]] {
      items = itemsData.map { d in
        TabBarItem(
          label: d["label"] as? String ?? "",
          sfSymbol: d["sfSymbol"] as? String
        )
      }
    }
    currentIndex = args["currentIndex"] as? Int ?? currentIndex
    if args.keys.contains("accessorySymbol") {
      accessorySymbol = args["accessorySymbol"] as? String
    }
    tint = GlassColor.fromARGB(args["tint"] as? Int)
  }
}

// MARK: - SwiftUI

@available(iOS 16.0, *)
struct GlassTabBarRoot: View {
  @ObservedObject var model: GlassTabBarModel

  // Colors are explicit, not `.primary`/`.secondary`: a platform-view hosting
  // controller can resolve those against the wrong trait (light) and make the
  // labels nearly invisible on a dark glass surface.
  private var accent: Color { model.tint.map { Color(uiColor: $0) } ?? .white }
  private var selectedColor: Color { accent }
  private var unselectedColor: Color { Color.white.opacity(0.55) }
  private func selectionFill(_ selected: Bool) -> Color {
    selected ? accent.opacity(0.18) : .clear
  }

  private func tabContent(_ item: TabBarItem, selected: Bool) -> some View {
    VStack(spacing: 4) {
      if let symbol = item.sfSymbol {
        Image(systemName: symbol)
          .font(.system(size: 20, weight: selected ? .semibold : .regular))
      }
      Text(item.label)
        .font(.system(size: 11, weight: selected ? .semibold : .regular))
    }
    .foregroundStyle(selected ? selectedColor : unselectedColor)
    .frame(maxWidth: .infinity)
    .padding(.vertical, 8)
    .padding(.horizontal, 6)
    // Selection pill — the visible "clicked" feedback the native TabView shows.
    .background(Capsule().fill(selectionFill(selected)))
    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selected)
  }

  private func tabButton(_ index: Int, _ item: TabBarItem) -> some View {
    Button(action: {
      model.currentIndex = index
      model.onIndexChanged?(index)
    }) {
      tabContent(item, selected: model.currentIndex == index)
        .contentShape(Capsule())
    }
    .buttonStyle(.plain)
  }

  var body: some View {
    if #available(iOS 26.0, *) {
      GlassEffectContainer(spacing: 16) {
        HStack(spacing: 16) {
          HStack(spacing: 4) {
            ForEach(Array(model.items.enumerated()), id: \.offset) { index, item in
              tabButton(index, item)
            }
          }
          .padding(.horizontal, 8)
          .glassEffect(.regular.interactive(), in: .capsule)

          if let accessory = model.accessorySymbol {
            Button(action: { model.onAccessoryTap?() }) {
              Image(systemName: accessory)
                .font(.system(size: 20))
                .foregroundStyle(accent)
                .frame(width: 52, height: 52)
                .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.interactive(), in: .circle)
          }
        }
      }
    } else {
      HStack(spacing: 4) {
        ForEach(Array(model.items.enumerated()), id: \.offset) { index, item in
          tabButton(index, item)
        }
      }
      .padding(.horizontal, 8)
      .background(.ultraThinMaterial, in: Capsule())
    }
  }
}
