import Flutter
import SwiftUI
import UIKit

// MARK: - Factory

final class GlassSearchBarViewFactory: NSObject, FlutterPlatformViewFactory {
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
    GlassSearchBarPlatformView(
      frame: frame, viewId: viewId,
      args: args as? [String: Any] ?? [:], messenger: messenger)
  }
}

// MARK: - Platform view

final class GlassSearchBarPlatformView: NSObject, FlutterPlatformView {
  private let container = UIView()
  private let channel: FlutterMethodChannel
  private let model: GlassSearchBarModel
  private var host: UIViewController?

  init(frame: CGRect, viewId: Int64, args: [String: Any], messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: "\(FlutterNativeViewPlugin.searchBarViewType)/\(viewId)", binaryMessenger: messenger)
    model = GlassSearchBarModel(args: args)
    container.backgroundColor = .clear

    super.init()

    model.onChanged = { [weak channel] text in
      channel?.invokeMethod("onChanged", arguments: text)
    }
    model.onSubmitted = { [weak channel] text in
      channel?.invokeMethod("onSubmitted", arguments: text)
    }

    if #available(iOS 16.0, *) {
      let hosting = UIHostingController(rootView: GlassSearchBarRoot(model: model))
      hosting.view.backgroundColor = .clear
      hosting.view.frame = container.bounds
      hosting.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      container.addSubview(hosting.view)
      host = hosting
    }

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(nil); return }
      switch call.method {
      case "setText":
        if let text = call.arguments as? String { self.model.text = text }
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  func view() -> UIView { container }
}

// MARK: - SwiftUI

final class GlassSearchBarModel: ObservableObject {
  @Published var text: String
  @Published var placeholder: String
  var onChanged: ((String) -> Void)?
  var onSubmitted: ((String) -> Void)?

  init(args: [String: Any]) {
    text = args["text"] as? String ?? ""
    placeholder = args["placeholder"] as? String ?? "Search"
  }
}

@available(iOS 16.0, *)
struct GlassSearchBarRoot: View {
  @ObservedObject var model: GlassSearchBarModel

  var body: some View {
    HStack(spacing: 8) {
      Image(systemName: "magnifyingglass")
        .foregroundColor(.secondary)
      TextField(model.placeholder, text: $model.text)
        .onSubmit { model.onSubmitted?(model.text) }
        .onChange(of: model.text) { newValue in
          model.onChanged?(newValue)
        }
    }
    .padding(.horizontal, 14)
    .padding(.vertical, 10)
    .background(
      Group {
        if #available(iOS 26.0, *) {
          Capsule()
            .fill(.white.opacity(0.12))
            .glassEffect(Glass.regular, in: Capsule())
        } else {
          Capsule()
            .fill(Color(.systemGray6))
        }
      }
    )
  }
}
