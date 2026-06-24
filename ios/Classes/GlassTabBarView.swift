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
  var onIndexChanged: ((Int) -> Void)?

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
  }
}

// MARK: - SwiftUI

@available(iOS 16.0, *)
struct GlassTabBarRoot: View {
  @ObservedObject var model: GlassTabBarModel

  var body: some View {
    if #available(iOS 26.0, *) {
      GlassEffectContainer(spacing: 0) {
        HStack(spacing: 0) {
          ForEach(Array(model.items.enumerated()), id: \.offset) { index, item in
            Button(action: {
              model.currentIndex = index
              model.onIndexChanged?(index)
            }) {
              VStack(spacing: 4) {
                if let symbol = item.sfSymbol {
                  Image(systemName: symbol)
                    .font(.system(size: 20))
                }
                Text(item.label)
                  .font(.system(size: 11, weight: model.currentIndex == index ? .semibold : .regular))
              }
              .foregroundStyle(model.currentIndex == index ? .primary : .secondary)
              .frame(maxWidth: .infinity)
              .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
          }
        }
        .padding(.horizontal, 8)
      }
    } else {
      HStack(spacing: 0) {
        ForEach(Array(model.items.enumerated()), id: \.offset) { index, item in
          Button(action: {
            model.currentIndex = index
            model.onIndexChanged?(index)
          }) {
            VStack(spacing: 4) {
              if let symbol = item.sfSymbol {
                Image(systemName: symbol)
                  .font(.system(size: 20))
              }
              Text(item.label)
                .font(.system(size: 11, weight: model.currentIndex == index ? .semibold : .regular))
            }
            .foregroundStyle(model.currentIndex == index ? .blue : .secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
          }
          .buttonStyle(.plain)
        }
      }
      .padding(.horizontal, 8)
      .background(.ultraThinMaterial)
    }
  }
}
